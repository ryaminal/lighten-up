<script lang="ts">
  import { setLightStatus } from '$lib/tauri';
  import { myState } from '$lib/stores';
  import type { LightColor } from '$lib/types';
  import { COLOR_CONFIG, type ColorConfig } from '$lib/config/colors';

  // Note prop passed from parent
  let { note = '' }: { note?: string } = $props();

  // Select which colors to display in the UI - back to just colors, no Off
  const displayedColors: LightColor[] = ['Green', 'Red', 'Blue', 'Magenta', 'Yellow', 'White'];

  type LightButton = {
    color: LightColor;
    config: ColorConfig;
  };

  const lightButtons: LightButton[] = displayedColors.map((color) => ({
    color,
    config: COLOR_CONFIG[color],
  }));

  let isChanging = $state(false);

  async function handleColorChange(color: LightColor) {
    if (isChanging) return;
    
    // If clicking the currently active color, toggle it off
    const currentColor = $myState?.light_state.color;
    const targetColor = currentColor === color ? 'Off' : color;
    
    isChanging = true;
    try {
      // Send both color and current note
      await setLightStatus(targetColor, note.trim() || undefined);
    } catch (error) {
      console.error('Failed to set color:', error);
    } finally {
      isChanging = false;
    }
  }

  // Check if color is currently active
  function isActive(color: LightColor): boolean {
    return $myState?.light_state.color === color;
  }
</script>

<div class="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
  {#each lightButtons as { color, config } (color)}
    {@const active = isActive(color)}
    <button
      class="relative flex flex-col items-center justify-center gap-3 h-28 lg:h-32 rounded-xl transition-all active:scale-[0.98] group hover:shadow-md
        {active
          ? `border-2 ${config.borderClass} ring-1 ${config.borderClass} scale-[1.02] z-10 bg-slate-50 dark:bg-slate-800/50`
          : 'border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/30 hover:bg-slate-50 dark:hover:bg-slate-700/50'}"
      style={active ? `box-shadow: 0 0 0 4px ${config.hex}26` : ''}
      type="button"
      onclick={() => handleColorChange(color)}
      disabled={isChanging}
      aria-label="{active ? 'Turn off' : 'Set light to'} {color}"
      title="{color} Light {active ? '(Click to turn off)' : ''}"
    >
      {#if active}
        <span class="absolute top-2 right-2 flex h-3 w-3">
          <span class="animate-ping absolute inline-flex h-full w-full rounded-full {config.colorClass} opacity-75"></span>
          <span class="relative inline-flex rounded-full h-3 w-3 {config.colorClass}"></span>
        </span>
      {/if}
      
      <span class="h-6 w-6 rounded-full {config.colorClass} shadow-md {active ? '' : 'opacity-80 group-hover:opacity-100'} transition-opacity"></span>
    </button>
  {/each}
</div>
