// TypeScript types matching Rust domain models

// Re-export generated types from Rust
export type { LightColor } from './generated/types';
export type { LightConfig, LightDefinition, LightDefinitionId } from './generated/types';

import type { LightColor } from './generated/types';

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
  note?: string; // Optional note/message
}

// Alias for clarity - my state is just PeerInfo
export type MyState = PeerInfo;
