// TypeScript types matching Rust domain models

export type LightColor = 'Red' | 'Yellow' | 'Green' | 'Blue' | 'Off';

export interface VectorClock {
  [peerId: string]: number;
}

export interface LightState {
  color: LightColor;
  clock: VectorClock;
  timestamp: number;
}

export interface PeerInfo {
  id: string;
  name: string;
  light_state: LightState;
}

// Alias for clarity - my state is just PeerInfo
export type MyState = PeerInfo;
