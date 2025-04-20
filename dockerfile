FROM ubuntu:20.04

# Set working directory
WORKDIR /app

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install Python and dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Install Playwright's bundled Chromium and its dependencies
RUN playwright install chromium \
    && playwright install-deps

# Copy application files
COPY . .

# Make the entrypoint script executable
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Use the entrypoint script to run the app
ENTRYPOINT ["./entrypoint.sh"]