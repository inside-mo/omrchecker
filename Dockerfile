FROM python:3.9-slim

# 1. System dependencies for OMRChecker, OpenCV, and pdf2image
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

ENV PYTHONUNBUFFERED=1

WORKDIR /app

# 2. Clone OMRChecker (always fresh)
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker

# 3. Patch import bug, just in case
RUN sed -i 's/from src.logger import logger/from .logger import logger/g' /app/OMRChecker/src/__init__.py

# 4. Python dependencies (quotes for versions, include pdf2image)
RUN pip install --no-cache-dir -r /app/OMRChecker/requirements.txt \
    && pip install --no-cache-dir "numpy<2.0" "opencv-python-headless==4.6.0.66" flask flask-cors gunicorn pdf2image

# 5. Copy your UI/server code in (overwrite any template app.py)
COPY app.py /app/OMRChecker/

WORKDIR /app/OMRChecker

EXPOSE 2014

# 6. Start Gunicorn (production) with Xvfb.  
ENTRYPOINT ["xvfb-run", "-a", "-e", "/dev/stdout", "--server-args=-screen 0 1920x1080x16", "gunicorn", "-k", "sync", "--workers", "1", "-b", "0.0.0.0:2014", "app:app", "--access-logfile", "-", "--error-logfile", "-"]

# For DEBUGGING ONLY: Switch to Flask dev server and get all logs to stdout:
ENTRYPOINT ["gunicorn", "-b", "0.0.0.0:2014", "app:app", "--access-logfile", "-", "--error-logfile", "-"]

