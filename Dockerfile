FROM python:3.9-slim

# Install required system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone the repository
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker

# Fix the import in __init__.py
RUN sed -i 's/from src.logger import logger/from .logger import logger/g' /app/OMRChecker/src/__init__.py

# Install upstream dependencies first, then add the missing ones
RUN cd /app/OMRChecker && pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir opencv-python-headless==4.10.0.82 rich>=10.0.0 flask>=2.0.0

# Copy our application files
COPY app.py /app/OMRChecker/

# Expose port 2014 as specified
EXPOSE 2014

# Run our application from the OMRChecker directory
WORKDIR /app/OMRChecker
CMD ["python", "app.py"]
