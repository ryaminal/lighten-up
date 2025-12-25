<script lang="ts">
  import { onMount } from 'svelte';
  import type { LightColor, LightConfig, LightDefinition, LightDefinitionId } from '$lib/types';
  import { lightConfig } from '$lib/stores';
  import { updateLightDefinition, deleteLightDefinition } from '$lib/tauri';

  let loading = true;
  let editingLight: LightDefinition | null = null;
  let showEditModal = false;

  // Form state
  let editingForm = {
    color: 'Red' as LightColor,
    name: '',
    enabled: true,
  };

  $: config = $lightConfig;
  $: sortedDefinitions = config
    ? [...(config as LightConfig).definitions].sort((a, b) => a.order - b.order)
    : [];

  const colorClasses: Record<string, { bg: string; ring: string; text: string }> = {
    Black: { bg: 'bg-slate-800', ring: 'ring-slate-600', text: 'text-white' },
    Red: { bg: 'bg-red-500', ring: 'ring-red-200 dark:ring-red-900', text: 'text-white' },
    Green: { bg: 'bg-green-500', ring: 'ring-green-200 dark:ring-green-900', text: 'text-white' },
    Yellow: {
      bg: 'bg-yellow-400',
      ring: 'ring-yellow-100 dark:ring-yellow-900',
      text: 'text-slate-900',
    },
    Blue: { bg: 'bg-blue-500', ring: 'ring-blue-200 dark:ring-blue-900', text: 'text-white' },
    Magenta: {
      bg: 'bg-purple-500',
      ring: 'ring-purple-100 dark:ring-purple-900',
      text: 'text-white',
    },
    Cyan: { bg: 'bg-cyan-500', ring: 'ring-cyan-200 dark:ring-cyan-900', text: 'text-white' },
    White: {
      bg: 'bg-slate-100',
      ring: 'ring-slate-200 dark:ring-slate-700',
      text: 'text-slate-900',
    },
  };

  onMount(async () => {
    loading = false;
  });

  function openEditModal(light: LightDefinition | null = null) {
    if (light) {
      editingLight = light;
      editingForm = {
        color: light.color,
        name: light.name,
        enabled: light.enabled,
      };
    } else {
      editingLight = null;
      editingForm = {
        color: 'Red' as LightColor,
        name: '',
        enabled: true,
      };
    }
    showEditModal = true;
  }

  function closeEditModal() {
    editingLight = null;
    showEditModal = false;
  }

  async function saveLight() {
    if (!editingForm.name) {
      alert('Please fill in the name field');
      return;
    }

    try {
      const definition: LightDefinition = {
        id: editingLight?.id || crypto.randomUUID(),
        color: editingForm.color,
        name: editingForm.name,
        meaning: editingForm.name, // Use name as meaning for backend compatibility
        enabled: editingForm.enabled,
        order:
          editingLight?.order ??
          (sortedDefinitions.length > 0
            ? Math.max(...sortedDefinitions.map((d) => d.order)) + 1
            : 0),
        updated_at: BigInt(Date.now()),
        updated_by: 'me', // Will be set by backend
      };

      await updateLightDefinition(definition);
      closeEditModal();
    } catch (e) {
      console.error('Failed to save light:', e);
      alert('Failed to save light definition');
    }
  }

  async function deleteLight(id: LightDefinitionId) {
    if (!confirm('Are you sure you want to delete this light?')) return;

    try {
      await deleteLightDefinition(id);
    } catch (e) {
      console.error('Failed to delete light:', e);
      alert('Failed to delete light definition');
    }
  }

  function getColorClasses(color: string) {
    return colorClasses[color] || colorClasses.White;
  }
</script>

