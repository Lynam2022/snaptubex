# Use Ubuntu as the base image for better FFmpeg support
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Node.js, Python, FFmpeg and required build tools
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    wget \
    software-properties-common \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update && apt-get install -y \
    nodejs \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Cài các gói cần thiết
RUN apt-get update && apt-get install -y wget tar xz-utils

# Cài FFmpeg static build từ BtbN (được cập nhật và có đầy đủ codec MP3)
RUN wget https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz \
    && tar -xf ffmpeg-master-latest-linux64-gpl.tar.xz \
    && cp ffmpeg-master-latest-linux64-gpl/bin/ffmpeg /usr/local/bin/ffmpeg \
    && cp ffmpeg-master-latest-linux64-gpl/bin/ffprobe /usr/local/bin/ffprobe \
    && chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe \
    && rm -rf ffmpeg-master-latest-linux64-gpl*

# Verify FFmpeg installation and codecs
RUN ffmpeg -version && \
    ffmpeg -codecs | grep mp3 && \
    ffmpeg -codecs | grep h264 && \
    ffmpeg -codecs | grep aac

# Create necessary directories
RUN mkdir -p /app/bin /app/downloads /app/subtitles /app/temp

# Set working directory
WORKDIR /app

# Copy package files first
COPY package*.json ./

# Install dependencies with error checking
RUN if [ -f "package.json" ]; then \
        echo "Installing dependencies..." && \
        npm install && \
        echo "Dependencies installed successfully"; \
    else \
        echo "Error: package.json not found" && exit 1; \
    fi

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["npm", "start"] 