#!/usr/bin/env python3

import asyncio
import json
from playwright.async_api import async_playwright

async def scrape_wow_content():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()

        # Set user agent to avoid blocking
        await page.set_extra_http_headers({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })

        dungeons_data = {}

        # Try multiple sources
        sources = [
            'https://www.wowhead.com/guides/dungeons',
            'https://www.icy-veins.com/wow/',
            'https://wowpedia.fandom.com/wiki/Dungeon'
        ]

        for url in sources:
            try:
                print(f"Trying {url}...")
                await page.goto(url, wait_until='networkidle')

                # Look for dungeon-related content
                content = await page.content()

                # Search for The War Within dungeons
                if 'War Within' in content or 'Season 3' in content:
                    # Extract dungeon names and boss info
                    dungeon_links = await page.query_selector_all('a[href*="dungeon"]')
                    for link in dungeon_links[:5]:  # Limit to prevent timeout
                        text = await link.inner_text()
                        href = await link.get_attribute('href')
                        if any(name in text for name in ['Ara-Kara', 'Dawnbreaker', 'Eco-Dome', 'Operation', 'Priory', 'Tazavesh']):
                            dungeons_data[text] = {
                                'url': href,
                                'source': url
                            }

                    print(f"Found {len(dungeons_data)} dungeons from {url}")
                    break

            except Exception as e:
                print(f"Error with {url}: {e}")
                continue

        await browser.close()

        # Output results
        print("\n=== SCRAPED DUNGEON DATA ===")
        print(json.dumps(dungeons_data, indent=2))

        return dungeons_data

if __name__ == "__main__":
    asyncio.run(scrape_wow_content())