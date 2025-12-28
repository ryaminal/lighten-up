import { render, screen, waitFor } from '@testing-library/svelte';
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import userEvent from '@testing-library/user-event';
import { myLightColor, lights } from '../stores';
import { mockIPC, clearMocks } from '@tauri-apps/api/mocks';
import LightColorPicker from './LightColorPicker.svelte';

// Mock the event listener API
vi.mock('@tauri-apps/api/event', () => ({
  listen: vi.fn(() => Promise.resolve(() => {})),
}));

describe('LightColorPicker', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    myLightColor.set('#000000');
    lights.set([]);

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    mockIPC((cmd, payload: any) => {
      if (cmd === 'set_light_color') {
        myLightColor.set(payload.color);
        return null;
      }
      return null;
    });
  });

  afterEach(() => {
    clearMocks();
  });

  describe('Light Grid Display', () => {
    it('should display enabled lights in grid', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Available',
          color: '#00ff00',
          enabled: true,
          priority: 1,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      expect(screen.getByText('Urgent')).toBeInTheDocument();
      expect(screen.getByText('Available')).toBeInTheDocument();
    });

    it('should filter out disabled lights', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Disabled',
          color: '#0000ff',
          enabled: false,
          priority: 1,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      expect(screen.getByText('Urgent')).toBeInTheDocument();
      expect(screen.queryByText('Disabled')).not.toBeInTheDocument();
    });

    it('should filter out black lights', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Off',
          color: '#000000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Available',
          color: '#00ff00',
          enabled: true,
          priority: 1,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      expect(screen.queryByText('Off')).not.toBeInTheDocument();
      expect(screen.getByText('Available')).toBeInTheDocument();
    });

    it('should sort lights by priority', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Low',
          color: '#00ff00',
          enabled: true,
          priority: 2,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'High',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-3',
          name: 'Medium',
          color: '#ffff00',
          enabled: true,
          priority: 1,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightColorPicker, { note: '' });

      const buttons = container.querySelectorAll('button');
      const buttonTexts = Array.from(buttons).map((btn) => btn.textContent);

      // Should be in priority order: High (0), Medium (1), Low (2)
      expect(buttonTexts[0]).toContain('High');
      expect(buttonTexts[1]).toContain('Medium');
      expect(buttonTexts[2]).toContain('Low');
    });

    it('should handle empty lights array', () => {
      lights.set([]);

      const { container } = render(LightColorPicker, { note: '' });

      const buttons = container.querySelectorAll('button');
      expect(buttons.length).toBe(0);
    });

    it('should handle null lights', () => {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      lights.set(null as any);

      const { container } = render(LightColorPicker, { note: '' });

      const buttons = container.querySelectorAll('button');
      expect(buttons.length).toBe(0);
    });
  });

  describe('Active Light Styling', () => {
    it('should show active styling when light matches myLightColor', () => {
      const now = Date.now();
      myLightColor.set('#ff0000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightColorPicker, { note: '' });

      const button = screen.getByLabelText(/Turn off Urgent/i);
      expect(button).toBeInTheDocument();

      // Check for pulsing animation
      const pulsingElement = container.querySelector('.animate-ping');
      expect(pulsingElement).toBeInTheDocument();
    });

    it('should show inactive styling when light does not match myLightColor', () => {
      const now = Date.now();
      myLightColor.set('#00ff00');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      const button = screen.getByLabelText(/Set light to Urgent/i);
      expect(button).toBeInTheDocument();
    });

    it('should display note on active light only', () => {
      const now = Date.now();
      myLightColor.set('#ff0000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Available',
          color: '#00ff00',
          enabled: true,
          priority: 1,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: 'In a meeting' });

      // Note should appear with quotes
      expect(screen.getByText('"In a meeting"')).toBeInTheDocument();
    });

    it('should not display note on inactive lights', () => {
      const now = Date.now();
      myLightColor.set('#000000'); // Off, so all lights inactive
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: 'In a meeting' });

      expect(screen.queryByText('"In a meeting"')).not.toBeInTheDocument();
    });

    it('should not display note if note is empty', () => {
      const now = Date.now();
      myLightColor.set('#ff0000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      // No quoted note should appear
      const button = screen.getByLabelText(/Turn off Urgent/i);
      expect(button.textContent).not.toContain('"');
    });
  });

  describe('Light Selection', () => {
    it('should activate light when clicked', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      myLightColor.set('#000000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      const button = screen.getByLabelText(/Set light to Urgent/i);
      await user.click(button);

      await waitFor(() => {
        expect(screen.getByLabelText(/Turn off Urgent/i)).toBeInTheDocument();
      });
    });

    it('should toggle off when active light is clicked', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      myLightColor.set('#ff0000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      const button = screen.getByLabelText(/Turn off Urgent/i);
      await user.click(button);

      await waitFor(() => {
        expect(screen.getByLabelText(/Set light to Urgent/i)).toBeInTheDocument();
      });
    });

    it('should pass note to backend when changing light', async () => {
      const user = userEvent.setup();
      const now = Date.now();

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      let capturedPayload: any;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      mockIPC((cmd, payload: any) => {
        if (cmd === 'set_light_color') {
          capturedPayload = payload;
          myLightColor.set(payload.color);
          return null;
        }
        return null;
      });

      myLightColor.set('#000000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: 'Test note' });

      const button = screen.getByLabelText(/Set light to Urgent/i);
      await user.click(button);

      await waitFor(() => {
        expect(capturedPayload).toBeDefined();
        expect(capturedPayload.color).toBe('#ff0000');
        expect(capturedPayload.note).toBe('Test note');
      });
    });

    it('should trim note before sending to backend', async () => {
      const user = userEvent.setup();
      const now = Date.now();

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      let capturedPayload: any;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      mockIPC((cmd, payload: any) => {
        if (cmd === 'set_light_color') {
          capturedPayload = payload;
          myLightColor.set(payload.color);
          return null;
        }
        return null;
      });

      myLightColor.set('#000000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '  Test note  ' });

      const button = screen.getByLabelText(/Set light to Urgent/i);
      await user.click(button);

      await waitFor(() => {
        expect(capturedPayload.note).toBe('Test note');
      });
    });

    it('should send undefined or null for empty note', async () => {
      const user = userEvent.setup();
      const now = Date.now();

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      let capturedPayload: any;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      mockIPC((cmd, payload: any) => {
        if (cmd === 'set_light_color') {
          capturedPayload = payload;
          myLightColor.set(payload.color);
          return null;
        }
        return null;
      });

      myLightColor.set('#000000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      const button = screen.getByLabelText(/Set light to Urgent/i);
      await user.click(button);

      await waitFor(() => {
        // Should be undefined or null (both acceptable for empty note)
        expect(capturedPayload.note == null).toBe(true);
      });
    });

    it('should disable buttons during color change', async () => {
      const user = userEvent.setup();
      const now = Date.now();

      // Simulate slow backend
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      mockIPC(async (cmd, payload: any) => {
        if (cmd === 'set_light_color') {
          await new Promise((resolve) => setTimeout(resolve, 100));
          myLightColor.set(payload.color);
          return null;
        }
        return null;
      });

      myLightColor.set('#000000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      const button = screen.getByLabelText(/Set light to Urgent/i);

      // Click should work
      await user.click(button);

      // Button should be disabled during change
      expect(button).toBeDisabled();

      // Wait for change to complete
      await waitFor(
        () => {
          expect(button).not.toBeDisabled();
        },
        { timeout: 200 }
      );
    });
  });

  describe('Accessibility', () => {
    it('should have proper aria-labels for inactive lights', () => {
      const now = Date.now();
      myLightColor.set('#000000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      const button = screen.getByLabelText('Set light to Urgent');
      expect(button).toBeInTheDocument();
    });

    it('should have proper aria-labels for active lights', () => {
      const now = Date.now();
      myLightColor.set('#ff0000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      const button = screen.getByLabelText('Turn off Urgent');
      expect(button).toBeInTheDocument();
    });
  });

  describe('Edge Cases', () => {
    it('should handle undefined note prop', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      expect(() => {
        render(LightColorPicker);
      }).not.toThrow();
    });

    it('should handle backend error gracefully', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const consoleError = vi.spyOn(console, 'error').mockImplementation(() => {});

      mockIPC((cmd) => {
        if (cmd === 'set_light_color') {
          throw new Error('Backend error');
        }
        return null;
      });

      myLightColor.set('#000000');
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightColorPicker, { note: '' });

      const button = screen.getByLabelText(/Set light to Urgent/i);
      await user.click(button);

      await waitFor(() => {
        expect(consoleError).toHaveBeenCalled();
      });

      consoleError.mockRestore();
    });
  });
});
