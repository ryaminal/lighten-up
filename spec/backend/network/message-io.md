# Network Message I/O Specification

## Overview

The **Message I/O** module provides low-level network message transmission and reception over TCP streams. It handles message framing, serialization, encryption/decryption, and peer identification extraction for the Lighten-Up peer-to-peer protocol.

**Module:** `src-tauri/src/network/message_io.rs`

**Key Responsibilities:**

- Read encrypted messages from TCP streams
- Write encrypted messages to TCP streams
- Frame messages with length prefixes (length-prefixed protocol)
- Serialize/deserialize messages using JSON
- Encrypt/decrypt message payloads
- Extract peer IDs from incoming messages

## Architecture

### Design Patterns

1. **Length-Prefixed Protocol**: Messages prefixed with 4-byte length field (u32, big-endian)
2. **Adapter Pattern**: Generic over `EncryptionAdapter` trait for encryption flexibility
3. **Type Safety**: Returns strongly-typed `PeerId` and `Message` types
4. **Error Propagation**: Consistent error handling with `AdapterError`

### Protocol Stack

```
┌─────────────────────────────────────────┐
│ Application Layer                       │
│ (PresenceService, ChatService, etc.)    │
└─────────────────┬───────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────┐
│ Message I/O (This Module)               │
│ - Framing (length prefix)               │
│ - Serialization (JSON)                  │
│ - Encryption/Decryption                 │
└─────────────────┬───────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────┐
│ TCP Stream (Tokio)                      │
│ - Reliable byte stream                  │
└─────────────────────────────────────────┘
```

### Dependencies

- `tokio::net::TcpStream` - Async TCP networking
- `tokio::io::{AsyncReadExt, AsyncWriteExt}` - Async I/O traits
- `serde_json` - JSON serialization/deserialization
- `adapters::EncryptionAdapter` - Encryption trait
- `adapters::Message` - Message type enum
- `domain::PeerId` - Strongly-typed peer identifier

## Data Structures

### Message

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", content = "payload")]
pub enum Message {
    Presence(PresenceMessage),
    Config(ConfigMessage),
    Chat(ChatMessage),
    Notification(Notification),
}
```

**Variants:**

- `Presence`: Heartbeat, online/offline status, light state updates
- `Config`: CRDT-based configuration synchronization
- `Chat`: Chat messages between peers
- `Notification`: Targeted notifications (patient ready, urgent assist, etc.)

**Serialization:**

- Uses Serde's `tag` + `content` for tagged union representation
- JSON format: `{"type": "Presence", "payload": {...}}`

### PresenceMessage

```rust
pub enum PresenceMessage {
    Online {
        peer_id: String,
        peer_name: String,
        light_state: LightState,
        note: Option<String>,
        timestamp: u64,
        notification_status: Box<Option<Notification>>,
    },
    Goodbye { peer_id: String },
    RequestStatus { peer_id: String },
}
```

### ConfigMessage

```rust
pub struct ConfigMessage {
    pub op: ConfigOp,
    pub peer_id: String,
    pub timestamp: u64,
}

pub enum ConfigOp {
    Upsert { id, color, name, enabled, priority, updated_at, updated_by },
    Delete { id, deleted_at },
    RequestSync { peer_id },
}
```

### ChatMessage

```rust
pub struct ChatMessage {
    pub id: String,
    pub peer_id: String,
    pub peer_name: String,
    pub content: String,
    pub timestamp: i64,
}
```

### Notification

```rust
pub struct Notification {
    pub notification_type: NotificationType,
    pub message: String,
    pub target_peer_id: String,
    pub sender_peer_id: String,
    pub timestamp: u64,
    pub priority: Option<String>,
    pub color: Option<String>,
}

