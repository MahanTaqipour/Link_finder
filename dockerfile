FROM zenika/alpine-chrome:latest

# Set working directory
WORKDIR /app

# Install Python and pip (alpine-chrome uses apk, not apt)
RUN apk add --no-cache python3 py3-pip

# Install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Make the entrypoint script executable
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Use the entrypoint script to run the app
ENTRYPOINT ["./entrypoint.sh"]