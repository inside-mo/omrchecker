FROM python:3.9-slim

# Install git and required dependencies
RUN apt-get update && apt-get install -y git && apt-get clean

# Create app directory
WORKDIR /app

# Clone the repository
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker

# Fix the problematic import
RUN sed -i 's/from src.logger import logger/from .logger import logger/g' /app/OMRChecker/src/__init__.py

# Install dependencies
RUN cd /app/OMRChecker && pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir rich>=10.0.0 flask>=2.0.0

# Copy our application files
COPY app.py /app/OMRChecker/

# Expose port 2014 as specified
EXPOSE 2014

# Run our application from the OMRChecker directory
WORKDIR /app/OMRChecker
CMD ["python", "app.py"]
