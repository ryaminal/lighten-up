# Encryption Layer Specification

## Overview

The **Encryption** module provides authenticated encryption for all network communication using ChaCha20-Poly1305 (AEAD cipher) with Argon2-based key derivation from passphrases. This ensures confidentiality, integrity, and authenticity of messages.

**Modules:**

- `src-tauri/src/encryption/chacha20.rs` - ChaCha20-Poly1305 implementation
- `src-tauri/src/encryption/key_derivation.rs` - Argon2 key derivation
- `src-tauri/src/encryption/mod.rs` - Module exports and tests

**Key Responsibilities:**

- Encrypt plaintext messages
- Decrypt ciphertext messages
- Derive cryptographic keys from passphrases
- Generate random nonces for semantic security
- Authenticate ciphertext (AEAD)

## Architecture

### Cryptographic Primitives

**Cipher:** ChaCha20-Poly1305

- **ChaCha20:** Stream cipher for confidentiality
- **Poly1305:** MAC for authentication
- **AEAD:** Authenticated Encryption with Associated Data
- **Key Size:** 256 bits (32 bytes)
- **Nonce Size:** 96 bits (12 bytes)

**Key Derivation:** Argon2

- **Function:** Password-based KDF
- **Variant:** Argon2id (default)
- **Purpose:** Derive encryption keys from human-memorable passphrases

### Design Patterns

1. **Adapter Pattern**: Implements `EncryptionAdapter` trait
2. **Builder Pattern**: Multiple constructors (new, from_passphrase, from_key_bytes)
3. **Nonce-Prefix**: Nonce prepended to ciphertext for transmission
4. **Fixed Salt**: Shared salt for peer key agreement (development)

## Data Structures

### ChaCha20Encryption

```rust
pub struct ChaCha20Encryption {
    key: [u8; KEY_SIZE],  // 32 bytes
}
```

**Fields:**

- `key`: 256-bit encryption key

**Constants:**

- `KEY_SIZE = 32` (256 bits)
- `NONCE_SIZE = 12` (96 bits)

## Public API

### Constructors

#### `new(key) -> Self`

Creates encryption adapter with pre-derived key.

**Parameters:**

- `key: [u8; KEY_SIZE]` - 32-byte encryption key

**Returns:** `ChaCha20Encryption` instance

**Location:** `src-tauri/src/encryption/chacha20.rs:18`

**Example:**

```rust
let key = [42u8; 32];
let encryption = ChaCha20Encryption::new(key);
```

#### `from_passphrase(passphrase) -> Result<Self>`

Creates encryption adapter by deriving key from passphrase.

**Parameters:**

- `passphrase: &str` - Human-readable passphrase

**Returns:** `Result<ChaCha20Encryption>` - Adapter or error

**Behavior:**

1. Derives key using Argon2 with fixed salt
2. Creates ChaCha20Encryption with derived key

**Errors:**

- `AdapterError::Encryption` - If key derivation fails

**Location:** `src-tauri/src/encryption/chacha20.rs:23`

**Example:**

```rust
let encryption = ChaCha20Encryption::from_passphrase("my-secret-passphrase")?;
```

#### `from_key_bytes(key_bytes) -> Result<Self>`

Creates encryption adapter from raw key bytes.

**Parameters:**

- `key_bytes: &[u8]` - Raw key material (must be exactly 32 bytes)

**Returns:** `Result<ChaCha20Encryption>` - Adapter or error

**Behavior:**

1. Validates key length (must be KEY_SIZE)
2. Copies bytes into fixed-size array
3. Creates ChaCha20Encryption

**Errors:**

- `AdapterError::Encryption` - If key length incorrect

**Location:** `src-tauri/src/encryption/chacha20.rs:29`

**Example:**

```rust
let key_bytes = hex::decode("0123456789abcdef...")?;
let encryption = ChaCha20Encryption::from_key_bytes(&key_bytes)?;
```

### Encryption Operations

