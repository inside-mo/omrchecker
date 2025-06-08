FROM python:3.9-slim

WORKDIR /app

# Install git and required dependencies
RUN apt-get update && apt-get install -y git && apt-get clean

# Clone the original repository
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/omr

# Install dependencies from requirements.txt
WORKDIR /app/omr
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir rich>=10.0.0 flask>=2.0.0

# Copy our custom files
WORKDIR /app
COPY app.py interaction.py ./

# Expose port 8000
EXPOSE 8000

# Set working directory to where Python can find the modules
WORKDIR /app/omr

# Run our custom app.py which is in the parent directory
CMD ["python", "../app.py"]
