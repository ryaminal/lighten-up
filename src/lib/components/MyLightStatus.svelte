<script lang="ts">
  import LightColorPicker from './LightColorPicker.svelte';
  import { myPeerName, myLightColor, myNote, lights } from '$lib/stores';
  import { setLightColor } from '$lib/tauri';
  import { COLOR_CONFIG } from '$lib/config/colors';
  import type { LightColor } from '$lib/generated/types';

  let note: string = '';
  const maxNoteLength = 60;
  let isSaving = false;

  // Keep note in sync with store
  $: {
    if ($myNote !== undefined) {
      note = $myNote || '';
    }
  }

  // Debounced note update - saves automatically as user types
  let saveTimeout: number | undefined;
  function handleNoteInput(e: Event) {
    const input = e.target as HTMLInputElement;
    note = input.value.slice(0, maxNoteLength);

    // Clear existing timeout
    if (saveTimeout) clearTimeout(saveTimeout);

    // Set new timeout to save after 500ms of no typing
    saveTimeout = setTimeout(() => {
      saveNoteRealtime($myLightColor);
    }, 500) as unknown as number;
  }

  async function saveNoteRealtime(color: string) {
    if (isSaving) return;
    isSaving = true;
    try {
      const trimmedNote = note.trim();
      await setLightColor(color as LightColor, trimmedNote || undefined);
    } catch (error) {
      console.error('Failed to save note:', error);
    } finally {
      isSaving = false;
    }
  }

  function getLightName(color: string): string {
    if (!$lights) return '';
    const light = $lights.find((l) => l.enabled && l.color === color);
    return light?.name || '';
  }

  $: currentConfig = COLOR_CONFIG[$myLightColor as LightColor] || COLOR_CONFIG.Off;
  $: isOff = $myLightColor === 'Off';
  $: statusMessage = $myNote?.trim() || '';
  $: lightName = getLightName($myLightColor);
</script>

<div class="flex flex-col h-full">
  <!-- Header with status -->
  <div class="flex justify-between items-start mb-6">
    <div>
      <div class="flex items-center gap-3 mb-1">
        <h1
          class="text-[#0d141b] dark:text-white text-2xl lg:text-3xl font-bold leading-tight tracking-tight"
        >
          {$myPeerName || 'Loading...'}
        </h1>
      </div>
      <div class="flex items-center gap-2">
        {#if isOff}
          <span class="flex h-3 w-3 rounded-full bg-slate-300 dark:bg-slate-600"></span>
          <p class="text-slate-500 dark:text-slate-400 text-sm font-bold tracking-wide uppercase">
            Status: OFF
          </p>
        {:else}
          <span class="relative flex h-3 w-3">
            <span
              class="animate-ping absolute inline-flex h-full w-full rounded-full {currentConfig.colorClass} opacity-75"
            ></span>
            <span
              class="relative inline-flex rounded-full h-3 w-3 {currentConfig.colorClass}"
              style="box-shadow: 0 0 8px {currentConfig.hex}40"
            ></span>
          </span>
          <div class="flex flex-col gap-0.5">
            {#if lightName}
              <p class="text-xs text-slate-500 dark:text-slate-400 font-medium">
                {lightName}
              </p>
            {/if}
            {#if statusMessage}
              <p class="text-sm tracking-wide text-slate-700 dark:text-slate-300">
                {statusMessage}
              </p>
            {/if}
          </div>
        {/if}
      </div>
    </div>
  </div>

  <!-- Note input and color picker section -->
  <div class="mb-6">
    <h2
      class="text-[#0d141b] dark:text-slate-200 text-xs font-bold uppercase tracking-wider mb-3 opacity-70"
    >
      Light Selection & Message
    </h2>

    <!-- Note input ABOVE color picker -->
    <div class="mb-4">
      <div class="relative w-full">
        <input
          type="text"
          class="block w-full rounded-xl border border-slate-200 dark:border-slate-600 bg-slate-50 dark:bg-slate-800/50 py-3 px-4 text-sm text-slate-900 dark:text-white placeholder:text-slate-400 focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all shadow-sm"
          placeholder="Add a custom message for this light (Optional)..."
          maxlength={maxNoteLength}
          value={note}
          oninput={handleNoteInput}
        />
      </div>
    </div>

    <!-- Color picker grid -->
    <LightColorPicker {note} />
  </div>

  <div class="mt-auto"></div>
</div>