#### `encrypt(plaintext) -> Result<Vec<u8>>`

Encrypts plaintext and prepends nonce.

**Parameters:**

- `plaintext: &[u8]` - Data to encrypt

**Returns:** `Result<Vec<u8>>` - Nonce + ciphertext + authentication tag

**Behavior:**

1. Generate random 12-byte nonce (OsRng)
2. Create ChaCha20-Poly1305 cipher with key
3. Encrypt plaintext with nonce
4. Prepend nonce to ciphertext
5. Return complete payload

**Output Format:**

```
[nonce (12 bytes)][ciphertext (N bytes)][auth tag (16 bytes)]
```

**Total Size:** `12 + plaintext.len() + 16` bytes

**Errors:**

- `AdapterError::Encryption` - If encryption fails (extremely rare)

**Location:** `src-tauri/src/encryption/chacha20.rs:46`

**Security Properties:**

- **Semantic Security**: Random nonce ensures same plaintext produces different ciphertexts
- **Authenticated**: Poly1305 tag prevents tampering
- **IND-CCA2**: Secure against chosen-ciphertext attacks

**Example:**

```rust
let plaintext = b"Hello, World!";
let ciphertext = encryption.encrypt(plaintext)?;
// ciphertext.len() == 12 + 13 + 16 = 41 bytes
```

#### `decrypt(ciphertext) -> Result<Vec<u8>>`

Decrypts ciphertext and verifies authentication tag.

**Parameters:**

- `ciphertext: &[u8]` - Nonce + encrypted data + tag

**Returns:** `Result<Vec<u8>>` - Decrypted plaintext

**Behavior:**

1. Validate minimum length (nonce + tag = 28 bytes)
2. Split nonce (first 12 bytes) from encrypted data
3. Create ChaCha20-Poly1305 cipher with key
4. Decrypt and verify authentication tag
5. Return plaintext

**Errors:**

- `AdapterError::Encryption("Ciphertext too short")` - If less than 12 bytes
- `AdapterError::Encryption("Decryption failed")` - If wrong key or tampered data

**Location:** `src-tauri/src/encryption/chacha20.rs:64`

**Security:**

- Verifies Poly1305 tag before returning plaintext
- Constant-time comparison prevents timing attacks
- Fails on any tampering or wrong key

**Example:**

```rust
let plaintext = encryption.decrypt(&ciphertext)?;
```

#### `derive_key(passphrase) -> Result<Vec<u8>>`

Derives key bytes from passphrase (with random salt).

**Parameters:**

- `passphrase: &str` - Passphrase to derive from

**Returns:** `Result<Vec<u8>>` - Derived key bytes

**Behavior:**

1. Generate random salt (OsRng)
2. Use Argon2 to hash passphrase with salt
3. Return hash bytes

**Note:** Uses random salt (unlike `from_passphrase` which uses fixed salt)

**Purpose:** For storing keys or one-time derivations

**Location:** `src-tauri/src/encryption/chacha20.rs:83`

**Example:**

```rust
let key_bytes = encryption.derive_key("passphrase")?;
// Store key_bytes securely
```

## Key Derivation

### derive_key_from_passphrase

```rust
pub fn derive_key_from_passphrase(passphrase: &str) -> Result<[u8; KEY_SIZE]>
```

**Purpose:** Derives encryption key for peer-to-peer communication.

**Parameters:**

- `passphrase: &str` - Shared passphrase

**Returns:** `Result<[u8; 32]>` - 32-byte encryption key

**Behavior:**

1. Uses fixed salt: `"lightenup1234567"`
2. Applies Argon2 key derivation
3. Extracts first 32 bytes of hash
4. Returns as fixed-size array

**Fixed Salt Rationale:**

- All peers must derive same key from same passphrase
- Fixed salt ensures key agreement
- **Security Note:** Acceptable for local network, pre-shared secret model

**Location:** `src-tauri/src/encryption/key_derivation.rs:8`

