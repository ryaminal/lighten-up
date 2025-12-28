import '@testing-library/jest-dom/vitest';
import { randomFillSync, randomUUID } from 'crypto';

// jsdom doesn't come with a WebCrypto implementation (required for Tauri mocks)
Object.defineProperty(window, 'crypto', {
  value: {
    getRandomValues: (buffer) => randomFillSync(buffer),
    randomUUID: () => randomUUID(),
  },
});

// Mock Tauri event listener internals
window.__TAURI_EVENT_PLUGIN_INTERNALS__ = {
  unregisterListener: () => Promise.resolve(),
};
