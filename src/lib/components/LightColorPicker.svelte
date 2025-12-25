<script lang="ts">
  import { setLightColor } from '$lib/tauri';
  import type { LightColor } from '$lib/types';

  type SemanticLight = {
    label: string;
    colorClass: string;
    buttonBorder: string;
    buttonBg: string;
    buttonBgHover: string;
    buttonBorderDark: string;
    buttonBgDark: string;
    buttonBgHoverDark: string;
    typeValue: LightColor;
    labelColor: string;
    labelColorDark: string;
  };
  const semanticLights: SemanticLight[] = [
    {
      label: 'Patient Ready',
      colorClass: 'bg-green-500',
      buttonBorder: 'border-green-200',
      buttonBg: 'bg-green-50',
      buttonBgHover: 'hover:bg-green-100',
      buttonBorderDark: 'dark:border-green-800',
      buttonBgDark: 'dark:bg-green-900/20',
      buttonBgHoverDark: 'dark:hover:bg-green-900/40',
      typeValue: 'Green',
      labelColor: 'text-green-900',
      labelColorDark: 'dark:text-green-100',
    },
    {
      label: 'Doctor Needed',
      colorClass: 'bg-red-500',
      buttonBorder: 'border-red-200',
      buttonBg: 'bg-red-50',
      buttonBgHover: 'hover:bg-red-100',
      buttonBorderDark: 'dark:border-red-800',
      buttonBgDark: 'dark:bg-red-900/20',
      buttonBgHoverDark: 'dark:hover:bg-red-900/40',
      typeValue: 'Red',
      labelColor: 'text-red-900',
      labelColorDark: 'dark:text-red-100',
    },
    {
      label: 'Assistance',
      colorClass: 'bg-blue-500',
      buttonBorder: 'border-blue-200',
      buttonBg: 'bg-blue-50',
      buttonBgHover: 'hover:bg-blue-100',
      buttonBorderDark: 'dark:border-blue-800',
      buttonBgDark: 'dark:bg-blue-900/20',
      buttonBgHoverDark: 'dark:hover:bg-blue-900/40',
      typeValue: 'Blue',
      labelColor: 'text-blue-900',
      labelColorDark: 'dark:text-blue-100',
    },
    {
      label: 'Vitals Taken',
      colorClass: 'bg-purple-500',
      buttonBorder: 'border-purple-200',
      buttonBg: 'bg-purple-50',
      buttonBgHover: 'hover:bg-purple-100',
      buttonBorderDark: 'dark:border-purple-800',
      buttonBgDark: 'dark:bg-purple-900/20',
      buttonBgHoverDark: 'dark:hover:bg-purple-900/40',
      typeValue: 'Purple',
      labelColor: 'text-purple-900',
      labelColorDark: 'dark:text-purple-100',
    },
    {
      label: 'Cleaning Req.',
      colorClass: 'bg-orange-400',
      buttonBorder: 'border-orange-200',
      buttonBg: 'bg-orange-50',
      buttonBgHover: 'hover:bg-orange-100',
      buttonBorderDark: 'dark:border-orange-800',
      buttonBgDark: 'dark:bg-orange-900/20',
      buttonBgHoverDark: 'dark:hover:bg-orange-900/40',
      typeValue: 'Orange',
      labelColor: 'text-orange-900',
      labelColorDark: 'dark:text-orange-100',
    },
    {
      label: 'Off',
      colorClass: 'bg-gray-400',
      buttonBorder: 'border-slate-200',
      buttonBg: 'bg-white',
      buttonBgHover: 'hover:bg-slate-50',
      buttonBorderDark: 'dark:border-slate-600',
      buttonBgDark: 'dark:bg-slate-800',
      buttonBgHoverDark: 'dark:hover:bg-slate-700',
      typeValue: 'Off',
      labelColor: 'text-slate-600',
      labelColorDark: 'dark:text-slate-300',
    },
  ];

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
  {#each semanticLights as opt (opt.label)}
    <button
      class="relative flex flex-col items-center justify-center gap-3 h-32 rounded-xl border transition-all active:scale-[0.98] group {opt.buttonBorder} {opt.buttonBg} {opt.buttonBgHover} {opt.buttonBorderDark} {opt.buttonBgDark} {opt.buttonBgHoverDark}"
      type="button"
      onclick={() => handleColorChange(opt.typeValue)}
      disabled={isChanging}
      aria-label="Set status to {opt.label}"
    >
      <span class="h-5 w-5 rounded-full {opt.colorClass} shadow-sm"></span>
      <p
        class="{opt.labelColor} {opt.labelColorDark} text-base font-bold text-center leading-tight px-3"
      >
        {opt.label}
      </p>
    </button>
  {/each}
</div>
