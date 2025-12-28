import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { mockIPC, clearMocks } from '@tauri-apps/api/mocks';
import * as tauri from './tauri';

describe('Tauri Commands', () => {
  beforeEach(() => {
    mockIPC((cmd, _payload) => {
      // Mock responses for different commands
      switch (cmd) {
        case 'get_my_peer_name':
          return 'Test Peer';
        case 'get_my_peer_id':
          return 'peer-123';
        case 'get_peers':
          return [
            {
              peer_id: 'peer-1',
              peer_name: 'Peer 1',
              light_state: { color: 'red', timestamp: 1000 },
              note: null,
              last_seen: 1000,
              notification_status: null,
            },
          ];
        case 'get_lights':
          return [
            {
              id: 'light-1',
              color: 'blue',
              name: 'Room 1',
              enabled: true,
              priority: 1,
              updated_at: 1000,
              updated_by: 'peer-1',
            },
          ];
        case 'get_chat_messages':
          return [
            {
              id: 'msg-1',
              peer_id: 'peer-1',
              peer_name: 'Peer 1',
              content: 'Hello',
              timestamp: 1000,
            },
          ];
        default:
          return null;
      }
    });
  });

  afterEach(() => {
    clearMocks();
  });

  describe('Peer Management', () => {
    it('getMyPeerName returns peer name', async () => {
      const name = await tauri.getMyPeerName();
      expect(name).toBe('Test Peer');
    });

    it('getMyPeerId returns peer id', async () => {
      const id = await tauri.getMyPeerId();
      expect(id).toBe('peer-123');
    });

    it('setPeerName invokes command with name', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'set_peer_name') {
          spy(payload);
        }
      });

      await tauri.setPeerName('New Name');

      expect(spy).toHaveBeenCalledWith({ name: 'New Name' });
    });

    it('getPeers returns array of peer presence', async () => {
      const peers = await tauri.getPeers();

      expect(peers).toHaveLength(1);
      expect(peers[0].peer_id).toBe('peer-1');
      expect(peers[0].peer_name).toBe('Peer 1');
      expect(peers[0].light_state.color).toBe('red');
    });
  });

  describe('Light Management', () => {
    it('setLightColor invokes command with color and note', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'set_light_color') {
          spy(payload);
        }
      });

      await tauri.setLightColor('green', 'Busy');

      expect(spy).toHaveBeenCalledWith({ color: 'green', note: 'Busy' });
    });

    it('setLightColor converts undefined note to null', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'set_light_color') {
          spy(payload);
        }
      });

      await tauri.setLightColor('green');

      expect(spy).toHaveBeenCalledWith({ color: 'green', note: null });
    });

    it('getLights returns array of light configs', async () => {
      const lights = await tauri.getLights();

      expect(lights).toHaveLength(1);
      expect(lights[0].id).toBe('light-1');
      expect(lights[0].name).toBe('Room 1');
      expect(lights[0].color).toBe('blue');
    });

    it('createLight invokes command with light config', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'create_light') {
          spy(payload);
        }
      });

      const light = {
        id: 'light-2',
        color: 'yellow',
        name: 'Room 2',
        enabled: true,
        priority: 2,
        updated_at: 2000,
        updated_by: 'peer-2',
      };

      await tauri.createLight(light);

      expect(spy).toHaveBeenCalledWith({ light });
    });

    it('updateLight invokes command with light config', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'update_light') {
          spy(payload);
        }
      });

      const light = {
        id: 'light-1',
        color: 'purple',
        name: 'Room 1 Updated',
        enabled: false,
        priority: 3,
        updated_at: 3000,
        updated_by: 'peer-3',
      };

      await tauri.updateLight(light);

      expect(spy).toHaveBeenCalledWith({ light });
    });

    it('deleteLight invokes command with id', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'delete_light') {
          spy(payload);
        }
      });

      await tauri.deleteLight('light-1');

      expect(spy).toHaveBeenCalledWith({ id: 'light-1' });
    });
  });

  describe('Chat Management', () => {
    it('sendChatMessage invokes command with content', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'send_chat_message') {
          spy(payload);
        }
      });

      await tauri.sendChatMessage('Hello world');

      expect(spy).toHaveBeenCalledWith({ content: 'Hello world' });
    });

    it('getChatMessages returns array of messages', async () => {
      const messages = await tauri.getChatMessages();

      expect(messages).toHaveLength(1);
      expect(messages[0].id).toBe('msg-1');
      expect(messages[0].content).toBe('Hello');
    });

    it('editChatMessage invokes command with id and content', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'edit_chat_message') {
          spy(payload);
        }
      });

      await tauri.editChatMessage('msg-1', 'Updated content');

      expect(spy).toHaveBeenCalledWith({ id: 'msg-1', content: 'Updated content' });
    });

    it('deleteChatMessage invokes command with id', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'delete_chat_message') {
          spy(payload);
        }
      });

      await tauri.deleteChatMessage('msg-1');

      expect(spy).toHaveBeenCalledWith({ id: 'msg-1' });
    });
  });

  describe('Notification Management', () => {
    it('sendNotification invokes command with all parameters', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'send_notification') {
          spy(payload);
        }
      });

      await tauri.sendNotification(
        'peer-2',
        'patient-ready',
        'Patient ready in room 1',
        'high',
        'red'
      );

      expect(spy).toHaveBeenCalledWith({
        targetPeerId: 'peer-2',
        notificationType: 'patient-ready',
        message: 'Patient ready in room 1',
        priority: 'high',
        color: 'red',
      });
    });

    it('sendNotification handles optional parameters', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'send_notification') {
          spy(payload);
        }
      });

      await tauri.sendNotification('peer-2', 'urgent-assist', 'Help needed');

      expect(spy).toHaveBeenCalledWith({
        targetPeerId: 'peer-2',
        notificationType: 'urgent-assist',
        message: 'Help needed',
        priority: undefined,
        color: undefined,
      });
    });

    it('sendPatientNotification invokes command with target and patient name', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'send_patient_notification') {
          spy(payload);
        }
      });

      await tauri.sendPatientNotification('peer-2', 'John Doe');

      expect(spy).toHaveBeenCalledWith({
        targetPeerId: 'peer-2',
        patientName: 'John Doe',
      });
    });

    it('clearNotification invokes command with peer id', async () => {
      const spy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'clear_notification') {
          spy(payload);
        }
      });

      await tauri.clearNotification('peer-2');

      expect(spy).toHaveBeenCalledWith({ peerId: 'peer-2' });
    });
  });
});

describe('Event Listeners', () => {
  afterEach(async () => {
    await tauri.cleanupListeners();
    clearMocks();
  });

  // Note: Event listener tests are skipped because Tauri's mocking doesn't fully support
  // the `listen` API in a unit test environment. These functions are integration-tested
  // through the actual application running in the Tauri runtime.

  it('cleanupListeners can be called multiple times', async () => {
    await tauri.cleanupListeners();
    await tauri.cleanupListeners();

    // Should not throw
  });
});
