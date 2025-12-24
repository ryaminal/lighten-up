<script lang="ts">
  import { onMount } from 'svelte';
  import { initializeTauri } from '$lib/tauri';
  import { isLoading, error } from '$lib/stores';
  import MyLightStatus from '$lib/components/MyLightStatus.svelte';
  import LightColorPicker from '$lib/components/LightColorPicker.svelte';
  import PeerList from '$lib/components/PeerList.svelte';

  onMount(() => {
    initializeTauri();
  });
</script>

<main class="container">
  <header>
    <h1>Lighten Up</h1>
    <p class="subtitle">Team Status at a Glance</p>
  </header>

  {#if $isLoading}
    <div class="loading">Loading...</div>
  {:else if $error}
    <div class="error">
      <p>Error: {$error}</p>
    </div>
  {:else}
    <div class="content">
      <div class="left-panel">
        <MyLightStatus />
        <LightColorPicker />
      </div>

      <div class="right-panel">
        <PeerList />
      </div>
    </div>
  {/if}
</main>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    font-family:
      -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
    background-color: #e5e7eb;
  }

  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
  }

  header {
    text-align: center;
    margin-bottom: 2rem;
  }

  h1 {
    font-size: 2.5rem;
    margin: 0;
    color: #111827;
  }

  .subtitle {
    color: #6b7280;
    font-size: 1.1rem;
    margin: 0.5rem 0 0 0;
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

  .content {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
  }

  .left-panel,
  .right-panel {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  @media (max-width: 768px) {
    .content {
      grid-template-columns: 1fr;
    }
  }
</style>
