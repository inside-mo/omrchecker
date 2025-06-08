FROM python:3.9-slim

# 1. System packages: Xvfb + XRandR libs
RUN apt-get update && apt-get install -y \
    git build-essential \
    libgl1 libglib2.0-0 libsm6 libxext6 libxrender-dev \
    libxrandr2 libxinerama1 libxcursor1 libxi6 \
    xvfb x11-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Clone OMRChecker
WORKDIR /app
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker
RUN sed -i 's/from src.logger import logger/from .logger import logger/' \
    /app/OMRChecker/src/__init__.py

# 3. Python deps – upstream first, then extras (note the escaped '<')
RUN pip install --no-cache-dir -r /app/OMRChecker/requirements.txt && \
    pip install --no-cache-dir \
        numpy\<2.0 \
        opencv-python-headless==4.6.0.66 \
        flask flask-cors \
        python-xlib

# 4. Copy UI
COPY app.py /app/OMRChecker/

EXPOSE 2014

# 5. Launch virtual display with RandR, then run app, UNBUFFERED for logging
ENTRYPOINT ["xvfb-run", "--error-file", "/dev/stderr", "-s", "-screen", "0", "1920x1080x16", "+extension", "RANDR"]
WORKDIR /app/OMRChecker
CMD ["python", "-u", "app.py"]
