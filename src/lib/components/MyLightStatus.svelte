<script lang="ts">
  import LightColorPicker from './LightColorPicker.svelte';
  import { myState } from '$lib/stores';
  import { setLightStatus } from '$lib/tauri';
  import type { LightColor } from '$lib/types';

  const labelMap: Record<LightColor, string> = {
    Green: 'Patient Ready',
    Red: 'Doctor Needed',
    Blue: 'Assistance',
    Purple: 'Vitals Taken',
    Orange: 'Cleaning Req.',
    Yellow: 'Cleaning Req.',
    White: 'Available',
    Off: 'OFF',
  };
  const colorClassMap: Record<LightColor, string> = {
    Green: 'bg-green-500',
    Red: 'bg-red-500',
    Blue: 'bg-blue-500',
    Purple: 'bg-purple-500',
    Orange: 'bg-orange-400',
    Yellow: 'bg-orange-400',
    White: 'bg-white',
    Off: 'bg-slate-300 dark:bg-slate-600',
  };

  let note: string = '';
  const maxNoteLength = 140;
  let editing = false;
  let isSaving = false;

  // Keep note in sync with store
  $: {
    if ($myState && !editing) {
      note = $myState.note || '';
    }
  }

  function handleNoteChange(e: Event) {
    editing = true;
    note = (e.target as HTMLTextAreaElement).value.slice(0, maxNoteLength);
  }

  async function saveNote() {
    if (!$myState || isSaving) return;
    isSaving = true;
    try {
      // Send current color and new note
      const trimmedNote = note.trim();
      await setLightStatus($myState.light_state.color, trimmedNote || undefined);
      editing = false;
    } catch (error) {
      console.error('Failed to save note:', error);
    } finally {
      isSaving = false;
    }
  }

  function cancelEdit() {
    editing = false;
    note = $myState?.note || '';
  }

  async function turnOffLight() {
    if (!$myState || isSaving) return;
    isSaving = true;
    try {
      await setLightStatus('Off', note || undefined);
    } catch (error) {
      console.error('Failed to turn off light:', error);
    } finally {
      isSaving = false;
    }
  }
</script>

{#if $myState}
  <div class="flex justify-between items-start mb-8">
    <div>
      <div class="flex items-center gap-3 mb-2">
        <h1 class="text-[#0d141b] dark:text-white text-3xl font-bold leading-tight tracking-tight">
          {$myState.name} - Nurse Call
        </h1>
      </div>
      <div class="flex items-center gap-2">
        <span class="flex h-3 w-3 rounded-full {colorClassMap[$myState.light_state.color]}"></span>
        <p class="text-[#4c739a] dark:text-slate-400 text-base font-medium leading-normal">
          Status: {labelMap[$myState.light_state.color]}
        </p>
      </div>
    </div>
  </div>

  <div class="mb-8">
    <h2
      class="text-[#0d141b] dark:text-slate-200 text-sm font-bold uppercase tracking-wide mb-6 flex items-center gap-2"
    >
      Activate Light
    </h2>
    <LightColorPicker />
  </div>

  <div class="flex-1 flex flex-col min-h-[150px]">
    <label
      for="mynote"
      class="text-[#0d141b] dark:text-slate-200 text-sm font-bold uppercase tracking-wide mb-3 flex items-center gap-2"
    >
      Add Note
    </label>
    <div class="relative flex-1">
      <textarea
        id="mynote"
        class="w-full h-full resize-none rounded-xl border border-slate-200 dark:border-slate-600 bg-slate-50 dark:bg-slate-800 p-5 text-base text-slate-900 dark:text-white placeholder:text-slate-400 focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all"
        bind:value={note}
        maxlength={maxNoteLength}
        on:input={handleNoteChange}
        placeholder="Type an optional message for the team..."
      ></textarea>
      <div class="absolute bottom-4 right-4 text-xs text-slate-400 font-medium">
        {note.length}/{maxNoteLength}
      </div>
    </div>
  </div>

  <div
    class="mt-8 flex justify-between gap-4 pt-8 border-t border-slate-100 dark:border-slate-700 items-center"
  >
    <button
      type="button"
      class="flex items-center gap-2 px-6 py-3 rounded-lg border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-400 font-bold hover:bg-slate-50 dark:hover:bg-slate-800 hover:text-red-500 dark:hover:text-red-400 transition-colors"
      on:click={turnOffLight}
    >
      Turn Off Light
    </button>
    <div class="flex gap-3">
      <button
        type="button"
        class="px-8 py-3 rounded-lg text-slate-600 dark:text-slate-300 font-bold hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
        on:click={cancelEdit}
      >
        Cancel
      </button>
      <button
        type="button"
        class="px-10 py-3 rounded-lg bg-slate-900 dark:bg-white text-white dark:text-slate-900 font-bold shadow-lg hover:shadow-xl transition-all active:scale-95"
        on:click={saveNote}
      >
        Update
      </button>
    </div>
  </div>
{/if}
