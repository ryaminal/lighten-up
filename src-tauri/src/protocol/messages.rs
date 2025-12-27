use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PresenceMessage {
    Online {
        peer_id: String,
        peer_name: String,
        light_state: LightState,
        note: Option<String>,
        timestamp: u64,
    },
    Goodbye {
        peer_id: String,
    },
    /// Request current online status from all peers.
    /// `peer_id` is the requester so others can reply directly.
    RequestStatus {
        peer_id: String,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum NotificationType {
    PatientReady,
    RoomReady,
    UrgentAssist,
    GeneralMessage,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Notification {
    #[serde(rename = "type")]
    pub notification_type: NotificationType,
    pub message: String,
    pub target_peer_id: String,
    pub sender_peer_id: String,
    pub timestamp: u64,
    pub priority: Option<String>,
    pub color: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LightState {
    pub color: String,
    pub timestamp: u64,
}

impl LightState {
    pub fn new(color: String) -> Self {
        Self {
            color,
            timestamp: crate::utils::current_timestamp(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConfigMessage {
    pub op: ConfigOp,
    pub peer_id: String,
    pub timestamp: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ConfigOp {
    Upsert {
        id: String,
        color: String,
        name: String,
        enabled: bool,
        priority: i32,
        updated_at: u64,
        updated_by: String,
    },
    Delete {
        id: String,
        deleted_at: u64,
    },
    /// Request all light configs from peers
    RequestSync {
        peer_id: String,
    },
}

// Re‑export the domain chat message type; no derives needed on a type alias.
pub type ChatMessage = crate::domain::ChatMessage;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LightConfig {
    pub id: String,
    pub color: String,
    pub name: String,
    pub enabled: bool,
    pub priority: i32,
    pub updated_at: u64,
    pub updated_by: String,
}
