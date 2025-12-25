<script lang="ts">
  import { onMount } from 'svelte';
  import { initializeTauri } from '$lib/tauri';
  import { isLoading, error, currentView, showNavigation } from '$lib/stores';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import MyLightStatus from '$lib/components/MyLightStatus.svelte';
  import PeerList from '$lib/components/PeerList.svelte';
  import LightConfigScreen from '$lib/components/LightConfigScreen.svelte';

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
    {#if $showNavigation}
      <Sidebar />
    {/if}

    {#if $currentView === 'dashboard'}
      <div class="flex-1 flex h-full overflow-hidden">
        <div
          class="flex-1 flex flex-col p-6 md:p-8 lg:p-10 overflow-y-auto custom-scrollbar border-r border-slate-200 dark:border-slate-700"
        >
          <MyLightStatus />
        </div>
        <PeerList />
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
