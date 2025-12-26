<script lang="ts">
  import { currentView } from '$lib/stores';
  import SettingsModal from './SettingsModal.svelte';

  let showSettings = false;

  function navigate(view: 'dashboard' | 'config') {
    currentView.set(view);
  }

  function openSettings() {
    showSettings = true;
  }

  function closeSettings() {
    showSettings = false;
  }
</script>

<aside
  class="w-20 bg-[#0f172a] text-slate-400 flex flex-col border-r border-slate-700 flex-shrink-0 transition-all duration-300 z-20 items-center pb-6"
>
  <div class="h-20 flex items-center justify-center w-full border-b border-slate-700/50 mb-4">
    <div
      class="h-10 w-10 bg-primary/20 rounded-xl flex items-center justify-center text-primary flex-shrink-0 hover:bg-primary/30 transition-colors cursor-pointer"
      title="Lighten Up"
    >
      <span class="text-2xl">💡</span>
    </div>
  </div>
  <nav class="flex-1 w-full px-3 space-y-4 flex flex-col items-center overflow-y-auto">
    <button
      class="h-12 w-12 flex items-center justify-center rounded-xl {$currentView === 'dashboard'
        ? 'bg-primary text-white shadow-lg shadow-primary/25'
        : 'bg-slate-800 text-slate-400 hover:bg-slate-700'} transition-all group relative"
      type="button"
      title="Active Lights"
      on:click={() => navigate('dashboard')}
    >
      <span class="text-2xl">💡</span>
    </button>
    <button
      class="h-12 w-12 flex items-center justify-center rounded-xl {$currentView === 'config'
        ? 'bg-primary text-white shadow-lg shadow-primary/25'
        : 'bg-slate-800 text-slate-400 hover:bg-slate-700'} transition-all group relative"
      type="button"
      title="Light Configuration"
      on:click={() => navigate('config')}
    >
      <span class="text-xl">⚙️</span>
    </button>
  </nav>
  <div class="mt-auto pt-4 border-t border-slate-700/50 w-full flex justify-center">
    <button
      class="h-10 w-10 rounded-full bg-slate-700 hover:bg-slate-600 transition-colors flex items-center justify-center text-white font-bold text-xs shadow-inner ring-2 ring-slate-800"
      title="Settings"
      type="button"
      on:click={openSettings}
    >
      ME
    </button>
  </div>
</aside>

<SettingsModal isOpen={showSettings} onClose={closeSettings} />
