import os
import sys
import logging
import traceback
from flask import Flask, request, jsonify, render_template_string
from pathlib import Path
import base64
from pdf2image import convert_from_bytes
import logging
logging.basicConfig(level=logging.INFO)

# Make sure we can import src.entry from OMRChecker
sys.path.insert(0, "/app/OMRChecker")

app = Flask(__name__)

# --- Production-grade logging ---
import logging
import sys

logging.basicConfig(
    stream=sys.stdout,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger("omrchecker")

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>OMRChecker Web Interface</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
        h1 { color: #333; }
        .container { max-width: 800px; margin: 0 auto; }
        .upload-form { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
        .result-container { margin-top: 20px; }
        img { max-width: 100%; border: 1px solid #ddd; margin-top: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>OMRChecker Web Interface</h1>
        <div class="upload-form">
            <h2>Upload OMR Template, Images, or PDFs</h2>
            <form id="uploadForm" enctype="multipart/form-data">
                <div>
                    <label for="template">Template Directory:</label>
                    <input type="file" id="template" name="template" webkitdirectory directory multiple>
                </div>
                <div style="margin-top: 10px;">
                    <label for="images">OMR Images:</label>
                    <input type="file" id="images" name="images" multiple>
                </div>
                <div style="margin-top: 10px;">
                    <label for="pdfs">PDF Files:</label>
                    <input type="file" id="pdfs" name="pdfs" multiple>
                </div>
                <button type="submit" style="margin-top: 10px;">Process</button>
            </form>
        </div>
        <div class="result-container" id="results">
            <!-- Results will be displayed here -->
        </div>
    </div>
    <script>
        document.getElementById('uploadForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const formData = new FormData();
            const templateFiles = document.getElementById('template').files;
            for(let i = 0; i < templateFiles.length; i++) {
                formData.append('template_files', templateFiles[i]);
            }
            const imageFiles = document.getElementById('images').files;
            for(let i = 0; i < imageFiles.length; i++) {
                formData.append('image_files', imageFiles[i]);
            }
            const pdfFiles = document.getElementById('pdfs').files;
            for(let i = 0; i < pdfFiles.length; i++) {
                formData.append('pdf_files', pdfFiles[i]);
            }
            fetch('/process', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                const resultsDiv = document.getElementById('results');
                resultsDiv.innerHTML = `<h2>Processing Results</h2><pre>${JSON.stringify(data, null, 2)}</pre>`;
                if(data.images && data.images.length > 0) {
                    data.images.forEach(img => {
                        const imgElement = document.createElement('img');
                        imgElement.src = `data:image/jpeg;base64,${img}`;
                        resultsDiv.appendChild(imgElement);
                    });
                }
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('results').innerHTML = `<h2>Error</h2><p>${error}</p>`;
            });
        });
    </script>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/process', methods=['POST'])
def process_omr():
    try:
        from src.entry import entry_point

        # Create temp directories
        template_dir = Path("/tmp/template")
        img_dir = Path("/tmp/images")
        out_dir = Path("/tmp/output")
        for d in [template_dir, img_dir, out_dir]:
            d.mkdir(parents=True, exist_ok=True)

        # Save uploaded template files
        template_files = request.files.getlist('template_files')
        for file in template_files:
            file_path = template_dir / file.filename
            file.save(str(file_path))

        # Save uploaded image files
        image_files = request.files.getlist('image_files')
        for file in image_files:
            file_path = img_dir / file.filename
            file.save(str(file_path))

        # Save and convert uploaded PDFs
        pdf_files = request.files.getlist('pdf_files')
        for pdf_file in pdf_files:
            pdf_bytes = pdf_file.read()
            images = convert_from_bytes(pdf_bytes)
            for i, img in enumerate(images):
                img_file = img_dir / f"{pdf_file.filename}_page_{i+1}.jpg"
                img.save(str(img_file), "JPEG")

        # Run OMRChecker
        args = {
            "setLayout": False,
            "debug": True,
            "input_paths": [str(img_dir)],
            "output_dir": str(out_dir)
        }

        logger.info("Calling OMRChecker entry_point")
        result = entry_point(img_dir, args)

        processed_images = []
        if out_dir.exists():
            for img_file in out_dir.glob("*.jpg"):
                with open(img_file, "rb") as f:
                    img_data = base64.b64encode(f.read()).decode('utf-8')
                    processed_images.append(img_data)

        return jsonify({
            "success": True,
            "message": "OMR processing completed",
            "results": result if result else {},
            "images": processed_images
        })

    except Exception as e:
        logger.error("Exception during OMR processing: %s", traceback.format_exc())
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == "__main__":
    logger.info("Starting OMRChecker Web Interface on port 2014")
    app.run(host="0.0.0.0", port=2014, debug=True)
