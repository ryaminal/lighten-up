import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { get } from 'svelte/store';
import { clearMocks } from '@tauri-apps/api/mocks';
import {
  myPeerId,
  myPeerName,
  myLightColor,
  myNote,
  peers,
  lights,
  isLoading,
  error,
  notification,
  peerNotifications,
  updatePeers,
  setError,
  setLoading,
  setNotification,
  setPeerNotification,
  clearPeerNotification,
} from './stores';

describe('Store Initialization', () => {
  afterEach(() => {
    clearMocks();
  });

  it('initializes with default values', () => {
    expect(get(myPeerId)).toBe('');
    expect(get(myPeerName)).toBe('');
    expect(get(myLightColor)).toBe('#000000');
    expect(get(myNote)).toBe('');
    expect(get(peers)).toEqual([]);
    expect(get(lights)).toEqual([]);
    expect(get(isLoading)).toBe(true);
    expect(get(error)).toBeNull();
    expect(get(notification)).toBeNull();
    expect(get(peerNotifications)).toBeInstanceOf(Map);
    expect(get(peerNotifications).size).toBe(0);
  });
});

describe('updatePeers', () => {
  beforeEach(() => {
    peers.set([]);
  });

  afterEach(() => {
    clearMocks();
  });

  it('updates peers list', () => {
    const testPeers = [
      {
        peer_id: 'peer1',
        peer_name: 'Test Peer 1',
        light_state: { color: '#FF0000', timestamp: 123456 },
        note: null,
        last_seen: 123456,
        notification_status: null,
      },
    ];

    updatePeers(testPeers);
    expect(get(peers)).toEqual(testPeers);
  });

  it('replaces previous peers list', () => {
    const initialPeers = [
      {
        peer_id: 'peer1',
        peer_name: 'Initial Peer',
        light_state: { color: '#000000', timestamp: 100000 },
        note: null,
        last_seen: 100000,
        notification_status: null,
      },
    ];

    const updatedPeers = [
      {
        peer_id: 'peer2',
        peer_name: 'Updated Peer',
        light_state: { color: '#00FF00', timestamp: 200000 },
        note: 'test note',
        last_seen: 200000,
        notification_status: null,
      },
    ];

    updatePeers(initialPeers);
    expect(get(peers)).toEqual(initialPeers);

    updatePeers(updatedPeers);
    expect(get(peers)).toEqual(updatedPeers);
    expect(get(peers)).not.toEqual(initialPeers);
  });
});

describe('Error Handling', () => {
  afterEach(() => {
    clearMocks();
  });

  it('sets error message', () => {
    const errorMessage = 'Test error message';
    setError(errorMessage);
    expect(get(error)).toBe(errorMessage);
  });

  it('clears error message', () => {
    setError('Initial error');
    expect(get(error)).toBe('Initial error');

    setError(null);
    expect(get(error)).toBeNull();
  });
});

describe('Loading State', () => {
  afterEach(() => {
    clearMocks();
  });

  it('sets loading to true', () => {
    setLoading(false);
    setLoading(true);
    expect(get(isLoading)).toBe(true);
  });

  it('sets loading to false', () => {
    setLoading(true);
    setLoading(false);
    expect(get(isLoading)).toBe(false);
  });
});

describe('Notification Management', () => {
  afterEach(() => {
    clearMocks();
  });

  it('sets global notification', () => {
    const testNotification = {
      type: 'patient-ready' as const,
      message: 'Patient is ready',
      targetPeerId: 'peer1',
      timestamp: 123456,
    };

    setNotification(testNotification);
    expect(get(notification)).toEqual(testNotification);
  });

  it('clears global notification', () => {
    const testNotification = {
      type: 'room-ready' as const,
      message: 'Room is ready',
      targetPeerId: 'peer1',
      timestamp: 123456,
    };

    setNotification(testNotification);
    expect(get(notification)).toEqual(testNotification);

    setNotification(null);
    expect(get(notification)).toBeNull();
  });

  it('sets peer-specific notification', () => {
    const peerId = 'peer1';
    const testNotification = {
      type: 'urgent-assist' as const,
      message: 'Urgent assistance needed',
      targetPeerId: peerId,
      timestamp: 123456,
    };

    setPeerNotification(peerId, testNotification);

    const notifications = get(peerNotifications);
    expect(notifications.has(peerId)).toBe(true);
    expect(notifications.get(peerId)).toEqual(testNotification);
  });

  it('clears peer-specific notification', () => {
    const peerId = 'peer1';
    const testNotification = {
      type: 'general-message' as const,
      message: 'General message',
      targetPeerId: peerId,
      timestamp: 123456,
    };

    setPeerNotification(peerId, testNotification);
    expect(get(peerNotifications).has(peerId)).toBe(true);

    clearPeerNotification(peerId);
    expect(get(peerNotifications).has(peerId)).toBe(false);
  });

  it('manages multiple peer notifications independently', () => {
    const peer1 = 'peer1';
    const peer2 = 'peer2';

    const notification1 = {
      type: 'patient-ready' as const,
      message: 'Patient 1 ready',
      targetPeerId: peer1,
      timestamp: 123456,
    };

    const notification2 = {
      type: 'room-ready' as const,
      message: 'Room 2 ready',
      targetPeerId: peer2,
      timestamp: 123457,
    };

    setPeerNotification(peer1, notification1);
    setPeerNotification(peer2, notification2);

    const notifications = get(peerNotifications);
    expect(notifications.size).toBe(2);
    expect(notifications.get(peer1)).toEqual(notification1);
    expect(notifications.get(peer2)).toEqual(notification2);

    clearPeerNotification(peer1);
    expect(get(peerNotifications).size).toBe(1);
    expect(get(peerNotifications).has(peer2)).toBe(true);
    expect(get(peerNotifications).has(peer1)).toBe(false);
  });
});
