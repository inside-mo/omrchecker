FROM python:3.10-slim

WORKDIR /app

# Install git and system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Clone OMRChecker and install it properly
RUN git clone https://github.com/Udayraj123/OMRChecker.git && \
    cd OMRChecker && \
    pip install -e .

# Copy our API files
COPY requirements.txt .
COPY app.py .

# Install additional dependencies
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /app

ENV PORT=2014
EXPOSE 2014

CMD ["python", "app.py"]
