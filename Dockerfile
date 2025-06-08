FROM python:3.9-slim

WORKDIR /app

# Install git and required dependencies
RUN apt-get update && apt-get install -y git && apt-get clean

# Clone the original OMRChecker repo directly to our workdir
RUN git clone https://github.com/Udayraj123/OMRChecker.git /app

# Install all dependencies from the original repo
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir rich>=10.0.0 flask>=2.0.0

# Copy our custom application files
COPY app.py /app/
COPY interaction.py /app/

# Expose port 8000 to match Coolify's default
EXPOSE 8000

CMD ["python", "app.py"]
