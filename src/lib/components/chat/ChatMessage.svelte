<script lang="ts">
  import type { ChatMessage } from '$lib/tauri';

  export let message: ChatMessage;
  export let currentName: string;
  export let isMyMessage: boolean;
  export let formattedTime: string;
  export let openMenuId: string | null;
  export let onToggleMenu: () => void;
  export let onEdit: () => void;
  export let onDelete: () => void;
</script>

<div class="group max-w-3xl relative">
  <div>
    <div class="flex items-center gap-2 mb-1">
      <span class="text-sm font-bold text-gray-900 dark:text-gray-100">{currentName}</span>
      <span class="text-[11px] text-gray-400">{formattedTime}</span>
      {#if isMyMessage}
        <div class="message-menu-container relative ml-auto">
          <button
            on:click={onToggleMenu}
            class="opacity-0 group-hover:opacity-100 p-1 hover:bg-gray-100 dark:hover:bg-gray-800 rounded transition-opacity"
            aria-label="Message options"
          >
            <span class="material-symbols-outlined text-[16px] text-gray-500">more_horiz</span>
          </button>
          {#if openMenuId === message.id}
            <div
              class="absolute right-0 top-6 bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-600 rounded-md shadow-lg z-50 py-1 min-w-[120px]"
            >
              <button
                on:click={onEdit}
                class="w-full px-4 py-2 text-left text-sm text-gray-900 dark:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center gap-2"
              >
                <span class="material-symbols-outlined text-[16px]">edit</span>
                Edit
              </button>
              <button
                on:click={onDelete}
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