pub enum NotificationType {
    PatientReady,
    RoomReady,
    UrgentAssist,
    GeneralMessage,
}
```

## Public API

### Reading Messages

#### `read_message<E>(stream, encryption) -> Result<(PeerId, Message)>`

Reads an encrypted, length-prefixed message from a TCP stream.

**Parameters:**

- `stream: &mut TcpStream` - Mutable reference to TCP stream
- `encryption: &E` - Reference to encryption adapter (generic)

**Type Constraints:**

- `E: EncryptionAdapter` - Encryption adapter trait

**Returns:** `Result<(PeerId, Message)>` - Peer ID and deserialized message

**Behavior:**

1. Read 4-byte length prefix (u32, big-endian)
2. Allocate buffer of specified length
3. Read exactly `len` bytes into buffer
4. Decrypt ciphertext using encryption adapter
5. Deserialize JSON to `Message` enum
6. Extract peer ID from message payload
7. Return `(PeerId, Message)` tuple

**Errors:**

- `AdapterError::Network` - If reading from stream fails
- `AdapterError::Encryption` - If decryption fails
- `AdapterError::Serialization` - If JSON deserialization fails

**Location:** `src-tauri/src/network/message_io.rs:7`

**Protocol Format:**

```
┌──────────┬─────────────────────────────────┐
│ Length   │ Encrypted Message Bytes         │
│ (4 bytes)│ (variable length)               │
│ u32 BE   │ JSON → Encrypted → Bytes        │
└──────────┴─────────────────────────────────┘
```

**Example:**

```rust
let mut stream = TcpStream::connect("192.168.1.100:3030").await?;
let encryption = ChaCha20Encryption::new(key);

let (peer_id, message) = read_message(&mut stream, &encryption).await?;
match message {
    Message::Chat(chat_msg) => println!("{}: {}", peer_id, chat_msg.content),
    Message::Presence(presence) => println!("Presence update from {}", peer_id),
    _ => {}
}
```

### Writing Messages

#### `write_message<E>(stream, message, encryption) -> Result<()>`

Writes an encrypted, length-prefixed message to a TCP stream.

**Parameters:**

- `stream: &mut TcpStream` - Mutable reference to TCP stream
- `message: &Message` - Reference to message to send
- `encryption: &E` - Reference to encryption adapter (generic)

**Type Constraints:**

- `E: EncryptionAdapter` - Encryption adapter trait

**Returns:** `Result<()>` - Unit on success

**Behavior:**

1. Serialize `Message` to JSON bytes
2. Encrypt JSON bytes using encryption adapter
3. Calculate length of encrypted payload (as u32)
4. Write 4-byte length prefix (u32, big-endian)
5. Write encrypted payload bytes
6. Return success

**Errors:**

- `AdapterError::Serialization` - If JSON serialization fails
- `AdapterError::Encryption` - If encryption fails
- `AdapterError::Network` - If writing to stream fails

**Location:** `src-tauri/src/network/message_io.rs:32`

**Example:**

```rust
let mut stream = TcpStream::connect("192.168.1.100:3030").await?;
let encryption = ChaCha20Encryption::new(key);

let message = Message::Chat(ChatMessage {
    id: Uuid::new_v4().to_string(),
    peer_id: "alice".to_string(),
    peer_name: "Alice".to_string(),
    content: "Hello!".to_string(),
    timestamp: current_timestamp(),
});

