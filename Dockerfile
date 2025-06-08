FROM python:3.9-slim

# Install git and required dependencies
RUN apt-get update && apt-get install -y git && apt-get clean

# Set up working directory
WORKDIR /app

# Clone the original repository
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app/OMRChecker

# Install dependencies from original repo plus missing packages
WORKDIR /app/OMRChecker
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir rich>=10.0.0 flask>=2.0.0

# Create symbolic link so src can be imported directly
WORKDIR /app
RUN ln -s /app/OMRChecker/src /app/src

# Copy our application files
COPY app.py interaction.py ./

# Expose port 2014 as specified
EXPOSE 2014

# Run our application
CMD ["python", "app.py"]
