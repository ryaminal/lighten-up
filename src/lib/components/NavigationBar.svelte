<script lang="ts">
  import { currentView } from '$lib/stores';

  export let onOpenSettings: () => void;

  type ViewType = 'dashboard' | 'tasks' | 'people' | 'chat' | 'settings';

  function setView(view: ViewType) {
    if (view === 'settings') {
      onOpenSettings();
    } else if (view === 'dashboard' || view === 'chat') {
      currentView.set(view as 'dashboard' | 'config');
    }
  }
</script>

<nav
  class="w-16 flex-shrink-0 bg-white dark:bg-[#111827] border-r border-gray-200 dark:border-gray-800 flex flex-col items-center py-4 z-20"
>
  <div class="mb-8">
    <div
      class="w-10 h-10 bg-[#3b82f6] rounded-lg flex items-center justify-center text-white font-bold text-xl shadow-lg"
    >
      L
    </div>
  </div>

  <div class="flex-1 w-full flex flex-col items-center space-y-4">
    <button
      class="p-3 rounded-xl text-gray-500 hover:bg-gray-100 hover:text-[#3b82f6] dark:text-gray-400 dark:hover:bg-gray-800 dark:hover:text-[#3b82f6] transition-colors"
      on:click={() => setView('dashboard')}
      aria-label="Dashboard"
    >
      <span class="material-icons-round">dashboard</span>
    </button>

    <button
      class="p-3 rounded-xl bg-[#3b82f6]/10 text-[#3b82f6] dark:bg-[#3b82f6]/20 dark:text-[#3b82f6] shadow-sm"
      aria-label="Tasks"
    >
      <span class="material-icons-round">list_alt</span>
    </button>

    <button
      class="p-3 rounded-xl text-gray-500 hover:bg-gray-100 hover:text-[#3b82f6] dark:text-gray-400 dark:hover:bg-gray-800 dark:hover:text-[#3b82f6] transition-colors"
      aria-label="People"
    >
      <span class="material-icons-round">people</span>
    </button>

    <button
      class="p-3 rounded-xl text-gray-500 hover:bg-gray-100 hover:text-[#3b82f6] dark:text-gray-400 dark:hover:bg-gray-800 dark:hover:text-[#3b82f6] transition-colors"
      on:click={() => setView('chat')}
      aria-label="Chat"
    >
      <span class="material-icons-round">chat_bubble</span>
    </button>
  </div>

  <div class="mt-auto">
    <button
      class="p-3 rounded-xl text-gray-500 hover:bg-gray-100 hover:text-[#3b82f6] dark:text-gray-400 dark:hover:bg-gray-800 dark:hover:text-[#3b82f6] transition-colors"
      on:click={() => setView('settings')}
      aria-label="Settings"
    >
      <span class="material-icons-round">settings</span>
    </button>
  </div>
</nav>
