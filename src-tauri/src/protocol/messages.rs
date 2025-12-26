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
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatMessage {
    pub id: String,
    pub peer_id: String,
    pub peer_name: String,
    pub content: String,
    pub timestamp: u64,
}

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
