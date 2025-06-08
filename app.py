from flask import Flask, request, jsonify
import os
from functools import wraps
import sys
sys.path.append('./omrchecker')
from src.core import evaluate_omr

app = Flask(__name__)
API_KEY = os.environ.get('API_KEY')

def require_api_key(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not API_KEY:
            return jsonify({"error": "API_KEY not configured"}), 500
        auth_header = request.headers.get('X-API-Key')
        if auth_header and auth_header == API_KEY:
            return f(*args, **kwargs)
        return jsonify({"error": "Invalid API Key"}), 401
    return decorated

@app.route('/process', methods=['POST'])
@require_api_key
def process_omr():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    # OMRChecker processing logic here

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=2014)
