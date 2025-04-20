FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install minimal dependencies for Playwright's Chromium
RUN apt-get update && apt-get install -y \
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

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright's bundled Chromium
RUN playwright install chromium

# Copy application files
COPY . .

# Make the entrypoint script executable
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Use the entrypoint script to run the app
ENTRYPOINT ["./entrypoint.sh"]