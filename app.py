import os
import sys

# Add current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Correct import after Python path is set
from OMRChecker.src.processor import ProcessOMR

def main():
    print("OMRChecker service is running!")
    # Your application logic here
    # Example: processor = ProcessOMR(...)

if __name__ == "__main__":
    main()
