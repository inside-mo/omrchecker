from flask import Flask, request, jsonify
import sys
sys.path.append('./omrchecker')
from src.core import evaluate_omr

app = Flask(__name__)

@app.route('/process', methods=['POST'])
def process_omr():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    # Add your OMRChecker processing logic here
    # Return results as JSON

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=2014)
