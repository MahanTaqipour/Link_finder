FROM python:3.9

# Install dependencies for Chrome
RUN apt-get update && apt-get install -y wget gnupg

# Method 1: Try installing Chrome via the Google repository
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y google-chrome-stable || echo "Failed to install Chrome via repository"

# Method 2: If the repository method fails, download and install Chrome directly
RUN if ! command -v google-chrome; then \
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
        && apt-get update \
        && apt-get install -y ./google-chrome-stable_current_amd64.deb \
        && rm google-chrome-stable_current_amd64.deb \
        || echo "Failed to install Chrome via direct download"; \
    fi

# Debug: Check Chrome installation and path
RUN echo "Checking Chrome installation..." \
    && command -v google-chrome || echo "Chrome binary not found" \
    && ls -l /usr/bin/google-chrome || echo "/usr/bin/google-chrome not found" \
    && find / -name "google-chrome" 2>/dev/null || echo "Chrome not found in any path"

WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
RUN playwright install
CMD ["streamlit", "run", "app.py", "--server.port=8501"]