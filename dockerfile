FROM python:3.9

# Install dependencies for Chrome/Chromium
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
    && rm -rf /var/lib/apt/lists/*

# Method 1: Install Chromium (preferred for Linux containers)
RUN apt-get update && apt-get install -y chromium \
    || echo "Failed to install Chromium"

# Method 2: Fallback to Chrome if Chromium fails
RUN if ! command -v chromium; then \
        echo "Chromium installation failed, attempting to install Chrome..."; \
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
        && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
        && apt-get update && apt-get install -y google-chrome-stable || echo "Failed to install Chrome via repository"; \
    fi

# Method 3: Direct Chrome download if the repository method fails
RUN if ! command -v google-chrome && ! command -v chromium; then \
        echo "Attempting direct Chrome download..."; \
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
        && apt-get update \
        && apt-get install -y ./google-chrome-stable_current_amd64.deb \
        && rm google-chrome-stable_current_amd64.deb \
        || echo "Failed to install Chrome via direct download"; \
    fi

# Debug: Check browser installation and paths
RUN echo "Checking browser installation..." \
    && (command -v chromium || echo "Chromium binary not found") \
    && (command -v google-chrome || echo "Chrome binary not found") \
    && (ls -l /usr/bin/chromium || echo "/usr/bin/chromium not found") \
    && (ls -l /usr/bin/google-chrome || echo "/usr/bin/google-chrome not found") \
    && (find / -name "chromium" 2>/dev/null || echo "Chromium not found in any path") \
    && (find / -name "google-chrome" 2>/dev/null || echo "Chrome not found in any path")

WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
RUN playwright install
CMD ["streamlit", "run", "app.py", "--server.port=8501"]