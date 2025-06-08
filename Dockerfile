FROM python:3.10-slim

WORKDIR /app

# Install git and system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Clone OMRChecker and install it
RUN git clone https://github.com/Udayraj123/OMRChecker.git && \
    cd OMRChecker && \
    pip install -e .

# Set up required directories
RUN mkdir -p /app/OMRChecker/inputs \
    mkdir -p /app/OMRChecker/outputs \
    mkdir -p /app/OMRChecker/templates

# Copy sample templates
RUN cp -r /app/OMRChecker/samples/* /app/OMRChecker/templates/

# Create patched version of interaction.py
RUN echo 'class InteractionUtils:\n    @staticmethod\n    def get_window_size():\n        return (1920, 1080)  # Default resolution\n' > /app/OMRChecker/src/utils/interaction.py

# Copy our API files
COPY requirements.txt .
COPY app.py .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set working directory to OMRChecker root
WORKDIR /app/OMRChecker

ENV PORT=2014
EXPOSE 2014

CMD ["python", "/app/app.py"]
