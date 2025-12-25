import { writable } from 'svelte/store';
import type { MyState, PeerInfo, LightState } from './types';
import type { LightConfig } from './generated/types';

export type ViewType = 'dashboard' | 'config';

export const myState = writable<MyState | null>(null);
export const peers = writable<PeerInfo[]>([]);
export const isLoading = writable(true);
export const error = writable<string | null>(null);
export const currentView = writable<ViewType>('dashboard');
export const lightConfig = writable<LightConfig | null>(null);

export function updateMyState(state: MyState) {
  myState.set(state);
}

export function updatePeers(peerList: PeerInfo[]) {
  peers.set(peerList);
}

export function addPeer(peer: PeerInfo) {
  peers.update((current) => {
    const exists = current.some((p) => p.id === peer.id);
    if (exists) {
      return current.map((p) => (p.id === peer.id ? peer : p));
    }
    return [...current, peer];
  });
}

export function updatePeerState(peerId: string, state: LightState) {
  peers.update((current) =>
    current.map((p) => (p.id === peerId ? { ...p, light_state: state } : p))
  );
}

export function removePeer(peerId: string) {
  peers.update((current) => current.filter((p) => p.id !== peerId));
}

export function setError(message: string | null) {
  error.set(message);
}

export function setLoading(loading: boolean) {
  isLoading.set(loading);
}
