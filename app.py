import sys
import traceback

print("Starting OMRChecker application")

try:
    # Import the new API
    from src.entry import entry_point
    from pathlib import Path
    print("Successfully imported entry_point from current OMRChecker version!")
    
    def main():
        print("OMRChecker service is running on port 2014!")
        # Example of how to use the new API:
        # template_dir = "path/to/template"
        # img_dir = "path/to/images" 
        # out_dir = "path/to/output"
        # 
        # args = {"setLayout": False, "debug": True,
        #        "input_paths": [img_dir], "output_dir": out_dir}
        # entry_point(Path(img_dir), args)
        
except ImportError as e:
    print(f"Import error: {e}")
    print("This could be due to a missing dependency.")
    traceback.print_exc()
    print("\nPlease add the missing package to the Dockerfile and rebuild.")
    sys.exit(1)

if __name__ == "__main__":
    main()
