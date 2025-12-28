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
    notification,
    setPeerNotification,
  } from '$lib/stores';
  import NavigationBar from '$lib/components/NavigationBar.svelte';
  import GlobalChat from '$lib/components/GlobalChat.svelte';
  import PriorityQueue from '$lib/components/PriorityQueue.svelte';
  import SettingsModal from '$lib/components/SettingsModal.svelte';
  import BottomStatusBar from '$lib/components/BottomStatusBar.svelte';
  import LightPickerModal from '$lib/components/LightPickerModal.svelte';
  import { setLightColor } from '$lib/tauri';

  let showSettings = false;
  let showStatusPicker = false;

  async function handleStatusSelect(color: string, message: string | null) {
    await setLightColor(color, message || undefined);
  }

  function updateMyStatusFromPeers(peersList: typeof $peers, myId: string) {
    const myPeer = peersList.find((p) => p.peer_id === myId);
    if (myPeer) {
      console.log('[Status] Updating my status from peers:', {
        name: myPeer.peer_name,
        color: myPeer.light_state.color,
        note: myPeer.note,
      });
      myPeerName.set(myPeer.peer_name);
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
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore - Notification type exists but linter cache is stale
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        onNotification: (notif: any) => {
          console.log('[Notification] Received:', notif);
          // Store in global notification store (for backwards compatibility)
          notification.set({
            type: notif.type,
            message: notif.message,
            targetPeerId: notif.target_peer_id,
            senderPeerId: notif.sender_peer_id,
            timestamp: notif.timestamp,
            priority: notif.priority,
            color: notif.color,
          });
          // Also store in peer-specific notifications map
          setPeerNotification(notif.target_peer_id, {
            type: notif.type,
            message: notif.message,
            targetPeerId: notif.target_peer_id,
            senderPeerId: notif.sender_peer_id,
            timestamp: notif.timestamp,
            priority: notif.priority,
            color: notif.color,
          });
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
    <LightPickerModal
      isOpen={showStatusPicker}
      onClose={() => (showStatusPicker = false)}
      onSelect={handleStatusSelect}
      currentColor={$myLightColor}
      title="Change Status Light"
      showMessageInput={false}
      submitLabel="Update Status"
      submitIcon="check"
      allowToggleOff={true}
      autoSubmitOnSelect={true}
    />
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
