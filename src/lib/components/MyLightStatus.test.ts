import { render, screen, waitFor } from '@testing-library/svelte';
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import userEvent from '@testing-library/user-event';
import { myPeerName, myLightColor, myNote, lights } from '../stores';
import { mockIPC, clearMocks } from '@tauri-apps/api/mocks';
import MyLightStatus from './MyLightStatus.svelte';

// Mock the event listener API
vi.mock('@tauri-apps/api/event', () => ({
  listen: vi.fn(() => Promise.resolve(() => {})),
}));

describe('MyLightStatus', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    myPeerName.set('Test User');
    myLightColor.set('#000000');
    myNote.set('');
    lights.set([]);

    mockIPC((cmd, payload: any) => {
      if (cmd === 'set_light_color') {
        // Simulate successful save
        myNote.set(payload.note || '');
        return null;
      }
      return null;
    });
  });

  afterEach(() => {
    clearMocks();
  });

  describe('Peer Name Display', () => {
    it('should display peer name', () => {
      myPeerName.set('Alice');

      render(MyLightStatus);

      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    it('should show "Loading..." when peer name is empty', () => {
      myPeerName.set('');

      render(MyLightStatus);

      expect(screen.getByText('Loading...')).toBeInTheDocument();
    });
  });

  describe('Status Display - Off State', () => {
    it('should show "Status: OFF" when light is black', () => {
      myLightColor.set('#000000');

      render(MyLightStatus);

      expect(screen.getByText('Status: OFF')).toBeInTheDocument();
    });

    it('should not show pulsing animation when light is off', () => {
      myLightColor.set('#000000');

      const { container } = render(MyLightStatus);

      const pulsingElements = container.querySelectorAll('.animate-ping');
      expect(pulsingElements.length).toBe(0);
    });

    it('should not show light name in status when light is off', () => {
      myLightColor.set('#000000');
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

      const { container } = render(MyLightStatus);

      // Check that light name is NOT in the status section (should only be in color picker grid)
      const statusSection = container.querySelector('.flex.items-center.gap-2');
      expect(statusSection?.textContent).not.toContain('Urgent');
      expect(statusSection?.textContent).toContain('Status: OFF');
    });
  });

  describe('Status Display - Active State', () => {
    it('should show pulsing animation when light is active', () => {
      myLightColor.set('#ff0000');

      const { container } = render(MyLightStatus);

      const pulsingElement = container.querySelector('.animate-ping');
      expect(pulsingElement).toBeInTheDocument();
    });

    it('should not show "Status: OFF" when light is active', () => {
      myLightColor.set('#ff0000');

      render(MyLightStatus);

      expect(screen.queryByText('Status: OFF')).not.toBeInTheDocument();
    });

    it('should show light name in status when light matches enabled light', () => {
      myLightColor.set('#ff0000');
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

      const { container } = render(MyLightStatus);

      // Check that light name appears in the status section
      const statusSection = container.querySelector('.flex.items-center.gap-2');
      expect(statusSection?.textContent).toContain('Urgent');
      expect(screen.getAllByText('Urgent').length).toBeGreaterThanOrEqual(1);
    });

    it('should not show light name when light is disabled', () => {
      myLightColor.set('#ff0000');
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: false,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(MyLightStatus);

      expect(screen.queryByText('Urgent')).not.toBeInTheDocument();
    });

    it('should not show light name in status when no matching color', () => {
      myLightColor.set('#ff0000');
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#00ff00', // Different color
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(MyLightStatus);

      // Check that light name is NOT in the status section (not matching color)
      const statusSection = container.querySelector('.flex.items-center.gap-2');
      expect(statusSection?.textContent).not.toContain('Urgent');
    });

    it('should display status message when present', () => {
      myLightColor.set('#ff0000');
      myNote.set('Working on feature');

      render(MyLightStatus);

      expect(screen.getByText('Working on feature')).toBeInTheDocument();
    });

    it('should not display status message when empty', () => {
      myLightColor.set('#ff0000');
      myNote.set('');

      const { container } = render(MyLightStatus);

      // Check that there's no status message paragraph
      const statusMessages = Array.from(container.querySelectorAll('p')).filter((p) =>
        p.textContent?.includes('Working')
      );
      expect(statusMessages.length).toBe(0);
    });

    it('should display both light name and status message in status section', () => {
      myLightColor.set('#ff0000');
      myNote.set('In a meeting');
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Busy',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(MyLightStatus);

      // Check that both light name and message appear in the status section
      const statusSection = container.querySelector('.flex.items-center.gap-2');
      expect(statusSection?.textContent).toContain('Busy');
      expect(statusSection?.textContent).toContain('In a meeting');
      expect(screen.getAllByText('Busy').length).toBeGreaterThanOrEqual(1);
      expect(screen.getByText('In a meeting')).toBeInTheDocument();
    });
  });

  describe('Note Input', () => {
    it('should display note input field', () => {
      render(MyLightStatus);

      const input = screen.getByPlaceholderText(/Add a custom message/);
      expect(input).toBeInTheDocument();
    });

    it('should display "Light Selection & Message" header', () => {
      render(MyLightStatus);

      expect(screen.getByText('Light Selection & Message')).toBeInTheDocument();
    });

    it('should sync note input with store value', () => {
      myNote.set('Test note');

      render(MyLightStatus);

      const input = screen.getByPlaceholderText(/Add a custom message/) as HTMLInputElement;
      expect(input.value).toBe('Test note');
    });

    it('should update note input when user types', async () => {
      const user = userEvent.setup();
      render(MyLightStatus);

      const input = screen.getByPlaceholderText(/Add a custom message/);
      await user.type(input, 'New note');

      await waitFor(() => {
        expect((input as HTMLInputElement).value).toBe('New note');
      });
    });

    it('should auto-save note after 500ms of no typing', async () => {
      vi.useFakeTimers();
      const user = userEvent.setup({ delay: null });
      myLightColor.set('#ff0000');
      render(MyLightStatus);

      const input = screen.getByPlaceholderText(/Add a custom message/);
      await user.type(input, 'Auto-save test');

      // Fast-forward time by 500ms
      vi.advanceTimersByTime(500);

      await waitFor(() => {
        expect(myNote.subscribe).toBeDefined();
      });

      vi.useRealTimers();
    });

    it('should enforce max note length of 60 characters', async () => {
      const user = userEvent.setup();
      render(MyLightStatus);

      const longNote = 'a'.repeat(70);
      const input = screen.getByPlaceholderText(/Add a custom message/);
      await user.type(input, longNote);

      await waitFor(() => {
        const inputElement = input as HTMLInputElement;
        expect(inputElement.value.length).toBeLessThanOrEqual(60);
      });
    });

    it('should trim note before saving', async () => {
      vi.useFakeTimers();
      const user = userEvent.setup({ delay: null });
      myLightColor.set('#ff0000');

      let savedNote: string | undefined;
      mockIPC((cmd, payload: any) => {
        if (cmd === 'set_light_color') {
          savedNote = payload.note;
          return null;
        }
        return null;
      });

      render(MyLightStatus);

      const input = screen.getByPlaceholderText(/Add a custom message/);
      await user.type(input, '  Test note  ');

      vi.advanceTimersByTime(500);

      await waitFor(() => {
        expect(savedNote).toBeDefined();
      });

      vi.useRealTimers();
    });

    it('should debounce rapid typing', async () => {
      vi.useFakeTimers();
      const user = userEvent.setup({ delay: null });
      myLightColor.set('#ff0000');

      let saveCount = 0;
      mockIPC((cmd) => {
        if (cmd === 'set_light_color') {
          saveCount++;
          return null;
        }
        return null;
      });

      render(MyLightStatus);

      const input = screen.getByPlaceholderText(/Add a custom message/);

      // Type multiple characters rapidly
      await user.type(input, 'a');
      vi.advanceTimersByTime(100);
      await user.type(input, 'b');
      vi.advanceTimersByTime(100);
      await user.type(input, 'c');

      // Wait for debounce
      vi.advanceTimersByTime(500);

      // Should only save once after debounce period
      await waitFor(() => {
        expect(saveCount).toBe(1);
      });

      vi.useRealTimers();
    });
  });

  describe('Edge Cases', () => {
    it('should handle undefined lights', () => {
      lights.set(undefined as any);
      myLightColor.set('#ff0000');

      render(MyLightStatus);

      // Should not crash, just not show light name
      expect(screen.queryByText('Urgent')).not.toBeInTheDocument();
    });

    it('should handle null myNote', () => {
      myNote.set(null as any);

      render(MyLightStatus);

      const input = screen.getByPlaceholderText(/Add a custom message/) as HTMLInputElement;
      expect(input.value).toBe('');
    });

    it('should handle undefined myNote', () => {
      myNote.set(undefined as any);

      render(MyLightStatus);

      const input = screen.getByPlaceholderText(/Add a custom message/) as HTMLInputElement;
      expect(input.value).toBe('');
    });

    it('should handle null myPeerName', () => {
      myPeerName.set(null as any);

      render(MyLightStatus);

      expect(screen.getByText('Loading...')).toBeInTheDocument();
    });
  });
});
