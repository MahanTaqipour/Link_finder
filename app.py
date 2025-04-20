import os
import logging
from playwright.sync_api import sync_playwright
from playwright_stealth import stealth_sync
from bs4 import BeautifulSoup

# Configure logging
logging.basicConfig(filename="scraper.log", level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def main():
    base_link = "https://geo.dailymotion.com/player/xkyen.html"

    # Read URLs from a file
    try:
        with open("urls.txt", "r") as f:
            site_urls = [url.strip() for url in f.readlines() if url.strip()]
    except FileNotFoundError:
        print("Error: urls.txt not found. Please create a file named 'urls.txt' with the URLs to scrape.")
        logging.error("urls.txt not found")
        return

    if not site_urls:
        print("Error: No URLs found in urls.txt.")
        logging.error("No URLs found in urls.txt")
        return

    # Process each URL
    all_links = []
    for site_url in site_urls:
        print(f"\nProcessing {site_url}...")
        logging.info(f"Processing {site_url}")
        try:
            # Fetch and search page with Playwright using bundled Chromium
            print("Launching Playwright browser with Chromium...")
            logging.info("Launching Playwright browser with Chromium")
            with sync_playwright() as p:
                browser = p.chromium.launch(
                    headless=True,
                    args=["--no-sandbox", "--disable-dev-shm-usage"]
                )
                page = browser.new_page()
                stealth_sync(page)
                page.set_extra_http_headers({
                    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
                    "Accept-Language": "en-US,en;q=0.9"
                })

                print(f"Navigating to {site_url}...")
                logging.info(f"Navigating to {site_url}")
                page.goto(site_url, wait_until="networkidle", timeout=60000)
                print("Waiting for page to load fully...")
                logging.info("Waiting for page to load fully")
                page.wait_for_timeout(10000)
                html_content = page.content()
                print("Page loaded.")
                logging.info("Page loaded")
                print("HTML content:")
                print(html_content)
                browser.close()

            # Search for links in <iframe data-src>
            print("Searching for links...")
            logging.info("Searching for links")
            soup = BeautifulSoup(html_content, "html.parser")
            links = []
            for iframe in soup.find_all("iframe", {"data-src": True}):
                data_src = iframe.get("data-src")
                if data_src and data_src.startswith(base_link):
                    links.append(data_src)

            # Display results
            if links:
                print("Found matching links:")
                logging.info(f"Found links: {links}")
                for link in set(links):
                    print(link)
                    all_links.append(link)
            else:
                print("No matching links found in the page content.")
                logging.warning("No links found")

        except Exception as e:
            print(f"Error: {e}")
            logging.error(f"Error: {e}")

    # Save all links to a file
    if all_links:
        with open("found_links.txt", "w") as f:
            for link in set(all_links):
                f.write(link + "\n")
        print("\nAll found links have been saved to found_links.txt.")
        logging.info("All found links saved to found_links.txt")

if __name__ == "__main__":
    main()