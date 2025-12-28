<script lang="ts">
  import { myLightColor, lights, peers, notification } from '$lib/stores';
  import { onMount, onDestroy } from 'svelte';
  import { clearNotification, getMyPeerId } from '$lib/tauri';

  export let onOpenStatusPicker: () => void;

  // myLightColor is a hex string
  $: colorHex = $myLightColor || '#9ca3af';
  $: currentLight = $lights?.find((l) => l.enabled && l.color === colorHex);
  $: statusName = currentLight?.name || 'Off';
  $: isUrgent = currentLight?.priority === 0;
  $: peerCount = $peers?.length || 0;

  // Notification display
  let currentTime = Date.now();
  let intervalId: number | undefined;

  $: notificationWithTime = $notification
    ? {
        ...$notification,
        _renderKey: currentTime,
      }
    : null;

  // Get light name from notification color
  $: notificationLightName = notificationWithTime?.color
    ? $lights?.find((l) => l.enabled && l.color === notificationWithTime.color)?.name
    : null;

  onMount(() => {
    intervalId = setInterval(() => {
      currentTime = Date.now();
    }, 1000);
  });

  onDestroy(() => {
    if (intervalId) clearInterval(intervalId);
  });

  function getTimeAgo(timestamp: number): string {
    // Backend sends timestamps in seconds, convert to milliseconds
    const timestampMs = timestamp * 1000;
    const seconds = Math.floor((Date.now() - timestampMs) / 1000);
    if (seconds < 60) return `${seconds}s ago`;
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}m ago`;
    const hours = Math.floor(minutes / 60);
    return `${hours}h ago`;
  }

  function getNotificationStyles(type: string, customColor?: string) {
    // If custom color is provided, use it with inline styles
    if (customColor) {
      return {
        icon: 'notifications',
        customColor: customColor,
        useCustomColor: true,
      };
    }

    // Otherwise fall back to type-based styles
    switch (type) {
      case 'patient-ready':
        return {
          icon: 'person',
          bgClass: 'bg-blue-50 dark:bg-blue-900/20',
          borderClass: 'border-blue-200 dark:border-blue-800',
          dotClass: 'bg-blue-500',
          iconClass: 'text-blue-600 dark:text-blue-400',
          labelClass: 'text-blue-700 dark:text-blue-300',
          textClass: 'text-blue-900 dark:text-blue-200',
          timeClass: 'text-blue-600 dark:text-blue-400',
          buttonClass:
            'text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-200',
          useCustomColor: false,
        };
      case 'room-ready':
        return {
          icon: 'check_circle',
          bgClass: 'bg-green-50 dark:bg-green-900/20',
          borderClass: 'border-green-200 dark:border-green-800',
          dotClass: 'bg-green-500',
          iconClass: 'text-green-600 dark:text-green-400',
          labelClass: 'text-green-700 dark:text-green-300',
          textClass: 'text-green-900 dark:text-green-200',
          timeClass: 'text-green-600 dark:text-green-400',
          buttonClass:
            'text-green-600 dark:text-green-400 hover:text-green-800 dark:hover:text-green-200',
          useCustomColor: false,
        };
      case 'urgent-assist':
        return {
          icon: 'priority_high',
          bgClass: 'bg-red-50 dark:bg-red-900/20',
          borderClass: 'border-red-200 dark:border-red-800',
          dotClass: 'bg-red-500',
          iconClass: 'text-red-600 dark:text-red-400',
          labelClass: 'text-red-700 dark:text-red-300',
          textClass: 'text-red-900 dark:text-red-200',
          timeClass: 'text-red-600 dark:text-red-400',
          buttonClass: 'text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-200',
          useCustomColor: false,
        };
      case 'general-message':
        return {
          icon: 'notifications',
          bgClass: 'bg-gray-50 dark:bg-gray-900/20',
          borderClass: 'border-gray-200 dark:border-gray-800',
          dotClass: 'bg-gray-500',
          iconClass: 'text-gray-600 dark:text-gray-400',
          labelClass: 'text-gray-700 dark:text-gray-300',
          textClass: 'text-gray-900 dark:text-gray-200',
          timeClass: 'text-gray-600 dark:text-gray-400',
          buttonClass:
            'text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200',
          useCustomColor: false,
        };
      default:
        return {
          icon: 'notifications',
          bgClass: 'bg-blue-50 dark:bg-blue-900/20',
          borderClass: 'border-blue-200 dark:border-blue-800',
          dotClass: 'bg-blue-500',
          iconClass: 'text-blue-600 dark:text-blue-400',
          labelClass: 'text-blue-700 dark:text-blue-300',
          textClass: 'text-blue-900 dark:text-blue-200',
          timeClass: 'text-blue-600 dark:text-blue-400',
          buttonClass:
            'text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-200',
          useCustomColor: false,
        };
    }
  }

  function dismissNotification() {
    // Clear from backend
    getMyPeerId().then((myPeerId) => {
      clearNotification(myPeerId);
    });
    // Clear from store
    notification.set(null);
  }
</script>

<footer
  class="bg-white dark:bg-[#111827] border-t border-gray-200 dark:border-gray-800 h-16 shrink-0 flex items-center justify-between px-6 z-30 relative shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.05)] dark:shadow-none"
>
  <div class="flex items-center">
    <button
      class="group flex items-center gap-3 pl-1 pr-4 py-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800/50 transition-all border border-transparent hover:border-gray-200 dark:hover:border-gray-700"
      on:click={onOpenStatusPicker}
      aria-label="Change status"
    >
      <div class="relative flex h-3 w-3">
        {#if isUrgent}
          <span
            class="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#ef4444] opacity-75"
          ></span>
        {/if}
        <span class="relative inline-flex rounded-full h-3 w-3" style="background-color: {colorHex}"
        ></span>
      </div>
      <div class="flex flex-col items-start">
        <span
          class="text-[10px] font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400"
          >Current Status</span
        >
        <div class="flex items-center gap-1.5">
          <span
            class="text-sm font-bold text-gray-900 dark:text-white group-hover:text-[#3b82f6] transition-colors"
            >{statusName}</span
          >
          <span class="material-symbols-outlined text-base text-gray-400 group-hover:text-[#3b82f6]"
            >expand_less</span
          >
        </div>
      </div>
    </button>
  </div>
  <div
    class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 hidden md:flex items-center gap-10"
  >
    {#if notificationWithTime}
      {@const styles = getNotificationStyles(notificationWithTime.type, notificationWithTime.color)}
      {#if styles.useCustomColor && styles.customColor}
        <div
          class="flex items-center gap-3 px-4 py-2 rounded-lg border-2"
          style="background-color: {styles.customColor}15; border-color: {styles.customColor}40"
        >
          <div class="relative flex h-2 w-2">
            <span
              class="animate-ping absolute inline-flex h-full w-full rounded-full opacity-75"
              style="background-color: {styles.customColor}"
            ></span>
            <span
              class="relative inline-flex rounded-full h-2 w-2"
              style="background-color: {styles.customColor}"
            ></span>
          </div>
          <div class="flex flex-col">
            {#if notificationLightName && notificationWithTime.message !== notificationLightName}
              <span
                class="text-[10px] font-bold uppercase tracking-wider leading-none mb-1"
                style="color: {styles.customColor}dd">{notificationLightName}</span
              >
              <span class="text-sm font-medium text-gray-900 dark:text-gray-200"
                >{notificationWithTime.message}</span
              >
            {:else if notificationLightName}
              <span class="text-sm font-medium text-gray-900 dark:text-gray-200"
                >{notificationLightName}</span
              >
            {:else}
              <span class="text-sm font-medium text-gray-900 dark:text-gray-200"
                >{notificationWithTime.message}</span
              >
            {/if}
          </div>
          <span class="text-xs ml-2" style="color: {styles.customColor}dd"
            >{getTimeAgo(notificationWithTime.timestamp)}</span
          >
          <button
            on:click={dismissNotification}
            class="ml-2 hover:opacity-70 transition-opacity"
            style="color: {styles.customColor}"
            aria-label="Dismiss notification"
          >
            <span class="material-symbols-outlined text-base">close</span>
          </button>
        </div>
      {:else}
        <div
          class="flex items-center gap-3 {styles.bgClass} px-4 py-2 rounded-lg border {styles.borderClass}"
        >
          <div class="relative flex h-2 w-2">
            <span
              class="animate-ping absolute inline-flex h-full w-full rounded-full {styles.dotClass} opacity-75"
            ></span>
            <span class="relative inline-flex rounded-full h-2 w-2 {styles.dotClass}"></span>
          </div>
          <span class="text-sm font-medium {styles.textClass}">{notificationWithTime.message}</span>
          <span class="text-xs {styles.timeClass} ml-2"
            >{getTimeAgo(notificationWithTime.timestamp)}</span
          >
          <button
            on:click={dismissNotification}
            class="ml-2 {styles.buttonClass}"
            aria-label="Dismiss notification"
          >
            <span class="material-symbols-outlined text-base">close</span>
          </button>
        </div>
      {/if}
    {/if}
  </div>
  <div class="flex items-center gap-4">
    <div class="flex items-center gap-3">
      <span class="material-symbols-outlined text-xl text-gray-400 dark:text-gray-500">groups</span>
      <div class="flex flex-col">
        <span
          class="text-[10px] font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 leading-none mb-0.5"
          >Peers Online</span
        >
        <span class="text-sm font-medium text-gray-900 dark:text-gray-200 leading-none"
          >{peerCount} Online</span
        >
      </div>
    </div>
  </div>
</footer>
