use crate::domain::{
    current_timestamp_secs, light::Light, light_config::LightConfig,
    light_state::LightState, peer_id::PeerId,
};
use serde::{Deserialize, Serialize};

/// Represents information about a peer
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct PeerInfo {
    pub id: PeerId,
    pub name: String,
    pub light_state: LightState,
    /// Last time we received any message from this peer (Unix timestamp in seconds)
    pub last_seen: u64,
    /// Optional note/message attached to the light status
    #[serde(default)]
    pub note: Option<String>,
}

impl PeerInfo {
    pub fn new(id: PeerId, name: String, light_state: LightState) -> Self {
        Self {
            id,
            name,
            light_state,
            last_seen: current_timestamp_secs(),
            note: None,
        }
    }

    pub fn with_note(mut self, note: Option<String>) -> Self {
        self.note = note;
        self
    }

    /// Update the last_seen timestamp to now
    pub fn touch(&mut self) {
        self.last_seen = current_timestamp_secs();
    }

    /// Check if this peer is stale (hasn't been seen in the given seconds)
    pub fn is_stale(&self, timeout_secs: u64) -> bool {
        let now = current_timestamp_secs();
        now.saturating_sub(self.last_seen) > timeout_secs
    }
}

/// Events that can occur in the system
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Event {
    PeerDiscovered { peer: PeerInfo },
    PeerStateChanged { peer_id: PeerId, state: LightState },
    PeerLeft { peer_id: PeerId },
    MyStateChanged { state: LightState },
    LightActivated { light: Light },
    LightDeactivated { light: Light },
    LightUpdated { light: Light },
    LightConfigChanged { config: LightConfig },
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::domain::{LightColor, VectorClock};

    #[test]
    fn test_peer_info_touch_updates_last_seen() {
        let peer_id = PeerId::new("test".to_string());
        let light_state = LightState::new(LightColor::Green, VectorClock::new(), 1000);
        let mut peer = PeerInfo::new(peer_id, "Test".to_string(), light_state);

        let original_last_seen = peer.last_seen;

        // Wait for at least 1 second
        std::thread::sleep(std::time::Duration::from_secs(1));

        peer.touch();
        assert!(peer.last_seen > original_last_seen);
    }

    #[test]
    fn test_peer_info_is_stale() {
        let peer_id = PeerId::new("test".to_string());
        let light_state = LightState::new(LightColor::Green, VectorClock::new(), 1000);
        let mut peer = PeerInfo::new(peer_id, "Test".to_string(), light_state);

        // Fresh peer should not be stale
        assert!(!peer.is_stale(60));

        // Set last_seen to 120 seconds ago
        peer.last_seen = current_timestamp_secs() - 120;

        // Should be stale with 60 second timeout
        assert!(peer.is_stale(60));

        // Should not be stale with 200 second timeout
        assert!(!peer.is_stale(200));
    }
}
