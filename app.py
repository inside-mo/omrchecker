import os
import sys
import traceback
import logging
from flask import Flask, request, jsonify, render_template_string
from pathlib import Path
import base64

# Make src imports always work, even if not run from /app/OMRChecker
sys.path.insert(0, "/app/OMRChecker")

# Set up robust logging for gunicorn/production (logs go to stdout)
logging.basicConfig(level=logging.INFO, stream=sys.stdout,
                    format="%(asctime)s %(levelname)s %(name)s: %(message)s")
logger = logging.getLogger("omrchecker_app")

app = Flask(__name__)

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
            <h2>Upload OMR Template and Images</h2>
            <form id="uploadForm" enctype="multipart/form-data">
                <div>
                    <label for="template">Template Directory:</label>
                    <input type="file" id="template" name="template" webkitdirectory directory multiple>
                </div>
                <div style="margin-top: 10px;">
                    <label for="images">OMR Images:</label>
                    <input type="file" id="images" name="images" multiple>
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
    logger.info("Index page accessed")
    return render_template_string(HTML_TEMPLATE)

@app.route('/process', methods=['POST'])
def process_omr():
    try:
        logger.info("Received POST /process request")
        from src.entry import entry_point

        template_dir = Path("/tmp/template")
        img_dir = Path("/tmp/images")
        out_dir = Path("/tmp/output")
        for d in [template_dir, img_dir, out_dir]:
            d.mkdir(parents=True, exist_ok=True)

        template_files = request.files.getlist('template_files')
        for file in template_files:
            file_path = template_dir / file.filename
            file.save(str(file_path))
        logger.info(f"Saved {len(template_files)} template files")

        image_files = request.files.getlist('image_files')
        for file in image_files:
            file_path = img_dir / file.filename
            file.save(str(file_path))
        logger.info(f"Saved {len(image_files)} image files")

        args = {
            "setLayout": False,
            "debug": True,
            "input_paths": [str(img_dir)],
            "output_dir": str(out_dir)
        }

        result = entry_point(img_dir, args)
        logger.info("entry_point() finished")

        processed_images = []
        if out_dir.exists():
            for img_file in out_dir.glob("*.jpg"):
                with open(img_file, "rb") as f:
                    img_data = base64.b64encode(f.read()).decode('utf-8')
                    processed_images.append(img_data)
        logger.info(f"Processed images: {len(processed_images)}")

        return jsonify({
            "success": True,
            "message": "OMR processing completed",
            "results": result if result else {},
            "images": processed_images
        })

    except Exception as e:
        logger.error(f"Exception in /process: {e}", exc_info=True)
        return jsonify({"success": False, "error": str(e)}), 500

# No __main__ block needed (gunicorn runs the app)

