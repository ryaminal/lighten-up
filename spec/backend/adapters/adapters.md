# Adapters Layer Specification

## Overview

The adapters layer provides infrastructure interface definitions, error types, and message envelopes for network communication. It acts as a bridge between domain abstractions and concrete implementations, following Clean Architecture principles.

**Location:** `src-tauri/src/adapters/`

- `mod.rs` (11 lines): Module exports
- `message.rs` (50 lines, 1 test): Network message envelope
- `error.rs` (41 lines, 1 test): Adapter error types
- `encryption.rs` (3 lines): Re-export EncryptionAdapter port
- `network.rs` (7 lines): Re-export NetworkAdapter port

**Total:** 112 lines including 2 tests

**Responsibilities:**

- Define Message enum for network message discrimination
- Provide AdapterError type for infrastructure failures
- Re-export domain ports for consistent API
- Enable serialization of heterogeneous message types
- Establish error handling patterns for adapters

## Architecture

### Design Pattern

**Facade Layer**

- Re-exports domain ports (NetworkAdapter, EncryptionAdapter)
- Wraps protocol messages in discriminated Message enum
- Provides adapter-specific error types

**Separation of Concerns:**

- Domain: Defines ports (interfaces)
- Adapters: Provides concrete implementations (in network/, encryption/ modules)
- This module: Common types used by all adapters

### Module Structure

```
adapters/
  ├── mod.rs            - Public exports
  ├── message.rs        - Message envelope enum
  ├── error.rs          - AdapterError type
  ├── encryption.rs     - Re-export EncryptionAdapter
  └── network.rs        - Re-export NetworkAdapter
```

**Exports:**

```rust
pub use crate::domain::{EncryptionAdapter, NetworkAdapter};
pub use error::{AdapterError, Result};
pub use message::Message;
```

**Note:** Actual adapter implementations live in `src-tauri/src/network/` and `src-tauri/src/encryption/`

## Message Envelope

### Message Enum

Discriminated union of all network message types.

**File:** `src-tauri/src/adapters/message.rs`

```rust
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(tag = "type", content = "payload")]
pub enum Message {
    Presence(PresenceMessage),
    Config(ConfigMessage),
    Chat(ChatMessage),
    Notification(Notification),
}
```

**Purpose:**

- Unified type for network transmission
- Enables message type discrimination at deserialization
- Wraps protocol-specific message types

**Serialization Format:**

- Uses serde's **"adjacently tagged"** representation
- `tag = "type"`: Adds "type" field with variant name
- `content = "payload"`: Nests variant data under "payload" field

**Example JSON (Presence):**

```json
{
  "type": "Presence",
  "payload": {
    "Online": {
      "peer_id": "peer-123",
      "peer_name": "Alice",
      ...
    }
  }
}
```

**Example JSON (Chat):**

```json
{
  "type": "Chat",
  "payload": {
    "id": "msg-456",
    "peer_id": "peer-123",
    "peer_name": "Alice",
    "content": "Hello!",
    "timestamp": 1234567890
  }
}
```

### Variants

#### `Presence(PresenceMessage)`

Wraps presence lifecycle messages (Online, Goodbye, RequestStatus).

**Usage:**

- Heartbeat broadcasts
- Status updates (light color, name, note)
- Graceful disconnect notifications
- Status sync requests

**Example:**

```rust
let msg = Message::Presence(PresenceMessage::Online {
    peer_id: "peer-123".to_string(),
    peer_name: "Alice".to_string(),
    light_state: LightState::new("green".to_string()),
    note: Some("Available".to_string()),
    timestamp: current_timestamp(),
    notification_status: Box::new(None),
});
```

---

#### `Config(ConfigMessage)`

Wraps configuration sync messages (Upsert, Delete, RequestSync).

**Usage:**

- Light configuration CRDT synchronization
- Configuration change broadcasts
- Full configuration sync requests

**Example:**

```rust
let msg = Message::Config(ConfigMessage {
    op: ConfigOp::Upsert {
        id: "light-1".to_string(),
        color: "green".to_string(),
        name: "Room 1".to_string(),
        enabled: true,
        priority: 1,
        updated_at: current_timestamp(),
        updated_by: "peer-123".to_string(),
    },
    peer_id: "peer-123".to_string(),
    timestamp: current_timestamp(),
});
```

