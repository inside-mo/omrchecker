FROM python:3.9-slim

# 1. System packages: Xorg/Xvfb + all XRandR runtime libs
RUN apt-get update && apt-get install -y \
    git build-essential \
    # OpenCV runtime
    libgl1 libglib2.0-0 libsm6 libxext6 libxrender-dev \
    # XRandR enumerator needs these
    libxrandr2 libxinerama1 libxcursor1 libxi6 \
    # X server itself + helper utils
    xvfb x11-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Application source
WORKDIR /app
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker
# Fix upstream relative‑import bug (still present in June 2025)
RUN sed -i 's/from src.logger import logger/from .logger import logger/' \
    /app/OMRChecker/src/__init__.py

# 3. Python dependencies – upstream first, then extras
RUN pip install --no-cache-dir -r /app/OMRChecker/requirements.txt \
    && pip install --no-cache-dir \
       numpy<2.0 opencv-python-headless==4.6.0.66 \
       flask flask-cors

# 4. Your Flask UI (already includes the API wrapper)
COPY app.py /app/OMRChecker/

# 5. Networking
EXPOSE 2014

# 6. Start virtual display *with* RandR, then run app
ENTRYPOINT ["xvfb-run", "-s", "-screen 0 1920x1080x16 +extension RANDR"]
WORKDIR /app/OMRChecker
CMD ["python", "app.py"]
