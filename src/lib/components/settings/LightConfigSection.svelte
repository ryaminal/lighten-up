<script lang="ts">
  import type { LightConfig } from '$lib/generated/types';
  import LightConfigRow from './LightConfigRow.svelte';
  import EmptyLightsState from './EmptyLightsState.svelte';

  export let lights: LightConfig[];
  export let lightTableContainer: HTMLDivElement | undefined = undefined;
  export let onAddLight: () => void;
  export let onMoveUp: (index: number) => void;
  export let onMoveDown: (index: number) => void;
  export let onLightChange: (light: LightConfig) => void;
  export let onDeleteLight: (id: string) => void;
</script>

<div class="space-y-4">
  <div class="flex items-center justify-between">
    <div class="flex items-center gap-2">
      <span
        class="flex h-8 w-8 items-center justify-center rounded-full bg-[#3b82f6]/10 text-[#3b82f6]"
      >
        <span class="material-icons-round text-base">lightbulb</span>
      </span>
      <h4 class="text-sm font-medium leading-none text-gray-900 dark:text-white">
        Light Configuration
      </h4>
    </div>

    <button
      class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 bg-[#3b82f6] hover:bg-[#2563eb] text-white h-8 px-3"
      on:click={onAddLight}
      aria-label="Add light"
    >
      <span class="material-symbols-outlined text-lg mr-1">add</span>
      Add Light
    </button>
  </div>

  <div class="rounded-md border border-gray-200 dark:border-gray-800 overflow-hidden">
    <!-- Table Header (Sticky) -->
    <div
      class="grid grid-cols-12 gap-6 p-3 bg-gray-50 dark:bg-gray-900/50 border-b border-gray-200 dark:border-gray-800 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider sticky top-0 z-10"
    >
      <div class="col-span-1 text-center">Priority</div>
      <div class="col-span-2 text-center">Color</div>
      <div class="col-span-7">Light Name</div>
      <div class="col-span-2 text-right">Actions</div>
    </div>

    <!-- Table Rows (Scrollable) -->
    <div bind:this={lightTableContainer} class="max-h-[240px] overflow-y-auto">
      {#if lights.length === 0}
        <EmptyLightsState />
      {:else}
        {#each lights as light, index (light.id)}
          <LightConfigRow
            {light}
            isFirst={index === 0}
            isLast={index === lights.length - 1}
            onMoveUp={() => onMoveUp(index)}
            onMoveDown={() => onMoveDown(index)}
            onChange={() => onLightChange(light)}
            onDelete={() => onDeleteLight(light.id)}
          />
        {/each}
      {/if}
    </div>
  </div>
</div>