---

#### `Chat(ChatMessage)`

Wraps chat messages.

**Usage:**

- Text message broadcasts
- Persistent chat history

**Example:**

```rust
let msg = Message::Chat(ChatMessage {
    id: "msg-789".to_string(),
    peer_id: "peer-123".to_string(),
    peer_name: "Alice".to_string(),
    content: "Hello everyone!".to_string(),
    timestamp: current_timestamp(),
});
```

---

#### `Notification(Notification)`

Wraps structured notifications (PatientReady, RoomReady, UrgentAssist, GeneralMessage).

**Usage:**

- Targeted alerts to specific peers
- Categorized notifications with priority
- Color-coded urgent messages

**Example:**

```rust
let msg = Message::Notification(Notification {
    notification_type: NotificationType::UrgentAssist,
    message: "Help needed in Room 3".to_string(),
    target_peer_id: "peer-456".to_string(),
    sender_peer_id: "peer-123".to_string(),
    timestamp: current_timestamp(),
    priority: Some("high".to_string()),
    color: Some("#FF0000".to_string()),
});
```

---

### Serialization Details

**Serde Attributes:**

- `#[serde(tag = "type", content = "payload")]`: Adjacently tagged enum
- Alternative: Externally tagged (default, no attributes needed)

**Adjacently Tagged Benefits:**

- Explicit type discriminator field
- Clean JSON structure
- Easy to parse in other languages

**Adjacently Tagged Trade-offs:**

- Extra nesting level (payload wrapper)
- Slightly larger JSON size (~10-20 bytes overhead)

**Alternative Serialization Formats:**

**1. Externally Tagged (Default):**

```rust
#[derive(Serialize, Deserialize)]
pub enum Message {
    Presence(PresenceMessage),
    // ...
}
```

JSON:

```json
{
  "Presence": {
    "Online": { ... }
  }
}
```

**2. Internally Tagged:**

```rust
#[derive(Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum Message {
    Presence { data: PresenceMessage },
    // ...
}
```

Requires flatten, more complex.

**Current Choice:** Adjacently tagged for clarity and debuggability.

---

### Test Coverage

**File:** `src-tauri/src/adapters/message.rs` lines 20-49

**Test:** `test_presence_message_serialization`

**Coverage:**

1. Creates PresenceMessage::Online with all fields
2. Wraps in Message::Presence
3. Serializes to JSON string
4. Deserializes back to Message
5. Pattern matches to verify correct variant and peer_id

**What's Tested:**

- ✅ Serialization round-trip
- ✅ Variant discrimination
- ✅ Field preservation (peer_id checked)

**What's Not Tested:**

- ❌ Other Message variants (Config, Chat, Notification)
- ❌ Error cases (invalid JSON, wrong format)
- ❌ Edge cases (empty strings, None values)
- ❌ JSON structure validation (format correctness)

**Example Expansion:**

```rust
#[test]
fn test_all_message_variants() {
    // Test Presence
    let presence = Message::Presence(/* ... */);
    test_round_trip(presence);

    // Test Config
    let config = Message::Config(/* ... */);
    test_round_trip(config);

    // Test Chat
    let chat = Message::Chat(/* ... */);
    test_round_trip(chat);

    // Test Notification
    let notification = Message::Notification(/* ... */);
    test_round_trip(notification);
}

fn test_round_trip(msg: Message) {
    let json = serde_json::to_string(&msg).unwrap();
    let deserialized: Message = serde_json::from_str(&json).unwrap();
    // Compare fields
}
```

---

## Adapter Errors

### AdapterError Enum

Error type for infrastructure layer failures.

**File:** `src-tauri/src/adapters/error.rs`

```rust
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

    #[error("{0}")]
    Other(String),
}

pub type Result<T> = std::result::Result<T, AdapterError>;
```

**Design:**

- Uses `thiserror` for automatic Error trait derivation
- Each variant wraps String message (not structured error types)
- Display format includes error category prefix

**Variants:**

