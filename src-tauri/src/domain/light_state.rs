use crate::domain::{light_color::LightColor, vector_clock::VectorClock};
use serde::{Deserialize, Serialize};

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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::domain::peer_id::PeerId;

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
