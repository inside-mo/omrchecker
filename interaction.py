print("OMR Interaction module loading...")

# Use the new API instead of the old ProcessOMR class
from src.entry import entry_point
from src.processors.manager import PROCESSOR_MANAGER
from pathlib import Path

class OMRProcessor:
    def __init__(self, template_path=None):
        self.template_path = template_path
    
    def load_template(self, template_path):
        """Load an OMR template configuration"""
        self.template_path = template_path
        return True
        
    def process_image(self, image_path):
        """Process an OMR sheet image using the new API"""
        if not self.template_path:
            return {"success": False, "error": "Template not loaded"}
            
        try:
            args = {
                "setLayout": False, 
                "debug": True,
                "input_paths": [image_path], 
                "output_dir": "output"
            }
            result = entry_point(Path(image_path), args)
            return {"success": True, "data": result}
        except Exception as e:
            return {"success": False, "error": str(e)}

# Example usage of specific processors if needed
def use_specific_processor():
    cropper = PROCESSOR_MANAGER.processors["CropPage"]()
    # Use the cropper as needed

if __name__ == "__main__":
    print("OMR Interaction module - import this in your application")
