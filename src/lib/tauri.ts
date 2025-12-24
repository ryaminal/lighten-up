import { invoke } from '@tauri-apps/api/core';
import { listen } from '@tauri-apps/api/event';
import type { LightColor, MyState, PeerInfo, LightState } from './types';
import {
  updateMyState,
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
  await listen('my-state-changed', (event) => {
    updateMyState(event.payload as MyState);
  });

  await listen('peer-discovered', (event) => {
    addPeer(event.payload as PeerInfo);
  });

  await listen('peer-state-changed', (event) => {
    const [peerId, state] = event.payload as [string, LightState];
    updatePeerState(peerId, state);
  });

  await listen('peer-left', (event) => {
    const peerId = event.payload as string;
    removePeer(peerId);
  });
}

async function loadInitialState() {
  const [myStateData, peersData] = await Promise.all([
    invoke<MyState>('get_my_state'),
    invoke<PeerInfo[]>('get_peers'),
  ]);

  updateMyState(myStateData);
  updatePeers(peersData);
}

export async function setLightColor(color: LightColor): Promise<void> {
  try {
    await invoke('set_light_color', { color });
  } catch (e) {
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
