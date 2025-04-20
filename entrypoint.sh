#!/bin/bash

# Set Playwright cache directory and ensure permissions
export PLAYWRIGHT_BROWSERS_PATH=/app/.playwright-browsers
mkdir -p $PLAYWRIGHT_BROWSERS_PATH
chmod -R 777 $PLAYWRIGHT_BROWSERS_PATH

echo "Installing Playwright browsers..."
# Run playwright install with verbose output
playwright install --with-deps || {
    echo "Error: Failed to install Playwright browsers."
    echo "Listing contents of $PLAYWRIGHT_BROWSERS_PATH:"
    ls -la $PLAYWRIGHT_BROWSERS_PATH
    echo "Listing contents of /opt/render/.cache/ms-playwright (default cache):"
    ls -la /opt/render/.cache/ms-playwright || echo "Default cache directory not found."
    exit 1
}

echo "Playwright browsers installed successfully."
echo "Listing contents of $PLAYWRIGHT_BROWSERS_PATH:"
ls -la $PLAYWRIGHT_BROWSERS_PATH

# Run the app
exec python app.py