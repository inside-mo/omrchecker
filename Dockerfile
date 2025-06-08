FROM python:3.10-slim

WORKDIR /app

# Install git
RUN apt-get update && apt-get install -y git

# Clone OMRChecker
RUN git clone https://github.com/Udayraj123/OMRChecker.git

# Copy our files
COPY requirements.txt .
COPY app.py .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Add OMRChecker to Python path
ENV PYTHONPATH="${PYTHONPATH}:/app/OMRChecker"

ENV PORT=2014
EXPOSE 2014

CMD ["python", "app.py"]
