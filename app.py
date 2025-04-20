import subprocess
import os
import platform
import time
import tempfile
import shutil
import streamlit as st
from playwright.sync_api import sync_playwright
from playwright_stealth import stealth_sync
from bs4 import BeautifulSoup

# Streamlit UI
st.title("Dailymotion Link Finder")
st.markdown("Enter a `seatv-24.xyz` URL to find Dailymotion links")

# Input field for URL
site_url = st.text_input("Enter the seatv-24.xyz website URL:", placeholder="https://seatv-24.xyz/...")
base_link = "https://geo.dailymotion.com/player/xkyen.html"

# Button to trigger link search
if st.button("Find Links"):
    if not site_url:
        st.error("Please enter a URL.")
    else:
        try:
            # Determine OS
            system = platform.system()
            if system == "Windows":
                chrome_path = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
            elif system == "Darwin":
                chrome_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
            elif system == "Linux":
                # Try multiple possible Chrome paths for Linux environments
                possible_paths = [
                    "/usr/bin/google-chrome",
                    "/usr/bin/google-chrome-stable",
                    "/opt/google/chrome/chrome",
                    "/usr/local/bin/google-chrome",
                    "/usr/lib/chromium-browser/chrome",
                    "/bin/google-chrome"
                ]
                chrome_path = None
                st.write("Attempting to find Chrome executable in the following paths:")
                for path in possible_paths:
                    st.write(f"Checking: {path}")
                    if os.path.exists(path):
                        chrome_path = path
                        break
                if not chrome_path:
                    # Try to find Chrome dynamically if none of the paths work
                    import subprocess
                    try:
                        chrome_path = subprocess.check_output(["which", "google-chrome"]).decode().strip()
                        st.write(f"Found Chrome via 'which': {chrome_path}")
                    except:
                        raise FileNotFoundError("Chrome executable not found in any of the expected paths: " + ", ".join(possible_paths) + ". Ensure Chrome is installed in the Docker container.")
            else:
                raise Exception("Unsupported operating system")

            # Log the Chrome path being used
            st.write(f"Using Chrome at: {chrome_path}")

            # Temporary directory for clean profile
            temp_profile_dir = tempfile.mkdtemp()

            # Chrome command with headless mode
            chrome_command = [
                chrome_path,
                "--headless=new",
                "--incognito",
                f"--user-data-dir={temp_profile_dir}",
                "--enable-javascript",
                "--no-sandbox",
                "--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
                site_url
            ]

            # Optional proxy to avoid CAPTCHA
            # proxy = os.getenv("PROXY_SERVER")
            # if proxy:
            #     chrome_command.append(f"--proxy-server={proxy}")

            # Launch Chrome
            chrome_process = subprocess.Popen(chrome_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            # Fetch and search page with Playwright
            st.write("Waiting for page to load and searching for links...")
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
            st.write("Searching for links...")
            soup = BeautifulSoup(html_content, "html.parser")
            links = []
            for iframe in soup.find_all("iframe", {"data-src": True}):
                data_src = iframe.get("data-src")
                if data_src and data_src.startswith(base_link):
                    links.append(data_src)

            # Display results
            if links:
                st.success("Found matching links:")
                for link in set(links):
                    st.write(link)
            else:
                st.warning("No matching links found in the page content.")

        except Exception as e:
            st.error(f"Error: {e}")

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
            st.write("Chrome closed.")