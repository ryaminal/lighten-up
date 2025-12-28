<script lang="ts">
  import { peers, lights } from '$lib/stores';
  import type { PeerPresence } from '$lib/tauri';
  import { sendNotification } from '$lib/tauri';
  import { onMount, onDestroy } from 'svelte';
  import LightPickerModal from './LightPickerModal.svelte';

  let currentTime = Date.now();
  let intervalId: number;
  let isModalOpen = false;
  let selectedPeer: PeerPresence | null = null;
  let sortByName = false; // false = priority sort (default), true = alphabetical sort

  onMount(() => {
    intervalId = setInterval(() => {
      currentTime = Date.now();
    }, 1000);
  });

  onDestroy(() => {
    if (intervalId) clearInterval(intervalId);
  });

  // Get light config for a peer's current color
  function getLightConfig(peer: PeerPresence) {
    const colorHex = peer.light_state.color;
    const light = $lights?.find((l) => l.enabled && l.color === colorHex);

    // If status light is off (#000000), give it very low priority (high number)
    const isOff = colorHex === '#000000';

    return {
      name: light?.name || 'Unknown',
      priority: isOff ? 1000 : (light?.priority ?? 0),
      color: colorHex,
    };
  }

  // Calculate time in current state
  function getTimeInState(timestamp: number): string {
    const now = Math.floor(currentTime / 1000);
    const elapsed = now - timestamp;

    if (elapsed < 60) return `${elapsed}s ago`;
    if (elapsed < 3600) return `${Math.floor(elapsed / 60)}m ago`;
    if (elapsed < 86400) return `${Math.floor(elapsed / 3600)}h ago`;
    return `${Math.floor(elapsed / 86400)}d ago`;
  }

  // Sort peers by priority (lowest number = highest priority), then by time in state (oldest first)
  // OR alphabetically by peer name if sortByName is enabled
  $: sortedPeers = [...($peers || [])].sort((a, b) => {
    if (sortByName) {
      // Alphabetical sort by peer name
      return a.peer_name.localeCompare(b.peer_name);
    } else {
      // Priority sort (default)
      const aPriority = getLightConfig(a).priority;
      const bPriority = getLightConfig(b).priority;
      // Lower number = higher priority (0 is highest)
      if (aPriority !== bPriority) return aPriority - bPriority;
      // Then by time in state (oldest first)
      return a.light_state.timestamp - b.light_state.timestamp;
    }
  });

  // Force reactivity by creating a computed value that depends on both peers and currentTime
  $: peersWithTime = sortedPeers.map((peer) => ({
    ...peer,
    _renderKey: currentTime,
  }));

  function handlePeerClick(peer: PeerPresence) {
    selectedPeer = peer;
    isModalOpen = true;
  }

  function handleModalClose() {
    isModalOpen = false;
    selectedPeer = null;
  }

  async function handleSendNotification(color: string, message: string | null) {
    if (!selectedPeer) return;

    // Get light name for the selected color to use as default message
    const light = $lights?.find((l) => l.enabled && l.color === color);
    const lightName = light?.name || 'Notification';
    const finalMessage = message || lightName;

    await sendNotification(
      selectedPeer.peer_id,
      'patient-ready',
      finalMessage,
      undefined,
      color || undefined
    );
  }

  function toggleSort() {
    sortByName = !sortByName;
  }
</script>

<aside
  class="w-80 bg-white dark:bg-[#111827] border-l border-gray-200 dark:border-gray-800 flex flex-col z-10 shadow-soft relative hidden md:flex"
