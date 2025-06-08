FROM python:3.9-slim

# Install required system dependencies for OpenCV and X11
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    xvfb \
    x11-utils \
    libxrandr2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone the latest version of the repository
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker

# Fix the import in __init__.py
RUN sed -i 's/from src.logger import logger/from .logger import logger/g' /app/OMRChecker/src/__init__.py

# Install upstream dependencies first, then add extras
RUN pip install --no-cache-dir -r /app/OMRChecker/requirements.txt \
    && pip install --no-cache-dir \
       numpy<2.0 opencv-python-headless==4.6.0.66 \
       flask flask-cors

# Copy our application file
COPY app.py /app/OMRChecker/

# Expose port 2014 as specified
EXPOSE 2014

# Use xvfb-run to handle the virtual display
ENTRYPOINT ["xvfb-run", "-s", "-screen 0 1920x1080x16"]

# Run our application from the OMRChecker directory
WORKDIR /app/OMRChecker
CMD ["python", "app.py"]
