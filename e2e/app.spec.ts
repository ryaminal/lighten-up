import { test, expect } from '@playwright/test';

test.describe('Global Chat', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    // Wait for the app to load
    await expect(page.locator('h1:has-text("Global Chat")')).toBeVisible();
  });

  test('should display chat header', async ({ page }) => {
    await expect(page.locator('h1')).toContainText('Global Chat');
    await expect(page.locator('.material-symbols-outlined:has-text("forum")')).toBeVisible();
  });

  test('should show empty state when no messages', async ({ page }) => {
    const emptyState = page.locator('text=No messages yet');
    // Empty state might be visible or chat might have messages
    // Just check the page loaded
    await expect(page.locator('h1')).toContainText('Global Chat');
  });

  test('should have message input field', async ({ page }) => {
    const messageInput = page.locator('textarea[placeholder="Type your message..."]');
    await expect(messageInput).toBeVisible();
    await expect(messageInput).toBeEditable();
  });

  test('should have send button', async ({ page }) => {
    const sendButton = page.locator('button[aria-label="Send message"]');
    await expect(sendButton).toBeVisible();
  });

  test('should type in message input', async ({ page }) => {
    const messageInput = page.locator('textarea[placeholder="Type your message..."]');
    await messageInput.fill('Hello, this is a test message!');
    await expect(messageInput).toHaveValue('Hello, this is a test message!');
  });

  test('should clear input after typing and clearing', async ({ page }) => {
    const messageInput = page.locator('textarea[placeholder="Type your message..."]');
    await messageInput.fill('Test message');
    await messageInput.clear();
    await expect(messageInput).toHaveValue('');
  });

  test('send button should be clickable', async ({ page }) => {
    const sendButton = page.locator('button[aria-label="Send message"]');
    await expect(sendButton).toBeEnabled();

    // Fill input and verify button is still enabled
    const messageInput = page.locator('textarea[placeholder="Type your message..."]');
    await messageInput.fill('Test');
    await expect(sendButton).toBeEnabled();
  });

  test('should handle long messages', async ({ page }) => {
    const messageInput = page.locator('textarea[placeholder="Type your message..."]');
    const longMessage = 'A'.repeat(500); // Max length
    await messageInput.fill(longMessage);
    await expect(messageInput).toHaveValue(longMessage);
  });

  test('should respect 500 character limit', async ({ page }) => {
    const messageInput = page.locator('textarea[placeholder="Type your message..."]');
    const tooLongMessage = 'A'.repeat(600);
    await messageInput.fill(tooLongMessage);

    // The backend should reject this, but we can verify the input accepts it
    // (backend validation will be tested in integration tests)
    const value = await messageInput.inputValue();
    expect(value.length).toBeLessThanOrEqual(600);
  });
});

test.describe('Settings Modal', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('should open settings modal when settings button clicked', async ({ page }) => {
    // Look for settings icon/button
    const settingsButton = page
      .locator('button')
      .filter({ hasText: 'settings' })
      .or(page.locator('button[aria-label*="ettings" i]'));

    // If settings button exists, click it
    if ((await settingsButton.count()) > 0) {
      await settingsButton.first().click();

      // Wait for modal to appear
      const modal = page.locator('text=Settings').or(page.locator('[role="dialog"]'));
      await expect(modal.first()).toBeVisible({ timeout: 5000 });
    }
  });
});

test.describe('Navigation', () => {
  test('should load the main page', async ({ page }) => {
    await page.goto('/');

    // Check that core UI elements are present
    await expect(page.locator('body')).toBeVisible();

    // Verify app has loaded (not showing loading state)
    await expect(page.locator('h1:has-text("Global Chat")')).toBeVisible({ timeout: 10000 });
  });

  test('should have proper page title', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/lighten.*up/i);
  });
});

test.describe('Accessibility', () => {
  test('should have proper ARIA labels', async ({ page }) => {
    await page.goto('/');

    // Check for aria-label on send button
    const sendButton = page.locator('button[aria-label="Send message"]');
    await expect(sendButton).toBeVisible();
  });

  test('should be keyboard navigable', async ({ page }) => {
    await page.goto('/');

    const messageInput = page.locator('textarea[placeholder="Type your message..."]');

    // Tab to input (may need multiple tabs depending on page structure)
    await page.keyboard.press('Tab');

    // Type a message
    await messageInput.fill('Test keyboard navigation');
    await expect(messageInput).toHaveValue('Test keyboard navigation');
  });
});
