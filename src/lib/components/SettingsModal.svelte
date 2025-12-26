<script lang="ts">
  import { onMount } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';
  import { getLights, createLight, updateLight, deleteLight } from '$lib/tauri';
  import type { LightConfig } from '$lib/generated/types';

  export let isOpen = false;
  export let onClose: () => void;

  let peerId = '';
  let peerName = '';
  let lights: LightConfig[] = [];
  let isLoading = true;
  let isSaving = false;
  let errorMessage = '';
  let successMessage = '';

  onMount(async () => {
    await loadData();
  });

  async function loadData() {
    try {
      isLoading = true;
      const [id, name, lightsData] = await Promise.all([
        invoke<string>('get_my_peer_id'),
        invoke<string>('get_my_peer_name'),
        getLights(),
      ]);
      peerId = id;
      peerName = name;
      lights = lightsData;
    } catch (err) {
      errorMessage = `Failed to load settings: ${err}`;
    } finally {
      isLoading = false;
    }
  }

  async function handleSave() {
    if (!peerName.trim()) {
      errorMessage = 'Display name cannot be empty';
      return;
    }

    try {
      isSaving = true;
      errorMessage = '';
      successMessage = '';

      await invoke('set_peer_name', { name: peerName.trim() });

      successMessage = 'Settings saved successfully!';
      setTimeout(() => {
        successMessage = '';
        onClose();
      }, 1500);
    } catch (err) {
      errorMessage = `Failed to save settings: ${err}`;
    } finally {
      isSaving = false;
    }
  }

  function handleAddLight() {
    const newLight: LightConfig = {
      id: crypto.randomUUID(),
      color: '#3b82f6',
      name: 'New Light',
      enabled: true,
      priority: 1,
      updated_at: Math.floor(Date.now() / 1000),
      updated_by: peerId,
    };
    lights = [...lights, newLight];
  }

  async function handleDeleteLight(id: string) {
    try {
      await deleteLight(id);
      lights = lights.filter((l) => l.id !== id);
    } catch (err) {
      errorMessage = `Failed to delete light: ${err}`;
    }
  }

  async function handleLightChange(light: LightConfig) {
    try {
      // Update timestamp before sending to backend
      light.updated_at = Math.floor(Date.now() / 1000);
      light.updated_by = peerId;
      await updateLight(light);
    } catch (err) {
      errorMessage = `Failed to update light: ${err}`;
    }
  }

  function getPriorityLabel(priority: number): string {
    if (priority >= 3) return 'High';
    if (priority === 2) return 'Medium';
    return 'Low';
  }

  function setPriority(light: LightConfig, priority: string) {
    const priorityMap: Record<string, number> = {
      High: 3,
      Medium: 2,
      Low: 1,
    };
    light.priority = priorityMap[priority];
    handleLightChange(light);
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      onClose();
    }
  }

  function handleResetDefaults() {
    if (
      confirm(
        'Are you sure you want to reset to default settings? This will restore the default light configuration.'
      )
    ) {
      // TODO: Implement reset defaults
      console.log('Reset defaults');
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
      class="relative w-full max-w-2xl border bg-white dark:bg-[#111827] text-gray-900 dark:text-gray-100 shadow-lg sm:rounded-lg overflow-hidden flex flex-col max-h-[90vh]"
      on:click|stopPropagation
      role="dialog"
      aria-modal="true"
      tabindex="-1"
    >
      <!-- Header -->
      <div class="flex flex-col space-y-1.5 p-6 pb-2 border-b border-gray-200 dark:border-gray-800">
        <div class="flex items-center justify-between">
          <div>
            <h3 class="font-semibold tracking-tight text-lg text-gray-900 dark:text-white">
              User/Room Settings
            </h3>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
              Configure room identification and light signaling preferences.
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

      {#if isLoading}
        <div class="flex items-center justify-center py-12">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[#3b82f6]"></div>
        </div>
      {:else}
        <!-- Content -->
        <div class="p-6 pt-6 overflow-y-auto space-y-8 custom-scrollbar">
          <!-- Identification Section -->
          <div class="space-y-4">
            <div class="flex items-center gap-2">
              <span
                class="flex h-8 w-8 items-center justify-center rounded-full bg-[#3b82f6]/10 text-[#3b82f6]"
              >
                <span class="material-icons-round text-base">badge</span>
              </span>
              <h4 class="text-sm font-medium leading-none text-gray-900 dark:text-white">
                Identification
              </h4>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="grid gap-2">
                <label class="text-sm font-medium leading-none text-gray-700 dark:text-gray-300">
                  Room Identifier
                </label>
                <input
                  class="flex h-10 w-full rounded-md border border-gray-300 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 px-3 py-2 text-sm text-gray-500 dark:text-gray-400 cursor-not-allowed"
                  value={peerId}
                  disabled
                  readonly
                />
                <p class="text-[0.8rem] text-gray-500 dark:text-gray-400">
                  Unique system ID (read-only in some cases).
                </p>
              </div>

              <div class="grid gap-2">
                <label class="text-sm font-medium leading-none text-gray-700 dark:text-gray-300">
                  Display Name
                </label>
                <input
                  class="flex h-10 w-full rounded-md border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-900 px-3 py-2 text-sm ring-offset-background placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 text-gray-900 dark:text-white"
                  bind:value={peerName}
                  disabled={isSaving}
                />
                <p class="text-[0.8rem] text-gray-500 dark:text-gray-400">
                  Friendly name shown on dashboards.
                </p>
              </div>
            </div>
          </div>

          <div class="h-px bg-gray-200 dark:border-gray-800"></div>

          <!-- Light Configuration Section -->
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <span
                  class="flex h-8 w-8 items-center justify-center rounded-full bg-[#3b82f6]/10 text-[#3b82f6]"
                >
                  <span class="material-icons-round text-base">lightbulb</span>
                </span>
                <h4 class="text-sm font-medium leading-none text-gray-900 dark:text-white">
                  Light Configuration
                </h4>
              </div>
              <button
                class="inline-flex items-center justify-center rounded-md text-xs font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-900 hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-900 dark:text-white h-8 px-3"
                on:click={handleAddLight}
              >
                <span class="material-symbols-outlined text-sm mr-1.5">add</span>
                Add Light
              </button>
            </div>

            <div class="rounded-md border border-gray-200 dark:border-gray-800">
              <!-- Table Header -->
              <div
                class="grid grid-cols-12 gap-4 p-3 bg-gray-50 dark:bg-gray-900/50 border-b border-gray-200 dark:border-gray-800 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider"
              >
                <div class="col-span-1 text-center">Color</div>
                <div class="col-span-6">Light Name</div>
                <div class="col-span-3">Priority</div>
                <div class="col-span-2 text-right">Actions</div>
              </div>

              <!-- Table Rows -->
              {#each lights as light (light.id)}
                <div
                  class="grid grid-cols-12 gap-4 p-3 items-center border-b border-gray-200 dark:border-gray-800 last:border-0 hover:bg-gray-50 dark:hover:bg-gray-900/30 transition-colors group"
                >
                  <!-- Color Picker -->
                  <div class="col-span-1 flex justify-center relative">
                    <div
                      class="h-6 w-6 rounded-full ring-offset-background transition-all cursor-pointer ring-2 ring-transparent group-hover:ring-gray-300 dark:group-hover:ring-gray-700 shadow-sm"
                      style="background-color: {light.color}"
                    ></div>
                    <input
                      class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                      type="color"
                      bind:value={light.color}
                      on:change={() => handleLightChange(light)}
                    />
                  </div>

                  <!-- Light Name -->
                  <div class="col-span-6">
                    <input
                      class="flex h-8 w-full rounded-md border border-transparent bg-transparent px-2 py-1 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-[#3b82f6] disabled:cursor-not-allowed disabled:opacity-50 hover:bg-gray-100 dark:hover:bg-gray-900 focus:bg-white dark:focus:bg-gray-900 text-gray-900 dark:text-white transition-all"
                      bind:value={light.name}
                      on:change={() => handleLightChange(light)}
                    />
                  </div>

                  <!-- Priority Dropdown -->
                  <div class="col-span-3">
                    <select
                      class="flex h-8 w-full items-center justify-between rounded-md border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-900 px-2 py-1 text-xs shadow-sm ring-offset-background placeholder:text-gray-500 focus:outline-none focus:ring-1 focus:ring-[#3b82f6] disabled:cursor-not-allowed disabled:opacity-50 text-gray-900 dark:text-white"
                      value={getPriorityLabel(light.priority)}
                      on:change={(e) => setPriority(light, e.currentTarget.value)}
                    >
                      <option class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white"
                        >High</option
                      >
                      <option class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white"
                        >Medium</option
                      >
                      <option class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white"
                        >Low</option
                      >
                    </select>
                  </div>

                  <!-- Delete Button -->
                  <div class="col-span-2 flex justify-end">
                    <button
                      class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 hover:bg-red-50 dark:hover:bg-red-900/10 hover:text-red-600 dark:hover:text-red-400 h-8 w-8 text-gray-400"
                      on:click={() => handleDeleteLight(light.id)}
                      aria-label="Delete light"
                    >
                      <span class="material-symbols-outlined text-lg">delete</span>
                    </button>
                  </div>
                </div>
              {/each}

              {#if lights.length === 0}
                <div class="p-8 text-center text-gray-500 dark:text-gray-400">
                  <span class="material-symbols-outlined text-4xl mb-2 opacity-50">lightbulb</span>
                  <p class="text-sm">No lights configured. Click "Add Light" to get started.</p>
                </div>
              {/if}
            </div>
          </div>

          {#if errorMessage}
            <div
              class="p-3 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm"
            >
              {errorMessage}
            </div>
          {/if}

          {#if successMessage}
            <div
              class="p-3 rounded-lg bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 text-green-800 dark:text-green-200 text-sm"
            >
              {successMessage}
            </div>
          {/if}
        </div>

        <!-- Footer -->
        <div
          class="flex items-center justify-between p-6 border-t border-gray-200 dark:border-gray-800 bg-gray-50 dark:bg-gray-900/20"
        >
          <button
            class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 hover:bg-gray-100 dark:hover:bg-gray-800 hover:text-gray-900 dark:hover:text-white h-10 px-4 py-2 text-gray-500 dark:text-gray-400"
            on:click={handleResetDefaults}
          >
            <span class="material-symbols-outlined text-base mr-2">restart_alt</span>
            Reset Defaults
          </button>
          <div class="flex gap-3">
            <button
              class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-900 hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-900 dark:text-white h-10 px-4 py-2"
              on:click={onClose}
              disabled={isSaving}
            >
              Cancel
            </button>
            <button
              class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 bg-[#3b82f6] text-white hover:bg-[#3b82f6]/90 h-10 px-4 py-2 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed"
              on:click={handleSave}
              disabled={isSaving}
            >
              {isSaving ? 'Saving...' : 'Save Changes'}
            </button>
          </div>
        </div>
      {/if}
    </div>
  </div>
{/if}

<style>
  .custom-scrollbar::-webkit-scrollbar {
    width: 6px;
  }
  .custom-scrollbar::-webkit-scrollbar-track {
    background: transparent;
  }
  .custom-scrollbar::-webkit-scrollbar-thumb {
    background-color: rgba(156, 163, 175, 0.3);
    border-radius: 20px;
  }
</style>
