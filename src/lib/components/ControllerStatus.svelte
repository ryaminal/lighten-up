<script lang="ts">
  import { onMount } from 'svelte';
  import type { ControllerInfo, PeerRole } from '$lib/types/controller';
  import { getControllerInfo, getMyRole, becomeController, resignController } from '$lib/tauri';

  let loading = true;
  let controllerInfo: ControllerInfo | null = null;
  let myRole: PeerRole = 'Follower';
  let isProcessing = false;

  onMount(async () => {
    await loadControllerState();
    loading = false;
  });

  async function loadControllerState() {
    try {
      [controllerInfo, myRole] = await Promise.all([getControllerInfo(), getMyRole()]);
    } catch (e) {
      console.error('Failed to load controller state:', e);
    }
  }

  async function handleBecomeController() {
    if (isProcessing) return;

    isProcessing = true;
    try {
      await becomeController();
      await loadControllerState();
    } catch (e) {
      console.error('Failed to become controller:', e);
    } finally {
      isProcessing = false;
    }
  }

  async function handleResignController() {
    if (isProcessing) return;

    isProcessing = true;
    try {
      await resignController();
      await loadControllerState();
    } catch (e) {
      console.error('Failed to resign as controller:', e);
    } finally {
      isProcessing = false;
    }
  }

  $: isController = myRole === 'Controller';
</script>

<div
  class="bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-slate-200 dark:border-slate-700 p-6"
>
  <h2 class="text-lg font-bold text-slate-900 dark:text-white mb-4">Network Controller</h2>

  {#if loading}
    <p class="text-slate-500 text-sm">Loading...</p>
  {:else}
    <div class="space-y-4">
      <!-- Current Status -->
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-slate-700 dark:text-slate-300">Your Role</p>
          <p
            class="text-lg font-bold {isController
              ? 'text-blue-600 dark:text-blue-400'
              : 'text-slate-600 dark:text-slate-400'}"
          >
            {myRole}
          </p>
        </div>

        {#if controllerInfo && !isController}
          <div class="text-right">
            <p class="text-sm font-medium text-slate-700 dark:text-slate-300">Current Controller</p>
            <p class="text-sm text-slate-600 dark:text-slate-400">
              {controllerInfo.name}
            </p>
          </div>
        {/if}
      </div>

      <!-- Controller Toggle -->
      <div class="pt-4 border-t border-slate-200 dark:border-slate-700">
        {#if isController}
          <button
            on:click={handleResignController}
            disabled={isProcessing}
            class="w-full px-4 py-2 bg-slate-200 dark:bg-slate-700 text-slate-900 dark:text-white rounded-lg hover:bg-slate-300 dark:hover:bg-slate-600 transition-colors disabled:opacity-50 text-sm font-medium"
          >
            {isProcessing ? 'Resigning...' : 'Resign as Controller'}
          </button>
        {:else}
          <button
            on:click={handleBecomeController}
            disabled={isProcessing}
            class="w-full px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors disabled:opacity-50 text-sm font-medium"
          >
            {isProcessing ? 'Taking Control...' : 'Become Controller'}
          </button>
        {/if}
      </div>

      <!-- Info Text -->
      <p class="text-xs text-slate-500 dark:text-slate-400">
        {#if isController}
          As controller, you manage the light configuration for all peers on the network.
        {:else}
          The controller manages the light configuration. Only one peer can be controller at a time.
        {/if}
      </p>
    </div>
  {/if}
</div>
