FROM python:3.9-slim

WORKDIR /app

# Install git and required dependencies
RUN apt-get update && apt-get install -y git && apt-get clean

# Clone the original OMRChecker repo
RUN git clone https://github.com/Udayraj123/OMRChecker.git

# Install all requirements from the original repo
RUN pip install --no-cache-dir -r /app/OMRChecker/requirements.txt
RUN pip install --no-cache-dir rich>=10.0.0 flask>=2.0.0

# Create a symbolic link to make the imports work
RUN ln -s /app/OMRChecker/src /app/src

# Copy your application files
COPY . .

# Set Python path correctly
ENV PYTHONPATH="${PYTHONPATH}:/app:/app/OMRChecker"

# Expose port 8000 to match Coolify's default
EXPOSE 8000

CMD ["python", "app.py"]
