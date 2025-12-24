use crate::adapters::{AdapterError, Result};
use argon2::{Argon2, password_hash::PasswordHasher};
use chacha20poly1305::aead::OsRng;

pub const KEY_SIZE: usize = 32;

/// Derive a key from a passphrase using Argon2
pub fn derive_key_from_passphrase(passphrase: &str) -> Result<[u8; KEY_SIZE]> {
    use argon2::password_hash::SaltString;

    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();

    let password_hash = argon2
        .hash_password(passphrase.as_bytes(), &salt)
        .map_err(|e| AdapterError::Encryption(format!("Failed to hash password: {}", e)))?;

    let hash_string = password_hash
        .hash
        .ok_or_else(|| AdapterError::Encryption("No hash generated".to_string()))?
        .to_string();

    let hash_bytes = hash_string.as_bytes();

    if hash_bytes.len() < KEY_SIZE {
        return Err(AdapterError::Encryption(
            "Hash too short for key".to_string(),
        ));
    }

    let mut key = [0u8; KEY_SIZE];
    key.copy_from_slice(&hash_bytes[..KEY_SIZE]);

    Ok(key)
}

/// Derive key bytes for storage or transmission
pub fn derive_key_bytes(passphrase: &str) -> Result<Vec<u8>> {
    use argon2::password_hash::SaltString;

    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();

    let password_hash = argon2
        .hash_password(passphrase.as_bytes(), &salt)
        .map_err(|e| AdapterError::Encryption(format!("Failed to hash password: {}", e)))?;

    let hash_string = password_hash
        .hash
        .ok_or_else(|| AdapterError::Encryption("No hash generated".to_string()))?
        .to_string();

    Ok(hash_string.into_bytes())
}
