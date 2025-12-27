import { writable } from 'svelte/store';
import type { PeerPresence } from './tauri';
import type { LightConfig } from './generated/types';

export type ViewType = 'dashboard' | 'config';

export type NotificationType = 'patient-ready' | 'room-ready' | 'urgent-assist' | 'general-message';

export interface Notification {
  type: NotificationType;
  message: string;
  targetPeerId: string;
  senderPeerId?: string;
  timestamp: number;
  priority?: 'low' | 'normal' | 'high' | 'critical';
  color?: string;
}

// Application stores
export const myPeerId = writable<string>('');
export const myPeerName = writable<string>('');
export const myLightColor = writable<string>('#000000');
export const myNote = writable<string>('');
export const peers = writable<PeerPresence[]>([]);
export const lights = writable<LightConfig[]>([]);
export const isLoading = writable(true);
export const error = writable<string | null>(null);
export const currentView = writable<ViewType>('dashboard');
export const showNavigation = writable(true);
export const notification = writable<Notification | null>(null);

export function updatePeers(peerList: PeerPresence[]) {
  peers.set(peerList);
}

export function setError(message: string | null) {
  error.set(message);
}

export function setLoading(loading: boolean) {
  isLoading.set(loading);
}

export function setNotification(notif: Notification | null) {
  notification.set(notif);
}
