//! Domain model for chat messages.
//!
//! This struct lives in the **domain** layer so that the application
//! logic can work with it without depending on protocol‑specific
//! serialization concerns.

use serde::{Deserialize, Serialize};

/// Represents a chat message exchanged between peers.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatMessage {
    /// Unique identifier for the message.
    pub id: String,
    /// Identifier of the sending peer.
    pub peer_id: String,
    /// Human‑readable name of the sending peer.
    pub peer_name: String,
    /// Message content.
    pub content: String,
    /// Unix timestamp (seconds) when the message was created/updated.
    pub timestamp: u64,
}
