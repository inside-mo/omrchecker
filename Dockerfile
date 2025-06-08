FROM python:3.9-slim

# System dependencies for OMR and PDF processing
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    libxi6 \
    xvfb \
    x11-utils \
    poppler-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone OMRChecker
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker

# Patch import bug in OMRChecker, just in case
RUN sed -i 's/from src.logger import logger/from .logger import logger/g' /app/OMRChecker/src/__init__.py

# Python dependencies
RUN pip install --no-cache-dir -r /app/OMRChecker/requirements.txt \
    && pip install --no-cache-dir "numpy<2.0" "opencv-python-headless==4.6.0.66" \
       flask flask-cors pdf2image

# Copy your UI/backend in
COPY app.py /app/OMRChecker/

EXPOSE 2014

WORKDIR /app/OMRChecker

# Use xvfb-run for headless X11
ENTRYPOINT ["xvfb-run", "--server-args=-screen 0 1920x1080x16", "-e", "/dev/stdout"]
CMD ["python", "-u", "app.py"]
