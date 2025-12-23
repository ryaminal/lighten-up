# blue_links_crawler.py
# Requirements (install with uv):
#   uv pip install playwright
# After installing playwright, run:
#   python -m playwright install chromium
#
# Usage:
#   python blue_links_crawler.py

from playwright.sync_api import sync_playwright
from urllib.parse import urljoin, urlparse
import time
import random

OUTPUT_FILE = "blue_links.md"
ALLOWED_DOMAIN = "bluenotesoftware.com"

# Read the existing links
with open(OUTPUT_FILE, 'r') as f:
    urls_to_visit = [line.strip() for line in f if line.strip()]

print(f"Found {len(urls_to_visit)} URLs to visit")

def is_internal_link(link):
    if not link:
        return False
    parsed = urlparse(link)
    # Accept if relative or in allowed domain
    if parsed.netloc and ALLOWED_DOMAIN not in parsed.netloc:
        return False
    if parsed.scheme not in ["http", "https", ""]:
        return False
    # Ignore media/doc files
    if parsed.path.endswith(('.jpg', '.jpeg', '.png', '.gif', '.ico', '.svg', '.pdf', '.doc', '.zip', '.mp4', '.avi', '.css', '.js')):
        return False
    if any(x in link for x in ['mailto:', 'tel:', 'javascript:']):
        return False
    return True

def normalize_url(url):
    """Remove fragment and trailing slash"""
    return url.split('#')[0].rstrip('/')

all_links = set()

with sync_playwright() as p:
    for i, url in enumerate(urls_to_visit, 1):
        print(f"\n[{i}/{len(urls_to_visit)}] Visiting: {url}")
        
        try:
            # Create a fresh browser context for each URL (like opening a new incognito window)
            browser = p.chromium.launch(headless=True)
            context = browser.new_context(
                user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
                viewport={'width': 1920, 'height': 1080},
            )
            
            page = context.new_page()
            
            # Random delay to avoid rate limiting
            if i > 1:
                delay = random.uniform(3, 6)
                print(f"  Waiting {delay:.1f}s...")
                time.sleep(delay)
            
            response = page.goto(url, wait_until="domcontentloaded", timeout=30000)
            
            if not response:
                print(f"  No response")
                all_links.add(normalize_url(url))
                context.close()
                browser.close()
                continue
            
            status = response.status
            print(f"  Status: {status}")
            
            if status >= 400:
                print(f"  Failed - adding URL anyway")
                all_links.add(normalize_url(url))
                context.close()
                browser.close()
                continue
            
            # Wait for content
            page.wait_for_timeout(1500)
            
            # Get all links
            links = page.eval_on_selector_all('a[href]', '(elements) => elements.map(e => e.href)')
            print(f"  Found {len(links)} links on this page")
            
            # Add this page
            all_links.add(normalize_url(url))
            
            # Add all internal links found
            new_count = 0
            for link in links:
                normalized = normalize_url(link)
                if is_internal_link(normalized):
                    if normalized not in all_links:
                        new_count += 1
                    all_links.add(normalized)
            
            print(f"  Added {new_count} new links. Total unique: {len(all_links)}")
            
            context.close()
            browser.close()
            
        except Exception as e:
            print(f"  Error: {e}")
            all_links.add(normalize_url(url))
            try:
                context.close()
                browser.close()
            except:
                pass
            continue

# Write to file
with open(OUTPUT_FILE, "w") as f:
    for link in sorted(all_links):
        f.write(link + "\n")

print(f"\n✓ Done! {len(all_links)} unique links written to {OUTPUT_FILE}")
