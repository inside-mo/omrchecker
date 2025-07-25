FROM python:3.9-slim

# 1. System dependencies for OMRChecker and headless display
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
    tini \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Clone OMRChecker repo
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker

# 3. Patch import bug (if necessary)
RUN sed -i 's/from src.logger import logger/from .logger import logger/g' /app/OMRChecker/src/__init__.py

# 4. Python dependencies
RUN pip install --no-cache-dir -r /app/OMRChecker/requirements.txt \
    && pip install --no-cache-dir "numpy<2.0" "opencv-python-headless==4.6.0.66" flask flask-cors gunicorn pdf2image

# 5. Copy your UI code in
COPY app.py /app/OMRChecker/

WORKDIR /app/OMRChecker

EXPOSE 2014

# 6. Start Gunicorn under xvfb-run, using tini for log/signal handling
ENTRYPOINT ["/usr/bin/tini", "--", "xvfb-run", "-a", "gunicorn", "-b", "0.0.0.0:2014", "app:app", "--access-logfile", "-", "--error-logfile", "-"]
