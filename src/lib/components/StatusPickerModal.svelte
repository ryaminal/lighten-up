<script lang="ts">
  import { myLightColor, lights, myNote } from '$lib/stores';
  import { setLightColor } from '$lib/tauri';
  // NOTE: Previously imported COLOR_CONFIG and LightColor were unused.
  // They have been removed to satisfy linting rules.

  export let isOpen = false;
  export let onClose: () => void;

  let selectedLightId: string | null = null;
  let note = '';
  let isUpdating = false;
  let errorMessage = '';

  $: availableLights = ($lights || []).filter((l) => l.enabled);
  $: currentColorHex = $myLightColor || '#000000';

  // Initialize note from store when modal opens
  $: if (isOpen) {
    note = $myNote || '';
    selectedLightId = null;
  }

  // Button is enabled if either color changed or note changed
  $: hasChanges = selectedLightId !== null || note !== ($myNote || '');

  async function handleUpdateStatus() {
    // Get the color from the selected light, or fall back to current color
    const selectedLight = availableLights.find((l) => l.id === selectedLightId);
    const colorToSet = selectedLight ? selectedLight.color : currentColorHex;

    try {
      isUpdating = true;
      errorMessage = '';

      // Pass null if note is empty string, otherwise pass the note value
      const noteValue = note.trim() === '' ? null : note;
      await setLightColor(colorToSet, noteValue || undefined);

      onClose();
      // Reset selections
      selectedLightId = null;
      note = '';
    } catch (err) {
      errorMessage = `Failed to update status: ${err}`;
    } finally {
      isUpdating = false;
    }
  }

  function handleLightSelect(lightId: string) {
    selectedLightId = lightId;
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      onClose();
    }
  }
</script>

{#if isOpen}
  <div
    class="fixed inset-0 z-[60] flex items-center justify-center bg-gray-900/80 backdrop-blur-sm transition-all duration-200"
    on:click={onClose}
    on:keydown={handleKeydown}
    role="button"
    tabindex="0"
  >
    <div
      class="relative w-full max-w-md border bg-white dark:bg-[#111827] text-gray-900 dark:text-gray-100 shadow-lg sm:rounded-lg overflow-hidden flex flex-col"
      on:click|stopPropagation
      on:keydown|stopPropagation
      role="dialog"
      aria-modal="true"
      tabindex="-1"
    >
      <!-- Header -->
      <div class="flex flex-col space-y-1.5 p-6 pb-4 border-b border-gray-200 dark:border-gray-800">
        <div class="flex items-center justify-between">
          <div>
            <h3 class="font-semibold tracking-tight text-lg text-gray-900 dark:text-white">
              Update Your Status
            </h3>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
              Select a light color to broadcast your status to the team.
            </p>
          </div>
          <button
            class="rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-[#3b82f6] focus:ring-offset-2 disabled:pointer-events-none hover:bg-gray-100 dark:hover:bg-gray-800 p-1"
            on:click={onClose}
            aria-label="Close"
          >
            <span class="material-icons-round text-lg">close</span>
          </button>
        </div>
      </div>

      <!-- Content -->
      <div class="p-6 space-y-6 overflow-y-auto max-h-[60vh]">
        <!-- Light Grid -->
        <div>
          <div class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-3 block">
            Select Status Light
          </div>
          <div class="grid grid-cols-4 gap-4">
            {#each availableLights as light (light.id)}
              {@const isSelected = selectedLightId === light.id}
              {@const isCurrent = currentColorHex === light.color}
              <button
                class="flex flex-col items-center gap-2 p-3 rounded-lg border-2 transition-all hover:shadow-md {isSelected
                  ? 'border-[#3b82f6] bg-blue-50 dark:bg-blue-900/20'
                  : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'}"
                on:click={() => handleLightSelect(light.id)}
              >
                <div class="relative">
                  <div
                    class="w-12 h-12 rounded-full shadow-sm transition-transform {isSelected
                      ? 'scale-110'
                      : 'scale-100'}"
                    style="background-color: {light.color}"
                  ></div>
                  {#if isCurrent}
                    <div
                      class="absolute -top-1 -right-1 w-5 h-5 bg-[#3b82f6] rounded-full flex items-center justify-center shadow-md"
                    >
                      <span class="material-symbols-outlined text-white text-xs">check</span>
                    </div>
                  {/if}
                </div>
                <span class="text-xs font-medium text-gray-700 dark:text-gray-300 text-center">
                  {light.name}
                </span>
              </button>
            {/each}
          </div>
        </div>

        <!-- Optional Note -->
        <div>
          <label
            class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2 block"
            for="status-note"
          >
            Optional Note
            <span class="text-gray-400 font-normal">(visible to team)</span>
          </label>
          <textarea
            id="status-note"
            class="flex min-h-[80px] w-full rounded-md border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-900 px-3 py-2 text-sm ring-offset-background placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 resize-none text-gray-900 dark:text-white"
            bind:value={note}
            placeholder="e.g., 'In exam room 4' or 'Taking break'"
            disabled={isUpdating}
          ></textarea>
        </div>

        {#if errorMessage}
          <div
            class="p-3 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm"
          >
            {errorMessage}
          </div>
        {/if}
      </div>

      <!-- Footer -->
      <div
        class="flex items-center justify-end gap-3 p-6 pt-4 border-t border-gray-200 dark:border-gray-800 bg-gray-50 dark:bg-gray-900/20"
      >
        <button
          class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-900 hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-900 dark:text-white h-10 px-4 py-2"
          on:click={onClose}
          disabled={isUpdating}
        >
          Cancel
        </button>
        <button
          class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 bg-[#3b82f6] text-white hover:bg-[#3b82f6]/90 h-10 px-4 py-2 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed"
          on:click={handleUpdateStatus}
          disabled={!hasChanges || isUpdating}
        >
          {isUpdating ? 'Updating...' : 'Update Status'}
        </button>
      </div>
    </div>
  </div>
{/if}
