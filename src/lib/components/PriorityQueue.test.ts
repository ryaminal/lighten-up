import { render, screen, waitFor } from '@testing-library/svelte';
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import userEvent from '@testing-library/user-event';
import { peers, lights } from '../stores';
import { mockIPC, clearMocks } from '@tauri-apps/api/mocks';
import PriorityQueue from './PriorityQueue.svelte';

// Mock the event listener API
vi.mock('@tauri-apps/api/event', () => ({
  listen: vi.fn(() => Promise.resolve(() => {})),
}));

describe('PriorityQueue', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    peers.set([]);
    lights.set([]);

    mockIPC(() => null);
  });

  afterEach(() => {
    clearMocks();
  });

  describe('Peer List Display', () => {
    it('should display peers with name, note, and time', async () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: 'In a meeting',
          light_state: {
            color: '#ff0000',
            timestamp: now - 300,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      render(PriorityQueue);

      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(screen.getByText('In a meeting')).toBeInTheDocument();
      expect(screen.getByText('5m ago')).toBeInTheDocument();
    });

    it('should show light name when note is empty', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Bob',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now - 60,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      expect(screen.getByText('Bob')).toBeInTheDocument();
      // Check that Urgent appears (both as badge and as note text)
      const urgentElements = container.querySelectorAll('*');
      const hasUrgent = Array.from(urgentElements).some((el) => el.textContent?.includes('Urgent'));
      expect(hasUrgent).toBe(true);
    });

    it('should show priority badge when light is on', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: 'Busy',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      // Check for priority badge specifically (in a span with the badge classes)
      const badge = container.querySelector('span.bg-orange-100');
      expect(badge).toBeInTheDocument();
      expect(badge?.textContent).toContain('Urgent');
    });

    it('should not show priority badge when light is off', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: 'Available',
          light_state: {
            color: '#000000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([]);

      render(PriorityQueue);

      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(screen.queryByText('Critical')).not.toBeInTheDocument();
      expect(screen.queryByText('Urgent')).not.toBeInTheDocument();
    });
  });

  describe('Empty State', () => {
    it('should show empty state when no peers online', () => {
      peers.set([]);

      render(PriorityQueue);

      expect(screen.getByText('No peers online...')).toBeInTheDocument();
    });

    it('should show 0 active in header', () => {
      peers.set([]);

      render(PriorityQueue);

      expect(screen.getByText(/0 Active/i)).toBeInTheDocument();
    });
  });

  describe('Priority Sorting', () => {
    it('should sort by priority by default (lowest number first)', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Charlie',
          note: '',
          light_state: {
            color: '#00ff00',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
        {
          peer_id: 'peer-2',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
        {
          peer_id: 'peer-3',
          peer_name: 'Bob',
          note: '',
          light_state: {
            color: '#ffff00',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Low',
          color: '#00ff00',
          enabled: true,
          priority: 4,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Critical',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
        {
          id: 'light-3',
          name: 'High',
          color: '#ffff00',
          enabled: true,
          priority: 2,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      const peerCards = container.querySelectorAll('[role="button"]');
      const names = Array.from(peerCards).map((card) => card.textContent);

      // Should be ordered: Alice (priority 0), Bob (priority 2), Charlie (priority 4)
      expect(names[0]).toContain('Alice');
      expect(names[1]).toContain('Bob');
      expect(names[2]).toContain('Charlie');
    });

    it('should sort by timestamp for same priority (oldest first)', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Charlie',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now - 100,
          },
          notification_status: null,
          last_seen: now,
        },
        {
          peer_id: 'peer-2',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now - 300,
          },
          notification_status: null,
          last_seen: now,
        },
        {
          peer_id: 'peer-3',
          peer_name: 'Bob',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now - 200,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      const peerCards = container.querySelectorAll('[role="button"]');
      const names = Array.from(peerCards).map((card) => card.textContent);

      // Same priority, so ordered by time: Alice (oldest), Bob, Charlie (newest)
      expect(names[0]).toContain('Alice');
      expect(names[1]).toContain('Bob');
      expect(names[2]).toContain('Charlie');
    });

    it('should show Priority badge in header by default', () => {
      peers.set([]);

      render(PriorityQueue);

      expect(screen.getByText('Priority')).toBeInTheDocument();
    });

    it('should give off status (#000000) lowest priority', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Off',
          note: '',
          light_state: {
            color: '#000000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
        {
          peer_id: 'peer-2',
          peer_name: 'On',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 5,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      const peerCards = container.querySelectorAll('[role="button"]');
      const names = Array.from(peerCards).map((card) => card.textContent);

      // "On" should come first despite higher priority number, because "Off" has priority 1000
      expect(names[0]).toContain('On');
      expect(names[1]).toContain('Off');
    });
  });

  describe('Alphabetical Sorting', () => {
    it('should sort alphabetically when toggle clicked', async () => {
      const user = userEvent.setup();
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Charlie',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
        {
          peer_id: 'peer-2',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#00ff00',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
        {
          peer_id: 'peer-3',
          peer_name: 'Bob',
          note: '',
          light_state: {
            color: '#ffff00',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Critical',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Low',
          color: '#00ff00',
          enabled: true,
          priority: 4,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
        {
          id: 'light-3',
          name: 'High',
          color: '#ffff00',
          enabled: true,
          priority: 2,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      const sortButton = screen.getByLabelText('Sort alphabetically');
      await user.click(sortButton);

      await waitFor(() => {
        const peerCards = container.querySelectorAll('[role="button"]');
        const names = Array.from(peerCards).map((card) => card.textContent);

        // Should be A-Z: Alice, Bob, Charlie
        expect(names[0]).toContain('Alice');
        expect(names[1]).toContain('Bob');
        expect(names[2]).toContain('Charlie');
      });
    });

    it('should show A-Z text in header when alphabetical', async () => {
      const user = userEvent.setup();
      peers.set([]);

      const { container } = render(PriorityQueue);

      const sortButton = screen.getByLabelText('Sort alphabetically');
      await user.click(sortButton);

      await waitFor(
        () => {
          const pElement = container.querySelector('p.text-xs');
          expect(pElement?.textContent).toContain('A-Z');
        },
        { timeout: 3000 }
      );
    });

    it('should change button aria-label when toggled', async () => {
      const user = userEvent.setup();
      peers.set([]);

      render(PriorityQueue);

      const sortButton = screen.getByLabelText('Sort alphabetically');
      await user.click(sortButton);

      await waitFor(() => {
        expect(screen.getByLabelText('Sort by priority')).toBeInTheDocument();
      });
    });

    it('should toggle back to priority sort', async () => {
      const user = userEvent.setup();
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Charlie',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
        {
          peer_id: 'peer-2',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#00ff00',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Critical',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Low',
          color: '#00ff00',
          enabled: true,
          priority: 4,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      let sortButton = screen.getByLabelText('Sort alphabetically');
      await user.click(sortButton);

      await waitFor(() => {
        const peerCards = container.querySelectorAll('[role="button"]');
        const names = Array.from(peerCards).map((card) => card.textContent);
        expect(names[0]).toContain('Alice');
      });

      sortButton = screen.getByLabelText('Sort by priority');
      await user.click(sortButton);

      await waitFor(() => {
        const peerCards = container.querySelectorAll('[role="button"]');
        const names = Array.from(peerCards).map((card) => card.textContent);
        // Back to priority: Charlie (priority 0) first
        expect(names[0]).toContain('Charlie');
      });
    });
  });

  describe('Time Display', () => {
    it('should format time in seconds', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now - 30,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([]);

      render(PriorityQueue);

      expect(screen.getByText('30s ago')).toBeInTheDocument();
    });

    it('should format time in minutes', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now - 180,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([]);

      render(PriorityQueue);

      expect(screen.getByText('3m ago')).toBeInTheDocument();
    });

    it('should format time in hours', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now - 7200,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([]);

      render(PriorityQueue);

      expect(screen.getByText('2h ago')).toBeInTheDocument();
    });

    it('should format time in days', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now - 172800,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([]);

      render(PriorityQueue);

      expect(screen.getByText('2d ago')).toBeInTheDocument();
    });

    it('should update time every second', async () => {
      vi.useFakeTimers();
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now - 59,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([]);

      render(PriorityQueue);

      expect(screen.getByText('59s ago')).toBeInTheDocument();

      // Advance time by 1 second
      vi.advanceTimersByTime(1000);

      await waitFor(() => {
        expect(screen.getByText('1m ago')).toBeInTheDocument();
      });

      vi.useRealTimers();
    });
  });

  describe('Priority Badges', () => {
    it('should show Critical badge for priority 0', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: 'Working',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Critical',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      const badge = container.querySelector('span.bg-red-100');
      expect(badge).toBeInTheDocument();
      expect(badge?.textContent).toContain('Critical');
    });

    it('should show Urgent badge for priority 1', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: 'Working',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      const badge = container.querySelector('span.bg-orange-100');
      expect(badge).toBeInTheDocument();
      expect(badge?.textContent).toContain('Urgent');
    });

    it('should show High badge for priority 2', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: 'Working',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'High',
          color: '#ff0000',
          enabled: true,
          priority: 2,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      const badge = container.querySelector('span.bg-yellow-100');
      expect(badge).toBeInTheDocument();
      expect(badge?.textContent).toContain('High');
    });

    it('should show Medium badge for priority 3', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: 'Working',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Medium',
          color: '#ff0000',
          enabled: true,
          priority: 3,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      const badge = container.querySelector('span.bg-blue-100');
      expect(badge).toBeInTheDocument();
      expect(badge?.textContent).toContain('Medium');
    });

    it('should show Low badge for priority >= 4', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: 'Working',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Low',
          color: '#ff0000',
          enabled: true,
          priority: 4,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(PriorityQueue);

      const badge = container.querySelector('span.bg-gray-100');
      expect(badge).toBeInTheDocument();
      expect(badge?.textContent).toContain('Low');
    });
  });

  describe('Notification Modal', () => {
    it('should open modal when peer clicked', async () => {
      const user = userEvent.setup();
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: 'Busy',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      render(PriorityQueue);

      const peerCard = screen.getByLabelText('Notify Alice that patient is ready');
      await user.click(peerCard);

      await waitFor(() => {
        expect(screen.getByRole('heading', { name: 'Send Notification' })).toBeInTheDocument();
        expect(screen.getByText('To: Alice')).toBeInTheDocument();
      });
    });

    it('should close modal when close button clicked', async () => {
      const user = userEvent.setup();
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      render(PriorityQueue);

      const peerCard = screen.getByLabelText('Notify Alice that patient is ready');
      await user.click(peerCard);

      await waitFor(() => {
        expect(screen.getByRole('heading', { name: 'Send Notification' })).toBeInTheDocument();
      });

      const closeButton = screen.getByLabelText('Close');
      await user.click(closeButton);

      await waitFor(() => {
        expect(
          screen.queryByRole('heading', { name: 'Send Notification' })
        ).not.toBeInTheDocument();
      });
    });

    it('should send notification with light name as default message', async () => {
      const user = userEvent.setup();
      const now = Math.floor(Date.now() / 1000);
      let capturedPayload: unknown;

      mockIPC((cmd, payload: unknown) => {
        if (cmd === 'send_notification') {
          capturedPayload = payload;
          return null;
        }
        return null;
      });

      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Available',
          color: '#00ff00',
          enabled: true,
          priority: 3,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      render(PriorityQueue);

      const peerCard = screen.getByLabelText('Notify Alice that patient is ready');
      await user.click(peerCard);

      await waitFor(() => {
        expect(screen.getByRole('heading', { name: 'Send Notification' })).toBeInTheDocument();
      });

      // Select a light
      const lightButton = screen.getByLabelText('Select Available');
      await user.click(lightButton);

      // Click send - find the actual button element, not the backdrop
      const sendButton = screen
        .getAllByRole('button', { name: /send notification/i })
        .find((btn) => btn.tagName === 'BUTTON');
      expect(sendButton).toBeDefined();
      await user.click(sendButton!);

      await waitFor(
        () => {
          expect(capturedPayload).toBeDefined();
        },
        { timeout: 3000 }
      );

      const payload = capturedPayload as Record<string, unknown>;
      expect(payload.targetPeerId).toBe('peer-1');
      expect(payload.notificationType).toBe('patient-ready');
      expect(payload.message).toBe('Available'); // Light name as default
      expect(payload.color).toBe('#00ff00');
    });

    it('should send notification with custom message', async () => {
      const user = userEvent.setup();
      const now = Math.floor(Date.now() / 1000);
      let capturedPayload: unknown;

      mockIPC((cmd, payload: unknown) => {
        if (cmd === 'send_notification') {
          capturedPayload = payload;
          return null;
        }
        return null;
      });

      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      render(PriorityQueue);

      const peerCard = screen.getByLabelText('Notify Alice that patient is ready');
      await user.click(peerCard);

      await waitFor(() => {
        expect(screen.getByRole('heading', { name: 'Send Notification' })).toBeInTheDocument();
      });

      // Enter custom message
      const input = screen.getByPlaceholderText('Enter patient name or message');
      await user.type(input, 'John Doe');

      // Select a light
      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      // Click send - find the actual button element, not the backdrop
      const sendButton = screen
        .getAllByRole('button', { name: /send notification/i })
        .find((btn) => btn.tagName === 'BUTTON');
      if (sendButton) {
        await user.click(sendButton);
      }

      await waitFor(() => {
        expect(capturedPayload).toBeDefined();
        const payload = capturedPayload as Record<string, unknown>;
        expect(payload.message).toBe('John Doe'); // Custom message
      });
    });
  });

  describe('Keyboard Navigation', () => {
    it('should open modal on Enter key', async () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      render(PriorityQueue);

      const peerCard = screen.getByLabelText('Notify Alice that patient is ready');
      peerCard.focus();
      peerCard.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', bubbles: true }));

      await waitFor(() => {
        expect(screen.getByRole('heading', { name: 'Send Notification' })).toBeInTheDocument();
      });
    });
  });

  describe('Edge Cases', () => {
    it('should handle null peers', () => {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      peers.set(null as any);
      lights.set([]);

      expect(() => {
        render(PriorityQueue);
      }).not.toThrow();

      expect(screen.getByText('No peers online...')).toBeInTheDocument();
    });

    it('should handle null lights', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      lights.set(null as any);

      expect(() => {
        render(PriorityQueue);
      }).not.toThrow();

      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(screen.getByText('Unknown')).toBeInTheDocument();
    });

    it('should handle light not found', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Available',
          color: '#00ff00',
          enabled: true,
          priority: 3,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      render(PriorityQueue);

      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(screen.getByText('Unknown')).toBeInTheDocument();
    });

    it('should handle disabled light', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          note: '',
          light_state: {
            color: '#ff0000',
            timestamp: now,
          },
          notification_status: null,
          last_seen: now,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: false,
          priority: 1,
          updated_at: now * 1000,
          updated_by: 'peer-1',
        },
      ]);

      render(PriorityQueue);

      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(screen.getByText('Unknown')).toBeInTheDocument();
    });
  });
});
