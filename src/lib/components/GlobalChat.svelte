<script lang="ts">
  import { onMount, onDestroy, afterUpdate } from 'svelte';
  import { getChatMessages, sendChatMessage, getMyPeerId, getMyPeerName } from '$lib/tauri';
  import { listen, type UnlistenFn } from '@tauri-apps/api/event';
  import type { ChatMessage } from '$lib/tauri';
  import { peers, myPeerName as myPeerNameStore } from '$lib/stores';

  let messages: ChatMessage[] = [];
  let messageInput = '';
  let isLoading = true;
  let myPeerId = '';
  let myPeerName = '';
  let unlistenChat: UnlistenFn | null = null;
  let messagesContainer: HTMLDivElement;

  // Get current peer name for a message (looks up from peers store)
  function getCurrentPeerName(message: ChatMessage): string {
    if (message.peer_id === myPeerId) {
      return $myPeerNameStore || myPeerName;
    }
    const peer = $peers?.find((p) => p.peer_id === message.peer_id);
    return peer?.peer_name || message.peer_name;
  }

  onMount(async () => {
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
        // Add message if it's not already in the list (avoid duplicates)
        if (!messages.find((m) => m.id === newMessage.id)) {
          messages = [...messages, newMessage];
        }
      });
    } catch (err) {
      console.error('Failed to load chat:', err);
      isLoading = false;
    }
  });

  onDestroy(async () => {
    if (unlistenChat) {
      await unlistenChat();
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
    if (!content) return;

    try {
      // Clear input immediately for better UX
      messageInput = '';

      // Send to backend (the chat-message event will add it to the UI)
      await sendChatMessage(content);
    } catch (err) {
      console.error('Failed to send message:', err);
      // Restore the message on error
      messageInput = content;
    }
  }

  function handleKeyDown(e: KeyboardEvent) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
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
        <div class="group flex gap-3 max-w-3xl">
          <div
            class="w-9 h-9 rounded-full bg-blue-100 dark:bg-blue-900/40 flex items-center justify-center text-blue-700 dark:text-blue-300 text-sm font-bold shrink-0 mt-1"
          >
            {getInitials(currentName)}
          </div>
          <div>
            <div class="flex items-center gap-2 mb-1">
              <span class="text-sm font-bold text-gray-900 dark:text-gray-100">{currentName}</span>
              <span class="text-[11px] text-gray-400">{formatTime(message.timestamp)}</span>
            </div>
            <div
              class="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800 rounded-lg rounded-tl-none p-4 shadow-sm"
            >
              <p
                class="text-sm text-gray-800 dark:text-gray-200 leading-relaxed whitespace-pre-line"
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
      <div class="flex gap-2 items-end">
        <button
          class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-gray-100 hover:text-gray-900 dark:hover:bg-gray-800 dark:hover:text-gray-50 h-10 w-10 shrink-0 text-gray-500"
          aria-label="Add attachment"
        >
          <span class="material-symbols-outlined text-[20px]">add</span>
        </button>

        <div class="flex-1 relative">
          <textarea
            bind:value={messageInput}
            on:keydown={handleKeyDown}
            class="flex min-h-[44px] w-full rounded-md border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-950 px-3 py-2.5 text-sm ring-offset-background placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 resize-none pr-10 shadow-sm text-slate-700 dark:text-slate-200"
            placeholder="Type your message..."
            rows="1"
            maxlength="40"
          ></textarea>
          <div class="absolute right-2 top-2">
            <button
              class="inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors hover:bg-gray-100 dark:hover:bg-gray-800 h-7 w-7 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
              aria-label="Add emoji"
            >
              <span class="material-symbols-outlined text-[18px]">sentiment_satisfied</span>
            </button>
          </div>
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
