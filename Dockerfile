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

# Install dependencies with specific versions that match the project's requirements.txt
RUN pip install --no-cache-dir numpy==1.19.5
RUN pip install --no-cache-dir opencv-python-headless==4.5.1.48
RUN pip install --no-cache-dir pandas==1.1.5
RUN pip install --no-cache-dir matplotlib==3.3.4
RUN pip install --no-cache-dir Pillow==8.1.0
RUN pip install --no-cache-dir pytz==2021.3
RUN pip install --no-cache-dir PyPDF2==1.26.0
RUN pip install --no-cache-dir rich==13.7.0
RUN pip install --no-cache-dir jsonschema==4.20.0
RUN pip install --no-cache-dir dotmap==1.3.30
RUN pip install --no-cache-dir flask>=2.0.0
RUN pip install --no-cache-dir python-dateutil

# Copy our application files
COPY app.py /app/OMRChecker/

# Expose port 2014 as specified
EXPOSE 2014

# Run our application from the OMRChecker directory
WORKDIR /app/OMRChecker
CMD ["python", "app.py"]
