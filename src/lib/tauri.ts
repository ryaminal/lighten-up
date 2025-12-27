import { invoke } from '@tauri-apps/api/core';
import { listen, type UnlistenFn } from '@tauri-apps/api/event';
import type { LightConfig } from './generated/types';

// ===========================
// Type Definitions
// ===========================

export interface PeerPresence {
  peer_id: string;
  peer_name: string;
  light_state: {
    color: string;
    timestamp: number;
  };
  note?: string | null;
  last_seen: number;
}

export interface ChatMessage {
  id: string;
  peer_id: string;
  peer_name: string;
  content: string;
  timestamp: number;
}

// ===========================
// Commands
// ===========================

export async function getMyPeerName(): Promise<string> {
  return await invoke('get_my_peer_name');
}

export async function getMyPeerId(): Promise<string> {
  return await invoke('get_my_peer_id');
}

export async function setPeerName(name: string): Promise<void> {
  await invoke('set_peer_name', { name });
}

export async function setLightColor(color: string, note?: string): Promise<void> {
  await invoke('set_light_color', { color, note: note || null });
}

export async function getPeers(): Promise<PeerPresence[]> {
  return await invoke('get_peers');
}

export async function getLights(): Promise<LightConfig[]> {
  return await invoke('get_lights');
}

export async function createLight(light: LightConfig): Promise<void> {
  await invoke('create_light', { light });
}

export async function updateLight(light: LightConfig): Promise<void> {
  await invoke('update_light', { light });
}

export async function deleteLight(id: string): Promise<void> {
  await invoke('delete_light', { id });
}

export async function sendChatMessage(content: string): Promise<void> {
  await invoke('send_chat_message', { content });
}

export async function getChatMessages(): Promise<ChatMessage[]> {
  return await invoke('get_chat_messages');
}

export async function editChatMessage(id: string, content: string): Promise<void> {
  await invoke('edit_chat_message', { id, content });
}

export async function deleteChatMessage(id: string): Promise<void> {
  await invoke('delete_chat_message', { id });
}

// ===========================
// Event Listeners
// ===========================

let unlistenFns: UnlistenFn[] = [];

export async function initializeTauri(callbacks: {
  onPeersChanged?: (peers: PeerPresence[]) => void;
  onLightsChanged?: (lights: LightConfig[]) => void;
  onChatMessage?: (message: ChatMessage) => void;
  onChatMessageDeleted?: (id: string) => void;
}): Promise<void> {
  // Clean up existing listeners
  await cleanupListeners();

  // Listen for peers changed
  if (callbacks.onPeersChanged) {
    const unlisten = await listen<PeerPresence[]>('peers-changed', (event) => {
      callbacks.onPeersChanged?.(event.payload);
    });
    unlistenFns.push(unlisten);
  }

  // Listen for lights config changed
  if (callbacks.onLightsChanged) {
    const unlisten = await listen<LightConfig[]>('lights-changed', (event) => {
      callbacks.onLightsChanged?.(event.payload);
    });
    unlistenFns.push(unlisten);
  }

  // Listen for chat messages
  if (callbacks.onChatMessage) {
    const unlisten = await listen<ChatMessage>('chat-message', (event) => {
      callbacks.onChatMessage?.(event.payload);
    });
    unlistenFns.push(unlisten);
  }

  // Listen for chat message deletions
  if (callbacks.onChatMessageDeleted) {
    const unlisten = await listen<string>('chat-message-deleted', (event) => {
      callbacks.onChatMessageDeleted?.(event.payload);
    });
    unlistenFns.push(unlisten);
  }

  console.log('[Tauri] Event listeners initialized');
}

export async function cleanupListeners(): Promise<void> {
  for (const unlisten of unlistenFns) {
    unlisten();
  }
  unlistenFns = [];
}