write_message(&mut stream, &message, &encryption).await?;
```

### Peer ID Extraction

#### `extract_peer_id(message) -> Result<PeerId>`

Extracts the sender's peer ID from a message.

**Parameters:**

- `message: &Message` - Reference to message

**Returns:** `Result<PeerId>` - Sender's peer ID

**Behavior:**

- Matches on message type
- Extracts `peer_id` field from payload
- Wraps in `PeerId` type
- Returns strongly-typed peer identifier

**Errors:**

- None (all message types guaranteed to have peer_id field)

**Location:** `src-tauri/src/network/message_io.rs:56`

**Extraction Logic:**

```rust
Message::Presence(presence) => match presence {
    PresenceMessage::Online { peer_id, .. } => PeerId::new(peer_id),
    PresenceMessage::Goodbye { peer_id } => PeerId::new(peer_id),
    PresenceMessage::RequestStatus { peer_id } => PeerId::new(peer_id),
},
Message::Config(config) => PeerId::new(&config.peer_id),
Message::Chat(chat) => PeerId::new(&chat.peer_id),
Message::Notification(notification) => PeerId::new(&notification.sender_peer_id),
```

## Wire Protocol

### Message Framing

**Length-Prefixed Protocol:**

```
Message := Length + Encrypted_Payload
Length := 4 bytes (u32, big-endian)
Encrypted_Payload := Encrypted(JSON(Message))
```

**Rationale:**

- Prevents partial reads (know exact message size)
- Enables efficient buffer allocation
- Standard framing technique for TCP streams
- Maximum message size: 2^32 - 1 bytes (4GB, unrealistic in practice)

### Serialization Format

**JSON Encoding:**

```json
{
  "type": "Chat",
  "payload": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "peer_id": "alice",
    "peer_name": "Alice",
    "content": "Hello, team!",
    "timestamp": 1703088000000
  }
}
```

**Benefits:**

- Human-readable for debugging
- Self-describing (includes type tags)
- Extensible (can add fields without breaking old clients)
- Well-supported libraries

**Tradeoffs:**

- Larger than binary formats (protobuf, msgpack)
- Slower than binary formats
- Acceptable for low-frequency messages (presence updates, chat)

### Encryption Layer

**Encryption Flow:**

```
Plaintext JSON → Encrypt → Ciphertext → Write to TCP
TCP → Read Ciphertext → Decrypt → Plaintext JSON
```

**Adapter Pattern:**

- Allows swapping encryption algorithms without changing protocol
- Current implementation: ChaCha20 symmetric encryption
- Future: Support for asymmetric encryption, key exchange

## Encryption Adapter Interface

### EncryptionAdapter Trait

```rust
pub trait EncryptionAdapter: Send + Sync {
    fn encrypt(&self, plaintext: &[u8]) -> Result<Vec<u8>>;
    fn decrypt(&self, ciphertext: &[u8]) -> Result<Vec<u8>>;
    fn derive_key(&self, passphrase: &str) -> Result<Vec<u8>>;
}
```

**Thread Safety:**

- `Send + Sync` bounds allow sharing across threads
- Implementations must be thread-safe (no mutable state or proper locking)

**Implementation:**

- `ChaCha20Encryption` - Symmetric encryption with shared key
- Located in `src-tauri/src/encryption/chacha20.rs`

## Error Handling

### Error Types

```rust
pub enum AdapterError {
    Network(String),       // TCP I/O errors
    Encryption(String),    // Encryption/decryption failures
    Serialization(String), // JSON serialization/deserialization errors
}
```

### Error Scenarios

#### Network Errors

**Read Failures:**

```rust
AdapterError::Network(format!("Failed to read length: {}", e))
AdapterError::Network(format!("Failed to read message: {}", e))
```

**Causes:**

- Connection closed by remote peer
- Network timeout
- TCP reset

**Write Failures:**

```rust
AdapterError::Network(format!("Failed to write length: {}", e))
AdapterError::Network(format!("Failed to write message: {}", e))
```

**Causes:**

- Connection closed
- Buffer full (backpressure)
- Network unavailable

#### Encryption Errors

**Decryption Failures:**

- Wrong encryption key
- Corrupted ciphertext
- Invalid ciphertext length

**Encryption Failures:**

- Cipher initialization failed
- Out of memory

#### Serialization Errors

**Deserialization Failures:**

```rust
AdapterError::Serialization(format!("Failed to deserialize: {}", e))
```

**Causes:**

- Invalid JSON syntax
- Unknown message type
- Missing required fields
- Type mismatch (string vs number)

**Serialization Failures:**

```rust
AdapterError::Serialization(format!("Failed to serialize: {}", e))
```

**Causes:**

- Extremely rare (all types are serializable)
- Out of memory

### Error Recovery

**Strategies:**

1. **Connection Errors**: Close stream, remove peer, attempt reconnection
2. **Decryption Errors**: Log error, close connection (wrong key or attack)
3. **Serialization Errors**: Log error, skip message, continue listening

## Performance Considerations

### Memory Allocation

**Read Path:**

```rust
let mut buf = vec![0u8; len];  // Allocation based on length prefix
```

**Optimization:**

- Single allocation per message (size known from length prefix)
- Reusable buffer possible (not currently implemented)

**Write Path:**

```rust
let json = serde_json::to_vec(message)?;      // Allocate JSON
let encrypted = encryption.encrypt(&json)?;   // Allocate encrypted bytes
```

**Optimization:**

- Two allocations per send (JSON + encrypted)
- Could use buffer pools to reduce allocation overhead

### Copy Operations

**Current Approach:**

- Zero copies on TCP read/write (Tokio handles efficiently)
- One copy during encryption (plaintext → ciphertext)
- One copy during decryption (ciphertext → plaintext)

**Potential Improvements:**

- In-place encryption/decryption (if cipher supports)
- Streaming serialization (serde_json supports this)

### Throughput

**Bottlenecks:**

1. **Encryption/Decryption** - CPU-bound (ChaCha20 is fast)
2. **JSON Serialization** - Moderate overhead
3. **Network Bandwidth** - Typical bottleneck on fast networks

**Scalability:**

- Designed for low-frequency messages (10-100 messages/sec per peer)
- Not optimized for high-throughput scenarios
- Consider binary format (MessagePack, Protobuf) for high-throughput needs

## Security Considerations

### Encryption Requirements

**Mandatory Encryption:**

- All messages encrypted before transmission
- No plaintext messages on wire
- Protects confidentiality and integrity

**Key Management:**

- Shared symmetric key (ChaCha20)
- Key derived from passphrase via Argon2
- All peers must share same passphrase

**Threats Mitigated:**

- **Eavesdropping**: Encrypted payloads unreadable
- **Replay Attacks**: Timestamps in messages (application-level validation)
- **Man-in-the-Middle**: Partially (no authentication of peers yet)

### Attack Vectors

#### Ciphertext Tampering

**Risk:** Attacker modifies encrypted message

**Mitigation:**

- ChaCha20-Poly1305 provides authenticated encryption (AEAD)
- Current implementation: ChaCha20 only (no authentication tag)
- **Recommendation:** Upgrade to ChaCha20-Poly1305 for authentication

#### Message Injection

**Risk:** Attacker sends valid encrypted messages

**Mitigation:**

- Requires knowing shared passphrase
- Peer ID validation (application layer)

#### Denial of Service

**Risk:** Malicious length prefix (e.g., 4GB message)

**Mitigation:**

- None currently (will attempt to allocate huge buffer)
- **Recommendation:** Add maximum message size limit (e.g., 10MB)

**Example:**

```rust
const MAX_MESSAGE_SIZE: u32 = 10 * 1024 * 1024; // 10MB