<div class="flex-1 overflow-y-auto bg-slate-50 dark:bg-[#1e293b]">
  <div class="max-w-7xl mx-auto p-8">
    <!-- Page Header -->
    <div class="flex flex-col md:flex-row md:items-start justify-between gap-4 mb-6">
      <div class="flex flex-col gap-2">
        <h1 class="text-slate-900 dark:text-white text-3xl font-bold tracking-tight">
          Light Configuration
        </h1>
        <p class="text-slate-500 dark:text-slate-400 text-base">
          Manage signal colors and their meanings. Changes sync across all peers immediately.
        </p>
      </div>
      <button
        on:click={() => openEditModal(null)}
        class="flex items-center justify-center gap-2 bg-primary hover:bg-blue-600 text-white px-5 py-2.5 rounded-lg text-sm font-bold shadow-md shadow-primary/20 transition-all active:scale-95 shrink-0"
      >
        <span class="text-xl">➕</span>
        <span>Add New Light</span>
      </button>
    </div>

    {#if loading}
      <div class="text-center py-12 text-slate-500">Loading configuration...</div>
    {:else if config}
      <!-- Lights Table -->
      <div
        class="bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-slate-200 dark:border-slate-700 overflow-hidden"
      >
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr
                class="bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-slate-700"
              >
                <th
                  class="py-4 px-6 text-xs font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wider"
                >
                  Signal Status
                </th>
                <th
                  class="py-4 px-6 text-xs font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wider"
                >
                  Status
                </th>
                <th
                  class="py-4 px-6 text-xs font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wider text-right"
                >
                  Actions
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-200 dark:divide-slate-700">
              {#each sortedDefinitions as light (light.id)}
                <tr class="group hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors">
                  <td class="py-4 px-6">
                    <div class="flex items-center gap-3">
                      <div
                        class="size-8 rounded-full {getColorClasses(light.color)
                          .bg} ring-2 {getColorClasses(light.color)
                          .ring} flex items-center justify-center shadow-sm"
                      ></div>
                      <div class="flex flex-col">
                        <span class="text-sm font-semibold text-slate-900 dark:text-white">
                          {light.name}
                        </span>
                        <span class="text-xs text-slate-500">
                          {light.color}
                        </span>
                      </div>
                    </div>
                  </td>
                  <td class="py-4 px-6">
                    {#if light.enabled}
                      <span
                        class="inline-flex items-center gap-1 text-xs text-green-600 dark:text-green-400"
                      >
                        <span class="inline-block size-1.5 rounded-full bg-green-500"></span>
                        Enabled
                      </span>
                    {:else}
                      <span class="inline-flex items-center gap-1 text-xs text-slate-500">
                        <span class="inline-block size-1.5 rounded-full bg-slate-400"></span>
                        Disabled
                      </span>
                    {/if}
                  </td>
                  <td class="py-4 px-6 text-right">
                    <div
                      class="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity"
                    >
                      <button
                        on:click={() => openEditModal(light)}
                        class="p-1.5 rounded-md text-slate-400 hover:text-primary hover:bg-primary/10 transition-colors"
                        title="Edit"
                      >
                        <span class="text-lg">✏️</span>
                      </button>
                      <button
                        on:click={() => deleteLight(light.id)}
                        class="p-1.5 rounded-md text-slate-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
                        title="Delete"
                      >
                        <span class="text-lg">🗑️</span>
                      </button>
                    </div>
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      </div>
    {:else}
      <div class="text-center py-12">
        <p class="text-slate-500 mb-4">No configuration loaded yet.</p>
        <button
          on:click={() => openEditModal(null)}
          class="bg-primary hover:bg-blue-600 text-white px-5 py-2.5 rounded-lg text-sm font-bold"
        >
          Create First Light
        </button>
      </div>
    {/if}
  </div>
</div>

<!-- Edit Modal -->
{#if showEditModal}
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
    <div class="bg-white dark:bg-slate-800 rounded-xl shadow-2xl max-w-md w-full p-6">
      <h2 class="text-xl font-bold text-slate-900 dark:text-white mb-4">
        {editingLight ? 'Edit Light' : 'Add New Light'}
      </h2>

      <form on:submit|preventDefault={saveLight} class="space-y-4">
        <div>
          <label
            for="color"
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Color
          </label>
          <select
            id="color"
            bind:value={editingForm.color}
            class="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-900 dark:text-white"
          >
            <option value="Red">Red</option>
            <option value="Green">Green</option>
            <option value="Yellow">Yellow</option>
            <option value="Blue">Blue</option>
            <option value="Magenta">Magenta</option>
            <option value="Cyan">Cyan</option>
            <option value="White">White</option>
            <option value="Black">Black</option>
          </select>
        </div>

        <div>
          <label
            for="name"
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Name
          </label>
          <input
            id="name"
            type="text"
            bind:value={editingForm.name}
            placeholder="e.g., Available"
            class="w-full px-3 py-2 border border-slate-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-900 dark:text-white"
          />
        </div>

        <div class="flex items-center gap-2">
          <input
            type="checkbox"
            bind:checked={editingForm.enabled}
            id="enabled"
            class="rounded border-slate-300 dark:border-slate-600"
          />
          <label for="enabled" class="text-sm text-slate-700 dark:text-slate-300"> Enabled </label>
        </div>

        <div class="flex gap-3 pt-4">
          <button
            type="button"
            on:click={closeEditModal}
            class="flex-1 px-4 py-2 border border-slate-300 dark:border-slate-600 text-slate-700 dark:text-slate-300 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="flex-1 px-4 py-2 bg-primary hover:bg-blue-600 text-white rounded-lg font-medium transition-colors"
          >
            Save
          </button>
        </div>
      </form>
    </div>
  </div>
{/if}
