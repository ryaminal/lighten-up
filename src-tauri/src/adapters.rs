use crate::domain::{LightState, PeerId, PeerInfo};
use async_trait::async_trait;
use std::collections::HashMap;

pub type Result<T> = std::result::Result<T, AdapterError>;

/// Errors that can occur in adapters
#[derive(Debug, thiserror::Error)]
pub enum AdapterError {
    #[error("Database error: {0}")]
    Database(String),

    #[error("Network error: {0}")]
    Network(String),

    #[error("Encryption error: {0}")]
    Encryption(String),

    #[error("Serialization error: {0}")]
    Serialization(String),

    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Invalid data: {0}")]
    InvalidData(String),
}

/// Database adapter trait for persistent storage
#[async_trait]
pub trait DatabaseAdapter: Send + Sync {
    /// Initialize the database schema
    async fn initialize(&self) -> Result<()>;

    /// Save or update peer information
    async fn save_peer(&self, peer: &PeerInfo) -> Result<()>;

    /// Get peer information by ID
    async fn get_peer(&self, peer_id: &PeerId) -> Result<PeerInfo>;

    /// Get all known peers
    async fn get_all_peers(&self) -> Result<Vec<PeerInfo>>;

    /// Delete a peer by ID
    async fn delete_peer(&self, peer_id: &PeerId) -> Result<()>;

    /// Save our own peer information
    async fn save_my_peer(&self, peer: &PeerInfo) -> Result<()>;

    /// Get our own peer information
    async fn get_my_peer(&self) -> Result<PeerInfo>;

    /// Update the name of our peer
    async fn update_my_name(&self, name: String) -> Result<()>;

    /// Update our light state
    async fn update_my_light_state(&self, state: &LightState) -> Result<()>;
}

/// Message types for network communication
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
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
}

/// Network adapter trait for peer discovery and communication
#[async_trait]
pub trait NetworkAdapter: Send + Sync {
    /// Start the network adapter (begin discovery and listening)
    async fn start(&self) -> Result<()>;

    /// Stop the network adapter
    async fn stop(&self) -> Result<()>;

    /// Send a message to a specific peer
    async fn send_to_peer(&self, peer_id: &PeerId, message: Message) -> Result<()>;

    /// Broadcast a message to all known peers
    async fn broadcast(&self, message: Message) -> Result<()>;

    /// Receive the next message (blocking until one arrives)
    async fn receive(&self) -> Result<(PeerId, Message)>;

    /// Get list of currently connected peer IDs
    async fn get_connected_peers(&self) -> Result<Vec<PeerId>>;
}

/// Encryption adapter trait for securing network communication
pub trait EncryptionAdapter: Send + Sync {
    /// Encrypt data using the configured key
    fn encrypt(&self, plaintext: &[u8]) -> Result<Vec<u8>>;

    /// Decrypt data using the configured key
    fn decrypt(&self, ciphertext: &[u8]) -> Result<Vec<u8>>;

    /// Derive a key from a passphrase
    fn derive_key(&self, passphrase: &str) -> Result<Vec<u8>>;
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

    #[test]
    fn test_adapter_error_display() {
        let error = AdapterError::Database("connection failed".to_string());
        assert_eq!(error.to_string(), "Database error: connection failed");

        let error = AdapterError::Network("timeout".to_string());
        assert_eq!(error.to_string(), "Network error: timeout");
    }
}