#### `Database(String)`

Database operation failures (queries, connections, migrations).

**Examples:**

- "Database error: connection pool exhausted"
- "Database error: constraint violation on chat_messages.id"

---

#### `Network(String)`

Network communication failures (TCP, discovery, routing).

**Examples:**

- "Network error: connection refused"
- "Network error: peer not found: peer-123"
- "Network error: send timeout after 5s"

---

#### `Encryption(String)`

Encryption/decryption failures.

**Examples:**

- "Encryption error: invalid key length"
- "Encryption error: authentication failed (tampered data)"

---

#### `Serialization(String)`

JSON serialization/deserialization failures.

**Examples:**

- "Serialization error: missing required field 'peer_id'"
- "Serialization error: invalid UTF-8 in message content"

---

#### `NotFound(String)`

Resource not found (peer, message, configuration).

**Examples:**

- "Not found: peer-456"
- "Not found: message msg-789"

---

#### `InvalidData(String)`

Data validation failures.

**Examples:**

- "Invalid data: peer_id cannot be empty"
- "Invalid data: content exceeds 10000 characters"

---

#### `Other(String)`

Catch-all for unexpected errors.

**Examples:**

- "Other: unexpected internal state"
- "Other: channel closed unexpectedly"

---

### Result Type Alias

```rust
pub type Result<T> = std::result::Result<T, AdapterError>;
```

**Usage:**

```rust
use crate::adapters::{Result, AdapterError};

async fn send_message(&self, msg: Message) -> Result<()> {
    // Returns Result<(), AdapterError>
}
```

---

### Test Coverage

**File:** `src-tauri/src/adapters/error.rs` lines 28-40

**Test:** `test_adapter_error_display`

**Coverage:**

1. Creates Database variant with message
2. Asserts Display formatting is correct
3. Creates Network variant with message
4. Asserts Display formatting is correct

**What's Tested:**

- ✅ Display trait implementation (via thiserror)
- ✅ Error message formatting

**What's Not Tested:**

- ❌ Error conversion from other error types
- ❌ Other error variants (Encryption, Serialization, etc.)
- ❌ Debug output format
- ❌ Error propagation with ? operator

**Example Expansion:**

```rust
#[test]
fn test_all_error_variants() {
    let errors = vec![
        AdapterError::Database("db error".into()),
        AdapterError::Network("network error".into()),
        AdapterError::Encryption("enc error".into()),
        AdapterError::Serialization("ser error".into()),
        AdapterError::NotFound("not found".into()),
        AdapterError::InvalidData("invalid".into()),
        AdapterError::Other("other".into()),
    ];

    for err in errors {
        // Test Display
        let display = err.to_string();
        assert!(!display.is_empty());

        // Test Debug
        let debug = format!("{:?}", err);
        assert!(!debug.is_empty());
    }
}

#[test]
fn test_error_conversion() {
    let io_err = std::io::Error::new(std::io::ErrorKind::NotFound, "file not found");
    let adapter_err = AdapterError::Database(io_err.to_string());
    assert!(adapter_err.to_string().contains("file not found"));
}
```

---

## Port Re-exports

### EncryptionAdapter

**File:** `src-tauri/src/adapters/encryption.rs`

```rust
pub use crate::domain::EncryptionAdapter;
```

**Purpose:** API consistency

- Consumers can import via `adapters::EncryptionAdapter`
- Avoids direct dependency on domain layer
- Maintains Clean Architecture contract (adapters depend on domain)

**Usage:**

```rust
use crate::adapters::EncryptionAdapter;  // Via adapters
// Or
use crate::domain::EncryptionAdapter;    // Directly from domain
```

---

### NetworkAdapter

**File:** `src-tauri/src/adapters/network.rs`

```rust
pub use crate::domain::NetworkAdapter;
```

**Purpose:** Same as EncryptionAdapter

- Consistent import path for adapter consumers
- Decouples consumers from domain structure

**Comment in File:**

> Re‑export the domain‑level port so external crates can import it via
> `crate::adapters::network::NetworkAdapter` without breaking the clean‑
> architecture contract.

---

## Design Rationale

### Why Separate Message Enum?

