<script lang="ts">
  import { setLightColor } from '$lib/tauri';
  import type { LightColor } from '$lib/types';
  import { COLOR_CONFIG, type ColorConfig } from '$lib/config/colors';

  // Select which colors to display in the UI
  // Using a subset focused on hospital/healthcare workflow
  const displayedColors: LightColor[] = ['Green', 'Red', 'Blue', 'Magenta', 'Yellow', 'Off'];

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
    isChanging = true;
    try {
      await setLightColor(color);
    } catch (error) {
      console.error('Failed to set color:', error);
    } finally {
      isChanging = false;
    }
  }
</script>

<div class="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
  {#each lightButtons as { color, config } (color)}
    <button
      class="relative flex flex-col items-center justify-center gap-3 h-32 rounded-xl border transition-all active:scale-[0.98] group {config.buttonBorder} {config.buttonBg} {config.buttonBgHover} {config.buttonBorderDark} {config.buttonBgDark} {config.buttonBgHoverDark}"
      type="button"
      onclick={() => handleColorChange(color)}
      disabled={isChanging}
      aria-label="Set status to {config.label}"
    >
      <span class="h-5 w-5 rounded-full {config.colorClass} shadow-sm"></span>
      <p
        class="{config.labelColor} {config.labelColorDark} text-base font-bold text-center leading-tight px-3"
      >
        {config.label}
      </p>
    </button>
  {/each}
</div>
