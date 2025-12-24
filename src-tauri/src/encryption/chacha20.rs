use crate::adapters::{AdapterError, EncryptionAdapter, Result};
use crate::encryption::key_derivation::{KEY_SIZE, derive_key_bytes, derive_key_from_passphrase};
use chacha20poly1305::{
    ChaCha20Poly1305, Nonce,
    aead::{Aead, KeyInit, OsRng},
};
use rand::RngCore;

const NONCE_SIZE: usize = 12;

/// ChaCha20Poly1305 encryption adapter implementation
pub struct ChaCha20Encryption {
    key: [u8; KEY_SIZE],
}

impl ChaCha20Encryption {
    /// Create a new encryption adapter with the given key
    pub fn new(key: [u8; KEY_SIZE]) -> Self {
        Self { key }
    }

    /// Create from a passphrase using Argon2 key derivation
    pub fn from_passphrase(passphrase: &str) -> Result<Self> {
        let key = derive_key_from_passphrase(passphrase)?;
        Ok(Self::new(key))
    }

    /// Create from a raw key bytes
    pub fn from_key_bytes(key_bytes: &[u8]) -> Result<Self> {
        if key_bytes.len() != KEY_SIZE {
            return Err(AdapterError::Encryption(format!(
                "Invalid key size: expected {}, got {}",
                KEY_SIZE,
                key_bytes.len()
            )));
        }

        let mut key = [0u8; KEY_SIZE];
        key.copy_from_slice(key_bytes);

        Ok(Self::new(key))
    }
}

impl EncryptionAdapter for ChaCha20Encryption {
    fn encrypt(&self, plaintext: &[u8]) -> Result<Vec<u8>> {
        let cipher = ChaCha20Poly1305::new(&self.key.into());

        let mut nonce_bytes = [0u8; NONCE_SIZE];
        OsRng.fill_bytes(&mut nonce_bytes);
        let nonce = Nonce::from_slice(&nonce_bytes);

        let ciphertext = cipher
            .encrypt(nonce, plaintext)
            .map_err(|e| AdapterError::Encryption(format!("Encryption failed: {}", e)))?;

        let mut result = Vec::with_capacity(NONCE_SIZE + ciphertext.len());
        result.extend_from_slice(&nonce_bytes);
        result.extend_from_slice(&ciphertext);

        Ok(result)
    }

    fn decrypt(&self, ciphertext: &[u8]) -> Result<Vec<u8>> {
        if ciphertext.len() < NONCE_SIZE {
            return Err(AdapterError::Encryption(
                "Ciphertext too short to contain nonce".to_string(),
            ));
        }

        let (nonce_bytes, encrypted_data) = ciphertext.split_at(NONCE_SIZE);
        let nonce = Nonce::from_slice(nonce_bytes);

        let cipher = ChaCha20Poly1305::new(&self.key.into());

        let plaintext = cipher
            .decrypt(nonce, encrypted_data)
            .map_err(|e| AdapterError::Encryption(format!("Decryption failed: {}", e)))?;

        Ok(plaintext)
    }

    fn derive_key(&self, passphrase: &str) -> Result<Vec<u8>> {
        derive_key_bytes(passphrase)
    }
}
