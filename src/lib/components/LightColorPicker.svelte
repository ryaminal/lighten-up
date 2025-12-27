<script lang="ts">
  import { setLightColor } from '$lib/tauri';
  import { myLightColor, lights } from '$lib/stores';

  // Note prop passed from parent
  let { note = '' }: { note?: string } = $props();

  // Dynamically get available lights from config
  let lightButtons = $derived(
    $lights
      ? $lights
          .filter((light) => light.enabled && light.color !== '#000000')
          .sort((a, b) => a.priority - b.priority)
          .map((light) => ({
            color: light.color,
            name: light.name,
          }))
      : []
  );

  let isChanging = $state(false);

  async function handleColorChange(color: string) {
    if (isChanging) return;

    // If clicking the currently active color, toggle it off
    const currentColor = $myLightColor;
    const targetColor = currentColor === color ? '#000000' : color;

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
  function isActive(color: string): boolean {
    return $myLightColor === color;
  }
</script>

<div class="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
  {#each lightButtons as { color, name } (color)}
    {@const active = isActive(color)}
    <button
      class="relative flex flex-col items-center justify-center gap-2 px-3 py-4 h-28 lg:h-32 rounded-xl transition-all active:scale-[0.98] group hover:shadow-md
        {active
        ? 'border-2 ring-1 scale-[1.02] z-10 bg-slate-50 dark:bg-slate-800/50'
        : 'border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/30 hover:bg-slate-50 dark:hover:bg-slate-700/50'}"
      style={active ? `border-color: ${color}; box-shadow: 0 0 0 4px ${color}26` : ''}
      type="button"
      onclick={() => handleColorChange(color)}
      disabled={isChanging}
      aria-label="{active ? 'Turn off' : 'Set light to'} {name}"
      title="{name} {active ? '(Click to turn off)' : ''}"
    >
      {#if active}
        <span class="absolute top-2 right-2 flex h-3 w-3">
          <span
            class="animate-ping absolute inline-flex h-full w-full rounded-full opacity-75"
            style="background-color: {color}"
          ></span>
          <span class="relative inline-flex rounded-full h-3 w-3" style="background-color: {color}"
          ></span>
        </span>
      {/if}

      <span
        class="h-6 w-6 rounded-full shadow-md {active
          ? ''
          : 'opacity-80 group-hover:opacity-100'} transition-opacity flex-shrink-0"
        style="background-color: {color}"
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