**Example:**

```rust
let key = derive_key_from_passphrase("team-secret-2024")?;
let encryption = ChaCha20Encryption::new(key);
```

### derive_key_bytes

```rust
pub fn derive_key_bytes(passphrase: &str) -> Result<Vec<u8>>
```

**Purpose:** Derives key bytes with random salt (for storage).

**Parameters:**

- `passphrase: &str` - Passphrase to derive from

**Returns:** `Result<Vec<u8>>` - Derived hash bytes

**Behavior:**

1. Generates random salt (OsRng)
2. Applies Argon2 key derivation
3. Returns hash as bytes

**Use Cases:**

- Storing derived keys
- One-time key generation
- Non-peer-to-peer scenarios

**Location:** `src-tauri/src/encryption/key_derivation.rs:41`

### Argon2 Parameters

**Variant:** Argon2id (default)

- Balanced resistance to side-channel and GPU attacks

**Parameters:** (Argon2::default())

- **Memory:** 15 MiB
- **Iterations:** 2
- **Parallelism:** 1 thread

**Tuning:** Default parameters suitable for desktop application

## Wire Format

### Encrypted Message Structure

```
┌────────────┬───────────────┬─────────────┐
│   Nonce    │  Ciphertext   │  Auth Tag   │
│  12 bytes  │   N bytes     │  16 bytes   │
└────────────┴───────────────┴─────────────┘
         ↑                          ↑
    Random (OsRng)            Poly1305 MAC
```

**Total Overhead:** 28 bytes per message (12 + 16)

**Example:**

```
Plaintext:  "Hello" (5 bytes)
Encrypted:  12 + 5 + 16 = 33 bytes
Overhead:   28 bytes (560% for short messages)
```

### Nonce Management

**Generation:** Cryptographically secure random (OsRng)

**Uniqueness:** Statistically guaranteed (2^96 possible values)

**Reuse Risk:** Negligible for realistic message volumes (< 2^48 messages)

**Best Practice:** New random nonce per encryption

## Security Properties

### Confidentiality

**Cipher:** ChaCha20 (256-bit key)

- Resistant to known cryptanalysis
- Faster than AES on CPUs without AES-NI
- No known weaknesses

**Key Space:** 2^256 keys (computationally infeasible to brute-force)

### Integrity & Authentication

**MAC:** Poly1305 (128-bit tag)

- Provably secure (information-theoretically secure for single use)
- Forgery probability: 2^-128 (negligible)

**AEAD Guarantees:**

- Ciphertext tampering detected
- Cannot decrypt with wrong key
- Cannot swap nonce without detection

### Semantic Security

**Random Nonces:** Same plaintext → different ciphertexts

**Test Evidence:**

```rust
let ciphertext1 = adapter.encrypt(b"Same message");
let ciphertext2 = adapter.encrypt(b"Same message");
assert_ne!(ciphertext1, ciphertext2);  // Different due to random nonces
```

### Key Derivation Security

**Argon2 Properties:**

- Memory-hard (resists GPU attacks)
- Time-hard (resists ASIC attacks)
- Configurable (tunable for performance/security tradeoff)

**Salt Usage:**

- Fixed salt: Enables key agreement but exposes to precomputation
- **Trade-off:** Convenience vs dictionary attack resistance

**Threat Model:**

- Acceptable for local network with pre-shared secret
- Not suitable for public internet without additional authentication

## Threat Model & Limitations

### Shared Key Model

**Current Design:** All peers share same encryption key

**Implications:**

- Any peer can decrypt all messages
- No peer-specific encryption
- Compromised key compromises all communication

**Future:** Per-peer keys with Diffie-Hellman key exchange

### Fixed Salt

**Security Implication:** Enables rainbow table attacks

**Mitigation:**

- Use strong passphrase (high entropy)
- Local network reduces attack surface

**Future:** Derive salt from peer IDs or use key exchange

### No Forward Secrecy

**Current:** Same key used for all messages

