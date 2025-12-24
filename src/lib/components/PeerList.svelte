<script lang="ts">
  import { peers } from '$lib/stores';
  import type { LightColor } from '$lib/types';

  const colorStyles: Record<LightColor, string> = {
    Red: 'bg-red-500',
    Yellow: 'bg-yellow-500',
    Green: 'bg-green-500',
    Blue: 'bg-blue-500',
    Off: 'bg-gray-400',
  };

  const colorNames: Record<LightColor, string> = {
    Red: 'Red',
    Yellow: 'Yellow',
    Green: 'Green',
    Blue: 'Blue',
    Off: 'Off',
  };
</script>

<div class="peer-list">
  <h2>Team Members</h2>
  {#if $peers.length === 0}
    <p class="no-peers">No peers discovered yet...</p>
  {:else}
    <div class="peers">
      {#each $peers as peer (peer.id)}
        <div class="peer-card">
          <div class="light-indicator {colorStyles[peer.light_state.color]}"></div>
          <div class="peer-info">
            <p class="peer-name">{peer.name}</p>
            <p class="peer-status">{colorNames[peer.light_state.color]}</p>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>

<style>
  .peer-list {
    padding: 1rem;
    border: 2px solid #333;
    border-radius: 8px;
    background: #f9f9f9;
  }

  h2 {
    margin: 0 0 1rem 0;
    font-size: 1.5rem;
  }

  .no-peers {
    color: #666;
    font-style: italic;
  }

  .peers {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .peer-card {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0.75rem;
    background: white;
    border: 1px solid #ddd;
    border-radius: 6px;
  }

  .light-indicator {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    border: 2px solid #333;
    flex-shrink: 0;
  }

  .peer-info {
    flex: 1;
  }

  .peer-name {
    font-weight: bold;
    margin: 0;
  }

  .peer-status {
    margin: 0.25rem 0 0 0;
    font-size: 0.9rem;
    color: #666;
  }
</style>
