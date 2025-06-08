FROM python:3.9-slim

# Install git and required dependencies
RUN apt-get update && apt-get install -y git && apt-get clean

# Clone the original repository
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app

# Change to the app directory
WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir rich>=10.0.0 flask>=2.0.0

# Copy our custom files into the cloned repository
COPY app.py interaction.py ./

# Expose port 2014 as specified
EXPOSE 2014

# Run our app
CMD ["python", "app.py"]
