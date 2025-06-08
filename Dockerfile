FROM python:3.10-slim

WORKDIR /app

# Install git and dependencies
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone OMRChecker
RUN git clone https://github.com/Udayraj123/OMRChecker.git && \
    cd OMRChecker && \
    cp -r samples/* .

# Create patched version of interaction.py
RUN echo 'class InteractionUtils:\n    @staticmethod\n    def get_window_size():\n        return (1920, 1080)  # Default resolution\n' > /app/OMRChecker/src/utils/interaction.py

# Copy our API files
COPY requirements.txt .
COPY app.py .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set Python path explicitly
ENV PYTHONPATH=/app/OMRChecker

ENV PORT=2014
EXPOSE 2014

CMD ["python", "app.py"]
