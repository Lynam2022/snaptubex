# Use Node.js as the base image
FROM node:18

# Install Python, FFmpeg and required build tools
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    ffmpeg \
    libavcodec58 \
    libavformat58 \
    libavutil56 \
    libswscale5 \
    libavfilter7 \
    libavdevice58 \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/python3 /usr/bin/python

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"] 