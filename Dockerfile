FROM python:3.9-slim

# 1. System dependencies
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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Clone OMRChecker
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker

# 3. Patch import bug, just in case
RUN sed -i 's/from src.logger import logger/from .logger import logger/g' /app/OMRChecker/src/__init__.py

# 4. Python dependencies (note quotes!)
RUN pip install --no-cache-dir -r /app/OMRChecker/requirements.txt \
    && pip install --no-cache-dir "numpy<2.0" "opencv-python-headless==4.6.0.66" \
       flask flask-cors

# 5. Copy your UI code in
COPY app.py /app/OMRChecker/

EXPOSE 2014

# 6. Xvfb and logging: direct all Xvfb logs to container logs, run Python unbuffered for real-time logging
ENTRYPOINT ["xvfb-run", "--server-args=-screen 0 1920x1080x16", "-e", "/dev/stdout"]
CMD ["python", "-u", "app.py"]

WORKDIR /app/OMRChecker
