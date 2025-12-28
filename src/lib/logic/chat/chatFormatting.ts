import type { ChatMessage, PeerPresence } from '$lib/tauri';

/**
 * Format timestamp to localized time string
 * @param timestamp Unix timestamp in seconds
 * @returns Formatted time string (e.g., "2:45 PM")
 */
export function formatTime(timestamp: number): string {
  const date = new Date(timestamp * 1000);
  return date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
}

/**
 * Get current peer name for a message
 * Looks up from peers store or falls back to message peer_name
 * @param message Chat message
 * @param myPeerId Current user's peer ID
 * @param myPeerName Current user's peer name
 * @param peers List of active peers
 * @returns Current peer name for the message
 */
export function getCurrentPeerName(
  message: ChatMessage,
  myPeerId: string,
  myPeerName: string,
  peers: PeerPresence[] | null
): string {
  if (message.peer_id === myPeerId) {
    return myPeerName;
  }
  const peer = peers?.find((p) => p.peer_id === message.peer_id);
  return peer?.peer_name || message.peer_name;
}

/**
 * Get initials from a name (up to 2 characters)
 * @param name Full name
 * @returns Uppercase initials (e.g., "JD")
 */
export function getInitials(name: string): string {
  return name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);
}
