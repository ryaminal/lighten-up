import { Page } from '@playwright/test';

/* eslint-disable @typescript-eslint/no-explicit-any */
/**
 * Mock Tauri APIs for browser-based E2E testing
 * This provides mock implementations of Tauri invoke functions
 */
export async function mockTauriAPIs(page: Page) {
  await page.addInitScript(() => {
    // Mock window.__TAURI_INTERNALS__
    (window as any).__TAURI_INTERNALS__ = {
      invoke: async (cmd: string, _args: any) => {
        console.log('[Mock Tauri] invoke:', cmd, _args);

        // Mock responses based on command
        switch (cmd) {
          case 'get_my_peer_id':
            return 'mock-peer-id-' + Math.random().toString(36).substring(7);
          case 'get_my_peer_name':
            return 'Test User';
          case 'get_chat_messages':
            return [];
          case 'get_peers':
            return [];
          case 'get_config':
            return { lights: [], peer_name: 'Test User' };
          default:
            console.warn('[Mock Tauri] Unhandled command:', cmd);
            return null;
        }
      },
    };

    // Mock event listening
    (window as any).__TAURI__ = {
      event: {
        listen: async (event: string, _handler: any) => {
          console.log('[Mock Tauri] Listening to event:', event);
          return () => {}; // Return unlisten function
        },
        once: async (event: string, _handler: any) => {
          console.log('[Mock Tauri] Listening once to event:', event);
          return () => {};
        },
        emit: async (event: string, payload: any) => {
          console.log('[Mock Tauri] Emitting event:', event, payload);
        },
      },
      core: {
        invoke: async (cmd: string, _args: any) => {
          return (window as any).__TAURI_INTERNALS__.invoke(cmd, _args);
        },
      },
    };
  });
}
