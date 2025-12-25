import { invoke } from '@tauri-apps/api/core';
import { listen } from '@tauri-apps/api/event';
import type {
  LightColor,
  MyState,
  PeerInfo,
  LightState,
  LightConfig,
  LightDefinition,
} from './types';
import type { ControllerInfo, PeerRole } from './types/controller';
import {
  myState,
  updatePeers,
  addPeer,
  updatePeerState,
  removePeer,
  setError,
  setLoading,
  lightConfig,
  controllerInfo,
  myRole,
} from './stores';

export async function initializeTauri() {
  try {
    await setupEventListeners();
    await loadInitialState();
    await loadLightConfig();
    await loadControllerInfo();
    setLoading(false);
  } catch (e) {
    const message = e instanceof Error ? e.message : 'Unknown error';
    setError(`Failed to initialize: ${message}`);
    setLoading(false);
  }
}

async function setupEventListeners() {
  console.log('Setting up event listeners...');
  await listen('my-state-changed', async (event) => {
    console.log('Received my-state-changed event:', event.payload);
    // Reload full state to get note updates
    const myStateData = await invoke<MyState>('get_my_state');
    myState.set(myStateData);
  });

  await listen('peer-discovered', (event) => {
    console.log('Received peer-discovered event:', event.payload);
    const peer = event.payload as PeerInfo;
    console.log('[FRONTEND] Peer note from event:', peer.note);
    addPeer(peer);
  });

  await listen('peer-state-changed', (event) => {
    console.log('Received peer-state-changed event:', event.payload);
    const [peerId, state] = event.payload as [string, LightState];
    updatePeerState(peerId, state);
  });

  await listen('peer-left', (event) => {
    console.log('Received peer-left event:', event.payload);
    const peerId = event.payload as string;
    removePeer(peerId);
  });

  await listen('light-config-changed', (event) => {
    console.log('Received light-config-changed event:', event.payload);
    const config = event.payload as LightConfig;
    lightConfig.set(config);
  });

  await listen('controller-elected', (event) => {
    console.log('Received controller-elected event:', event.payload);
    const [controllerId, controllerName] = event.payload as [string, string];
    controllerInfo.set({ id: controllerId, name: controllerName });
    // Reload my role to see if I'm the controller
    loadControllerInfo();
  });

  await listen('controller-resigned', (event) => {
    console.log('Received controller-resigned event:', event.payload);
    controllerInfo.set(null);
    myRole.set('Follower');
  });

  console.log('Event listeners setup complete');
}

async function loadInitialState() {
  const [myStateData, peersData] = await Promise.all([
    invoke<MyState>('get_my_state'),
    invoke<PeerInfo[]>('get_peers'),
  ]);

  myState.set(myStateData);
  updatePeers(peersData);
}

async function loadLightConfig() {
  try {
    const config = await invoke<LightConfig>('get_light_config');
    lightConfig.set(config);
    console.log('Light config loaded:', config);
  } catch (e) {
    console.error('Failed to load light config:', e);
  }
}

async function loadControllerInfo() {
  try {
    const [info, role] = await Promise.all([
      invoke<ControllerInfo | null>('get_controller_info'),
      invoke<PeerRole>('get_my_role'),
    ]);
    controllerInfo.set(info);
    myRole.set(role);
    console.log('Controller info loaded:', info, 'My role:', role);
  } catch (e) {
    console.error('Failed to load controller info:', e);
  }
}

export async function setLightColor(color: LightColor): Promise<void> {
  console.log('setLightColor called with:', color);
  try {
    console.log('About to invoke set_light_color command...');
    const startTime = Date.now();
    const result = await invoke('set_light_color', { color });
    const elapsed = Date.now() - startTime;
    console.log(`set_light_color command completed successfully in ${elapsed}ms, result:`, result);
  } catch (e) {
    console.error('set_light_color command failed:', e);
    const message = e instanceof Error ? e.message : 'Unknown error';
    setError(`Failed to set color: ${message}`);
    throw e;
  }
}

export async function setLightStatus(color: LightColor, note?: string): Promise<void> {
  console.log('[FRONTEND] setLightStatus called with:', color, note);
  try {
    const result = await invoke('set_light_status', { color, note: note || null });
    console.log('[FRONTEND] set_light_status command completed successfully, result:', result);
  } catch (e) {
    console.error('set_light_status command failed:', e);
    const message = e instanceof Error ? e.message : 'Unknown error';
    setError(`Failed to set status: ${message}`);
    throw e;
  }
}

export async function getMyState(): Promise<MyState> {
  return invoke<MyState>('get_my_state');
}

export async function getPeers(): Promise<PeerInfo[]> {
  return invoke<PeerInfo[]>('get_peers');
}

export async function getLightConfig(): Promise<LightConfig> {
  return invoke<LightConfig>('get_light_config');
}

export async function updateLightDefinition(definition: LightDefinition): Promise<void> {
  try {
    // Convert BigInt to number for JSON serialization
    const serializableDefinition = {
      ...definition,
      updated_at: Number(definition.updated_at),
    };
    await invoke('update_light_definition', { definition: serializableDefinition });
  } catch (e) {
    const message = e instanceof Error ? e.message : 'Unknown error';
    setError(`Failed to update light definition: ${message}`);
    throw e;
  }
}

export async function deleteLightDefinition(id: string): Promise<void> {
  try {
    await invoke('delete_light_definition', { id });
  } catch (e) {
    const message = e instanceof Error ? e.message : 'Unknown error';
    setError(`Failed to delete light definition: ${message}`);
    throw e;
  }
}

// ========================================
// Controller Commands
// ========================================

export async function getControllerInfo(): Promise<
  import('./types/controller').ControllerInfo | null
> {
  try {
    return await invoke('get_controller_info');
  } catch (e) {
    const message = e instanceof Error ? e.message : 'Unknown error';
    setError(`Failed to get controller info: ${message}`);
    throw e;
  }
}

export async function getMyRole(): Promise<import('./types/controller').PeerRole> {
  try {
    return await invoke('get_my_role');
  } catch (e) {
    const message = e instanceof Error ? e.message : 'Unknown error';
    setError(`Failed to get my role: ${message}`);
    throw e;
  }
}

export async function becomeController(): Promise<void> {
  try {
    await invoke('become_controller');
  } catch (e) {
    const message = e instanceof Error ? e.message : 'Unknown error';
    setError(`Failed to become controller: ${message}`);
    throw e;
  }
}

export async function resignController(): Promise<void> {
  try {
    await invoke('resign_controller');
  } catch (e) {
    const message = e instanceof Error ? e.message : 'Unknown error';
    setError(`Failed to resign as controller: ${message}`);
    throw e;
  }
}
