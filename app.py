import os
import sys
import traceback
import logging
from flask import Flask, request, jsonify, render_template_string
from pathlib import Path
import base64

# Required for PDF conversion
from pdf2image import convert_from_bytes

# Make sure we can import src.entry from OMRChecker
sys.path.insert(0, "/app/OMRChecker")

print("==== APP.PY STARTED ====", flush=True)

app = Flask(__name__)

# Set up Python logging to stdout
logging.basicConfig(stream=sys.stdout, level=logging.INFO)
app.logger.setLevel(logging.INFO)

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
            <h2>Upload OMR Template, Images, or PDF</h2>
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
                    <label for="pdf">PDF File:</label>
                    <input type="file" id="pdf" name="pdf">
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
            const pdfFile = document.getElementById('pdf').files[0];
            if (pdfFile) {
                formData.append('pdf', pdfFile);
            }
