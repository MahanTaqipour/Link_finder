FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install minimal dependencies for Chrome
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    libnss3 \
    libgbm1 \
    fonts-liberation \
    libx11-6 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrender1 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    && rm -rf /var/lib/apt/lists/*

# Add Chrome's official APT repository and install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable

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