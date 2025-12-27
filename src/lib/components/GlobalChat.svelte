<script lang="ts">
  import { onMount, onDestroy, afterUpdate } from 'svelte';
  import {
    getChatMessages,
    sendChatMessage,
    editChatMessage,
    deleteChatMessage,
    getMyPeerId,
    getMyPeerName,
  } from '$lib/tauri';
  import { listen, type UnlistenFn } from '@tauri-apps/api/event';
  import type { ChatMessage } from '$lib/tauri';
  import { peers, myPeerName as myPeerNameStore } from '$lib/stores';

  let messages: ChatMessage[] = [];
  let messageInput = '';
  let isLoading = true;
  let myPeerId = '';
  let myPeerName = '';
  let unlistenChat: UnlistenFn | null = null;
  let unlistenChatDeleted: UnlistenFn | null = null;
  let messagesContainer: HTMLDivElement;
  let editingMessageId: string | null = null;
  let openMenuId: string | null = null;

  // Close menu when clicking outside
  function handleClickOutside(event: MouseEvent) {
    const target = event.target as HTMLElement;
    if (openMenuId && !target.closest('.message-menu-container')) {
      openMenuId = null;
    }
  }

  // Get current peer name for a message (looks up from peers store)
  function getCurrentPeerName(message: ChatMessage): string {
    if (message.peer_id === myPeerId) {
      return $myPeerNameStore || myPeerName;
    }
    const peer = $peers?.find((p) => p.peer_id === message.peer_id);
    return peer?.peer_name || message.peer_name;
  }

  onMount(async () => {
    document.addEventListener('click', handleClickOutside);

    try {
      const [chatMessages, peerId, peerName] = await Promise.all([
        getChatMessages(),
        getMyPeerId(),
        getMyPeerName(),
      ]);
      messages = chatMessages;
      myPeerId = peerId;
      myPeerName = peerName;
      isLoading = false;

      // Listen for new chat messages
      unlistenChat = await listen<ChatMessage>('chat-message', (event) => {
        const newMessage = event.payload;
        // Check if message already exists (edit case)
        const existingIndex = messages.findIndex((m) => m.id === newMessage.id);
        if (existingIndex !== -1) {
          // Update existing message (edit)
          messages[existingIndex] = newMessage;
          messages = [...messages];
        } else {
          // Add new message
          messages = [...messages, newMessage];
        }
      });

      // Listen for chat message deletions
      unlistenChatDeleted = await listen<string>('chat-message-deleted', (event) => {
        const deletedId = event.payload;
        messages = messages.filter((m) => m.id !== deletedId);
      });
    } catch (err) {
      console.error('Failed to load chat:', err);
      isLoading = false;
    }
  });

  onDestroy(async () => {
    document.removeEventListener('click', handleClickOutside);
    if (unlistenChat) {
      await unlistenChat();
    }
    if (unlistenChatDeleted) {
      await unlistenChatDeleted();
    }
  });

  afterUpdate(() => {
    scrollToBottom();
  });

  function scrollToBottom() {
    if (messagesContainer) {
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
  }

  async function handleSendMessage() {
    const content = messageInput.trim();

    try {
      if (editingMessageId) {
        if (!content) {
          // If editing and content is empty, delete the message
          await deleteChatMessage(editingMessageId);
        } else {
          // Edit existing message
          await editChatMessage(editingMessageId, content);
        }
      } else {
        // Only send new message if there's content
        if (!content) return;
        await sendChatMessage(content);
      }

      // Clear input and editing state
      messageInput = '';
      editingMessageId = null;
    } catch (err) {
      console.error('Failed to send/edit/delete message:', err);
      // Restore the message on error
      messageInput = content;
    }
  }

  function handleEditLastMessage() {
    // Find the last message from current user
    const myMessages = messages.filter((m) => m.peer_id === myPeerId);
    if (myMessages.length === 0) return;

    const lastMessage = myMessages[myMessages.length - 1];
    messageInput = lastMessage.content;
    editingMessageId = lastMessage.id;
  }

  function handleEditMessage(message: ChatMessage) {
    messageInput = message.content;
    editingMessageId = message.id;
    openMenuId = null;
  }

  async function handleDeleteMessage(id: string) {
    try {
      await deleteChatMessage(id);
      openMenuId = null;
    } catch (err) {
      console.error('Failed to delete message:', err);
    }
  }

  function toggleMenu(id: string) {
    openMenuId = openMenuId === id ? null : id;
  }

  function cancelEdit() {
    messageInput = '';
    editingMessageId = null;
  }

  function handleKeyDown(e: KeyboardEvent) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    } else if (e.key === 'ArrowUp' && !messageInput) {
      e.preventDefault();
      handleEditLastMessage();
    } else if (e.key === 'Escape' && editingMessageId) {
      e.preventDefault();
      cancelEdit();
    }
  }

  function getInitials(name: string): string {
    return name
      .split(' ')
      .map((n) => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  }

  function formatTime(timestamp: number): string {
    const date = new Date(timestamp * 1000);
    return date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
  }
</script>

<main class="flex-1 flex flex-col h-full overflow-hidden bg-gray-50 dark:bg-[#1f2937] relative z-0">
  <header
    class="bg-white dark:bg-[#111827] border-b border-gray-200 dark:border-gray-800 h-16 flex items-center px-4 sm:px-6 shrink-0 shadow-sm z-10"
  >
    <div class="flex items-center gap-2">
      <span class="material-symbols-outlined text-gray-400 dark:text-gray-500">forum</span>
      <h1 class="text-lg font-bold text-gray-800 dark:text-white whitespace-nowrap">Global Chat</h1>
    </div>
  </header>

  <div
    bind:this={messagesContainer}
    class="flex-1 overflow-y-auto p-4 md:p-6 space-y-6 custom-scrollbar bg-gray-50 dark:bg-[#0f1521]"
  >
    {#if isLoading}
      <div class="flex items-center justify-center h-full">
        <p class="text-gray-400">Loading messages...</p>
      </div>
    {:else if messages.length === 0}
      <div class="flex items-center justify-center h-full">
        <div class="text-center">
          <span class="material-symbols-outlined text-6xl text-gray-300 dark:text-gray-700 mb-4"
            >chat_bubble</span
          >
          <p class="text-gray-400">No messages yet. Start the conversation!</p>
        </div>
      </div>
    {:else}
      <div class="flex items-center justify-center my-6">
        <div class="h-px bg-gray-200 dark:bg-gray-800 w-full max-w-[120px]"></div>
        <span class="px-3 text-xs font-medium text-gray-400 uppercase tracking-wider">Today</span>
        <div class="h-px bg-gray-200 dark:bg-gray-800 w-full max-w-[120px]"></div>
      </div>

      {#each messages as message (message.id)}
        {@const currentName = getCurrentPeerName(message)}
        {@const isMyMessage = message.peer_id === myPeerId}
        <div class="group max-w-3xl relative">
          <div>
            <div class="flex items-center gap-2 mb-1">
              <span class="text-sm font-bold text-gray-900 dark:text-gray-100">{currentName}</span>
              <span class="text-[11px] text-gray-400">{formatTime(message.timestamp)}</span>
              {#if isMyMessage}
                <div class="message-menu-container relative ml-auto">
                  <button
                    on:click={() => toggleMenu(message.id)}
                    class="opacity-0 group-hover:opacity-100 p-1 hover:bg-gray-100 dark:hover:bg-gray-800 rounded transition-opacity"
                    aria-label="Message options"
                  >
                    <span class="material-symbols-outlined text-[16px] text-gray-500"
                      >more_horiz</span
                    >
                  </button>
                  {#if openMenuId === message.id}
                    <div
                      class="absolute right-0 top-6 bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-600 rounded-md shadow-lg z-50 py-1 min-w-[120px]"
                    >
                      <button
                        on:click={() => handleEditMessage(message)}
                        class="w-full px-4 py-2 text-left text-sm text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center gap-2"
                      >
                        <span class="material-symbols-outlined text-[16px]">edit</span>
                        Edit
                      </button>
                      <button
                        on:click={() => handleDeleteMessage(message.id)}
                        class="w-full px-4 py-2 text-left text-sm hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center gap-2 text-red-600 dark:text-red-400"
                      >
                        <span class="material-symbols-outlined text-[16px]">delete</span>
                        Delete
                      </button>
                    </div>
                  {/if}
                </div>
              {/if}
            </div>
            <div
              class="{isMyMessage
                ? 'bg-blue-50 dark:bg-blue-950/30 border-blue-200 dark:border-blue-900/50'
                : 'bg-white dark:bg-[#111827] border-gray-200 dark:border-gray-800'} border rounded-lg rounded-tl-none p-4 shadow-sm"
            >
              <p
                class="text-sm text-gray-800 dark:text-gray-200 leading-relaxed whitespace-pre-line break-words overflow-wrap-anywhere"
                style="overflow-wrap: anywhere; word-break: break-word;"
              >
                {message.content}
              </p>
            </div>
          </div>
        </div>
      {/each}
    {/if}
  </div>

  <div
    class="p-4 bg-white dark:bg-[#111827] border-t border-gray-200 dark:border-gray-800 shrink-0 z-10"
  >
    <div class="max-w-4xl mx-auto space-y-3">
      {#if editingMessageId}
        <div
          class="flex items-center justify-between px-3 py-2 bg-blue-50 dark:bg-blue-950/30 border border-blue-200 dark:border-blue-900/50 rounded-md text-sm"
        >
          <span class="text-blue-700 dark:text-blue-300">Editing message (clear to delete)</span>
          <button
            on:click={cancelEdit}
            class="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-200"
          >
            <span class="material-symbols-outlined text-[18px]">close</span>
          </button>
        </div>
      {/if}
      <div class="flex gap-2 items-end">
        <div class="flex-1 relative">
          <textarea
            bind:value={messageInput}
            on:keydown={handleKeyDown}
            class="flex min-h-[44px] w-full rounded-md border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-950 px-3 py-2.5 text-sm ring-offset-background placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 resize-none shadow-sm text-slate-700 dark:text-slate-200"
            placeholder="Type your message..."
            rows="1"
          ></textarea>
        </div>

        <button
          on:click={handleSendMessage}
          class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-[#3b82f6] text-white hover:bg-[#3b82f6]/90 h-10 w-10 shrink-0 shadow-sm"
          aria-label="Send message"
        >
          <span class="material-symbols-outlined text-[18px]">send</span>
        </button>
      </div>
    </div>
  </div>
</main>

<style>
  .custom-scrollbar::-webkit-scrollbar {
    width: 6px;
  }
  .custom-scrollbar::-webkit-scrollbar-track {
    background: transparent;
  }
  .custom-scrollbar::-webkit-scrollbar-thumb {
    background-color: rgba(156, 163, 175, 0.5);
    border-radius: 20px;
  }
</style>
