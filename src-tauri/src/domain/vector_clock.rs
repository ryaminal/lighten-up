use crate::domain::peer_id::PeerId;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

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

#[cfg(test)]
mod tests {
    use super::*;

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
}
