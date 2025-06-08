FROM python:3.10-slim

WORKDIR /app

# Install git and system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Clone OMRChecker
RUN git clone https://github.com/Udayraj123/OMRChecker.git

# Set up required directories
WORKDIR /app/OMRChecker
RUN mkdir -p inputs outputs templates

# Copy sample templates and configs
RUN cp -r samples/* templates/ && \
    cp -r samples/samples1/* inputs/

# Create patched version of interaction.py for headless mode
RUN echo 'class InteractionUtils:\n    @staticmethod\n    def get_window_size():\n        return (1920, 1080)\n' > src/utils/interaction.py

# Copy our API files
COPY requirements.txt app.py ./

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

ENV PYTHONPATH=/app/OMRChecker
ENV PORT=2014
EXPOSE 2014

CMD ["python", "app.py"]
