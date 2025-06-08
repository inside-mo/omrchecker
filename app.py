import os
import sys

# Explicitly add the OMRChecker directory to the path
omr_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'omr')
sys.path.insert(0, omr_dir)

# Now we can import from the src module
try:
    from src.processor import ProcessOMR
    print("Successfully imported ProcessOMR!")
except ImportError as e:
    print(f"Import error: {e}")
    print(f"Current path: {sys.path}")
    print(f"Files in directory: {os.listdir(omr_dir)}")
    print(f"Files in src: {os.listdir(os.path.join(omr_dir, 'src'))}")
    raise

def main():
    print("OMRChecker service is running!")
    # Your application logic here

if __name__ == "__main__":
    main()
