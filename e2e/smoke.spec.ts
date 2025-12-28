import { test, expect } from '@playwright/test';
import { mockTauriAPIs } from './helpers/mockTauri';

test.describe('Lighten-Up Application', () => {
  test('should load the application', async ({ page }) => {
    // Mock Tauri APIs before navigating
    await mockTauriAPIs(page);

    await page.goto('/');

    // Wait for the app to fully load
    await page.waitForLoadState('networkidle');

    // Check that the main chat header is visible
    await expect(page.locator('h1:has-text("Global Chat")')).toBeVisible({ timeout: 10000 });

    // Verify core UI elements are present
    const messageInput = page.locator('textarea[placeholder="Type your message..."]');
    await expect(messageInput).toBeVisible();

    const sendButton = page.locator('button[aria-label="Send message"]');
    await expect(sendButton).toBeVisible();
  });
});
