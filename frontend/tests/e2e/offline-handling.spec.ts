import { test, expect } from '@playwright/test'

test.describe('Offline Error Handling', () => {
  // T026: E2E test offline error handling
  test('displays error message when going offline', async ({ page, context }) => {
    // Start with online connection
    await page.goto('/')

    // Wait for initial load
    await expect(page.locator('text=HealerKit - Chrome Web App')).toBeVisible()

    // Simulate network going offline
    await context.setOffline(true)

    // Try to navigate to a dungeon (which requires API call)
    await page.click('text=Ara-Kara, City of Echoes', { timeout: 1000 }).catch(() => {
      // Click might fail if element not found, continue with test
    })

    // Should show offline error message
    await expect(page.locator('text=Connection lost')).toBeVisible({ timeout: 10000 })
    await expect(page.locator('text=Please check your internet connection')).toBeVisible()
  })

  test('shows offline indicator in header', async ({ page, context }) => {
    await page.goto('/')

    // Go offline
    await context.setOffline(true)

    // Trigger a network request that will fail
    await page.evaluate(() => {
      fetch('/api/v1/seasons').catch(() => {
        // Trigger offline state in app
        window.dispatchEvent(new Event('offline'))
      })
    })

    // Should show offline indicator
    await expect(page.locator('[data-testid="offline-indicator"]')).toBeVisible()
    await expect(page.locator('text=Offline')).toBeVisible()
  })

  test('recovers when connection is restored', async ({ page, context }) => {
    await page.goto('/')

    // Go offline
    await context.setOffline(true)

    // Wait for offline state
    await page.evaluate(() => {
      window.dispatchEvent(new Event('offline'))
    })

    await expect(page.locator('[data-testid="offline-indicator"]')).toBeVisible()

    // Go back online
    await context.setOffline(false)

    // Trigger online event
    await page.evaluate(() => {
      window.dispatchEvent(new Event('online'))
    })

    // Should hide offline indicator
    await expect(page.locator('[data-testid="offline-indicator"]')).not.toBeVisible()

    // Should show normal content again
    await expect(page.locator('text=Loading dungeons...')).toBeVisible()
  })

  test('prevents navigation when offline', async ({ page, context }) => {
    await page.goto('/')

    // Wait for initial load
    await page.waitForLoadState('networkidle')

    // Go offline
    await context.setOffline(true)

    // Try to navigate to a specific route
    await page.goto('/dungeon/550e8400-e29b-41d4-a716-446655440001')

    // Should show offline error instead of loading dungeon
    await expect(page.locator('text=Connection required')).toBeVisible()
    await expect(page.locator('text=This feature requires an internet connection')).toBeVisible()
  })

  test('caches previously loaded data for offline viewing', async ({ page, context }) => {
    await page.goto('/')

    // Wait for dungeons to load while online
    await expect(page.locator('text=Ara-Kara, City of Echoes')).toBeVisible()

    // Click on a dungeon to load its data
    await page.click('text=Ara-Kara, City of Echoes')
    await expect(page.locator('text=Avanoxx')).toBeVisible()

    // Go offline
    await context.setOffline(true)

    // Navigate back to home
    await page.click('text=HealerKit - Chrome Web App')

    // Previously loaded dungeon list should still be visible
    await expect(page.locator('text=Ara-Kara, City of Echoes')).toBeVisible()

    // But trying to load new data should show offline message
    await page.click('text=The Stonevault') // Different dungeon

    await expect(page.locator('text=Connection required')).toBeVisible()
  })

  test('shows retry button for failed network requests', async ({ page, context }) => {
    await page.goto('/')

    // Go offline
    await context.setOffline(true)

    // Try to load boss details (will fail)
    await page.goto('/boss/550e8400-e29b-41d4-a716-446655440002')

    // Should show error with retry option
    await expect(page.locator('text=Failed to load boss encounter')).toBeVisible()
    await expect(page.locator('button', { hasText: 'Retry' })).toBeVisible()

    // Go back online
    await context.setOffline(false)

    // Click retry button
    await page.click('button', { hasText: 'Retry' })

    // Should successfully load the content
    await expect(page.locator('text=Avanoxx')).toBeVisible()
    await expect(page.locator('text=Failed to load')).not.toBeVisible()
  })

  test('handles intermittent connectivity gracefully', async ({ page, context }) => {
    await page.goto('/')

    // Simulate intermittent connectivity by toggling offline/online rapidly
    for (let i = 0; i < 3; i++) {
      await context.setOffline(true)
      await page.waitForTimeout(500)
      await context.setOffline(false)
      await page.waitForTimeout(500)
    }

    // App should still function normally after intermittent issues
    await expect(page.locator('text=HealerKit - Chrome Web App')).toBeVisible()
    await expect(page.locator('text=Loading dungeons...')).toBeVisible()
  })

  test('offline message includes helpful instructions', async ({ page, context }) => {
    await page.goto('/')

    await context.setOffline(true)

    // Trigger offline state
    await page.evaluate(() => {
      window.dispatchEvent(new Event('offline'))
    })

    const offlineMessage = page.locator('[data-testid="offline-message"]')
    await expect(offlineMessage).toBeVisible()

    // Should include helpful instructions
    await expect(offlineMessage.locator('text=Check your internet connection')).toBeVisible()
    await expect(offlineMessage.locator('text=Try refreshing the page')).toBeVisible()
    await expect(offlineMessage.locator('text=Contact support if the problem persists')).toBeVisible()
  })
})