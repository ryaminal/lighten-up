<script lang="ts">
  import { myLightColor, lights, myNote } from '$lib/stores';
  import { setLightColor } from '$lib/tauri';

  export let isOpen = false;
  export let onClose: () => void;

  let note = '';
  let isUpdating = false;
  let errorMessage = '';

  $: availableLights = ($lights || [])
    .filter((l) => l.enabled)
    .sort((a, b) => a.priority - b.priority);
  $: currentColorHex = $myLightColor || '#000000';

  // Initialize note from store when modal opens
  $: if (isOpen) {
    note = $myNote || '';
  }

  function getPriorityLabel(priority: number): string {
    if (priority === 0) return 'Critical';
    if (priority === 1) return 'Urgent';
    if (priority === 2) return 'High';
    if (priority === 3) return 'Medium';
    return 'Low';
  }

  function getPriorityBadgeClass(priority: number): string {
    if (priority === 0) return 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300';
    if (priority === 1)
      return 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-300';
    if (priority === 2)
      return 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300';
    if (priority === 3) return 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300';
    return 'bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400';
  }

  async function handleLightClick(lightColor: string) {
    if (isUpdating) return;

    try {
      isUpdating = true;
      errorMessage = '';

      // If clicking current light, turn it off (set to black/off)
      const colorToSet = lightColor === currentColorHex ? '#000000' : lightColor;

      // Pass current note value
      const noteValue = note.trim() === '' ? null : note;
      await setLightColor(colorToSet, noteValue || undefined);

      // Close modal after successful update
      onClose();
    } catch (err) {
      errorMessage = `Failed to update status: ${err}`;
    } finally {
      isUpdating = false;
    }
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
      class="relative w-full max-w-3xl border bg-white dark:bg-[#111827] text-gray-900 dark:text-gray-100 shadow-lg sm:rounded-lg overflow-hidden flex flex-col max-h-[85vh]"
      on:click|stopPropagation
      on:keydown|stopPropagation
      role="dialog"
      aria-modal="true"
      tabindex="-1"
    >
      <!-- Header -->
      <div
        class="flex items-center justify-between p-6 pb-4 border-b border-gray-200 dark:border-gray-800"
      >
        <div class="flex items-center gap-2">
          <span
            class="flex h-8 w-8 items-center justify-center rounded-full bg-[#3b82f6]/10 text-[#3b82f6]"
          >
            <span class="material-icons-round text-base">lightbulb</span>
          </span>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
            Available Status Lights
          </h3>
        </div>
        <button
          class="rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-[#3b82f6] focus:ring-offset-2 disabled:pointer-events-none hover:bg-gray-100 dark:hover:bg-gray-800 p-1"
          on:click={onClose}
          aria-label="Close"
        >
          <span class="material-icons-round text-lg">close</span>
        </button>
      </div>

      <!-- Content -->
      <div class="p-6 space-y-4 overflow-y-auto flex-1">
        <!-- Light Grid - 4 columns for better density -->
        <div class="grid grid-cols-4 gap-3">
          {#each availableLights as light (light.id)}
            {@const isCurrent = currentColorHex === light.color}
            <button
              class="flex flex-col items-center gap-2 p-3 rounded-lg border-2 transition-all hover:shadow-lg hover:scale-105 active:scale-95 {isCurrent
                ? 'border-green-500 bg-green-50 dark:bg-green-900/20'
                : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'} {isUpdating
                ? 'opacity-50 cursor-not-allowed'
                : 'cursor-pointer'}"
              on:click={() => handleLightClick(light.color)}
              disabled={isUpdating}
            >
              <div class="relative">
                <div
                  class="w-12 h-12 rounded-full shadow-md transition-all {isCurrent
                    ? 'ring-4 ring-green-500/30 scale-110'
                    : 'scale-100'}"
                  style="background-color: {light.color}"
                ></div>
                {#if isCurrent}
                  <div
                    class="absolute -top-1 -right-1 w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shadow-md"
                  >
                    <span class="material-icons-round text-white text-sm">check</span>
                  </div>
                {/if}
              </div>
              <div class="flex flex-col items-center gap-1 w-full">
                <span
                  class="text-xs font-semibold text-gray-900 dark:text-gray-100 text-center truncate w-full"
                >
                  {light.name}
                </span>
                <span
                  class="{getPriorityBadgeClass(
                    light.priority
                  )} text-[9px] font-bold px-1.5 py-0.5 rounded-full uppercase tracking-wider"
                >
                  {getPriorityLabel(light.priority)}
                </span>
              </div>
            </button>
          {/each}
        </div>

        <div class="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1.5 mt-2">
          <span class="material-icons-round text-sm">info</span>
          <span>Click your current status light to turn it off</span>
        </div>

        {#if errorMessage}
          <div
            class="p-3 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm flex items-center gap-2"
          >
            <span class="material-icons-round text-base">error</span>
            {errorMessage}
          </div>
        {/if}
      </div>
    </div>
  </div>
{/if}
