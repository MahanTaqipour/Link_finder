FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install dependencies for Chromium, Playwright, and DBus
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
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
    dbus \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

# Install Chromium
RUN apt-get update && apt-get install -y chromium \
    && rm -rf /var/lib/apt/lists/* \
    || echo "Failed to install Chromium"

# Install Chrome as a fallback if Chromium fails
RUN if ! command -v chromium; then \
        echo "Chromium installation failed, attempting to install Chrome..."; \
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
        && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
        && apt-get update \
        && apt-get install -y google-chrome-stable \
        && rm -rf /var/lib/apt/lists/* \
        || echo "Failed to install Chrome via repository"; \
    fi

# Debug: Check browser installation and paths
RUN echo "Checking browser installation..." \
    && (command -v chromium || echo "Chromium binary not found") \
    && (command -v google-chrome || echo "Chrome binary not found") \
    && (ls -l /usr/bin/chromium || echo "/usr/bin/chromium not found") \
    && (ls -l /usr/bin/google-chrome || echo "/usr/bin/google-chrome not found") \
    && (find / -name "chromium" 2>/dev/null || echo "Chromium not found in any path") \
    && (find / -name "google-chrome" 2>/dev/null || echo "Chrome not found in any path")

# Copy application files and install Python dependencies
COPY . .
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright dependencies
RUN playwright install --with-deps

# Default command (for debugging, we'll override this with bash)
CMD ["python", "app.py"]