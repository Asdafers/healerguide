import { test, expect } from '@playwright/test'

test.describe('Browser Detection', () => {
  // T025: E2E test Chrome browser detection
  test('allows access in Chrome browser', async ({ page }) => {
    await page.goto('/')

    // Should not show browser warning in Chrome
    await expect(page.locator('[data-testid="browser-warning"]')).not.toBeVisible()

    // Should show main application content
    await expect(page.locator('text=HealerKit - Chrome Web App')).toBeVisible()
    await expect(page.locator('text=Loading dungeons...')).toBeVisible()
  })

  test('shows warning for non-Chrome browsers', async ({ page, browserName }) => {
    // Skip this test in Chrome since we can't easily simulate other browsers
    test.skip(browserName === 'chromium', 'This test is for non-Chrome browsers')

    await page.goto('/')

    // Should show browser warning
    await expect(page.locator('[data-testid="browser-warning"]')).toBeVisible()
    await expect(page.locator('text=Browser not supported')).toBeVisible()
    await expect(page.locator('text=Please use Chrome')).toBeVisible()

    // Should show download link
    const chromeLink = page.locator('a[href="https://www.google.com/chrome/"]')
    await expect(chromeLink).toBeVisible()
    await expect(chromeLink).toHaveAttribute('target', '_blank')
  })

  test('browser warning prevents app usage', async ({ page, browserName }) => {
    test.skip(browserName === 'chromium', 'This test is for non-Chrome browsers')

    await page.goto('/')

    // Should not show main app navigation
    await expect(page.locator('text=Loading dungeons...')).not.toBeVisible()

    // Main app content should be hidden
    await expect(page.locator('[data-testid="dungeon-grid"]')).not.toBeVisible()
  })

  test('browser warning has proper styling and accessibility', async ({ page, browserName }) => {
    test.skip(browserName === 'chromium', 'This test is for non-Chrome browsers')

    await page.goto('/')

    const warning = page.locator('[data-testid="browser-warning"]')
    await expect(warning).toBeVisible()

    // Check styling classes are applied
    await expect(warning).toHaveClass(/browser-warning/)

    // Check accessibility - warning should be announced to screen readers
    await expect(warning).toHaveAttribute('role', 'alert')
  })

  test('Chrome detection works with different Chrome versions', async ({ page }) => {
    // Test with different Chrome user agent strings
    const chromeVersions = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
    ]

    for (const userAgent of chromeVersions) {
      await page.goto('/', { waitUntil: 'networkidle' })
      await page.addInitScript(`
        Object.defineProperty(navigator, 'userAgent', {
          get: () => '${userAgent}'
        });
      `)

      await page.reload()

      // Should not show browser warning
      await expect(page.locator('[data-testid="browser-warning"]')).not.toBeVisible()

      // Should show main app
      await expect(page.locator('text=HealerKit - Chrome Web App')).toBeVisible()
    }
  })

  test('Edge browser shows warning despite Chromium base', async ({ page }) => {
    await page.goto('/')
    await page.addInitScript(`
      Object.defineProperty(navigator, 'userAgent', {
        get: () => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0'
      });
    `)

    await page.reload()

    // Should show browser warning for Edge
    await expect(page.locator('[data-testid="browser-warning"]')).toBeVisible()
    await expect(page.locator('text=Browser not supported')).toBeVisible()
  })
})