<script lang="ts">
  import { onMount } from 'svelte';
  import { initializeTauri } from '$lib/tauri';
  import { isLoading, error } from '$lib/stores';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import MyLightStatus from '$lib/components/MyLightStatus.svelte';
  import PeerList from '$lib/components/PeerList.svelte';

  onMount(() => {
    initializeTauri();
  });
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
    <div class="flex-1 flex flex-col h-full overflow-hidden">
      <div class="flex-1 flex w-full overflow-hidden relative">
        <div
          class="flex-1 flex flex-col p-6 md:p-8 lg:p-10 overflow-y-auto custom-scrollbar border-r border-slate-200 dark:border-slate-700 relative"
        >
          <MyLightStatus />
        </div>
        <PeerList />
      </div>
      <!-- Simplified bottom status bar -->
      <div class="h-14 bg-slate-50 dark:bg-[#0f172a] border-t border-slate-200 dark:border-slate-700 flex items-center justify-between px-4 sm:px-6 z-30 flex-shrink-0 select-none shadow-[0_-4px_12px_rgba(0,0,0,0.03)]">
        <div class="flex items-center gap-6 h-full">
          <div class="flex items-center gap-2 pr-4 border-r border-slate-200 dark:border-slate-700 h-8" title="System Online">
            <span class="relative flex h-2 w-2">
              <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
              <span class="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
            </span>
            <span class="text-xs text-slate-600 dark:text-slate-400 font-medium">System Online</span>
          </div>
        </div>
        <div class="text-xs text-slate-400">Lighten Up v0.1.0</div>
      </div>
    </div>
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