**Alternative 1:** Use protocol types directly in NetworkAdapter

```rust
trait NetworkAdapter {
    async fn send_presence(&self, peer_id: &PeerId, msg: PresenceMessage);
    async fn send_config(&self, peer_id: &PeerId, msg: ConfigMessage);
    async fn send_chat(&self, peer_id: &PeerId, msg: ChatMessage);
    async fn send_notification(&self, peer_id: &PeerId, msg: Notification);
}
```

**Problem:** Many methods, harder to add new message types

**Alternative 2:** Use serde_json::Value

```rust
async fn send(&self, peer_id: &PeerId, msg: serde_json::Value);
```

**Problem:** Loses type safety, no compile-time checking

**Chosen Approach:** Single Message enum

- **Benefit:** Single method `send(&self, peer_id, Message)`
- **Benefit:** Type-safe (compiler checks message types)
- **Benefit:** Easy to add new message types (add variant)
- **Benefit:** Uniform serialization (all messages go through same path)

---

### Why String-Based Errors?

**Current:**

```rust
AdapterError::Network(String)
```

**Alternative:** Structured errors

```rust
AdapterError::Network {
    peer_id: PeerId,
    error_code: NetworkErrorCode,
    context: String,
}
```

**Trade-offs:**

**Current (String) Pros:**

- Simple and flexible
- Easy to construct: `.map_err(|e| AdapterError::Network(e.to_string()))`
- No rigid structure requirements

**Current Cons:**

