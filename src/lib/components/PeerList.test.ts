import { render, screen } from '@testing-library/svelte';
import { describe, it, expect, beforeEach } from 'vitest';
import { peers, lights } from '../stores';
import PeerList from './PeerList.svelte';

describe('PeerList', () => {
  beforeEach(() => {
    peers.set([]);
    lights.set([]);
  });

  describe('Empty State', () => {
    it('should show "Searching for peers..." when no peers', () => {
      peers.set([]);
      lights.set([]);

      render(PeerList);

      expect(screen.getByText('Searching for peers...')).toBeInTheDocument();
    });

    it('should show "0 Active" badge when no peers', () => {
      peers.set([]);
      lights.set([]);

      render(PeerList);

      expect(screen.getByText('0 Active')).toBeInTheDocument();
    });
  });

  describe('Peer Display', () => {
    it('should display peer name', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          light_state: { color: '#ff0000', timestamp: now },
          last_seen: now - 10,
          note: null,
          notification_status: null,
        },
      ]);
      lights.set([]);

      render(PeerList);

      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    it('should display peer count correctly', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          light_state: { color: '#ff0000', timestamp: now },
          last_seen: now,
          note: null,
          notification_status: null,
        },
        {
          peer_id: 'peer-2',
          peer_name: 'Bob',
          light_state: { color: '#00ff00', timestamp: now },
          last_seen: now,
          note: null,
          notification_status: null,
        },
      ]);
      lights.set([]);

      render(PeerList);

      expect(screen.getByText('2 Active')).toBeInTheDocument();
    });

    it('should display peer note if present', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          light_state: { color: '#ff0000', timestamp: now },
          last_seen: now,
          note: 'Working on frontend',
          notification_status: null,
        },
      ]);
      lights.set([]);

      render(PeerList);

      expect(screen.getByText('Working on frontend')).toBeInTheDocument();
    });

    it('should not display note section if note is null', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          light_state: { color: '#ff0000', timestamp: now },
          last_seen: now,
          note: null,
          notification_status: null,
        },
      ]);
      lights.set([]);

      const { container } = render(PeerList);

      // Should only have one paragraph (empty state text or peer name)
      const paragraphs = container.querySelectorAll('p');
      expect(paragraphs.length).toBe(0); // No note paragraph
    });
  });

  describe('Light Name Display', () => {
    it('should display light name when color matches enabled light', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          light_state: { color: '#ff0000', timestamp: now },
          last_seen: now,
          note: null,
          notification_status: null,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 1,
          updated_at: Date.now(),
          updated_by: 'peer-1',
        },
      ]);

      render(PeerList);

      expect(screen.getByText('Urgent')).toBeInTheDocument();
    });

    it('should not display light name if light is disabled', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          light_state: { color: '#ff0000', timestamp: now },
          last_seen: now,
          note: null,
          notification_status: null,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: false,
          priority: 1,
          updated_at: Date.now(),
          updated_by: 'peer-1',
        },
      ]);

      render(PeerList);

      expect(screen.queryByText('Urgent')).not.toBeInTheDocument();
    });

    it('should not display light name if no matching color', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          light_state: { color: '#ff0000', timestamp: now },
          last_seen: now,
          note: null,
          notification_status: null,
        },
      ]);
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#00ff00', // Different color
          enabled: true,
          priority: 1,
          updated_at: Date.now(),
          updated_by: 'peer-1',
        },
      ]);

      render(PeerList);

      expect(screen.queryByText('Urgent')).not.toBeInTheDocument();
    });
  });

  describe('Time Elapsed Formatting', () => {
    it('should format time under 60 seconds correctly', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          light_state: { color: '#ff0000', timestamp: now },
          last_seen: now - 45, // 45 seconds ago
          note: null,
          notification_status: null,
        },
      ]);
      lights.set([]);

      render(PeerList);

      // Should display as 00:45 format
      expect(screen.getByText(/00:4[45]/)).toBeInTheDocument();
    });

    it('should format time over 60 seconds correctly', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          light_state: { color: '#ff0000', timestamp: now },
          last_seen: now - 125, // 2 minutes 5 seconds ago
          note: null,
          notification_status: null,
        },
      ]);
      lights.set([]);

      render(PeerList);

      // Should display as 02:05 format
      expect(screen.getByText(/02:0[45]/)).toBeInTheDocument();
    });
  });

  describe('Multiple Peers', () => {
    it('should display all peers in the list', () => {
      const now = Math.floor(Date.now() / 1000);
      peers.set([
        {
          peer_id: 'peer-1',
          peer_name: 'Alice',
          light_state: { color: '#ff0000', timestamp: now },
          last_seen: now,
          note: null,
          notification_status: null,
        },
        {
          peer_id: 'peer-2',
          peer_name: 'Bob',
          light_state: { color: '#00ff00', timestamp: now },
          last_seen: now,
          note: null,
          notification_status: null,
        },
        {
          peer_id: 'peer-3',
          peer_name: 'Charlie',
          light_state: { color: '#0000ff', timestamp: now },
          last_seen: now,
          note: null,
          notification_status: null,
        },
      ]);
      lights.set([]);

      render(PeerList);

      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(screen.getByText('Bob')).toBeInTheDocument();
      expect(screen.getByText('Charlie')).toBeInTheDocument();
      expect(screen.getByText('3 Active')).toBeInTheDocument();
    });
  });

  describe('UI Elements', () => {
    it('should display "Active Lights" header', () => {
      peers.set([]);
      lights.set([]);

      render(PeerList);

      expect(screen.getByText('Active Lights')).toBeInTheDocument();
    });

    it('should display sort dropdown', () => {
      peers.set([]);
      lights.set([]);

      render(PeerList);

      expect(screen.getByText('Sort by Priority')).toBeInTheDocument();
    });
  });
});
