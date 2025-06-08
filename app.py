print("Starting OMRChecker application")

# Import the new entry point that replaced ProcessOMR
from src.entry import entry_point
from pathlib import Path

print("OMRChecker service is running on port 2014!")

def main():
    # Example of using the new API:
    # args = {"setLayout": False, "debug": True,
    #         "input_paths": ["sample_input"], "output_dir": "output"}
    # entry_point(Path("sample_input"), args)
    pass

if __name__ == "__main__":
    main()
