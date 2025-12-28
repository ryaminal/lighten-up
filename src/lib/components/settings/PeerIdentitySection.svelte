<script lang="ts">
  export let peerId: string;
  export let peerName: string;
  export let onSaveName: () => void;
</script>

<div class="space-y-4">
  <div class="flex items-center gap-2">
    <span
      class="flex h-8 w-8 items-center justify-center rounded-full bg-[#3b82f6]/10 text-[#3b82f6]"
    >
      <span class="material-icons-round text-base">badge</span>
    </span>
    <h4 class="text-sm font-medium leading-none text-gray-900 dark:text-white">Identification</h4>
  </div>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <div class="grid gap-2">
      <label
        for="room-identifier"
        class="text-sm font-medium leading-none text-gray-700 dark:text-gray-300"
      >
        Room Identifier
      </label>
      <input
        class="flex h-10 w-full rounded-md border border-gray-300 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 px-3 py-2 text-sm text-gray-500 dark:text-gray-400 cursor-not-allowed"
        value={peerId}
        disabled
        readonly
      />
    </div>

    <div class="grid gap-2">
      <label
        for="display-name"
        class="text-sm font-medium leading-none text-gray-700 dark:text-gray-300"
      >
        Display Name
      </label>
      <input
        class="flex h-10 w-full rounded-md border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-900 px-3 py-2 text-sm ring-offset-background placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#3b82f6] focus-visible:ring-offset-2 text-gray-900 dark:text-white"
        bind:value={peerName}
        on:blur={onSaveName}
        maxlength="15"
      />
    </div>
  </div>
</div>
