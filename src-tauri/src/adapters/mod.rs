pub mod encryption;
pub mod error;
pub mod message;
pub mod network;

// Re‑export ports from the domain layer to keep the original public API.
pub use crate::domain::EncryptionAdapter;
pub use crate::domain::NetworkAdapter;
pub use error::{AdapterError, Result};
pub use message::Message;
