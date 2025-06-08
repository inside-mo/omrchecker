FROM python:3.9-slim

# 1. System dependencies (including X11 libs for screeninfo, OpenCV, and Xvfb)
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

# 2. Clone the OMRChecker upstream codebase
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker

# 3. Patch relative import in __init__.py if needed (safeguard)
RUN sed -i 's/from src.logger import logger/from .logger import logger/g' /app/OMRChecker/src/__init__.py

# 4. Install Python dependencies
RUN pip install --no-cache-dir -r /app/OMRChecker/requirements.txt \
    && pip install --no-cache-dir \
        numpy<2.0 opencv-python-headless==4.6.0.66 \
        flask flask-cors

# 5. Copy your web app UI file(s) in
COPY app.py /app/OMRChecker/

# 6. Expose web service port
EXPOSE 2014

# 7. Launch: Xvfb with the correct screen arg, then run your app
ENTRYPOINT ["xvfb-run", "--server-args=-screen 0 1920x1080x16"]
CMD ["python", "app.py"]

WORKDIR /app/OMRChecker
