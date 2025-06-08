import os
import sys

# Explicitly add the OMRChecker directory to the path
omr_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'omr')
sys.path.insert(0, omr_dir)

# Import from the src module
from src.processor import ProcessOMR

class OMRProcessor:
    def __init__(self, template_path=None):
        self.processor = None
        if template_path:
            self.load_template(template_path)
    
    def load_template(self, template_path):
        """Load an OMR template configuration"""
        self.processor = ProcessOMR(template_path)
        return True
        
    def process_image(self, image_path):
        """Process an OMR sheet image"""
        if not self.processor:
            return {"success": False, "error": "Template not loaded"}
            
        try:
            result = self.processor.process(image_path)
            return {"success": True, "data": result}
        except Exception as e:
            return {"success": False, "error": str(e)}

if __name__ == "__main__":
    print("OMR Interaction module - import this in your application")
