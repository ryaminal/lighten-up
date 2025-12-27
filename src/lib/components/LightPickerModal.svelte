<script lang="ts">
  import { lights } from '$lib/stores';
  import { tick } from 'svelte';

  export let isOpen = false;
  export let onClose: () => void;
  export let onSelect: (color: string, message: string | null) => Promise<void>;
  export let currentColor: string | null = null;
  export let title: string = 'Select Light';
  export let subtitle: string | null = null;
  export let showMessageInput: boolean = false;
  export let messageLabel: string = 'Message';
  export let messagePlaceholder: string = 'Enter message';
  export let messageRequired: boolean = false;
  export let messageMaxLength: number = 60;
  export let submitLabel: string = 'Select';
  export let submitIcon: string = 'check';
  export let allowToggleOff: boolean = false;
  export let autoSubmitOnSelect: boolean = false;

  let message = '';
  let selectedColor: string | null = null;
  let isSubmitting = false;
  let inputElement: HTMLInputElement;

  $: remainingChars = messageMaxLength - message.length;
  $: canSubmit =
    !isSubmitting &&
    selectedColor !== null &&
    (!messageRequired || (messageRequired && message.trim().length > 0));

  // Get available light colors
  $: lightButtons = $lights
    ? $lights
        .filter((light) => light.enabled && light.color !== '#000000')
        .sort((a, b) => a.priority - b.priority)
        .map((light) => ({
          color: light.color,
          name: light.name,
          priority: light.priority,
        }))
    : [];

  // Focus input when modal opens
  $: if (isOpen && showMessageInput) {
    tick().then(() => {
      inputElement?.focus();
    });
  }

  // Reset state when modal closes
  $: if (!isOpen) {
    message = '';
    selectedColor = null;
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

  function handleClose() {
    if (!isSubmitting) {
      onClose();
    }
  }

  async function handleSubmit() {
    if (!canSubmit) return;

    isSubmitting = true;
    try {
      const finalMessage = message.trim() || null;
      await onSelect(selectedColor!, finalMessage);
      onClose();
    } catch (error) {
      console.error('Failed to select light:', error);
    } finally {
      isSubmitting = false;
    }
  }

  function handleKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape') {
      handleClose();
    } else if (e.key === 'Enter' && canSubmit && !showMessageInput) {
      handleSubmit();
    }
  }

  function handleBackdropClick(e: MouseEvent) {
    if (e.target === e.currentTarget) {
      handleClose();
    }
  }

  async function handleColorSelect(color: string) {
    let colorToSubmit: string;

    if (allowToggleOff && currentColor === color) {
      colorToSubmit = '#000000'; // Turn off
      selectedColor = '#000000';
    } else {
      colorToSubmit = color;
      selectedColor = color;
    }

    // Auto-submit if enabled - submit directly without waiting for state update
    if (autoSubmitOnSelect) {
      isSubmitting = true;
      try {
        const finalMessage = message.trim() || null;
        await onSelect(colorToSubmit, finalMessage);
        onClose();
      } catch (error) {
        console.error('Failed to select light:', error);
      } finally {
        isSubmitting = false;
      }
    }
  }
</script>

