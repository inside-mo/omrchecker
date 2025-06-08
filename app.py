import os
import sys

# Add the current directory and the OMRChecker directory to the Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)
sys.path.insert(0, os.path.join(current_dir, 'OMRChecker'))

# Import the processor - note the changed import path
from src.processor import ProcessOMR

def main():
    print("OMRChecker service is running!")
    # Your application logic here
    # For example: processor = ProcessOMR(...)

if __name__ == "__main__":
    main()