**Risk:** Compromised key exposes all past messages

**Future:** Ephemeral keys with Diffie-Hellman

### Replay Attacks

**Current:** No protection against message replay

**Application-Level:** Timestamps used for ordering

**Future:** Add sequence numbers or time windows

## Performance Considerations

### Encryption Speed

**ChaCha20:** ~1-2 GB/sec on modern CPUs

- Faster than AES on CPUs without AES-NI
- Suitable for real-time communication

**Overhead:**

- Small messages (< 100 bytes): 28-byte overhead significant
- Large messages (> 1 KB): < 3% overhead

**Typical Message Sizes:**

- Chat: 100-500 bytes → ~10-30% overhead
- Presence: 200 bytes → ~14% overhead

### Key Derivation Cost

**Argon2 Performance:** ~50-100ms per derivation

**Impact:**

- One-time cost at startup (from_passphrase)
- No impact on message throughput

**Recommendation:** Cache derived keys, don't re-derive per message

## Error Handling

### Encryption Errors

**Possible Causes:**

- Out of memory (extremely rare)
- RNG failure (should never happen with OsRng)

**Response:** Panic or fail fast (unrecoverable)

### Decryption Errors

**Common Causes:**

1. Wrong encryption key
2. Corrupted ciphertext
3. Truncated message
4. Authentication tag mismatch

**Error Message:** `"Decryption failed"`

**Response:** Log error, close connection, mark peer offline

### Key Derivation Errors

**Possible Causes:**

- Invalid salt encoding
- Argon2 library failure

**Response:** Propagate error to caller, prevent startup

## Test Coverage

**Location:** `src-tauri/src/encryption/mod.rs:7-112`

**Total Tests:** 8 comprehensive tests

### Test Categories

#### Roundtrip Tests (1 test)

1. ✅ `test_encrypt_decrypt_roundtrip` - Verify encrypt → decrypt recovers plaintext

#### Semantic Security (1 test)

2. ✅ `test_encrypt_produces_different_ciphertexts` - Same plaintext → different ciphertexts

#### Authentication (1 test)

3. ✅ `test_decrypt_with_wrong_key_fails` - Wrong key fails decryption

#### Constructor Tests (3 tests)

4. ✅ `test_from_passphrase` - Create from passphrase and roundtrip
5. ✅ `test_from_key_bytes` - Create from raw bytes
6. ✅ `test_from_key_bytes_wrong_size` - Reject wrong key size

#### Error Handling (1 test)

7. ✅ `test_decrypt_too_short_ciphertext` - Reject invalid ciphertext

#### Key Derivation (1 test)

8. ✅ `test_derive_key` - Derive key from passphrase

### Coverage Analysis

**Covered:**

- ✅ Basic encryption/decryption
- ✅ Nonce randomness (semantic security)
- ✅ Authentication (wrong key fails)
- ✅ All constructor variants
- ✅ Error cases

**Missing Tests:**

- ⚠️ Large message handling (> 1 MB)
- ⚠️ Performance benchmarks
- ⚠️ Concurrent encryption (thread safety)
- ⚠️ Nonce collision (statistical test)

**Recommendation:** Add large message and concurrent access tests

## Integration Points

### Network Layer

**Usage in Transport:**

```rust
// Sending
let encrypted = encryption.encrypt(&json_bytes)?;
stream.write_all(&encrypted).await?;

// Receiving
let mut buf = vec![0u8; len];
stream.read_exact(&mut buf).await?;
let plaintext = encryption.decrypt(&buf)?;
```

### Application Startup

**Initialization:**

```rust
// User provides passphrase
let passphrase = prompt_user_for_passphrase()?;

// Derive encryption key
let encryption = ChaCha20Encryption::from_passphrase(&passphrase)?;

// Share with network layer
let network = MdnsNetwork::new(peer_id, encryption);
```

### Key Storage

**Persistent Key:**

