<script lang="ts">
  import { onMount } from 'svelte';
  import { initializeTauri } from '$lib/tauri';
  import { isLoading, error, currentView, myState, lightConfig } from '$lib/stores';
  import { COLOR_CONFIG } from '$lib/config/colors';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import MyLightStatus from '$lib/components/MyLightStatus.svelte';
  import PeerList from '$lib/components/PeerList.svelte';
  import LightConfigScreen from '$lib/components/LightConfigScreen.svelte';
  import type { LightColor } from '$lib/types';

  onMount(() => {
    initializeTauri();
  });

  function getLightName(color: LightColor): string {
    if (!$lightConfig) return '';
    const definition = $lightConfig.definitions.find((d) => d.color === color);
    return definition?.name || '';
  }

  $: currentConfig = $myState ? COLOR_CONFIG[$myState.light_state.color] : COLOR_CONFIG.Off;
  $: isOff = $myState?.light_state.color === 'Off';
  $: statusMessage = $myState?.note?.trim() || '';
  $: lightName = $myState ? getLightName($myState.light_state.color) : '';
</script>

{#if $isLoading}
  <div class="loading">Loading...</div>
{:else if $error}
  <div class="error">
    <p>Error: {$error}</p>
  </div>
{:else}
  <div class="h-screen w-full flex overflow-hidden bg-white dark:bg-[#1e293b]">
    <Sidebar />

    {#if $currentView === 'dashboard'}
      <div class="flex-1 flex flex-col h-full overflow-hidden">
        <div class="flex-1 flex w-full overflow-hidden relative">
          <div
            class="flex-1 flex flex-col p-6 md:p-8 lg:p-10 overflow-y-auto custom-scrollbar border-r border-slate-200 dark:border-slate-700 relative"
          >
            <MyLightStatus />
          </div>
          <PeerList />
        </div>
        <!-- Bottom status bar -->
        <div
          class="h-14 bg-slate-50 dark:bg-[#0f172a] border-t border-slate-200 dark:border-slate-700 flex items-center justify-between px-4 sm:px-6 z-30 flex-shrink-0 select-none shadow-[0_-4px_12px_rgba(0,0,0,0.03)]"
        >
          <div class="flex items-center gap-6 h-full">
            {#if isOff}
              <div class="flex items-center gap-2 h-8">
                <span class="flex h-2.5 w-2.5 rounded-full bg-slate-300 dark:bg-slate-600"></span>
                <span class="text-xs text-slate-500 dark:text-slate-400 font-medium uppercase"
                  >Light Off</span
                >
              </div>
            {:else}
              <div class="flex items-center gap-2 h-8">
                <span class="relative flex h-2.5 w-2.5">
                  <span
                    class="animate-ping absolute inline-flex h-full w-full rounded-full {currentConfig.colorClass} opacity-75"
                  ></span>
                  <span
                    class="relative inline-flex rounded-full h-2.5 w-2.5 {currentConfig.colorClass}"
                  ></span>
                </span>
                <div class="flex items-center gap-2">
                  {#if lightName}
                    <span class="text-xs text-slate-600 dark:text-slate-400 font-medium"
                      >{lightName}</span
                    >
                  {/if}
                  {#if statusMessage}
                    {#if lightName}
                      <span class="text-xs text-slate-500 dark:text-slate-500">•</span>
                    {/if}
                    <span class="text-xs text-slate-700 dark:text-slate-300 font-semibold"
                      >{statusMessage}</span
                    >
                  {/if}
                </div>
              </div>
            {/if}
          </div>
          <div class="text-xs text-slate-400">Lighten Up v0.1.0</div>
        </div>
      </div>
    {:else if $currentView === 'config'}
      <LightConfigScreen />
    {/if}
  </div>
{/if}

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    font-family:
      -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Inter',
      sans-serif;
    background-color: #f6f7f8;
  }
  :global(body.dark) {
    background-color: #101922;
  }
  .loading,
  .error {
    text-align: center;
    padding: 2rem;
    font-size: 1.2rem;
  }
  .error {
    color: #dc2626;
    background: #fee2e2;
    border: 2px solid #dc2626;
    border-radius: 8px;
  }
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
