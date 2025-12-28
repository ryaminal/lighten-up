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
  import { formatTime, getCurrentPeerName } from '$lib/logic/chat/chatFormatting';
  import ChatMessage_Component from './chat/ChatMessage.svelte';
  import ChatInput from './chat/ChatInput.svelte';
  import ChatDateDivider from './chat/ChatDateDivider.svelte';

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

  function handleClickOutside(event: MouseEvent) {
    const target = event.target as HTMLElement;
    if (openMenuId && !target.closest('.message-menu-container')) {
      openMenuId = null;
    }
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

      unlistenChat = await listen<ChatMessage>('chat-message', (event) => {
        const newMessage = event.payload;
        const existingIndex = messages.findIndex((m) => m.id === newMessage.id);
        if (existingIndex !== -1) {
          messages[existingIndex] = newMessage;
          messages = [...messages];
        } else {
          messages = [...messages, newMessage];
        }
      });

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
    if (unlistenChat) await unlistenChat();
    if (unlistenChatDeleted) await unlistenChatDeleted();
  });

  afterUpdate(() => {
    if (messagesContainer) {
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
  });

  async function handleSendMessage() {
    const content = messageInput.trim();

    try {
      if (editingMessageId) {
        if (!content) {
          await deleteChatMessage(editingMessageId);
        } else {
          await editChatMessage(editingMessageId, content);
        }
      } else {
        if (!content) return;
        await sendChatMessage(content);
      }

      messageInput = '';
      editingMessageId = null;
    } catch (err) {
      console.error('Failed to send/edit/delete message:', err);
      messageInput = content;
    }
  }

  function handleEditLastMessage() {
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
      <ChatDateDivider />

      {#each messages as message (message.id)}
        {@const currentName = getCurrentPeerName(
          message,
          myPeerId,
          $myPeerNameStore || myPeerName,
          $peers
        )}
        {@const isMyMessage = message.peer_id === myPeerId}
        <ChatMessage_Component
          {message}
          {currentName}
          {isMyMessage}
          formattedTime={formatTime(message.timestamp)}
          {openMenuId}
          onToggleMenu={() => toggleMenu(message.id)}
          onEdit={() => handleEditMessage(message)}
          onDelete={() => handleDeleteMessage(message.id)}
        />
      {/each}
    {/if}
  </div>

  <ChatInput
    bind:messageInput
    {editingMessageId}
    onSend={handleSendMessage}
    onCancelEdit={cancelEdit}
    onKeyDown={handleKeyDown}
  />
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
