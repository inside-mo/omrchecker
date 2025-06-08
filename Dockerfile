FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Add application directory to Python path
ENV PYTHONPATH="${PYTHONPATH}:/app"

# Expose port 8000 to match Coolify's default
EXPOSE 8000

CMD ["python", "app.py"]
