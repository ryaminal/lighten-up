use crate::protocol::messages::{ChatMessage, ConfigMessage, Notification, PresenceMessage};

/// Message types for network communication
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(tag = "type", content = "payload")]
pub enum Message {
    /// Presence message (heartbeat, online/offline status)
    Presence(PresenceMessage),

    /// Configuration sync message (CRDT-based)
    Config(ConfigMessage),

    /// Chat message
    Chat(ChatMessage),

    /// Generic notification (patient ready, room ready, urgent assist, etc.)
    Notification(Notification),
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::protocol::messages::LightState;

    #[test]
    fn test_presence_message_serialization() {
        let msg = PresenceMessage::Online {
            peer_id: "test-peer".to_string(),
            peer_name: "Test".to_string(),
            light_state: LightState::new("#FF0000".to_string()),
            note: Some("Testing".to_string()),
            timestamp: 123456,
        };

        let message = Message::Presence(msg);

        let serialized = serde_json::to_string(&message).expect("Failed to serialize");
        let deserialized: Message =
            serde_json::from_str(&serialized).expect("Failed to deserialize");

        match deserialized {
            Message::Presence(PresenceMessage::Online { peer_id, .. }) => {
                assert_eq!(peer_id, "test-peer")
            }
            _ => panic!("Wrong message type"),
        }
    }
}
