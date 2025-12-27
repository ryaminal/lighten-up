<script lang="ts">
  import { peers, lights } from '$lib/stores';
  import { onMount, onDestroy } from 'svelte';

  let currentTime = Date.now();
  let intervalId: number;

  onMount(() => {
    intervalId = setInterval(() => {
      currentTime = Date.now();
    }, 1000);
  });

  onDestroy(() => {
    if (intervalId) clearInterval(intervalId);
  });

  function formatElapsed(lastSeen: number): string {
    if (!lastSeen) return '';
    const nowSec = Math.floor(currentTime / 1000);
    const elapsed = nowSec - lastSeen;
    if (elapsed < 60) return `00:${elapsed.toString().padStart(2, '0')}`;
    const minutes = Math.floor(elapsed / 60);
    const secs = elapsed % 60;
    return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  function getLightName(color: string): string {
    if (!$lights) return '';
    const light = $lights.find((l) => l.enabled && l.color === color);
    return light?.name || '';
  }

  // Force reactivity by creating a computed value that depends on both peers and currentTime
  $: peersWithTime = $peers.map((peer) => ({
    ...peer,
    _renderKey: currentTime,
  }));
</script>

<div class="w-full md:w-[400px] xl:w-[450px] bg-slate-50 dark:bg-[#15202b] flex flex-col h-full">
  <div
    class="p-6 border-b border-slate-200 dark:border-slate-700 bg-white/50 dark:bg-slate-900/20 backdrop-blur-sm flex flex-col gap-4 sticky top-0 z-10"
  >
    <div class="flex justify-between items-center">
      <h3
        class="text-slate-800 dark:text-slate-100 font-bold text-sm uppercase tracking-wider flex items-center gap-2"
      >
        Active Lights
      </h3>
      <div class="flex gap-1">
        <span
          class="text-xs font-semibold bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300 px-3 py-1 rounded-full"
          >{peersWithTime.length} Active</span
        >
      </div>
    </div>
    <div class="flex gap-2">
      <select
        class="block w-full rounded-lg border-0 py-2 pl-3 pr-10 text-slate-700 dark:text-slate-200 ring-1 ring-inset ring-slate-300 dark:ring-slate-600 focus:ring-2 focus:ring-primary text-sm sm:leading-6 bg-white dark:bg-slate-800"
      >
        <option>Sort by Priority</option>
        <option>Sort by Time Elapsed</option>
        <option>Sort by Room Number</option>
      </select>
    </div>
  </div>

  <div class="flex-1 overflow-y-auto p-4 custom-scrollbar space-y-3 pb-8">
    {#if peersWithTime.length === 0}
      <p class="text-slate-400 italic text-center mt-8">Searching for peers...</p>
    {:else}
      {#each peersWithTime as peer (peer.peer_id)}
        {@const lightName = getLightName(peer.light_state.color)}
        <div
          class="group flex items-center gap-4 p-4 rounded-xl bg-white dark:bg-slate-800 shadow-sm hover:shadow-md transition-all cursor-pointer border-l-[6px]"
          style="border-left-color: {peer.light_state.color}"
        >
          <div class="flex-1 min-w-0">
            <div class="flex justify-between items-start mb-2">
              <h4 class="text-base font-bold text-slate-900 dark:text-white truncate">
                {peer.peer_name}
              </h4>
              <span
                class="text-xs font-mono px-2 py-0.5 rounded bg-slate-100 dark:bg-slate-700 text-slate-500 font-medium"
              >
                {formatElapsed(peer.last_seen)}
              </span>
            </div>
            {#if lightName}
              <p class="text-xs text-slate-500 dark:text-slate-400 font-medium truncate mb-1">
                {lightName}
              </p>
            {/if}
            {#if peer.note}
              <p class="text-sm text-slate-700 dark:text-slate-300 truncate">
                {peer.note}
              </p>
            {/if}
          </div>
        </div>
      {/each}
    {/if}
  </div>
  <div
    class="h-8 bg-gradient-to-t from-slate-50 dark:from-[#15202b] to-transparent pointer-events-none -mt-8 z-10"
  ></div>
</div>

<style>
  .custom-scrollbar::-webkit-scrollbar {
    width: 6px;
  }
  .custom-scrollbar::-webkit-scrollbar-track {
    background: transparent;
  }
  .custom-scrollbar::-webkit-scrollbar-thumb {
    background-color: #cbd5e1;
    border-radius: 20px;
  }
  :global(.dark) .custom-scrollbar::-webkit-scrollbar-thumb {
    background-color: #334155;
  }
</style>
