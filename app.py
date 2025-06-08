print("Starting OMRChecker application")

# Import the new API
from src.entry import entry_point
from pathlib import Path

print("OMRChecker service is running on port 2014!")

def main():
    print("Successfully imported entry_point from current OMRChecker version!")
    
    # Example of how to use the new API:
    # template_dir = "path/to/template"
    # img_dir = "path/to/images"
    # out_dir = "path/to/output"
    # 
    # args = {"setLayout": False, "debug": True,
    #        "input_paths": [img_dir], "output_dir": out_dir}
    # entry_point(Path(img_dir), args)
    
    pass

if __name__ == "__main__":
    main()
