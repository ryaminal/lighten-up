use crate::adapters::error::Result;

/// Encryption adapter trait for securing network communication
pub trait EncryptionAdapter: Send + Sync {
    /// Encrypt data using the configured key
    fn encrypt(&self, plaintext: &[u8]) -> Result<Vec<u8>>;

    /// Decrypt data using the configured key
    fn decrypt(&self, ciphertext: &[u8]) -> Result<Vec<u8>>;

    /// Derive a key from a passphrase
    fn derive_key(&self, passphrase: &str) -> Result<Vec<u8>>;
}
