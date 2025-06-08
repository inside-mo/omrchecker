import os
import sys
import time

# Configure paths
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'OMRChecker'))

# Wait a moment to make sure everything is ready
print("Starting OMRChecker service...")
time.sleep(1)

# Import after paths are set
from OMRChecker.src.processor import ProcessOMR

def main():
    print("OMRChecker service is running!")
    # Your application logic here

if __name__ == "__main__":
    main()
