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
