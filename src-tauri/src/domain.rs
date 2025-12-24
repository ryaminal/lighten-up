use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Unique identifier for a peer in the network
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct PeerId(String);

impl PeerId {
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into())
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl std::fmt::Display for PeerId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

/// Represents a light color state
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
pub enum LightColor {
    Red,
    Green,
    Blue,
    Yellow,
    Orange,
    Purple,
    White,
    #[default]
    Off,
}

/// Vector clock for causal ordering
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct VectorClock {
    clocks: HashMap<PeerId, u64>,
}

impl VectorClock {
    pub fn new() -> Self {
        Self {
            clocks: HashMap::new(),
        }
    }

    /// Increment the clock for a given peer
    pub fn increment(&mut self, peer_id: &PeerId) {
        let counter = self.clocks.entry(peer_id.clone()).or_insert(0);
        *counter += 1;
    }

    /// Get the current value for a peer
    pub fn get(&self, peer_id: &PeerId) -> u64 {
        self.clocks.get(peer_id).copied().unwrap_or(0)
    }

    /// Merge another vector clock into this one (take max of each peer)
    pub fn merge(&mut self, other: &VectorClock) {
        for (peer_id, &other_time) in &other.clocks {
            let current_time = self.clocks.entry(peer_id.clone()).or_insert(0);
            *current_time = (*current_time).max(other_time);
        }
    }

    /// Check if this clock happened before another (this < other)
    pub fn happens_before(&self, other: &VectorClock) -> bool {
        let mut strictly_less = false;
        let mut all_less_or_equal = true;

        let all_peers: std::collections::HashSet<_> = self
            .clocks
            .keys()
            .chain(other.clocks.keys())
            .cloned()
            .collect();

        for peer_id in all_peers {
            let self_time = self.get(&peer_id);
            let other_time = other.get(&peer_id);

            if self_time > other_time {
                all_less_or_equal = false;
                break;
            }
            if self_time < other_time {
                strictly_less = true;
            }
        }

        all_less_or_equal && strictly_less
    }

    /// Check if two clocks are concurrent (neither happens before the other)
    pub fn is_concurrent(&self, other: &VectorClock) -> bool {
        !self.happens_before(other) && !other.happens_before(self) && self != other
    }
}

impl Default for VectorClock {
    fn default() -> Self {
        Self::new()
    }
}

/// Light state with Last-Write-Wins semantics
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct LightState {
    pub color: LightColor,
    pub vector_clock: VectorClock,
    pub timestamp: u64,
}

impl LightState {
    pub fn new(color: LightColor, vector_clock: VectorClock, timestamp: u64) -> Self {
        Self {
            color,
            vector_clock,
            timestamp,
        }
    }

    /// Merge this state with another using Last-Write-Wins with vector clock comparison
    pub fn merge(&mut self, other: &LightState) {
        if other.vector_clock.happens_before(&self.vector_clock) {
            return;
        }

        if self.vector_clock.happens_before(&other.vector_clock) {
            self.color = other.color.clone();
            self.vector_clock = other.vector_clock.clone();
            self.timestamp = other.timestamp;
            return;
        }

        if self.vector_clock.is_concurrent(&other.vector_clock) {
            if other.timestamp > self.timestamp {
                self.color = other.color.clone();
                self.vector_clock.merge(&other.vector_clock);
                self.timestamp = other.timestamp;
            } else if other.timestamp == self.timestamp {
                self.vector_clock.merge(&other.vector_clock);
            }
        }
    }
}

/// Represents information about a peer
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct PeerInfo {
    pub id: PeerId,
    pub name: String,
    pub light_state: LightState,
}

impl PeerInfo {
    pub fn new(id: PeerId, name: String, light_state: LightState) -> Self {
        Self {
            id,
            name,
            light_state,
        }
    }
}

/// Events that can occur in the system
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Event {
    PeerDiscovered { peer: PeerInfo },
    PeerStateChanged { peer_id: PeerId, state: LightState },
    PeerLeft { peer_id: PeerId },
    MyStateChanged { state: LightState },
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_peer_id_creation() {
        let id = PeerId::new("test-peer-1");
        assert_eq!(id.as_str(), "test-peer-1");
    }

    #[test]
    fn test_vector_clock_increment() {
        let mut clock = VectorClock::new();
        let peer_id = PeerId::new("peer1");

        assert_eq!(clock.get(&peer_id), 0);
        clock.increment(&peer_id);
        assert_eq!(clock.get(&peer_id), 1);
        clock.increment(&peer_id);
        assert_eq!(clock.get(&peer_id), 2);
    }

    #[test]
    fn test_vector_clock_merge() {
        let mut clock1 = VectorClock::new();
        let mut clock2 = VectorClock::new();

        let peer1 = PeerId::new("peer1");
        let peer2 = PeerId::new("peer2");

        clock1.increment(&peer1);
        clock1.increment(&peer1);

        clock2.increment(&peer2);
        clock2.increment(&peer2);
        clock2.increment(&peer2);

        clock1.merge(&clock2);

        assert_eq!(clock1.get(&peer1), 2);
        assert_eq!(clock1.get(&peer2), 3);
    }

    #[test]
    fn test_vector_clock_happens_before() {
        let mut clock1 = VectorClock::new();
        let mut clock2 = VectorClock::new();

        let peer1 = PeerId::new("peer1");

        clock1.increment(&peer1);

        clock2.increment(&peer1);
        clock2.increment(&peer1);

        assert!(clock1.happens_before(&clock2));
        assert!(!clock2.happens_before(&clock1));
    }

    #[test]
    fn test_vector_clock_concurrent() {
        let mut clock1 = VectorClock::new();
        let mut clock2 = VectorClock::new();

        let peer1 = PeerId::new("peer1");
        let peer2 = PeerId::new("peer2");

        clock1.increment(&peer1);
        clock2.increment(&peer2);

        assert!(clock1.is_concurrent(&clock2));
        assert!(clock2.is_concurrent(&clock1));
    }

    #[test]
    fn test_light_state_merge_happens_before() {
        let peer_id = PeerId::new("peer1");

        let mut clock1 = VectorClock::new();
        clock1.increment(&peer_id);

        let mut clock2 = VectorClock::new();
        clock2.increment(&peer_id);
        clock2.increment(&peer_id);

        let mut state1 = LightState::new(LightColor::Red, clock1, 100);
        let state2 = LightState::new(LightColor::Blue, clock2, 200);

        state1.merge(&state2);

        assert_eq!(state1.color, LightColor::Blue);
    }

    #[test]
    fn test_light_state_merge_concurrent_uses_timestamp() {
        let peer1 = PeerId::new("peer1");
        let peer2 = PeerId::new("peer2");

        let mut clock1 = VectorClock::new();
        clock1.increment(&peer1);

        let mut clock2 = VectorClock::new();
        clock2.increment(&peer2);

        let mut state1 = LightState::new(LightColor::Red, clock1, 100);
        let state2 = LightState::new(LightColor::Blue, clock2, 200);

        state1.merge(&state2);

        assert_eq!(state1.color, LightColor::Blue);
    }
}
