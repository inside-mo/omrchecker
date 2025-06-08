from flask import Flask, request, jsonify
import os
from functools import wraps
import tempfile
from src.processor import ProcessOMR

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

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"})

@app.route('/process', methods=['POST'])
@require_api_key
def process_omr():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    template = request.form.get('template', 'default')
    file = request.files['file']
    
    # Save uploaded file temporarily
    with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as temp_file:
        file.save(temp_file.name)
        try:
            # Process with OMRChecker using the selected template
            processor = ProcessOMR()
            results = processor.process_path(temp_file.name, template)
            return jsonify({
                'success': True,
                'results': results
            })
        except Exception as e:
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500
        finally:
            # Clean up temp file
            os.unlink(temp_file.name)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=2014)
