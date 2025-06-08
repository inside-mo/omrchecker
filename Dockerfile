FROM python:3.9-slim

# Ensure logs are unbuffered
ENV PYTHONUNBUFFERED=1

# System dependencies for OMRChecker, pdf2image, and headless display
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    poppler-utils \
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
 && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone OMRChecker repo (adapt/remove if not needed)
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker

# Patch import bug if necessary (optional, as before)
RUN sed -i 's/from src.logger import logger/from .logger import logger/g' /app/OMRChecker/src/__init__.py || true

# Python dependencies
RUN pip install --no-cache-dir -r /app/OMRChecker/requirements.txt \
 && pip install --no-cache-dir "numpy<2.0" "opencv-python-headless==4.6.0.66" flask flask-cors gunicorn pdf2image

# Copy your custom app.py in (if you want to override the repo one)
COPY app.py /app/OMRChecker/

WORKDIR /app/OMRChecker

EXPOSE 2014

# Start Gunicorn with unbuffered output via Xvfb for OpenCV/PDF/GUI stuff
ENTRYPOINT ["xvfb-run", "-a", "-e", "/dev/stdout", "--server-args=-screen 0 1920x1080x16", "gunicorn", "-k", "sync", "--workers", "1", "-b", "0.0.0.0:2014", "app:app", "--access-logfile", "-", "--error-logfile", "-"]
