FROM python:3.9

# Install dependencies for Chrome
RUN apt-get update && apt-get install -y wget gnupg

# Add Google's public key and repository
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list

# Install Google Chrome
RUN apt-get update && apt-get install -y google-chrome-stable

# Verify Chrome installation
RUN which google-chrome || echo "Chrome not found"

WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
RUN playwright install
CMD ["streamlit", "run", "app.py", "--server.port=8501"]