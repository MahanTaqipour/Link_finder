#!/bin/bash

# Debug: Verify Chrome is installed
echo "Verifying Chrome installation..."
if ! command -v google-chrome; then
    echo "Error: Google Chrome not found."
    exit 1
fi
google-chrome --version

# Debug: Check network connectivity
echo "Checking network connectivity..."
curl -I https://dl.google.com || echo "Warning: Failed to reach dl.google.com"

# Run the app
exec python app.py