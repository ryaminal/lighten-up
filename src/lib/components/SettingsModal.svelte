<script lang="ts">
  import { onMount } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';
  import { getLights } from '$lib/tauri';
  import type { LightConfig } from '$lib/generated/types';
  import PeerIdentitySection from './settings/PeerIdentitySection.svelte';
  import LightConfigSection from './settings/LightConfigSection.svelte';
  import {
    addNewLight,
    removeLight,
    updateLightDetails,
    moveLightPriority,
    normalizePriorities,
  } from '$lib/logic/settings/useLightOperations';
  import { validateUniqueColor } from '$lib/logic/settings/lightColorUtils';

  export let isOpen = false;
  export let onClose: () => void;

  let peerId = '';
  let peerName = '';
  let initialPeerName = '';
  let lights: LightConfig[] = [];
  let isLoading = true;
  let errorMessage = '';
  let lightTableContainer: HTMLDivElement | undefined;

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
      initialPeerName = name;
      lights = lightsData.sort((a, b) => a.priority - b.priority);
      lights = await normalizePriorities(lights, peerId);
    } catch (err) {
      errorMessage = `Failed to load settings: ${err}`;
    } finally {
      isLoading = false;
    }
  }

  async function savePeerName() {
    const trimmedName = peerName.trim();

    if (!trimmedName) {
      errorMessage = 'Display name cannot be empty';
      peerName = initialPeerName;
      return;
    }

    if (trimmedName === initialPeerName) {
      console.log('[Settings] Peer name unchanged, skipping save');
      return;
    }

    try {
      errorMessage = '';
      console.log('[Settings] Saving peer name:', trimmedName);
      await invoke('set_peer_name', { name: trimmedName });
      initialPeerName = trimmedName;
      console.log('[Settings] Peer name saved successfully:', trimmedName);
    } catch (err) {
      console.error('[Settings] Failed to save peer name:', err);
      errorMessage = `Failed to save name: ${err}`;
      peerName = initialPeerName;
    }
  }

  async function handleClose() {
    await savePeerName();
    onClose();
  }

  async function handleAddLight() {
    try {
      lights = await addNewLight(lights, peerId);
      setTimeout(() => {
        if (lightTableContainer) {
          lightTableContainer.scrollTop = lightTableContainer.scrollHeight;
        }
      }, 100);
    } catch (err) {
      errorMessage = `Failed to add light: ${err}`;
    }
  }

  async function handleDeleteLight(id: string) {
    try {
      lights = await removeLight(id);
    } catch (err) {
      errorMessage = `Failed to delete light: ${err}`;
    }
  }

  async function handleLightChange(light: LightConfig) {
    try {
      const validation = validateUniqueColor(light, lights);
      if (!validation.isValid && validation.duplicateLight) {
        errorMessage = `Color already used by "${validation.duplicateLight.name}". Each light must have a unique color.`;
        lights = await getLights().then((l) => l.sort((a, b) => a.priority - b.priority));
        return;
      }

      lights = await updateLightDetails(light, peerId);
      errorMessage = '';
    } catch (err) {
      errorMessage = `Failed to update light: ${err}`;
    }
  }

  async function handleMoveLightUp(index: number) {
    if (index === 0) return;
    try {
      const optimisticLights = [...lights];
      [optimisticLights[index - 1], optimisticLights[index]] = [
        optimisticLights[index],
        optimisticLights[index - 1],
      ];
      lights = optimisticLights;
      lights = await moveLightPriority(lights, index, index - 1, peerId);
    } catch (err) {
      errorMessage = `Failed to reorder lights: ${err}`;
      lights = await getLights().then((l) => l.sort((a, b) => a.priority - b.priority));
    }
  }

  async function handleMoveLightDown(index: number) {
    if (index === lights.length - 1) return;
    try {
      const optimisticLights = [...lights];
      [optimisticLights[index], optimisticLights[index + 1]] = [
        optimisticLights[index + 1],
        optimisticLights[index],
      ];
      lights = optimisticLights;
      lights = await moveLightPriority(lights, index, index + 1, peerId);
    } catch (err) {
      errorMessage = `Failed to reorder lights: ${err}`;
      lights = await getLights().then((l) => l.sort((a, b) => a.priority - b.priority));
    }
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      handleClose();
    }
  }
</script>

{#if isOpen}
  <div
    class="fixed inset-0 z-[60] flex items-center justify-center bg-gray-900/80 backdrop-blur-sm transition-all duration-200"
    on:click={handleClose}
    on:keydown={handleKeydown}
    role="button"
    tabindex="0"
  >
    <div
      class="relative w-full max-w-2xl border bg-white dark:bg-[#111827] text-gray-900 dark:text-gray-100 shadow-lg sm:rounded-lg overflow-hidden flex flex-col max-h-[85vh]"
      on:click|stopPropagation
      on:keydown={handleKeydown}
      role="dialog"
      aria-modal="true"
      tabindex="-1"
    >
      <!-- Header -->
      <div class="flex flex-col space-y-1.5 p-6 pb-4 border-b border-gray-200 dark:border-gray-800">
        <div class="flex items-center justify-between">
          <h3 class="font-semibold tracking-tight text-lg text-gray-900 dark:text-white">
            Settings
          </h3>
          <button
            class="rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-[#3b82f6] focus:ring-offset-2 disabled:pointer-events-none hover:bg-gray-100 dark:hover:bg-gray-800 p-1"
            on:click={handleClose}
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
        <div class="p-6 pt-6 space-y-8">
          <PeerIdentitySection {peerId} bind:peerName onSaveName={savePeerName} />

          <div class="h-px bg-gray-200 dark:border-gray-800"></div>

          <LightConfigSection
            {lights}
            bind:lightTableContainer
            onAddLight={handleAddLight}
            onMoveUp={handleMoveLightUp}
            onMoveDown={handleMoveLightDown}
            onLightChange={handleLightChange}
            onDeleteLight={handleDeleteLight}
          />

          {#if errorMessage}
            <div
              class="p-3 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm"
            >
              {errorMessage}
            </div>
          {/if}
        </div>
      {/if}
    </div>
  </div>
{/if}

<style>
</style>
