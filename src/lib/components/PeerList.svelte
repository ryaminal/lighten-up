<script lang="ts">
  import { peers } from '$lib/stores';
  import { COLOR_CONFIG } from '$lib/config/colors';

  function formatElapsed(lastSeen: number): string {
    if (!lastSeen) return '';
    const nowSec = Math.floor(Date.now() / 1000);
    const elapsed = nowSec - lastSeen;
    if (elapsed < 60) return `00:${elapsed.toString().padStart(2, '0')}`;
    const minutes = Math.floor(elapsed / 60);
    const secs = elapsed % 60;
    return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
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
          >{$peers.length} Active</span
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
    {#if $peers.length === 0}
      <p class="text-slate-400 italic text-center mt-8">Searching for peers...</p>
    {:else}
      {#each $peers as peer, idx (peer.id)}
        {@const config = COLOR_CONFIG[peer.light_state.color]}
        <div
          class="group flex items-center gap-4 p-4 rounded-xl bg-white dark:bg-slate-800 shadow-sm hover:shadow-md transition-all cursor-pointer border-l-[6px] {config.borderClass}"
        >
          <div class="flex-1 min-w-0">
            <div class="flex justify-between items-start mb-1">
              <h4 class="text-base font-bold text-slate-900 dark:text-white truncate">
                {peer.name}
              </h4>
              <span class="text-xs font-mono px-2 py-0.5 rounded {config.timeBgClass}">
                {formatElapsed(peer.last_seen)}
              </span>
            </div>
            <div class="flex items-center gap-2{idx === 0 ? ' mb-1.5' : ''}">
              <span
                class="h-2.5 w-2.5 rounded-full {config.colorClass}{idx === 0
                  ? ' animate-pulse'
                  : ''}"
              ></span>
              <p class="text-sm text-slate-700 dark:text-slate-200 font-semibold">
                {config.label}
              </p>
            </div>
            {#if peer.note}
              <p class="text-xs text-slate-500 truncate">{peer.note}</p>
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
