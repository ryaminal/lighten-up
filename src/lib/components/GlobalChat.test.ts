import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/svelte';
import { mockIPC, clearMocks } from '@tauri-apps/api/mocks';
import userEvent from '@testing-library/user-event';
import { peers, myPeerName } from '../stores';

// Mock the event listener API before importing the component
vi.mock('@tauri-apps/api/event', () => ({
  listen: vi.fn(() => Promise.resolve(() => {})),
}));

import GlobalChat from './GlobalChat.svelte';

describe('GlobalChat', () => {
  const mockMessages = [
    {
      id: 'msg-1',
      peer_id: 'peer-1',
      peer_name: 'Alice',
      content: 'Hello everyone!',
      timestamp: 1000000000,
    },
    {
      id: 'msg-2',
      peer_id: 'peer-2',
      peer_name: 'Bob',
      content: 'Hi Alice!',
      timestamp: 1000000060,
    },
  ];

  beforeEach(() => {
    mockIPC((cmd, _payload) => {
      switch (cmd) {
        case 'get_chat_messages':
          return mockMessages;
        case 'get_my_peer_id':
          return 'peer-1';
        case 'get_my_peer_name':
          return 'Alice';
        case 'send_chat_message':
        case 'edit_chat_message':
        case 'delete_chat_message':
          return null;
        default:
          return null;
      }
    });
  });

  afterEach(() => {
    clearMocks();
  });

  describe('Initial Rendering', () => {
    it('shows loading state initially', async () => {
      render(GlobalChat);

      expect(screen.getByText('Loading messages...')).toBeInTheDocument();
    });

    it('displays messages after loading', async () => {
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('Hello everyone!')).toBeInTheDocument();
      });

      expect(screen.getByText('Hi Alice!')).toBeInTheDocument();
    });

    it('shows empty state when no messages exist', async () => {
      mockIPC((cmd) => {
        if (cmd === 'get_chat_messages') return [];
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('No messages yet. Start the conversation!')).toBeInTheDocument();
      });
    });

    it('displays header with title', async () => {
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('Global Chat')).toBeInTheDocument();
      });
    });
  });

  describe('Message Display', () => {
    it('displays peer names correctly', async () => {
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('Alice')).toBeInTheDocument();
      });

      expect(screen.getByText('Bob')).toBeInTheDocument();
    });

    it('formats timestamps correctly', async () => {
      render(GlobalChat);

      await waitFor(() => {
        // Timestamps are formatted as locale time strings
        const timestamps = screen.getAllByText(/\d{1,2}:\d{2}/);
        expect(timestamps.length).toBeGreaterThan(0);
      });
    });

    it('applies different styling to own messages', async () => {
      render(GlobalChat);

      await waitFor(() => {
        const messages = screen.getAllByText(/Hello everyone!|Hi Alice!/);
        expect(messages).toHaveLength(2);
      });
    });
  });

  describe('Sending Messages', () => {
    it('sends message when send button is clicked', async () => {
      const sendSpy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'send_chat_message') {
          sendSpy(payload);
          return null;
        }
        if (cmd === 'get_chat_messages') return [];
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      const user = userEvent.setup();
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByPlaceholderText('Type your message...')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Type your message...');
      await user.type(input, 'Test message');

      const sendButton = screen.getByLabelText('Send message');
      await user.click(sendButton);

      expect(sendSpy).toHaveBeenCalledWith({ content: 'Test message' });
    });

    it('sends message on Enter key press', async () => {
      const sendSpy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'send_chat_message') {
          sendSpy(payload);
          return null;
        }
        if (cmd === 'get_chat_messages') return [];
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      const user = userEvent.setup();
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByPlaceholderText('Type your message...')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Type your message...');
      await user.type(input, 'Test message{Enter}');

      expect(sendSpy).toHaveBeenCalledWith({ content: 'Test message' });
    });

    it('does not send empty messages', async () => {
      const sendSpy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'send_chat_message') {
          sendSpy(payload);
          return null;
        }
        if (cmd === 'get_chat_messages') return [];
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      const user = userEvent.setup();
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByPlaceholderText('Type your message...')).toBeInTheDocument();
      });

      const sendButton = screen.getByLabelText('Send message');
      await user.click(sendButton);

      expect(sendSpy).not.toHaveBeenCalled();
    });

    it('trims whitespace from messages', async () => {
      const sendSpy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'send_chat_message') {
          sendSpy(payload);
          return null;
        }
        if (cmd === 'get_chat_messages') return [];
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      const user = userEvent.setup();
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByPlaceholderText('Type your message...')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Type your message...');
      await user.type(input, '  Test message  ');

      const sendButton = screen.getByLabelText('Send message');
      await user.click(sendButton);

      expect(sendSpy).toHaveBeenCalledWith({ content: 'Test message' });
    });

    it('clears input after sending message', async () => {
      mockIPC((cmd) => {
        if (cmd === 'get_chat_messages') return [];
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        if (cmd === 'send_chat_message') return null;
        return null;
      });

      const user = userEvent.setup();
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByPlaceholderText('Type your message...')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Type your message...') as HTMLTextAreaElement;
      await user.type(input, 'Test message');

      const sendButton = screen.getByLabelText('Send message');
      await user.click(sendButton);

      await waitFor(() => {
        expect(input.value).toBe('');
      });
    });
  });

  describe('Editing Messages', () => {
    it('enters edit mode when ArrowUp is pressed on empty input', async () => {
      mockIPC((cmd) => {
        if (cmd === 'get_chat_messages') return mockMessages;
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      const user = userEvent.setup();
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('Hello everyone!')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Type your message...') as HTMLTextAreaElement;
      await user.click(input);
      await user.keyboard('{ArrowUp}');

      await waitFor(() => {
        expect(screen.getByText('Editing message (clear to delete)')).toBeInTheDocument();
      });

      expect(input.value).toBe('Hello everyone!');
    });

    it('edits message when in edit mode and sends', async () => {
      const editSpy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'edit_chat_message') {
          editSpy(payload);
          return null;
        }
        if (cmd === 'get_chat_messages') return mockMessages;
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      const user = userEvent.setup();
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('Hello everyone!')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Type your message...') as HTMLTextAreaElement;
      await user.click(input);
      await user.keyboard('{ArrowUp}');

      await waitFor(() => {
        expect(input.value).toBe('Hello everyone!');
      });

      await user.clear(input);
      await user.type(input, 'Edited message');

      const sendButton = screen.getByLabelText('Send message');
      await user.click(sendButton);

      expect(editSpy).toHaveBeenCalledWith({
        id: 'msg-1',
        content: 'Edited message',
      });
    });

    it('deletes message when editing and content is cleared', async () => {
      const deleteSpy = vi.fn();
      mockIPC((cmd, payload) => {
        if (cmd === 'delete_chat_message') {
          deleteSpy(payload);
          return null;
        }
        if (cmd === 'get_chat_messages') return mockMessages;
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      const user = userEvent.setup();
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('Hello everyone!')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Type your message...') as HTMLTextAreaElement;
      await user.click(input);
      await user.keyboard('{ArrowUp}');

      await waitFor(() => {
        expect(input.value).toBe('Hello everyone!');
      });

      await user.clear(input);

      const sendButton = screen.getByLabelText('Send message');
      await user.click(sendButton);

      expect(deleteSpy).toHaveBeenCalledWith({ id: 'msg-1' });
    });

    it('cancels edit mode with Escape key', async () => {
      mockIPC((cmd) => {
        if (cmd === 'get_chat_messages') return mockMessages;
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      const user = userEvent.setup();
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('Hello everyone!')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Type your message...') as HTMLTextAreaElement;
      await user.click(input);
      await user.keyboard('{ArrowUp}');

      await waitFor(() => {
        expect(screen.getByText('Editing message (clear to delete)')).toBeInTheDocument();
      });

      await user.keyboard('{Escape}');

      await waitFor(() => {
        expect(screen.queryByText('Editing message (clear to delete)')).not.toBeInTheDocument();
      });

      expect(input.value).toBe('');
    });

    it('clears edit mode after successful edit', async () => {
      mockIPC((cmd) => {
        if (cmd === 'get_chat_messages') return mockMessages;
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        if (cmd === 'edit_chat_message') return null;
        return null;
      });

      const user = userEvent.setup();
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('Hello everyone!')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Type your message...') as HTMLTextAreaElement;
      await user.click(input);
      await user.keyboard('{ArrowUp}');

      await waitFor(() => {
        expect(input.value).toBe('Hello everyone!');
      });

      await user.type(input, ' edited');

      const sendButton = screen.getByLabelText('Send message');
      await user.click(sendButton);

      await waitFor(() => {
        expect(screen.queryByText('Editing message (clear to delete)')).not.toBeInTheDocument();
      });
    });
  });

  describe('Peer Name Updates', () => {
    it('displays updated peer name from store', async () => {
      mockIPC((cmd) => {
        if (cmd === 'get_chat_messages') return mockMessages;
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('Alice')).toBeInTheDocument();
      });

      // Update the store
      myPeerName.set('Alice Updated');

      await waitFor(() => {
        expect(screen.getByText('Alice Updated')).toBeInTheDocument();
      });
    });

    it('uses peer name from peers store for other users', async () => {
      mockIPC((cmd) => {
        if (cmd === 'get_chat_messages') return mockMessages;
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('Bob')).toBeInTheDocument();
      });

      // Update peers store with new name
      peers.set([
        {
          peer_id: 'peer-2',
          peer_name: 'Bob Updated',
          light_state: { color: 'red', timestamp: 1000 },
          note: null,
          last_seen: 1000,
          notification_status: null,
        },
      ]);

      await waitFor(() => {
        expect(screen.getByText('Bob Updated')).toBeInTheDocument();
      });
    });

    it('falls back to message peer name when peer not in store', async () => {
      mockIPC((cmd) => {
        if (cmd === 'get_chat_messages') return mockMessages;
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      peers.set([]);

      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByText('Bob')).toBeInTheDocument();
      });
    });
  });

  describe('Error Handling', () => {
    it('handles load error gracefully', async () => {
      mockIPC((cmd) => {
        if (cmd === 'get_chat_messages') throw new Error('Load failed');
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        return null;
      });

      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});

      render(GlobalChat);

      await waitFor(() => {
        expect(consoleSpy).toHaveBeenCalledWith('Failed to load chat:', expect.any(Error));
      });

      consoleSpy.mockRestore();
    });

    it('restores message input on send error', async () => {
      mockIPC((cmd) => {
        if (cmd === 'get_chat_messages') return [];
        if (cmd === 'get_my_peer_id') return 'peer-1';
        if (cmd === 'get_my_peer_name') return 'Alice';
        if (cmd === 'send_chat_message') throw new Error('Send failed');
        return null;
      });

      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
      const user = userEvent.setup();
      render(GlobalChat);

      await waitFor(() => {
        expect(screen.getByPlaceholderText('Type your message...')).toBeInTheDocument();
      });

      const input = screen.getByPlaceholderText('Type your message...') as HTMLTextAreaElement;
      await user.type(input, 'Test message');

      const sendButton = screen.getByLabelText('Send message');
      await user.click(sendButton);

      await waitFor(() => {
        expect(input.value).toBe('Test message');
      });

      consoleSpy.mockRestore();
    });
  });
});
