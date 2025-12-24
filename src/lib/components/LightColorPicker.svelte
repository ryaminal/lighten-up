<script lang="ts">
  import { setLightColor } from '$lib/tauri';
  import type { LightColor } from '$lib/types';

  const colors: LightColor[] = ['Red', 'Yellow', 'Green', 'Blue', 'Off'];

  const colorStyles: Record<LightColor, string> = {
    Red: 'bg-red-500',
    Yellow: 'bg-yellow-500',
    Green: 'bg-green-500',
    Blue: 'bg-blue-500',
    Off: 'bg-gray-400',
  };

  let isChanging = $state(false);

  async function handleColorChange(color: LightColor) {
    console.log('handleColorChange called with:', color);
    if (isChanging) {
      console.log('Already changing, ignoring');
      return;
    }
    isChanging = true;
    console.log('Set isChanging = true, current value:', isChanging);
    try {
      console.log('Calling setLightColor...');
      await setLightColor(color);
      console.log('setLightColor returned successfully');
    } catch (error) {
      console.error('Failed to set color:', error);
    } finally {
      console.log('In finally block - Setting isChanging = false');
      isChanging = false;
      console.log('isChanging is now:', isChanging);
    }
  }
</script>

<div class="color-picker">
  <h2>Change Your Status</h2>
  <div class="colors">
    {#each colors as color (color)}
      <button
        class="color-button {colorStyles[color]}"
        onclick={() => handleColorChange(color)}
        disabled={isChanging}
        aria-label="Set status to {color}"
      >
        {color}
      </button>
    {/each}
  </div>
</div>

<style>
  .color-picker {
    padding: 1rem;
    border: 2px solid #333;
    border-radius: 8px;
    background: #f9f9f9;
  }

  h2 {
    margin: 0 0 1rem 0;
    font-size: 1.5rem;
  }

  .colors {
    display: flex;
    gap: 0.75rem;
    flex-wrap: wrap;
  }

  .color-button {
    flex: 1;
    min-width: 80px;
    padding: 1rem;
    border: 3px solid #333;
    border-radius: 8px;
    font-weight: bold;
    font-size: 1rem;
    cursor: pointer;
    transition: transform 0.1s;
  }

  .color-button:hover:not(:disabled) {
    transform: scale(1.05);
  }

  .color-button:active:not(:disabled) {
    transform: scale(0.95);
  }

  .color-button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
</style>
