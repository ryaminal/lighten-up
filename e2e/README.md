# End-to-End Testing

This directory contains Playwright E2E tests for the Lighten-Up application.

## Status

**Infrastructure: Ready**  
**Tests: Not yet implemented**

The E2E testing infrastructure is set up and ready to use, but we haven't written comprehensive tests yet. Current unit and integration tests (128 passing) provide strong coverage.

## Setup

E2E tests use Playwright to test the application in a real browser with mocked Tauri APIs.

### Running Tests

```bash
# Run E2E tests (when implemented)
pnpm run test:e2e

# Run with visible browser
pnpm run test:e2e:headed

# Open Playwright UI for debugging
pnpm run test:e2e:ui

# Debug specific test
pnpm run test:e2e:debug

# Or use Make targets
make e2e
make e2e-headed
```

## Architecture

### Test Files

- `smoke.spec.ts` - Basic smoke tests (app loads, core UI visible)
- `app.spec.ts` - Comprehensive UI tests (placeholder)

### Helpers

- `mockTauri.ts` - Mocks Tauri APIs (`__TAURI__` and `__TAURI_INTERNALS__`) for browser testing
- `globalTeardown.ts` - Ensures dev server processes are killed after tests

## Configuration

- **Dev Server**: Tests run against Vite dev server on `localhost:5173`
- **Browser**: Chromium (can add Firefox/WebKit in `playwright.config.ts`)
- **Timeout**: 120 seconds for dev server startup
- **Cleanup**: Automatic process cleanup on test completion

## Why Mock Tauri APIs?

Testing the actual Tauri app requires WebDriver setup with `tauri-driver`, which is more complex. For faster feedback, we:

1. Test the web UI in a regular browser (Chromium)
2. Mock Tauri APIs to simulate backend responses
3. Get fast, reliable tests without full Tauri runtime

This approach tests the UI layer thoroughly while unit tests cover backend logic.

## Future Work

When ready to expand E2E coverage:

1. **Chat Workflows**: Send messages, edit, delete, keyboard shortcuts
2. **Settings**: Open modal, add/edit lights, change peer name
3. **Peer Interactions**: Peer list updates, notifications, presence
4. **Accessibility**: Keyboard navigation, screen reader support

For now, the existing unit/integration tests provide excellent coverage.
