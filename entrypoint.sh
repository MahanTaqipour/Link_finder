#!/bin/bash

# Debug: Verify Chrome is installed
echo "Verifying Chrome installation..."
if ! command -v google-chrome; then
    echo "Error: Google Chrome not found."
    exit 1
fi
google-chrome --version

# Run the app
exec python app.py