# extract_content.py
# Requirements (install with uv):
#   uv pip install playwright
#
# Usage:
#   python extract_content.py

from playwright.sync_api import sync_playwright
from urllib.parse import urlparse
import time
import random
import json

OUTPUT_FILE = "blue_links.md"
CONTENT_OUTPUT = "site_content.json"

# Read the existing links
with open(OUTPUT_FILE, 'r') as f:
    all_urls = [line.strip() for line in f if line.strip()]

# Prioritize key pages for PRD
priority_keywords = [
    'bluenotesoftware.com/lights/',
    'bluenotesoftware.com/about',
    'bluenotesoftware.com/customers',
    'bluenotesoftware.com/blog/?id=',
    'bluenotesoftware.com/support',
    'support.bluenotesoftware.com/article/',
    'bluenotesoftware.com/bluenote-communicator-classic',
    'bluenotesoftware.com/bill-of-rights'
]

# Select prioritized URLs (max 30)
urls_to_visit = []
for keyword in priority_keywords:
    matching = [u for u in all_urls if keyword in u and u not in urls_to_visit]
    urls_to_visit.extend(matching[:5])  # Max 5 per category

# Add homepage if not already there
if 'https://www.bluenotesoftware.com' not in urls_to_visit:
    urls_to_visit.insert(0, 'https://www.bluenotesoftware.com')

urls_to_visit = urls_to_visit[:30]  # Cap at 30 pages

print(f"Extracting content from {len(urls_to_visit)} priority pages for PRD")

all_content = []

with sync_playwright() as p:
    for i, url in enumerate(urls_to_visit, 1):
        print(f"\n[{i}/{len(urls_to_visit)}] Extracting: {url}")
        
        try:
            # Create a fresh browser context for each URL
            browser = p.chromium.launch(headless=True)
            context = browser.new_context(
                user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
                viewport={'width': 1920, 'height': 1080},
            )
            
            page = context.new_page()
            
            # Random delay to avoid rate limiting
            if i > 1:
                delay = random.uniform(3, 5)
                time.sleep(delay)
            
            response = page.goto(url, wait_until="domcontentloaded", timeout=30000)
            
            if not response or response.status >= 400:
                print(f"  Skipped - status: {response.status if response else 'No response'}")
                context.close()
                browser.close()
                continue
            
            # Wait for content
            page.wait_for_timeout(2000)
            
            # Extract content
            title = page.title()
            
            # Get main content text (excluding nav, footer, etc)
            main_text = page.evaluate("""
                () => {
                    // Try to find main content area
                    let content = document.querySelector('main') || 
                                  document.querySelector('article') || 
                                  document.querySelector('.content') ||
                                  document.querySelector('#content') ||
                                  document.body;
                    
                    // Remove script, style, nav, footer
                    let clone = content.cloneNode(true);
                    clone.querySelectorAll('script, style, nav, footer, header, .nav, .footer, .header, .menu').forEach(el => el.remove());
                    
                    return clone.innerText.trim();
                }
            """)
            
            # Get meta description if available
            meta_desc = page.evaluate("""
                () => {
                    let meta = document.querySelector('meta[name="description"]');
                    return meta ? meta.content : '';
                }
            """)
            
            # Get all headings
            headings = page.evaluate("""
                () => {
                    let headings = [];
                    document.querySelectorAll('h1, h2, h3').forEach(h => {
                        headings.push({
                            level: h.tagName,
                            text: h.innerText.trim()
                        });
                    });
                    return headings;
                }
            """)
            
            # Get list items (often contain features)
            features = page.evaluate("""
                () => {
                    let items = [];
                    document.querySelectorAll('ul li, ol li').forEach(li => {
                        let text = li.innerText.trim();
                        if (text && text.length < 200) {
                            items.push(text);
                        }
                    });
                    return items.slice(0, 20);  // Max 20 items
                }
            """)
            
            content_data = {
                'url': url,
                'title': title,
                'meta_description': meta_desc,
                'headings': headings,
                'features': features,
                'content': main_text[:3000] if main_text else ''  # Limit to 3000 chars per page
            }
            
            all_content.append(content_data)
            print(f"  ✓ Extracted: {title[:60]}...")
            
            context.close()
            browser.close()
            
        except Exception as e:
            print(f"  Error: {e}")
            try:
                context.close()
                browser.close()
            except:
                pass
            continue

# Write to JSON file
with open(CONTENT_OUTPUT, "w") as f:
    json.dump(all_content, f, indent=2)

print(f"\n✓ Done! Extracted content from {len(all_content)} pages")
print(f"Content saved to {CONTENT_OUTPUT}")
