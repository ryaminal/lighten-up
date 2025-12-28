<script lang="ts">
  export let messageInput: string;
  export let editingMessageId: string | null;
  export let onSend: () => void;
  export let onCancelEdit: () => void;
  export let onKeyDown: (e: KeyboardEvent) => void;
</script>

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
          on:click={onCancelEdit}
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
          on:keydown={onKeyDown}
          class="flex min-h-[44px] w-full rounded-md border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-950 px-3 py-2.5 text-sm ring-offset-background placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 resize-none shadow-sm text-slate-700 dark:text-slate-200"
          placeholder="Type your message..."
          rows="1"
        ></textarea>
      </div>

      <button
        on:click={onSend}
        class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-[#3b82f6] text-white hover:bg-[#3b82f6]/90 h-10 w-10 shrink-0 shadow-sm"
        aria-label="Send message"
      >
        <span class="material-symbols-outlined text-[18px]">send</span>
      </button>
    </div>
  </div>
</div>