```rust
// First run: derive and store
let key = derive_key_from_passphrase(passphrase)?;
save_key_to_secure_storage(&key)?;

// Subsequent runs: load from storage
let key = load_key_from_secure_storage()?;
let encryption = ChaCha20Encryption::new(key);
```

## Usage Examples

### Basic Encryption

```rust
use encryption::ChaCha20Encryption;

// Create from passphrase
let encryption = ChaCha20Encryption::from_passphrase("secret-passphrase")?;

// Encrypt
let plaintext = b"Hello, World!";
let ciphertext = encryption.encrypt(plaintext)?;
println!("Encrypted: {} bytes", ciphertext.len());

// Decrypt
let decrypted = encryption.decrypt(&ciphertext)?;
assert_eq!(plaintext, decrypted.as_slice());
```

### Key Management

```rust
// Derive key once
let key = derive_key_from_passphrase("team-secret-2024")?;

// Share among multiple components
let encryption1 = ChaCha20Encryption::new(key);
let encryption2 = ChaCha20Encryption::new(key);

// Both can decrypt messages from each other
let ciphertext = encryption1.encrypt(b"message")?;
let plaintext = encryption2.decrypt(&ciphertext)?;
```

### Error Handling

```rust
match encryption.decrypt(&ciphertext) {
    Ok(plaintext) => {
        // Process message
        handle_message(&plaintext);
    }
    Err(AdapterError::Encryption(e)) if e.contains("Decryption failed") => {
        eprintln!("Wrong key or corrupted message");
        // Close connection
    }
    Err(e) => eprintln!("Unexpected error: {}", e),
}
```

## Future Improvements

### Cryptographic Enhancements

1. **Per-Peer Keys** - Unique key per peer pair:

   ```rust
   struct PeerEncryption {
       keys: HashMap<PeerId, [u8; 32]>,
   }
   ```

2. **Forward Secrecy** - Ephemeral keys with X25519:

   ```rust
   let (public, private) = generate_keypair();
   let shared_secret = dh_exchange(my_private, their_public);
   ```

3. **Key Rotation** - Periodic key updates:

   ```rust
   if key_age > Duration::from_days(30) {
       renegotiate_key().await?;
   }
   ```

4. **Additional Data** - AEAD with associated data:
   ```rust
   cipher.encrypt(nonce, Payload {
       msg: plaintext,
       aad: &[peer_id, timestamp],  // Authenticated but not encrypted
   })
   ```

### Performance Optimizations

1. **Batch Encryption** - Encrypt multiple messages at once:

   ```rust
   fn encrypt_batch(&self, plaintexts: &[&[u8]]) -> Result<Vec<Vec<u8>>>
   ```

2. **Zero-Copy** - In-place encryption:

   ```rust
   fn encrypt_in_place(&self, buffer: &mut Vec<u8>) -> Result<()>
   ```

3. **Hardware Acceleration** - Use AES-NI when available:
   ```rust
   #[cfg(target_feature = "aes")]
   use aes_gcm::Aes256Gcm;
   ```

### Key Management

1. **Secure Storage** - OS keychain integration:

   ```rust
   #[cfg(target_os = "macos")]
   use keychain_services;
   ```

2. **Key Exchange Protocol** - SPAKE2 or SRP:

   ```rust
   let (key, verifier) = spake2_client(passphrase)?;
   let session_key = spake2_server(verifier)?;
   ```

3. **Random Salt** - Per-installation salt:
   ```rust
   let salt = generate_random_salt();
   save_salt_to_config(&salt)?;
   ```

## Related Documentation

- **Network Message I/O:** `spec/backend/network/message-io.md`
- **Encryption Adapter Trait:** `spec/backend/domain/ports.md` (to be created)
- **Security Architecture:** `spec/architecture.md`
- **Key Derivation (Argon2):** https://github.com/RustCrypto/password-hashes
- **ChaCha20-Poly1305 (AEAD):** https://github.com/RustCrypto/AEADs
