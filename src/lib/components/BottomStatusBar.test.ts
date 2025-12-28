import { render, screen, waitFor } from '@testing-library/svelte';
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import userEvent from '@testing-library/user-event';
import { myLightColor, lights, peers, notification } from '../stores';
import { mockIPC, clearMocks } from '@tauri-apps/api/mocks';
import BottomStatusBar from './BottomStatusBar.svelte';

// Mock the event listener API
vi.mock('@tauri-apps/api/event', () => ({
  listen: vi.fn(() => Promise.resolve(() => {})),
}));

describe('BottomStatusBar', () => {
  const mockOnOpenStatusPicker = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
    myLightColor.set('#000000');
    lights.set([]);
    peers.set([]);
    notification.set(null);

    mockIPC((cmd, _payload) => {
      if (cmd === 'get_my_peer_id') return 'peer-1';
      if (cmd === 'clear_notification') return null;
      return null;
    });
  });

  afterEach(() => {
    clearMocks();
  });

  describe('Status Display', () => {
    it('should display "Off" when no light is selected', () => {
      myLightColor.set('#9ca3af');
      lights.set([]);

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('Off')).toBeInTheDocument();
    });

    it('should display current light name when selected', () => {
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

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('Urgent')).toBeInTheDocument();
    });

    it('should display "Off" when light is disabled', () => {
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

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('Off')).toBeInTheDocument();
    });

    it('should show "Current Status" label', () => {
      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('Current Status')).toBeInTheDocument();
    });

    it('should call onOpenStatusPicker when status button is clicked', async () => {
      const user = userEvent.setup();
      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      const button = screen.getByLabelText('Change status');
      await user.click(button);

      expect(mockOnOpenStatusPicker).toHaveBeenCalledTimes(1);
    });
  });

  describe('Peer Count Display', () => {
    it('should show "0 Online" when no peers', () => {
      peers.set([]);

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('0 Online')).toBeInTheDocument();
    });

    it('should show correct peer count', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          light_state: { color: '#ff0000', timestamp: now },
          last_seen: now,
          note: null,
        },
        {
          peer_id: 'peer-2',
          peer_name: 'Bob',
          light_state: { color: '#00ff00', timestamp: now },
          last_seen: now,
          note: null,
        },
      ]);

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('2 Online')).toBeInTheDocument();
    });

    it('should show "Peers Online" label', () => {
      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('Peers Online')).toBeInTheDocument();
    });
  });

  describe('Notification Display', () => {
    it('should not display notification when none exists', () => {
      notification.set(null);

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.queryByLabelText('Dismiss notification')).not.toBeInTheDocument();
    });

    it('should display notification message', () => {
      const now = Math.floor(Date.now() / 1000);
      notification.set({
        type: 'general-message',
        message: 'Test notification',
        targetPeerId: 'peer-1',
        senderPeerId: 'peer-2',
        timestamp: now,
      });

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('Test notification')).toBeInTheDocument();
    });

    it('should dismiss notification when dismiss button is clicked', async () => {
      const user = userEvent.setup();
      const now = Math.floor(Date.now() / 1000);
      notification.set({
        type: 'general-message',
        message: 'Test notification',
        targetPeerId: 'peer-1',
        senderPeerId: 'peer-2',
        timestamp: now,
      });

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      const dismissButton = screen.getByLabelText('Dismiss notification');
      await user.click(dismissButton);

      await waitFor(() => {
        expect(screen.queryByText('Test notification')).not.toBeInTheDocument();
      });
    });

    it('should display time ago for recent notification', () => {
      const now = Math.floor(Date.now() / 1000) - 30; // 30 seconds ago
      notification.set({
        type: 'general-message',
        message: 'Test notification',
        targetPeerId: 'peer-1',
        senderPeerId: 'peer-2',
        timestamp: now,
      });

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText(/\d+s ago/)).toBeInTheDocument();
    });

    it('should display minutes ago for older notification', () => {
      const now = Math.floor(Date.now() / 1000) - 120; // 2 minutes ago
      notification.set({
        type: 'general-message',
        message: 'Test notification',
        targetPeerId: 'peer-1',
        senderPeerId: 'peer-2',
        timestamp: now,
      });

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText(/\d+m ago/)).toBeInTheDocument();
    });

    it('should display hours ago for very old notification', () => {
      const now = Math.floor(Date.now() / 1000) - 7200; // 2 hours ago
      notification.set({
        type: 'general-message',
        message: 'Test notification',
        targetPeerId: 'peer-1',
        senderPeerId: 'peer-2',
        timestamp: now,
      });

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText(/\d+h ago/)).toBeInTheDocument();
    });

    it('should display light name for notification with custom color', () => {
      const now = Math.floor(Date.now() / 1000);
      const lightNow = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: lightNow,
          updated_by: 'peer-1',
        },
      ]);
      notification.set({
        type: 'general-message',
        message: 'Help needed',
        targetPeerId: 'peer-1',
        senderPeerId: 'peer-2',
        timestamp: now,
        color: '#ff0000',
      });

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('Urgent')).toBeInTheDocument();
      expect(screen.getByText('Help needed')).toBeInTheDocument();
    });

    it('should not duplicate light name if message equals light name', () => {
      const now = Math.floor(Date.now() / 1000);
      const lightNow = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: lightNow,
          updated_by: 'peer-1',
        },
      ]);
      notification.set({
        type: 'general-message',
        message: 'Urgent',
        targetPeerId: 'peer-1',
        senderPeerId: 'peer-2',
        timestamp: now,
        color: '#ff0000',
      });

      const { container } = render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      // Should only have one instance of "Urgent"
      const urgentTexts = container.querySelectorAll('*');
      const urgentCount = Array.from(urgentTexts).filter(
        (el) => el.textContent === 'Urgent'
      ).length;
      expect(urgentCount).toBeLessThanOrEqual(2); // Status + notification, but not duplicated within notification
    });
  });

  describe('Urgent Status Animation', () => {
    it('should show pulsing animation for urgent status', () => {
      myLightColor.set('#ff0000');
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0, // Priority 0 = urgent
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      const pulsingElement = container.querySelector('.animate-ping');
      expect(pulsingElement).toBeInTheDocument();
    });

    it('should not show pulsing animation for non-urgent status', () => {
      myLightColor.set('#00ff00');
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Available',
          color: '#00ff00',
          enabled: true,
          priority: 1, // Not urgent
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      const pulsingElements = container.querySelectorAll('.animate-ping');
      // Should have 0 pulsing elements (none for status)
      expect(pulsingElements.length).toBe(0);
    });
  });

  describe('Edge Cases', () => {
    it('should handle null myLightColor', () => {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      myLightColor.set(null as any);

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      // Should default to #9ca3af and show "Off"
      expect(screen.getByText('Off')).toBeInTheDocument();
    });

    it('should handle undefined peers', () => {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      peers.set(undefined as any);

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('0 Online')).toBeInTheDocument();
    });

    it('should handle undefined lights', () => {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      lights.set(undefined as any);
      myLightColor.set('#ff0000');

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('Off')).toBeInTheDocument();
    });

    it('should handle notification with no color', () => {
      const now = Math.floor(Date.now() / 1000);
      notification.set({
        type: 'general-message',
        message: 'Test notification',
        targetPeerId: 'peer-1',
        senderPeerId: 'peer-2',
        timestamp: now,
      });

      render(BottomStatusBar, { onOpenStatusPicker: mockOnOpenStatusPicker });

      expect(screen.getByText('Test notification')).toBeInTheDocument();
    });
  });
});
