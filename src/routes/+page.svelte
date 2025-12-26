<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import {
    initializeTauri,
    cleanupListeners,
    getPeers,
    getLights,
    getMyPeerName,
    getMyPeerId,
  } from '$lib/tauri';
  import {
    isLoading,
    error,
    peers,
    lights,
    myPeerName,
    myLightColor,
    myNote,
    myPeerId,
  } from '$lib/stores';
  import NavigationBar from '$lib/components/NavigationBar.svelte';
  import GlobalChat from '$lib/components/GlobalChat.svelte';
  import PriorityQueue from '$lib/components/PriorityQueue.svelte';
  import SettingsModal from '$lib/components/SettingsModal.svelte';
  import BottomStatusBar from '$lib/components/BottomStatusBar.svelte';
  import StatusPickerModal from '$lib/components/StatusPickerModal.svelte';

  let showSettings = false;
  let showStatusPicker = false;

  function updateMyStatusFromPeers(peersList: typeof $peers, myId: string) {
    const myPeer = peersList.find((p) => p.peer_id === myId);
    if (myPeer) {
      myLightColor.set(myPeer.light_state.color);
      myNote.set(myPeer.note || '');
    }
  }

  onMount(async () => {
    try {
      // Load initial data
      const [initialPeers, initialLights, initialName, initialPeerId] = await Promise.all([
        getPeers(),
        getLights(),
        getMyPeerName(),
        getMyPeerId(),
      ]);

      peers.set(initialPeers);
      lights.set(initialLights);
      myPeerName.set(initialName);
      myPeerId.set(initialPeerId);

      // Set initial status from peers list
      updateMyStatusFromPeers(initialPeers, initialPeerId);

      // Initialize Tauri event listeners
      await initializeTauri({
        onPeersChanged: (updatedPeers) => {
          console.log('[Peers] Updated:', updatedPeers.length, 'peers');
          peers.set(updatedPeers);
          // Update my status whenever peers change
          updateMyStatusFromPeers(updatedPeers, initialPeerId);
        },
        onLightsChanged: (updatedLights) => {
          console.log('[Lights] Updated:', updatedLights.length, 'lights', updatedLights);
          lights.set(updatedLights);
        },
        onChatMessage: (message) => {
          console.log('[Chat] Received message:', message);
        },
      });

      isLoading.set(false);
    } catch (e) {
      console.error('Failed to initialize:', e);
      error.set(e instanceof Error ? e.message : String(e));
      isLoading.set(false);
    }
  });

  onDestroy(async () => {
    await cleanupListeners();
  });
</script>

{#if $isLoading}
  <div class="h-screen w-full flex items-center justify-center bg-gray-50 dark:bg-[#1f2937]">
    <div class="text-center">
      <div
        class="animate-spin rounded-full h-12 w-12 border-b-2 border-[#3b82f6] mx-auto mb-4"
      ></div>
      <p class="text-gray-500 dark:text-gray-400">Loading...</p>
    </div>
  </div>
{:else if $error}
  <div class="h-screen w-full flex items-center justify-center bg-gray-50 dark:bg-[#1f2937]">
    <div
      class="max-w-md p-6 bg-white dark:bg-[#111827] rounded-lg shadow-lg border border-red-200 dark:border-red-900"
    >
      <h2 class="text-xl font-bold text-red-600 dark:text-red-400 mb-2">Error</h2>
      <p class="text-gray-700 dark:text-gray-300">{$error}</p>
    </div>
  </div>
{:else}
  <div class="h-screen w-full flex flex-col overflow-hidden bg-gray-50 dark:bg-[#1f2937]">
    <div class="flex flex-1 overflow-hidden">
      <NavigationBar onOpenSettings={() => (showSettings = true)} />
      <GlobalChat />
      <PriorityQueue />
    </div>
    <BottomStatusBar onOpenStatusPicker={() => (showStatusPicker = true)} />
  </div>

  {#if showSettings}
    <SettingsModal isOpen={showSettings} onClose={() => (showSettings = false)} />
  {/if}

  {#if showStatusPicker}
    <StatusPickerModal isOpen={showStatusPicker} onClose={() => (showStatusPicker = false)} />
  {/if}
{/if}

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    font-family:
      'Inter',
      -apple-system,
      BlinkMacSystemFont,
      'Segoe UI',
      Roboto,
      Oxygen,
      Ubuntu,
      Cantarell,
      sans-serif;
    background-color: #f3f4f6;
  }
  :global(body.dark) {
    background-color: #1f2937;
  }
</style>
