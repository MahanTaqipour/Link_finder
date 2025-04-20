FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install dependencies for Chrome
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    libx11-xcb1 \
    libxss1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxtst6 \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libasound2 \
    fonts-liberation \
    libx11-6 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome with verbose output
RUN echo "Installing Google Chrome..." \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable || { echo "Failed to install Google Chrome"; exit 1; } \
    && rm -rf /var/lib/apt/lists/*

# Debug: Check Chrome installation
RUN echo "Checking Chrome installation..." \
    && (command -v google-chrome || echo "Chrome binary not found") \
    && (ls -l /usr/bin/google-chrome || echo "/usr/bin/google-chrome not found") \
    && (google-chrome --version || echo "Failed to get Chrome version")

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Make the entrypoint script executable
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Use the entrypoint script to run the app
ENTRYPOINT ["./entrypoint.sh"]