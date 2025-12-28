<script lang="ts">
  import type { LightConfig } from '$lib/generated/types';

  export let light: LightConfig;
  export let isFirst: boolean;
  export let isLast: boolean;
  export let onMoveUp: () => void;
  export let onMoveDown: () => void;
  export let onChange: () => void;
  export let onDelete: () => void;
</script>

<div
  class="grid grid-cols-12 gap-6 p-3 items-center border-b border-gray-200 dark:border-gray-800 last:border-0 hover:bg-gray-50 dark:hover:bg-gray-900/30 transition-all duration-200 group"
>
  <!-- Up/Down Arrows -->
  <div class="col-span-1 flex flex-col items-center gap-1">
    <button
      class="inline-flex items-center justify-center rounded text-xs transition-colors hover:bg-gray-200 dark:hover:bg-gray-700 h-5 w-5 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 disabled:opacity-30 disabled:cursor-not-allowed disabled:hover:bg-transparent"
      on:click={onMoveUp}
      disabled={isFirst}
      aria-label="Move up"
      title="Move up"
    >
      <span class="material-icons-round text-base">keyboard_arrow_up</span>
    </button>
    <button
      class="inline-flex items-center justify-center rounded text-xs transition-colors hover:bg-gray-200 dark:hover:bg-gray-700 h-5 w-5 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 disabled:opacity-30 disabled:cursor-not-allowed disabled:hover:bg-transparent"
      on:click={onMoveDown}
      disabled={isLast}
      aria-label="Move down"
      title="Move down"
    >
      <span class="material-icons-round text-base">keyboard_arrow_down</span>
    </button>
  </div>

  <!-- Color Picker -->
  <div class="col-span-2 flex justify-center relative">
    <div
      class="h-6 w-6 rounded-full ring-offset-background transition-all cursor-pointer ring-2 ring-transparent group-hover:ring-gray-300 dark:group-hover:ring-gray-700 shadow-sm"
      style="background-color: {light.color}"
    ></div>
    <input
      class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
      type="color"
      bind:value={light.color}
      on:change={onChange}
      on:click|stopPropagation
    />
  </div>

  <!-- Light Name -->
  <div class="col-span-7">
    <input
      class="flex h-8 w-full rounded-md border border-transparent bg-transparent px-2 py-1 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-[#3b82f6] disabled:cursor-not-allowed disabled:opacity-50 hover:bg-gray-100 dark:hover:bg-gray-900 focus:bg-white dark:focus:bg-gray-900 text-gray-900 dark:text-white transition-all"
      bind:value={light.name}
      on:change={onChange}
      maxlength="14"
    />
  </div>

  <!-- Delete Button -->
  <div class="col-span-2 flex justify-end">
    <button
      class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 hover:bg-red-50 dark:hover:bg-red-900/10 hover:text-red-600 dark:hover:text-red-400 h-8 w-8 text-gray-400"
      on:click={onDelete}
      aria-label="Delete light"
    >
      <span class="material-symbols-outlined text-lg">delete</span>
    </button>
  </div>
</div>
