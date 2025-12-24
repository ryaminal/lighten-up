use crate::domain::{LightState, PeerId, PeerInfo};
use std::collections::HashMap;

/// Message types for network communication
/// Designed to be extensible for future message types (chat, alerts, etc.)
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(tag = "type", content = "payload")]
pub enum Message {
    /// Announce peer presence with current state
    PeerAnnouncement { peer: PeerInfo },

    /// Update to peer state
    StateUpdate { peer_id: PeerId, state: LightState },

    /// Request full state from a peer
    StateSyncRequest,

    /// Response with full state
    StateSyncResponse { peers: HashMap<PeerId, PeerInfo> },

    /// Peer is leaving the network
    PeerLeaving { peer_id: PeerId },

    /// Heartbeat to maintain connection
    Heartbeat { peer_id: PeerId },

    /// Generic application-level message (extensible for chat, alerts, etc.)
    /// Using serde_json::Value for flexibility
    #[serde(rename = "app")]
    ApplicationMessage {
        message_type: String,
        from: PeerId,
        data: serde_json::Value,
    },
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_message_serialization() {
        let peer_id = PeerId::new("test-peer");
        let message = Message::Heartbeat {
            peer_id: peer_id.clone(),
        };

        let serialized = serde_json::to_string(&message).expect("Failed to serialize");
        let deserialized: Message =
            serde_json::from_str(&serialized).expect("Failed to deserialize");

        match deserialized {
            Message::Heartbeat { peer_id: id } => assert_eq!(id, peer_id),
            _ => panic!("Wrong message type"),
        }
    }
}