let len = stream.read_u32().await? as usize;
if len > MAX_MESSAGE_SIZE as usize {
    return Err(AdapterError::Network("Message too large".to_string()));
}
```

#### Connection Exhaustion

**Risk:** Attacker opens many connections

**Mitigation:**

- TCP connection limits (OS level)
- Peer authentication (application level)

## Test Coverage

**Current Status:** No unit tests (0 tests)

**Testing Challenges:**

- Requires TCP connections
- Requires encryption setup
- Async code testing

**Recommended Test Strategy:**

### Unit Tests (Future)

1. **Roundtrip Test**

   ```rust
   #[tokio::test]
   async fn test_message_roundtrip() {
       // Setup: Create paired TCP streams (tokio::io::duplex)
       // Write message to one end
       // Read from other end
       // Assert message unchanged
   }
   ```

2. **Error Handling Test**

   ```rust
   #[tokio::test]
   async fn test_read_connection_closed() {
       // Setup: Close stream after writing length
       // Read should return Network error
   }
   ```

3. **Serialization Test**

   ```rust
   #[test]
   fn test_extract_peer_id_all_types() {
       // Test peer ID extraction for all Message variants
   }
   ```

4. **Large Message Test**
   ```rust
   #[tokio::test]
   async fn test_large_message() {
       // Send 1MB message
       // Verify successful transmission
   }
   ```

### Integration Tests (Future)

1. **Two-Peer Communication**
   - Launch two peers
   - Send messages bidirectionally
   - Verify delivery

2. **Encryption Key Mismatch**
   - Peer A uses key1
   - Peer B uses key2
   - Verify decryption fails

3. **Connection Interruption**
   - Send message
   - Close connection mid-transmission
   - Verify error handling

## Integration Points

### Network Layer

**Used By:**

- `network::transport::Transport` - Higher-level connection management
- Peer connection handlers

**Usage Pattern:**

```rust
// Accept incoming connection
let mut stream = listener.accept().await?;

// Read messages in loop
loop {
    match read_message(&mut stream, &encryption).await {
        Ok((peer_id, message)) => {
            // Handle message based on type
            handle_message(peer_id, message).await;
        }
        Err(e) => {
            log::error!("Read error: {}", e);
            break;
        }
    }
}
```

### Application Layer

**Message Dispatch:**

```rust
let (peer_id, message) = read_message(&mut stream, &encryption).await?;

