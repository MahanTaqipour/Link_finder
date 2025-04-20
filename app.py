import subprocess
import os
import platform
import time
import tempfile
import shutil
from playwright.sync_api import sync_playwright
from playwright_stealth import stealth_sync
from bs4 import BeautifulSoup

# Get website URL from input
site_url = input("Please enter the seatv-24.xyz website URL: ")

# Base URL to search
base_link = "https://geo.dailymotion.com/player/xkyen.html"

try:
    # Determine OS
    system = platform.system()
    if system == "Windows":
        chrome_path = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
    elif system == "Darwin":
        chrome_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    elif system == "Linux":
        chrome_path = "/usr/bin/google-chrome"
    else:
        raise Exception("Unsupported operating system")

    # Verify Chrome executable
    if not os.path.exists(chrome_path):
        raise FileNotFoundError(f"Chrome executable not found at {chrome_path}")

    # Temporary directory for clean profile
    temp_profile_dir = tempfile.mkdtemp()

    # Chrome command with headless mode
    chrome_command = [
        chrome_path,
        "--headless=new",  # Run Chrome headlessly
        "--incognito",
        f"--user-data-dir={temp_profile_dir}",
        "--enable-javascript",
        "--no-sandbox",
        "--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
        site_url
    ]

    # Optional proxy to avoid CAPTCHA
    # proxy = "http://user:pass@residential-proxy:port"
    # chrome_command.append(f"--proxy-server={proxy}")

    # Launch Chrome
    chrome_process = subprocess.Popen(chrome_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Fetch and search page with Playwright
    print("Waiting for page to load and searching for links...")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        stealth_sync(page)
        page.set_extra_http_headers({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
            "Accept-Language": "en-US,en;q=0.9"
        })
        # Optional Playwright proxy
        # browser = p.chromium.launch(headless=True, proxy={"server": "http://proxy:port", "username": "user", "password": "pass"})

        # Navigate and wait
        page.goto(site_url, wait_until="networkidle", timeout=60000)
        page.wait_for_timeout(5000)  # Handle lazyload
        html_content = page.content()
        browser.close()

    # Search for links in <iframe data-src>
    print("Searching for links...")
    soup = BeautifulSoup(html_content, "html.parser")
    links = []
    for iframe in soup.find_all("iframe", {"data-src": True}):
        data_src = iframe.get("data-src")
        if data_src and data_src.startswith(base_link):
            links.append(data_src)

    # Print results
    if links:
        print("Found matching links:")
        for link in set(links):
            print(link)
    else:
        print("No matching links found in the page content")

except Exception as e:
    print(f"Error: {e}")

finally:
    # Terminate Chrome process
    if 'chrome_process' in locals():
        chrome_process.terminate()
        time.sleep(1)
        if chrome_process.poll() is None:
            chrome_process.kill()
    # Clean up temporary profile
    if 'temp_profile_dir' in locals() and os.path.exists(temp_profile_dir):
        shutil.rmtree(temp_profile_dir)
    print("Chrome closed.")
    print("Press any key to close")
    input()