<script lang="ts">
  import LightColorPicker from './LightColorPicker.svelte';
  import { myState } from '$lib/stores';
  import { setLightStatus } from '$lib/tauri';
  import { COLOR_CONFIG } from '$lib/config/colors';

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

  $: currentConfig = $myState ? COLOR_CONFIG[$myState.light_state.color] : COLOR_CONFIG.Off;
</script>

<div class="flex flex-col gap-8">
  <div class="flex flex-col gap-4">
    <div class="flex items-center gap-3 mb-4">
      <span class="h-3 w-3 rounded-full {currentConfig.colorClass}"></span>
      <h2 class="text-3xl font-bold text-slate-900 dark:text-white">
        {$myState?.name || 'Loading...'}
      </h2>
    </div>
    <p class="text-slate-600 dark:text-slate-400 text-sm flex items-center gap-2">
      Current status:
      <span class="font-semibold text-slate-900 dark:text-white">{currentConfig.label}</span>
    </p>
  </div>

  <div class="flex flex-col gap-4">
    <h3 class="text-sm font-semibold text-slate-700 dark:text-slate-300 uppercase tracking-wide">
      Activate Light with BlueNote
    </h3>
    <LightColorPicker />
  </div>

  <div class="flex flex-col gap-4">
    <label
      for="status-note"
      class="text-sm font-semibold text-slate-700 dark:text-slate-300 uppercase tracking-wide"
    >
      Add Note (Optional)
    </label>
    <div class="relative">
      <textarea
        id="status-note"
        class="w-full rounded-xl border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-4 py-3 text-slate-900 dark:text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary resize-none"
        placeholder="Add a note about the status..."
        rows="3"
        maxlength={maxNoteLength}
        value={note}
        oninput={handleNoteChange}
      ></textarea>
      <div class="absolute bottom-3 right-3 text-xs text-slate-400">
        {note.length}/{maxNoteLength}
      </div>
    </div>
  </div>

  <div class="flex gap-3">
    <button
      class="flex-1 px-6 py-3 rounded-xl bg-red-500 hover:bg-red-600 text-white font-semibold transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      onclick={turnOffLight}
      disabled={isSaving}
    >
      Turn Off Light
    </button>
    <button
      class="flex-1 px-6 py-3 rounded-xl border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 hover:bg-slate-50 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-200 font-semibold transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      onclick={cancelEdit}
      disabled={isSaving || !editing}
    >
      Cancel
    </button>
    <button
      class="flex-1 px-6 py-3 rounded-xl bg-primary hover:bg-primary/90 text-white font-semibold transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      onclick={saveNote}
      disabled={isSaving}
    >
      {isSaving ? 'Saving...' : 'Update'}
    </button>
  </div>
</div>