match message {
    Message::Presence(presence) => {
        presence_service.handle_presence(peer_id, presence).await?;
    }
    Message::Config(config) => {
        config_service.handle_config(peer_id, config).await?;
    }
    Message::Chat(chat) => {
        chat_service.handle_message(chat).await?;
    }
    Message::Notification(notification) => {
        notification_service.handle_notification(notification).await?;
    }
}
```

## Usage Examples

### Basic Send/Receive

```rust
use message_io::{read_message, write_message};

// Setup
let encryption = ChaCha20Encryption::new(key);
let mut stream = TcpStream::connect(peer_addr).await?;

// Send a message
let message = Message::Presence(PresenceMessage::Online {
    peer_id: "alice".to_string(),
    peer_name: "Alice".to_string(),
    light_state: LightState::new("#00FF00".to_string()),
    note: Some("Available".to_string()),
    timestamp: current_timestamp(),
    notification_status: Box::new(None),
});

write_message(&mut stream, &message, &encryption).await?;

// Receive response
let (peer_id, response) = read_message(&mut stream, &encryption).await?;
println!("Received message from {}", peer_id);
```

### Message Loop

```rust
// Continuous message reading
loop {
    match read_message(&mut stream, &encryption).await {
        Ok((peer_id, message)) => {
            log::info!("Message from {}: {:?}", peer_id, message);

            // Dispatch to appropriate handler
            dispatch_message(peer_id, message).await;
        }
        Err(AdapterError::Network(e)) if e.contains("connection closed") => {
            log::info!("Peer disconnected");
            break;
        }
        Err(e) => {
            log::error!("Read error: {}", e);
            break;
        }
    }
}
```

### Error Handling

```rust
match write_message(&mut stream, &message, &encryption).await {
    Ok(_) => log::debug!("Message sent successfully"),
    Err(AdapterError::Network(e)) => {
        log::error!("Network error: {}", e);
        // Close connection, mark peer offline
        stream.shutdown().await.ok();
    }
    Err(AdapterError::Encryption(e)) => {
        log::error!("Encryption error: {}", e);
        // Critical error, should not happen
        panic!("Encryption failure: {}", e);
    }
    Err(e) => {
        log::error!("Unexpected error: {}", e);
    }
}
```

## Future Improvements

### Protocol Enhancements

1. **Binary Serialization** - Switch to MessagePack or Protobuf
   - Smaller message size
   - Faster serialization
   - Backward compatibility via versioning

2. **Compression** - Add optional compression layer
   - LZ4 or Zstd for fast compression
   - Negotiate compression during handshake

3. **Message Batching** - Send multiple messages in single frame
   - Reduce framing overhead
   - Better throughput for high-frequency updates

4. **Multiplexing** - Multiple logical streams over one TCP connection
   - Reduce connection overhead
   - Priority-based message sending

### Security Enhancements

1. **Authenticated Encryption** - Use ChaCha20-Poly1305 (AEAD)
   - Prevent tampering
   - Verify message integrity

2. **Key Exchange** - Implement Diffie-Hellman key exchange
   - Avoid shared passphrase requirement
   - Support per-connection keys

3. **Message Size Limits** - Enforce maximum message size
   - Prevent DoS attacks
   - Validate length prefix

4. **Rate Limiting** - Limit messages per peer
   - Prevent flooding
   - Protect against malicious peers

### Performance Optimizations

1. **Buffer Pooling** - Reuse buffers to reduce allocations
   - Object pool pattern
   - Amortize allocation cost

2. **Zero-Copy I/O** - Minimize data copying
   - Direct buffer access
   - Streaming encryption

3. **Pipelining** - Send next message while waiting for ACK
   - Improve throughput
   - Requires reliable ordering

### Reliability

1. **Message Acknowledgments** - Add ACK/NACK protocol
   - Reliable delivery guarantee
   - Detect message loss

2. **Retry Logic** - Automatic message resend
   - Exponential backoff
   - Idempotency tokens

3. **Health Checks** - Periodic ping/pong
   - Detect dead connections
   - Close stale streams

## Related Documentation

- **Protocol Messages:** `spec/backend/protocol/messages.md` (to be created)
- **Encryption:** `spec/backend/encryption/chacha20.md` (to be created)
- **Network Transport:** `spec/backend/network/transport.md` (to be created)
- **Domain Ports:** `spec/backend/domain/ports.md` (to be created)
- **Error Handling:** `spec/backend/adapters/error.md` (to be created)
- **Wire Protocol:** `docs/PROTOCOL.md`
