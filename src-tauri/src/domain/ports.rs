//! Domain ports (interfaces) defining the contracts that adapters must implement.
//!
//! According to the Clean Architecture guardrails, ports belong in the
//! **domain** layer so that higher layers depend only on abstractions.

use crate::adapters::message::Message;
use crate::domain::PeerId;
use async_trait::async_trait;

/// Network adapter port used by the application layer.
#[async_trait]
pub trait NetworkAdapter: Send + Sync {
    /// Start discovery and listening.
    async fn start(&self) -> crate::adapters::error::Result<()>;

    /// Stop the network adapter.
    async fn stop(&self) -> crate::adapters::error::Result<()>;

    /// Send a message to a specific peer.
    async fn send_to_peer(
        &self,
        peer_id: &PeerId,
        message: Message,
    ) -> crate::adapters::error::Result<()>;

    /// Broadcast a message to all known peers.
    async fn broadcast(&self, message: Message) -> crate::adapters::error::Result<()>;

    /// Receive the next incoming message (blocking until one arrives).
    async fn receive(&self) -> crate::adapters::error::Result<(PeerId, Message)>;

    /// Retrieve the list of currently connected peer IDs.
    async fn get_connected_peers(&self) -> crate::adapters::error::Result<Vec<PeerId>>;
}

/// Encryption adapter port for securing network traffic.
pub trait EncryptionAdapter: Send + Sync {
    /// Encrypt plaintext bytes.
    fn encrypt(&self, plaintext: &[u8]) -> crate::adapters::error::Result<Vec<u8>>;

    /// Decrypt ciphertext bytes.
    fn decrypt(&self, ciphertext: &[u8]) -> crate::adapters::error::Result<Vec<u8>>;

    /// Derive a cryptographic key from a passphrase.
    fn derive_key(&self, passphrase: &str) -> crate::adapters::error::Result<Vec<u8>>;
}
