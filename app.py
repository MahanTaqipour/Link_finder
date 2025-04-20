import os
from playwright.sync_api import sync_playwright
from playwright_stealth import stealth_sync
from bs4 import BeautifulSoup

def main():
    # Hardcode the URL for Render.com deployment
    site_url = "https://seatv-24.xyz/battle-through-the-heavens-s5-episode-143-subtitle/"
    base_link = "https://geo.dailymotion.com/player/xkyen.html"

    print(f"Using URL: {site_url}")

    try:
        # Fetch and search page with Playwright
        print("Launching Playwright browser and loading page...")
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
            page.goto(site_url, wait_until="networkidle", timeout=60000)
            print("Waiting for page to load fully...")
            page.wait_for_timeout(10000)
            html_content = page.content()
            print("Page loaded.")
            browser.close()

        # Search for links in <iframe data-src>
        print("Searching for links...")
        soup = BeautifulSoup(html_content, "html.parser")
        links = []
        for iframe in soup.find_all("iframe", {"data-src": True}):
            data_src = iframe.get("data-src")
            if data_src and data_src.startswith(base_link):
                links.append(data_src)

        # Display results
        if links:
            print("Found matching links:")
            for link in set(links):
                print(link)
        else:
            print("No matching links found in the page content.")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()