use crate::domain::{Light, LightColor, LightConfig, LightState, PeerId, PeerInfo};
use std::collections::HashMap;

/// Message types for network communication
/// Designed to be extensible for future message types (chat, alerts, etc.)
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(tag = "type", content = "payload")]
pub enum Message {
    // ========================================
    // BROADCAST MESSAGES (All → All)
    // These are processed by all peers
    // ========================================
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

    /// Light was activated
    LightActivated { light: Light },

    /// Light was deactivated
    LightDeactivated { light: Light },

    /// Comment was added to a light
    LightCommentAdded { light: Light },

    /// Light priority was changed
    LightPriorityChanged { light: Light },

    /// Request all active lights from peers
    LightSyncRequest,

    /// Response with all lights
    LightSyncResponse { lights: Vec<Light> },

    /// Follower is overriding a global status command (emergency)
    StatusOverride {
        peer_id: PeerId,
        reason: String,
        original_command: LightColor,
    },

    // ========================================
    // PUB/SUB MESSAGES (Controller → Followers)
    // Only processed by subscribers (followers)
    // ========================================
    /// Controller election announcement
    /// All peers update who the controller is
    /// Previous controller steps down
    ControllerElected {
        controller_id: PeerId,
        controller_name: String,
    },

    /// Controller is resigning
    ControllerResigned { controller_id: PeerId },

    /// Request light configuration from controller
    ConfigSyncRequest { from_peer: PeerId },

    /// Controller broadcasts complete light configuration
    /// Followers replace their config with this
    ConfigUpdate {
        config: LightConfig,
        from_controller: PeerId,
    },

    /// Controller broadcasts a global status command
    /// All followers should set their light to this color
    GlobalStatusCommand {
        color: LightColor,
        reason: String,
        from_controller: PeerId,
    },

    /// Controller assigns a task/patient to a specific peer
    TaskAssignment {
        target_peer: PeerId,
        task: String,
        from_controller: PeerId,
    },

    // ========================================
    // DEPRECATED - Keep for backward compat
    // ========================================
    /// Request light configuration from peers (DEPRECATED - use ConfigSyncRequest)
    #[deprecated(note = "Use ConfigSyncRequest instead")]
    LightConfigRequest,

    /// Broadcast complete light configuration (DEPRECATED - use ConfigUpdate)
    #[deprecated(note = "Use ConfigUpdate instead")]
    LightConfigSync { config: LightConfig },
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
