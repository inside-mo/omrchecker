import os
import sys

# Set up environment
print("Starting OMRChecker application")

# Patch the problematic import in __init__.py file
init_file = '/app/OMRChecker/src/__init__.py'
if os.path.exists(init_file):
    with open(init_file, 'r') as f:
        content = f.read()
    if 'from src.logger import logger' in content:
        with open(init_file, 'w') as f:
            f.write(content.replace('from src.logger import logger', 'from .logger import logger'))
            print("Fixed import in src/__init__.py")

# Now import should work
from src.processor import ProcessOMR

def main():
    print("OMRChecker service is running on port 2014!")
    # Your application logic here

if __name__ == "__main__":
    main()
