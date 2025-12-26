<script lang="ts">
  import { peers, lights } from '$lib/stores';
  import { COLOR_CONFIG } from '$lib/config/colors';
  import type { LightColor } from '$lib/generated/types';
  import type { PeerPresence } from '$lib/tauri';

  // Get light config for a peer's current color
  function getLightConfig(peer: PeerPresence) {
    const colorHex = peer.light_state.color;
    const light = $lights?.find((l) => l.enabled && l.color === colorHex);

    // Find matching LightColor enum
    const colorEntry = Object.entries(COLOR_CONFIG).find(([_, config]) => config.hex === colorHex);
    const lightColorName = colorEntry ? colorEntry[0] : 'Off';
    const colorConfig = COLOR_CONFIG[lightColorName as LightColor];

    return {
      name: light?.name || lightColorName,
      priority: light?.priority || 0,
      color: colorHex, // Use actual hex color, not the config color
      borderColor: colorHex, // Use actual hex for border
      borderClass: colorEntry ? colorConfig.borderClass : '', // Only use class if it matches
    };
  }

  // Calculate time in current state
  function getTimeInState(timestamp: number): string {
    const now = Math.floor(Date.now() / 1000);
    const elapsed = now - timestamp;

    if (elapsed < 60) return `${elapsed}s ago`;
    if (elapsed < 3600) return `${Math.floor(elapsed / 60)}m ago`;
    if (elapsed < 86400) return `${Math.floor(elapsed / 3600)}h ago`;
    return `${Math.floor(elapsed / 86400)}d ago`;
  }

  // Sort peers by priority (highest first), then by time in state (oldest first)
  $: sortedPeers = [...($peers || [])].sort((a, b) => {
    const aPriority = getLightConfig(a).priority;
    const bPriority = getLightConfig(b).priority;
    // Higher priority first
    if (aPriority !== bPriority) return bPriority - aPriority;
    // Then by time in state (oldest first)
    return a.light_state.timestamp - b.light_state.timestamp;
  });

  $: hasUrgent = sortedPeers.some((p) => getLightConfig(p).priority >= 3);
</script>

<aside
  class="w-80 bg-white dark:bg-[#111827] border-l border-gray-200 dark:border-gray-800 flex flex-col z-10 shadow-soft relative hidden md:flex"
>
  <div
    class="h-16 px-5 border-b border-gray-200 dark:border-gray-800 flex items-center justify-between bg-white dark:bg-gray-950/50 backdrop-blur-sm sticky top-0"
  >
    <div>
      <h2 class="font-bold text-lg text-gray-800 dark:text-white">Priority Queue</h2>
      <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
        {sortedPeers.length} Active
      </p>
    </div>
    <button
      class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
      aria-label="Filter"
    >
      <span class="material-icons-round text-xl">filter_list</span>
    </button>
  </div>

  <div class="flex-1 overflow-y-auto p-3 space-y-3 custom-scrollbar">
    {#if sortedPeers.length === 0}
      <p class="text-gray-400 italic text-center mt-8">No peers online...</p>
    {:else}
      {#each sortedPeers as peer (peer.peer_id)}
        {@const config = getLightConfig(peer)}
        {@const timeInState = getTimeInState(peer.light_state.timestamp)}
        {@const priorityLabel =
          config.priority >= 3
            ? 'Urgent'
            : config.priority === 2
              ? 'Attention'
              : config.priority === 1
                ? 'Info'
                : 'Normal'}
        {@const badgeClass =
          config.priority >= 3
            ? 'bg-red-100 text-[#ef4444] dark:bg-red-900/30 dark:text-red-300'
            : config.priority === 2
              ? 'bg-orange-100 text-[#f97316] dark:bg-orange-900/30 dark:text-orange-300'
              : config.priority === 1
                ? 'bg-blue-100 text-blue-600 dark:bg-blue-900/30 dark:text-blue-300'
                : 'bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400'}
        {@const hoverClass =
          config.priority >= 3
            ? 'hover:bg-red-50 dark:hover:bg-gray-800/80'
            : config.priority === 2
              ? 'hover:bg-orange-50 dark:hover:bg-gray-800/80'
              : config.priority === 1
                ? 'hover:bg-blue-50 dark:hover:bg-gray-800/80'
                : 'hover:bg-gray-50 dark:hover:bg-gray-800/80'}

        <div
          class="group relative bg-white dark:bg-gray-900 rounded-lg p-3 border-l-4 shadow-sm hover:shadow-md transition-all cursor-pointer ring-1 ring-gray-100 dark:ring-gray-800 {hoverClass}"
          style="border-left-color: {config.borderColor}"
        >
          <div class="flex justify-between items-center mb-2">
            <div class="flex items-center gap-2">
              <span
                class="{badgeClass} text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-wider"
              >
                {priorityLabel}
              </span>
              <h3 class="font-semibold text-gray-900 dark:text-gray-100 text-sm">
                {peer.peer_name}
              </h3>
            </div>
            <span class="text-xs text-gray-400 dark:text-gray-500 font-mono">{timeInState}</span>
          </div>
          <p class="text-xs text-gray-500 dark:text-gray-400 line-clamp-1">
            {peer.note || config.name}
          </p>
          <div
            class="absolute right-3 bottom-3 opacity-0 group-hover:opacity-100 transition-opacity"
          >
            <span class="material-icons-round text-gray-400 text-sm">chevron_right</span>
          </div>
        </div>
      {/each}
    {/if}
  </div>

  <div
    class="p-3 bg-gray-50 dark:bg-gray-950 border-t border-gray-200 dark:border-gray-800 text-xs text-center text-gray-500 dark:text-gray-400"
  >
    <div class="flex items-center justify-center space-x-2">
      {#if hasUrgent}
        <span class="relative flex h-2 w-2">
          <span
            class="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#ef4444] opacity-75"
          ></span>
          <span class="relative inline-flex rounded-full h-2 w-2 bg-[#ef4444]"></span>
        </span>
        <span class="font-medium text-[#ef4444] dark:text-red-400">Action Required</span>
      {:else}
        <span class="w-2 h-2 rounded-full bg-green-500"></span>
        <span>System Online</span>
      {/if}
    </div>
  </div>
</aside>

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