{#if isOpen}
  <div
    class="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
    on:click={handleBackdropClick}
    on:keydown={handleKeydown}
    role="button"
    tabindex="-1"
  >
    <div
      class="bg-white dark:bg-gray-900 rounded-xl shadow-2xl w-full max-w-md border border-gray-200 dark:border-gray-800"
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <div
        class="px-6 py-4 border-b border-gray-200 dark:border-gray-800 flex items-center justify-between"
      >
        <div>
          <h2 id="modal-title" class="text-lg font-bold text-gray-900 dark:text-white">
            {title}
          </h2>
          {#if subtitle}
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-0.5">
              {subtitle}
            </p>
          {/if}
        </div>
        <button
          type="button"
          class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
          on:click={handleClose}
          disabled={isSubmitting}
          aria-label="Close"
        >
          <span class="material-icons-round text-2xl">close</span>
        </button>
      </div>

      <div class="px-6 py-6">
        <div class="space-y-5">
          {#if showMessageInput}
            <div>
              <label
                for="message"
                class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2"
              >
                {messageLabel}
                {#if !messageRequired}
                  <span class="text-gray-500 dark:text-gray-400 font-normal">(Optional)</span>
                {/if}
              </label>
              <input
                id="message"
                type="text"
                bind:this={inputElement}
                bind:value={message}
                maxlength={messageMaxLength}
                placeholder={messagePlaceholder}
                class="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-800 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-600 focus:border-transparent transition-all"
                disabled={isSubmitting}
                on:keydown={(e) => e.key === 'Enter' && canSubmit && handleSubmit()}
              />
              <div class="flex justify-end items-center mt-2">
                <span
                  class="text-xs font-mono {remainingChars < 10
                    ? 'text-orange-500 dark:text-orange-400'
                    : 'text-gray-400 dark:text-gray-500'}"
                >
                  {remainingChars}
                </span>
              </div>
            </div>
          {/if}

          <div>
            <div class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3">
              Select Color
            </div>
            <div class="grid grid-cols-4 gap-2">
              {#each lightButtons as { color, name, priority } (color)}
                {@const isSelected = selectedColor === color}
                {@const isCurrent = currentColor === color}
                <button
                  type="button"
                  class="relative flex flex-col items-center justify-center gap-1.5 px-2 py-3 rounded-lg transition-all active:scale-95
                    {isSelected
                    ? 'border-2 bg-slate-50 dark:bg-slate-800/50'
                    : 'border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/30 hover:bg-slate-50 dark:hover:bg-slate-700/50'}"
                  style={isSelected
                    ? `border-color: ${color}; box-shadow: 0 0 0 2px ${color}26`
                    : ''}
                  on:click={() => handleColorSelect(color)}
                  disabled={isSubmitting}
                  aria-label="{isSelected ? 'Deselect' : 'Select'} {name}"
                  title={name}
                >
                  {#if isCurrent}
                    <span class="absolute -top-1 -right-1 flex h-4 w-4">
                      <span
                        class="absolute inline-flex h-full w-full rounded-full bg-green-500 opacity-75"
                      ></span>
                      <span
                        class="relative inline-flex rounded-full h-4 w-4 bg-green-500 items-center justify-center"
                      >
                        <span class="material-icons-round text-white text-[10px]">check</span>
                      </span>
                    </span>
                  {/if}

                  {#if isSelected && !isCurrent}
                    <span class="absolute top-1 right-1 flex h-2 w-2">
                      <span
                        class="animate-ping absolute inline-flex h-full w-full rounded-full opacity-75"
                        style="background-color: {color}"
                      ></span>
                      <span
                        class="relative inline-flex rounded-full h-2 w-2"
                        style="background-color: {color}"
                      ></span>
                    </span>
                  {/if}

                  <span
                    class="h-5 w-5 rounded-full shadow-sm {isSelected
                      ? ''
                      : 'opacity-80'} transition-opacity flex-shrink-0"
                    style="background-color: {color}"
                  ></span>

                  <span
                    class="text-[10px] font-semibold text-slate-700 dark:text-slate-200 line-clamp-1 text-center"
                  >
                    {name}
                  </span>

                  <span
                    class="{getPriorityBadgeClass(
                      priority
                    )} text-[8px] font-bold px-1 py-0.5 rounded-full uppercase tracking-wider"
                  >
                    {getPriorityLabel(priority)}
                  </span>
                </button>
              {/each}
            </div>
            {#if allowToggleOff}
              <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">
                Click your current light to turn it off
              </p>
            {/if}
          </div>
        </div>
      </div>

      {#if !autoSubmitOnSelect}
        <div
          class="px-6 py-4 bg-gray-50 dark:bg-gray-950 rounded-b-xl border-t border-gray-200 dark:border-gray-800 flex justify-end gap-3"
        >
          <button
            type="button"
            class="px-5 py-2.5 rounded-lg text-sm font-semibold text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-800 transition-colors"
            on:click={handleClose}
            disabled={isSubmitting}
          >
            Cancel
          </button>
          <button
            type="button"
            class="px-5 py-2.5 rounded-lg text-sm font-semibold bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center gap-2"
            on:click={handleSubmit}
            disabled={!canSubmit}
          >
            {#if isSubmitting}
              <span class="material-icons-round text-sm animate-spin">refresh</span>
              Submitting...
            {:else}
              <span class="material-icons-round text-sm">{submitIcon}</span>
              {submitLabel}
            {/if}
          </button>
        </div>
      {/if}
    </div>
  </div>
{/if}
