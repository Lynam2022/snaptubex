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

# Install FFmpeg with all codecs
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libavcodec58 \
    libavformat58 \
    libavutil56 \
    libswscale5 \
    libavfilter7 \
    libavdevice58 \
    libmp3lame0 \
    libmp3lame-dev \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/python3 /usr/bin/python

# Create necessary directories
RUN mkdir -p /app/bin /app/downloads /app/subtitles /app/temp

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["npm", "start"] 