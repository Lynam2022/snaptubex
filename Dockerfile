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

# Debug: Show Node.js and npm versions
RUN node --version && npm --version

# Debug: Show package.json contents and directory structure
RUN ls -la && cat package.json

# Configure npm with individual steps and error checking
RUN npm config set registry https://registry.npmjs.org/ || echo "Failed to set registry" && \
    npm config set loglevel verbose || echo "Failed to set loglevel" && \
    npm config set fetch-retries 5 || echo "Failed to set fetch-retries" && \
    npm config set fetch-retry-mintimeout 20000 || echo "Failed to set fetch-retry-mintimeout" && \
    npm config set fetch-retry-maxtimeout 120000 || echo "Failed to set fetch-retry-maxtimeout"

# Install dependencies with individual steps
RUN npm install --verbose --no-audit --no-fund --no-optional --prefer-offline --no-package-lock || \
    (echo "First npm install attempt failed, trying with --force..." && \
     npm install --verbose --no-audit --no-fund --no-optional --prefer-offline --no-package-lock --force) || \
    (echo "Second npm install attempt failed, trying with --legacy-peer-deps..." && \
     npm install --verbose --no-audit --no-fund --no-optional --prefer-offline --no-package-lock --legacy-peer-deps)

# Copy the rest of the application
COPY . .

# Create required directories if they don't exist
RUN mkdir -p downloads subtitles temp

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["npm", "start"] 