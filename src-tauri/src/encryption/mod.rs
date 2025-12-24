mod chacha20;
mod key_derivation;

pub use chacha20::ChaCha20Encryption;
pub use key_derivation::KEY_SIZE;

#[cfg(test)]
mod tests {
    use super::*;
    use crate::adapters::EncryptionAdapter;

    #[test]
    fn test_encrypt_decrypt_roundtrip() {
        let key = [42u8; KEY_SIZE];
        let adapter = ChaCha20Encryption::new(key);

        let plaintext = b"Hello, World! This is a test message.";
        let ciphertext = adapter.encrypt(plaintext).expect("Encryption failed");
        let decrypted = adapter.decrypt(&ciphertext).expect("Decryption failed");

        assert_eq!(plaintext, decrypted.as_slice());
    }

    #[test]
    fn test_encrypt_produces_different_ciphertexts() {
        let key = [42u8; KEY_SIZE];
        let adapter = ChaCha20Encryption::new(key);

        let plaintext = b"Same message";
        let ciphertext1 = adapter.encrypt(plaintext).expect("Encryption failed");
        let ciphertext2 = adapter.encrypt(plaintext).expect("Encryption failed");

        assert_ne!(ciphertext1, ciphertext2);

        let decrypted1 = adapter.decrypt(&ciphertext1).expect("Decryption failed");
        let decrypted2 = adapter.decrypt(&ciphertext2).expect("Decryption failed");

        assert_eq!(decrypted1, decrypted2);
        assert_eq!(plaintext, decrypted1.as_slice());
    }

    #[test]
    fn test_decrypt_with_wrong_key_fails() {
        let key1 = [42u8; KEY_SIZE];
        let key2 = [99u8; KEY_SIZE];

        let adapter1 = ChaCha20Encryption::new(key1);
        let adapter2 = ChaCha20Encryption::new(key2);

        let plaintext = b"Secret message";
        let ciphertext = adapter1.encrypt(plaintext).expect("Encryption failed");

        let result = adapter2.decrypt(&ciphertext);
        assert!(result.is_err());
    }

    #[test]
    fn test_from_passphrase() {
        let passphrase = "my-secure-passphrase-123";
        let adapter = ChaCha20Encryption::from_passphrase(passphrase)
            .expect("Failed to create from passphrase");

        let plaintext = b"Test message";
        let ciphertext = adapter.encrypt(plaintext).expect("Encryption failed");
        let decrypted = adapter.decrypt(&ciphertext).expect("Decryption failed");

        assert_eq!(plaintext, decrypted.as_slice());
    }

    #[test]
    fn test_from_key_bytes() {
        let key_bytes = [123u8; KEY_SIZE];
        let adapter =
            ChaCha20Encryption::from_key_bytes(&key_bytes).expect("Failed to create from bytes");

        let plaintext = b"Test message";
        let ciphertext = adapter.encrypt(plaintext).expect("Encryption failed");
        let decrypted = adapter.decrypt(&ciphertext).expect("Decryption failed");

        assert_eq!(plaintext, decrypted.as_slice());
    }

    #[test]
    fn test_from_key_bytes_wrong_size() {
        let key_bytes = [123u8; 16];
        let result = ChaCha20Encryption::from_key_bytes(&key_bytes);
        assert!(result.is_err());
    }

    #[test]
    fn test_decrypt_too_short_ciphertext() {
        let key = [42u8; KEY_SIZE];
        let adapter = ChaCha20Encryption::new(key);

        let short_data = [0u8; 5];
        let result = adapter.decrypt(&short_data);
        assert!(result.is_err());
    }

    #[test]
    fn test_derive_key() {
        let key = [42u8; KEY_SIZE];
        let adapter = ChaCha20Encryption::new(key);

        let derived = adapter
            .derive_key("test-passphrase")
            .expect("Key derivation failed");

        assert!(!derived.is_empty());
        assert!(derived.len() >= KEY_SIZE);
    }
}
