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
  state: LightState;
}

export interface MyState {
  peer_id: string;
  name: string;
  state: LightState;
}
