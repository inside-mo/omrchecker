FROM python:3.10-slim

WORKDIR /app

# Install git and X11 dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3-tk \
    python3-dev \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxinerama1 \
    libxi6 \
    libxrandr2 \
    libxcursor1 \
    x11-utils \
    patch \
    && rm -rf /var