- Loses error structure (can't programmatically handle specific cases)
- String parsing if caller needs details
- No type safety on error reasons

**Future Improvement:**

- Add structured variants for common cases
- Keep String fallback for rare errors

---

## Integration Points

### Upstream (Consumers of Adapters)

**NetworkAdapter Implementations:**

- `network::mdns::MdnsAdapter` (implements NetworkAdapter)
- Uses `Message` enum for send/receive
- Returns `adapters::Result<T>`

**EncryptionAdapter Implementations:**

- `encryption::chacha20::ChaCha20Encryption` (implements EncryptionAdapter)
- Returns `adapters::Result<T>`

**Service Layer:**

- Depends on adapter ports
- Converts `AdapterError` to `AppError`
- Constructs `Message` variants from protocol messages

---

### Downstream (Adapters Dependencies)

**Protocol Layer:**

- Provides message types (PresenceMessage, ConfigMessage, etc.)
- Wrapped in Message enum

**Domain Layer:**

- Defines ports (NetworkAdapter, EncryptionAdapter)
- Re-exported by adapters

**Serde:**

- Serialization of Message enum
- Automatic JSON conversion

---

## Usage Examples

### Creating and Serializing Messages

```rust
use crate::adapters::Message;
use crate::protocol::messages::{PresenceMessage, LightState};

// Create message
let msg = Message::Presence(PresenceMessage::Online {
    peer_id: "peer-123".to_string(),
    peer_name: "Alice".to_string(),
    light_state: LightState::new("green".to_string()),
    note: Some("Available".to_string()),
    timestamp: current_timestamp(),
    notification_status: Box::new(None),
});

// Serialize to JSON
let json_bytes = serde_json::to_vec(&msg)?;

// Send over network
network_adapter.send_to_peer(&peer_id, msg).await?;
```

---

### Receiving and Deserializing Messages

```rust
use crate::adapters::Message;

// Receive from network
let (peer_id, message) = network_adapter.receive().await?;

// Pattern match on message type
match message {
    Message::Presence(presence_msg) => {
        presence_service.handle(presence_msg).await?;
    }
    Message::Config(config_msg) => {
        config_service.handle(config_msg).await?;
    }
    Message::Chat(chat_msg) => {
        chat_service.handle(chat_msg).await?;
    }
    Message::Notification(notif) => {
        notification_service.handle(notif).await?;
    }
}
```

---

### Error Handling

```rust
use crate::adapters::{Result, AdapterError};

async fn send_with_retry(&self, msg: Message) -> Result<()> {
    for attempt in 1..=3 {
        match self.network.send(msg.clone()).await {
            Ok(()) => return Ok(()),
            Err(AdapterError::Network(e)) if attempt < 3 => {
                log::warn!("Send failed (attempt {}): {}", attempt, e);
                tokio::time::sleep(Duration::from_secs(1)).await;
            }
            Err(e) => return Err(e),
        }
    }
    Err(AdapterError::Network("max retries exceeded".into()))
}

// Convert to AppError
fn handle_adapter_error(err: AdapterError) -> AppError {
    match err {
        AdapterError::NotFound(msg) => AppError::NotFound,
        other => AppError::Other(anyhow::anyhow!("{}", other)),
    }
}
```

---

## Future Improvements

### High Priority

**1. Expand Test Coverage**

- Test all Message variants (Config, Chat, Notification)
- Test all AdapterError variants
- Test error conversion patterns
- Test JSON format validation

**2. Add Structured Error Data**

```rust
#[derive(Debug, thiserror::Error)]
pub enum AdapterError {
    #[error("Network error: {message}")]
    Network {
        peer_id: Option<PeerId>,
        message: String,
        source: Option<Box<dyn std::error::Error + Send + Sync>>,
    },
    // ...
}
```

**3. Add Error Context Helpers**

```rust
trait ErrorContext<T> {
    fn with_peer_context(self, peer_id: &PeerId) -> Result<T>;
}

impl<T> ErrorContext<T> for Result<T> {
    fn with_peer_context(self, peer_id: &PeerId) -> Result<T> {
        self.map_err(|e| {
            AdapterError::Network {
                peer_id: Some(peer_id.clone()),
                message: e.to_string(),
                source: Some(Box::new(e)),
            }
        })
    }
}
```

---

### Medium Priority

**4. Add Message Validation**

```rust
impl Message {
    pub fn validate(&self) -> Result<()> {
        match self {
            Message::Chat(chat) if chat.content.len() > 10_000 => {
                Err(AdapterError::InvalidData("content too long".into()))
            }
            _ => Ok(()),
        }
    }
}
```

**5. Add Message Metadata**

```rust
impl Message {
    pub fn message_type(&self) -> &'static str {
        match self {
            Message::Presence(_) => "Presence",
            Message::Config(_) => "Config",
            Message::Chat(_) => "Chat",
            Message::Notification(_) => "Notification",
        }
    }

    pub fn size_estimate(&self) -> usize {
        // Estimate serialized size
    }
}
```

**6. Consider Binary Serialization**

- Add optional bincode or protobuf support
- Reduce message size (30-50% smaller)
- Faster serialization (2-10x)
- Trade-off: Less debuggable

---

### Low Priority

**7. Add Message Versioning**

```rust
#[derive(Serialize, Deserialize)]
pub struct VersionedMessage {
    pub version: u32,
    pub payload: Message,
}
```

**8. Add Error Metrics**

- Track error counts by variant
- Monitor error rates over time
- Alert on error spikes

**9. Generate OpenAPI Schema**

- Document message formats
- Enable client generation
- Validate JSON against schema

---

## Related Documentation

### Specifications

- **Domain Layer:** `spec/backend/domain/domain.md` - Defines ports re-exported here
- **Protocol Messages:** `spec/backend/protocol/messages.md` - Message types wrapped in Message enum
- **Network Layer:** `spec/backend/network/` - Implements NetworkAdapter using Message
- **Encryption Layer:** `spec/backend/encryption/encryption.md` - Implements EncryptionAdapter

### Implementation Files

- **Module:** `src-tauri/src/adapters/mod.rs` (11 lines)
- **Message:** `src-tauri/src/adapters/message.rs` (50 lines, 1 test)
- **Error:** `src-tauri/src/adapters/error.rs` (41 lines, 1 test)
- **Encryption Re-export:** `src-tauri/src/adapters/encryption.rs` (3 lines)
- **Network Re-export:** `src-tauri/src/adapters/network.rs` (7 lines)

### External Resources

- **Serde Tagged Enums:** https://serde.rs/enum-representations.html
- **thiserror:** https://docs.rs/thiserror/latest/thiserror/
- **Clean Architecture:** https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **Rust Error Handling:** https://doc.rust-lang.org/book/ch09-00-error-handling.html
