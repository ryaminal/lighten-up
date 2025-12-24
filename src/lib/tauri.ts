import { invoke } from '@tauri-apps/api/core';
import { listen } from '@tauri-apps/api/event';
import type { LightColor, MyState, PeerInfo, LightState } from './types';
import {
  myState,
  updatePeers,
  addPeer,
  updatePeerState,
  removePeer,
  setError,
  setLoading,
} from './stores';

export async function initializeTauri() {
  try {
    await setupEventListeners();
    await loadInitialState();
    setLoading(false);
  } catch (e) {
    const message = e instanceof Error ? e.message : 'Unknown error';
    setError(`Failed to initialize: ${message}`);
    setLoading(false);
  }
}

async function setupEventListeners() {
  console.log('Setting up event listeners...');
  await listen('my-state-changed', (event) => {
    console.log('Received my-state-changed event:', event.payload);
    const newLightState = event.payload as LightState;
    // Update only the light_state field, preserve id and name
    myState.update((current) => {
      if (!current) return current;
      return {
        ...current,
        light_state: newLightState,
      };
    });
  });

  await listen('peer-discovered', (event) => {
    console.log('Received peer-discovered event:', event.payload);
    addPeer(event.payload as PeerInfo);
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

export async function getMyState(): Promise<MyState> {
  return invoke<MyState>('get_my_state');
}

export async function getPeers(): Promise<PeerInfo[]> {
  return invoke<PeerInfo[]>('get_peers');
}
