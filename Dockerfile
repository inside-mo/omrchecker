FROM python:3.10-slim

WORKDIR /app

# Install git and X11 dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3-tk \
    python3-dev \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxinerama1 \
    libxi6 \
    libxrandr2 \
    libxcursor1 \
    x11-utils \
    && rm -rf /var/lib/apt/lists/*

# Clone OMRChecker
RUN git clone https://github.com/Udayraj123/OMRChecker.git

# Copy our files
COPY requirements.txt .
COPY app.py .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir screeninfo==0.8.1

# Add OMRChecker to Python path
ENV PYTHONPATH="${PYTHONPATH}:/app/OMRChecker"
ENV DISPLAY=:0

ENV PORT=2014
EXPOSE 2014

CMD ["python", "app.py"]
