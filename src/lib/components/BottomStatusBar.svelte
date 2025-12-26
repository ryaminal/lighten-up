<script lang="ts">
  import { myLightColor, lights, peers } from '$lib/stores';
  import { COLOR_CONFIG } from '$lib/config/colors';
  import type { LightColor } from '$lib/generated/types';

  export let onOpenStatusPicker: () => void;

  // myLightColor is a hex string, we need to find the matching LightColor enum
  $: colorHex = $myLightColor || '#9ca3af';
  $: colorEntry = Object.entries(COLOR_CONFIG).find(([_, config]) => config.hex === colorHex);
  $: lightColorName = (colorEntry ? colorEntry[0] : 'Off') as LightColor;
  $: colorConfig = COLOR_CONFIG[lightColorName];
  $: currentLight = $lights?.find((l) => l.enabled && l.color === colorHex);
  $: statusName = currentLight?.name || lightColorName;
  $: isUrgent = lightColorName === 'Red';
  $: peerCount = $peers?.length || 0;
</script>

<footer
  class="bg-white dark:bg-[#111827] border-t border-gray-200 dark:border-gray-800 h-16 shrink-0 flex items-center justify-between px-6 z-30 relative shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.05)] dark:shadow-none"
>
  <div class="flex items-center">
    <button
      class="group flex items-center gap-3 pl-1 pr-4 py-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800/50 transition-all border border-transparent hover:border-gray-200 dark:hover:border-gray-700"
      on:click={onOpenStatusPicker}
      aria-label="Change status"
    >
      <div class="relative flex h-3 w-3">
        {#if isUrgent}
          <span
            class="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#ef4444] opacity-75"
          ></span>
        {/if}
        <span class="relative inline-flex rounded-full h-3 w-3" style="background-color: {colorHex}"
        ></span>
      </div>
      <div class="flex flex-col items-start">
        <span
          class="text-[10px] font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400"
          >Current Status</span
        >
        <div class="flex items-center gap-1.5">
          <span
            class="text-sm font-bold text-gray-900 dark:text-white group-hover:text-[#3b82f6] transition-colors"
            >{statusName}</span
          >
          <span class="material-symbols-outlined text-base text-gray-400 group-hover:text-[#3b82f6]"
            >expand_less</span
          >
        </div>
      </div>
    </button>
  </div>
  <div
    class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 hidden md:flex items-center gap-10"
  >
    <div class="flex items-center gap-3">
      <span class="material-symbols-outlined text-xl text-gray-400 dark:text-gray-500">timer</span>
      <div class="flex flex-col">
        <span
          class="text-[10px] font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 leading-none mb-0.5"
          >Duration</span
        >
        <span class="text-sm font-mono font-medium text-gray-900 dark:text-gray-200 leading-none"
          >--:--</span
        >
      </div>
    </div>
    <div class="h-8 w-px bg-gray-200 dark:bg-gray-800"></div>
    <div class="flex items-center gap-3">
      <span class="material-symbols-outlined text-xl text-gray-400 dark:text-gray-500">groups</span>
      <div class="flex flex-col">
        <span
          class="text-[10px] font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 leading-none mb-0.5"
          >Peers Online</span
        >
        <span class="text-sm font-medium text-gray-900 dark:text-gray-200 leading-none"
          >{peerCount} Online</span
        >
      </div>
    </div>
  </div>
  <div class="flex items-center gap-4">
    <div
      class="hidden lg:flex items-center gap-2 text-xs text-gray-500 dark:text-gray-400 font-medium"
    >
      <span class="w-2 h-2 rounded-full bg-green-500"></span>
      <span>System Online</span>
    </div>
  </div>
</footer>
