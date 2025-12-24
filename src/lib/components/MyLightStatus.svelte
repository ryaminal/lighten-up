<script lang="ts">
  import { myState } from '$lib/stores';
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

{#if $myState}
  <div class="my-status">
    <h2>My Status</h2>
    <div class="status-info">
      <div class="light-indicator {colorStyles[$myState.light_state.color]}"></div>
      <div class="details">
        <p class="name">{$myState.name}</p>
        <p class="color">Status: {colorNames[$myState.light_state.color]}</p>
      </div>
    </div>
  </div>
{/if}

<style>
  .my-status {
    padding: 1rem;
    border: 2px solid #333;
    border-radius: 8px;
    background: #f9f9f9;
  }

  h2 {
    margin: 0 0 1rem 0;
    font-size: 1.5rem;
  }

  .status-info {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .light-indicator {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    border: 3px solid #333;
  }

  .details {
    flex: 1;
  }

  .name {
    font-weight: bold;
    font-size: 1.2rem;
    margin: 0;
  }

  .color {
    margin: 0.5rem 0 0 0;
    color: #666;
  }

  :global(.bg-red-500) {
    background-color: #ef4444;
  }
  :global(.bg-yellow-500) {
    background-color: #eab308;
  }
  :global(.bg-green-500) {
    background-color: #22c55e;
  }
  :global(.bg-blue-500) {
    background-color: #3b82f6;
  }
  :global(.bg-gray-400) {
    background-color: #9ca3af;
  }
</style>
