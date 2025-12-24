// TypeScript types matching Rust domain models

export type LightColor = 'Red' | 'Yellow' | 'Green' | 'Blue' | 'Off';

export interface VectorClock {
  [peerId: string]: number;
}

export interface LightState {
  color: LightColor;
  vector_clock: VectorClock;
  timestamp: number;
}

export interface PeerInfo {
  id: string;
  name: string;
  light_state: LightState;
  last_seen: number; // Unix timestamp in seconds
}

// Alias for clarity - my state is just PeerInfo
export type MyState = PeerInfo;
