use crate::adapters::{error::Result, message::Message};
use crate::domain::PeerId;
use async_trait::async_trait;

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
