<script lang="ts">
  import { setLightColor } from '$lib/tauri';
  import { myLightColor, lights } from '$lib/stores';
  import type { LightColor } from '$lib/generated/types';
  import { COLOR_CONFIG, type ColorConfig } from '$lib/config/colors';

  // Note prop passed from parent
  let { note = '' }: { note?: string } = $props();

  type LightButton = {
    color: LightColor;
    config: ColorConfig;
    name: string;
  };

  // Dynamically get available lights from config
  let lightButtons = $derived(
    $lights
      ? $lights
          .filter((light) => light.enabled && light.color !== 'Off')
          .sort((a, b) => a.priority - b.priority)
          .map((light) => ({
            color: light.color as LightColor,
            config: COLOR_CONFIG[light.color as LightColor],
            name: light.name,
          }))
      : []
  );

  let isChanging = $state(false);

  async function handleColorChange(color: LightColor) {
    if (isChanging) return;

    // If clicking the currently active color, toggle it off
    const currentColor = $myLightColor;
    const targetColor = currentColor === color ? 'Off' : color;

    isChanging = true;
    try {
      // Send both color and current note
      await setLightColor(targetColor, note.trim() || undefined);
    } catch (error) {
      console.error('Failed to set color:', error);
    } finally {
      isChanging = false;
    }
  }

  // Check if color is currently active
  function isActive(color: LightColor): boolean {
    return $myLightColor === color;
  }
</script>

<div class="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
  {#each lightButtons as { color, config, name } (color)}
    {@const active = isActive(color)}
    <button
      class="relative flex flex-col items-center justify-center gap-2 px-3 py-4 h-28 lg:h-32 rounded-xl transition-all active:scale-[0.98] group hover:shadow-md
        {active
        ? `border-2 ${config.borderClass} ring-1 ${config.borderClass} scale-[1.02] z-10 bg-slate-50 dark:bg-slate-800/50`
        : 'border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/30 hover:bg-slate-50 dark:hover:bg-slate-700/50'}"
      style={active ? `box-shadow: 0 0 0 4px ${config.hex}26` : ''}
      type="button"
      onclick={() => handleColorChange(color)}
      disabled={isChanging}
      aria-label="{active ? 'Turn off' : 'Set light to'} {name}"
      title="{name} {active ? '(Click to turn off)' : ''}"
    >
      {#if active}
        <span class="absolute top-2 right-2 flex h-3 w-3">
          <span
            class="animate-ping absolute inline-flex h-full w-full rounded-full {config.colorClass} opacity-75"
          ></span>
          <span class="relative inline-flex rounded-full h-3 w-3 {config.colorClass}"></span>
        </span>
      {/if}

      <span
        class="h-6 w-6 rounded-full {config.colorClass} shadow-md {active
          ? ''
          : 'opacity-80 group-hover:opacity-100'} transition-opacity flex-shrink-0"
      ></span>

      <div class="flex flex-col items-center gap-0.5 text-center w-full">
        <span class="text-xs font-semibold text-slate-700 dark:text-slate-200 line-clamp-1">
          {name}
        </span>
        {#if active && note.trim()}
          <span
            class="text-[10px] text-slate-600 dark:text-slate-300 font-medium line-clamp-1 mt-0.5"
          >
            "{note.trim()}"
          </span>
        {/if}
      </div>
    </button>
  {/each}
</div>