>
  <div
    class="h-16 px-5 border-b border-gray-200 dark:border-gray-800 flex items-center justify-between bg-white dark:bg-gray-950/50 backdrop-blur-sm sticky top-0"
  >
    <div>
      <h2 class="font-bold text-lg text-gray-800 dark:text-white">Priority Queue</h2>
      <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
        {sortedPeers.length} Active •
        {#if sortByName}
          {sortByName ? 'A-Z' : 'Priority'}
        {:else}
          <span class="font-bold text-blue-600 dark:text-blue-400">Priority</span>
        {/if}
      </p>
    </div>
    <button
      class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
      on:click={toggleSort}
      aria-label={sortByName ? 'Sort by priority' : 'Sort alphabetically'}
      title={sortByName ? 'Sort by priority' : 'Sort alphabetically'}
    >
      <span class="material-icons-round text-xl">{sortByName ? 'swap_vert' : 'sort'}</span>
    </button>
  </div>

  <div class="flex-1 overflow-y-auto p-3 space-y-3 custom-scrollbar">
    {#if sortedPeers.length === 0}
      <p class="text-gray-400 italic text-center mt-8">No peers online...</p>
    {:else}
      {#each peersWithTime as peer (peer.peer_id)}
        {@const config = getLightConfig(peer)}
        {@const priorityLabel =
          config.priority === 0
            ? 'Critical'
            : config.priority === 1
              ? 'Urgent'
              : config.priority === 2
                ? 'High'
                : config.priority === 3
                  ? 'Medium'
                  : 'Low'}
        {@const badgeClass =
          config.priority === 0
            ? 'bg-red-100 text-[#ef4444] dark:bg-red-900/30 dark:text-red-300'
            : config.priority === 1
              ? 'bg-orange-100 text-[#f97316] dark:bg-orange-900/30 dark:text-orange-300'
              : config.priority === 2
                ? 'bg-yellow-100 text-yellow-600 dark:bg-yellow-900/30 dark:text-yellow-300'
                : config.priority === 3
                  ? 'bg-blue-100 text-blue-600 dark:bg-blue-900/30 dark:text-blue-300'
                  : 'bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400'}
        {@const peerNotification = peer.notification_status}
        {@const hasNotificationForPeer =
          peerNotification !== undefined && peerNotification !== null}
        {@const notificationColor = hasNotificationForPeer ? peerNotification?.color : null}
        {@const isStatusLightOn = config.color !== '#000000'}
        {@const insetShadows = [
          isStatusLightOn ? `inset 4px 0 0 ${config.color}` : null,
          hasNotificationForPeer ? `inset -4px 0 0 ${notificationColor}` : null,
        ]
          .filter(Boolean)
          .join(', ')}
        {@const normalShadow = '0 1px 2px 0 rgb(0 0 0 / 0.05)'}
        {@const hoverShadow = '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)'}
        {@const boxShadowNormal = insetShadows ? `${normalShadow}, ${insetShadows}` : normalShadow}
        {@const boxShadowHover = insetShadows ? `${hoverShadow}, ${insetShadows}` : hoverShadow}

        <div
          class="group relative bg-white dark:bg-gray-900 rounded-lg p-3 transition-all cursor-pointer ring-1 ring-gray-100 dark:ring-gray-800"
          style="box-shadow: {boxShadowNormal}; --hover-shadow: {boxShadowHover};"
          on:mouseenter={(e) => (e.currentTarget.style.boxShadow = boxShadowHover)}
          on:mouseleave={(e) => (e.currentTarget.style.boxShadow = boxShadowNormal)}
          on:click={() => handlePeerClick(peer)}
          on:keydown={(e) => e.key === 'Enter' && handlePeerClick(peer)}
          role="button"
          tabindex="0"
          aria-label="Notify {peer.peer_name} that patient is ready"
        >
          <div class="flex justify-between items-start mb-2">
            <h3 class="font-semibold text-gray-900 dark:text-gray-100 text-sm">
              {peer.peer_name}
            </h3>
            {#if isStatusLightOn}
              <span
                class="{badgeClass} text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-wider flex-shrink-0"
              >
                {priorityLabel}
              </span>
            {/if}
          </div>
          <div class="flex justify-between items-center gap-2">
            <p class="text-xs text-gray-500 dark:text-gray-400 line-clamp-1 flex-1">
              {peer.note || config.name}
            </p>
            <span class="text-xs text-gray-400 dark:text-gray-500 font-mono flex-shrink-0"
              >{getTimeInState(peer.light_state.timestamp)}</span
            >
          </div>
        </div>
      {/each}
    {/if}
  </div>
</aside>

<LightPickerModal
  isOpen={isModalOpen}
  onClose={handleModalClose}
  onSelect={handleSendNotification}
  currentColor={null}
  title="Send Notification"
  subtitle={selectedPeer ? `To: ${selectedPeer.peer_name}` : ''}
  showMessageInput={true}
  messageLabel="Message"
  messagePlaceholder="Enter patient name or message"
  messageRequired={false}
  messageMaxLength={30}
  submitLabel="Send Notification"
  submitIcon="send"
  allowToggleOff={false}
/>

<style>
  .custom-scrollbar::-webkit-scrollbar {
    width: 6px;
  }
  .custom-scrollbar::-webkit-scrollbar-track {
    background: transparent;
  }
  .custom-scrollbar::-webkit-scrollbar-thumb {
    background-color: rgba(156, 163, 175, 0.5);
    border-radius: 20px;
  }
</style>
