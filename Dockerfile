FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    git build-essential libgl1 libglib2.0-0 libsm6 libxext6 \
    libxrender-dev libxrandr2 libxinerama1 libxcursor1 libxi6 \
    xvfb x11-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker

RUN sed -i 's/from src.logger import logger/from .logger import logger/g' /app/OMRChecker/src/__init__.py

RUN pip install --no-cache-dir -r /app/OMRChecker/requirements.txt \
    && pip install --no-cache-dir "numpy<2.0" "opencv-python-headless==4.6.0.66" \
       flask flask-cors

COPY app.py /app/OMRChecker/

WORKDIR /app/OMRChecker

EXPOSE 2014

CMD ["xvfb-run", "-a", "python", "-u", "app.py"]
