# Domain Layer Specification

## Overview

The domain layer defines core business entities, error types, and architectural ports (interfaces) following Clean Architecture principles. It contains no external dependencies except serialization (serde) and establishes contracts that outer layers must implement.

**Location:** `src-tauri/src/domain/`

- `chat_message.rs` (23 lines): Chat message entity
- `errors.rs` (24 lines): Application error types
- `peer_id.rs` (33 lines, 1 test): Peer identifier type
- `ports.rs` (47 lines): Adapter interfaces
- `mod.rs` (11 lines): Module exports

**Total:** 138 lines of domain code

**Responsibilities:**

- Define domain entities (ChatMessage, PeerId)
- Establish error handling patterns (AppError, DomainResult)
- Declare adapter ports (NetworkAdapter, EncryptionAdapter)
- Enforce separation of concerns (domain independent of infrastructure)
- Enable testability through interface abstractions

## Architecture

### Clean Architecture Principles

**Dependency Rule:** Domain depends on nothing (except std and serde)

- No database dependencies
- No network dependencies
- No framework dependencies
- Services and adapters depend on domain (not vice versa)

**Ports and Adapters:**

- **Ports:** Interfaces defined in domain (NetworkAdapter, EncryptionAdapter)
- **Adapters:** Concrete implementations in adapters layer
- Application uses ports; adapters implement ports

**Benefits:**

- Testability: Mock ports for unit tests
- Flexibility: Swap implementations without changing business logic
- Maintainability: Domain logic isolated from technical concerns

### Module Structure

```
domain/
  ├── mod.rs              - Public exports
  ├── chat_message.rs     - Chat domain entity
  ├── errors.rs           - Error types and Result alias
  ├── peer_id.rs          - Peer identifier wrapper
  └── ports.rs            - Adapter interfaces
```

**Exports:**

```rust
pub use chat_message::ChatMessage;
pub use errors::{AppError, DomainResult};
pub use peer_id::PeerId;
pub use ports::{NetworkAdapter, EncryptionAdapter};
```

## Domain Entities

### ChatMessage

Represents a chat message in the domain model.

**File:** `src-tauri/src/domain/chat_message.rs`

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatMessage {
    pub id: String,
    pub peer_id: String,
    pub peer_name: String,
    pub content: String,
    pub timestamp: u64,
}
```

**Fields:**

- `id`: Unique message identifier (typically UUID)
- `peer_id`: Sender's peer identifier
- `peer_name`: Sender's display name (denormalized for UI performance)
- `content`: Message text content
- `timestamp`: Unix timestamp in milliseconds

**Design Rationale:**

- **Domain entity:** Lives in domain layer, not protocol layer
- **Serializable:** Can be sent over network (derives Serialize, Deserialize)
- **Denormalized:** Includes peer_name to avoid lookups in UI rendering
- **Simple:** No behavior methods (pure data structure)

**Usage:**

- Protocol layer: Type-aliased as `protocol::ChatMessage`
- Service layer: ChatService operates on ChatMessage
- Database layer: Persisted to SQLite via chat_db
- Network layer: Serialized to JSON for transmission

**Example:**

```rust
let msg = ChatMessage {
    id: "msg-123".to_string(),
    peer_id: "peer-456".to_string(),
    peer_name: "Alice".to_string(),
    content: "Hello everyone!".to_string(),
    timestamp: 1234567890,
};
```

**Validation:** Not enforced at domain level

- Service layer should validate content length
- Service layer should sanitize content
- Domain accepts any String values

---

### PeerId

Type-safe wrapper for peer identifiers.

**File:** `src-tauri/src/domain/peer_id.rs`

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct PeerId(String);

impl PeerId {
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into())
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl std::fmt::Display for PeerId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}
```

**Design Pattern:** Newtype wrapper

- Wraps String to provide type safety
- Prevents mixing peer IDs with other strings
- Implements common traits (Debug, Clone, PartialEq, Eq, Hash, Display)

**Traits:**

- `Debug`: For logging and debugging
- `Clone`: Cheap cloning (String is cloned)
- `PartialEq, Eq`: Equality comparison
- `Hash`: Use as HashMap key
- `Serialize, Deserialize`: Network transmission and storage
- `Display`: Formatting for logs and UI

**API:**

- `new(id)`: Constructor accepting anything convertible to String
- `as_str()`: Borrow inner string without cloning

**Benefits:**

- **Type Safety:** Can't accidentally pass wrong string type
- **Intent:** Makes peer ID usage explicit in function signatures
- **Future-Proofing:** Can add validation logic later without API changes

**Example:**

```rust
// Create peer ID
let peer_id = PeerId::new("peer-123");

// Use as HashMap key
let mut presence_map: HashMap<PeerId, PeerPresence> = HashMap::new();
presence_map.insert(peer_id.clone(), presence);

// Display
println!("Connected to {}", peer_id);  // Uses Display impl

// Access inner string
assert_eq!(peer_id.as_str(), "peer-123");
```

**Current Limitation:** No validation

- Accepts any string (empty strings, invalid formats, etc.)
- Could add validation in `new()` later:
  ```rust
  pub fn new(id: impl Into<String>) -> Result<Self, PeerIdError> {
      let s = id.into();
      if s.is_empty() {
          return Err(PeerIdError::Empty);
      }
      Ok(Self(s))
  }
  ```

**Test Coverage:**

- 1 test: `test_peer_id_creation` (basic construction and access)

---

## Error Handling

### AppError

Top-level error enum for application and service layers.

**File:** `src-tauri/src/domain/errors.rs`

```rust
#[derive(Debug, Error)]
pub enum AppError {
    #[error("Message not found")]
    NotFound,

    #[error("Permission denied")]
    PermissionDenied,

    #[error("{0}")]
    Other(#[from] anyhow::Error),
}
```

**Variants:**

- `NotFound`: Resource not found (e.g., message ID doesn't exist)
- `PermissionDenied`: Operation not allowed (future use, not currently used)
- `Other(anyhow::Error)`: Catch-all for lower-level errors

**Design Pattern:** Typed error enum with anyhow fallback

- **Typed variants:** Explicit error cases for domain logic
- **anyhow fallback:** Gracefully handle unexpected errors from dependencies
- **thiserror:** Automatic Error trait implementation

**Error Conversion:**

```rust
// Automatic conversion from anyhow::Error
let db_result: Result<T, anyhow::Error> = database_operation();
let app_result: Result<T, AppError> = db_result.map_err(Into::into);

// Or with ? operator
fn service_method() -> Result<()> {
    let value = database_operation()?;  // anyhow::Error -> AppError::Other
    Ok(())
}
```

**Usage:**

- Service layer returns `Result<T>` (aliased to `Result<T, AppError>`)
- Command handlers convert AppError to Tauri error responses
- Network layer may convert to adapter errors

**Example:**

```rust
use crate::domain::{AppError, DomainResult};

pub async fn get_message(&self, id: &str) -> DomainResult<ChatMessage> {
    let msg = self.db.find_message(id)?;  // anyhow -> AppError::Other
    msg.ok_or(AppError::NotFound)
}

pub async fn delete_message(&self, id: &str, requester: &str) -> DomainResult<()> {
    if !self.can_delete(requester) {
        return Err(AppError::PermissionDenied);
    }
    self.db.delete(id)?;
    Ok(())
}
```

---

### DomainResult

Convenience type alias for Result with AppError.

```rust
pub type Result<T> = std::result::Result<T, AppError>;
```

**Usage:**

```rust
use crate::domain::DomainResult;

pub async fn service_method(&self) -> DomainResult<Vec<String>> {
    // Return Result<Vec<String>, AppError>
}
```

**Benefits:**

- Concise function signatures
- Consistent error type across services
- Easy to change error type project-wide

---

## Adapter Ports

### NetworkAdapter

Interface for network communication.

**File:** `src-tauri/src/domain/ports.rs`

```rust
#[async_trait]
pub trait NetworkAdapter: Send + Sync {
    async fn start(&self) -> crate::adapters::error::Result<()>;
    async fn stop(&self) -> crate::adapters::error::Result<()>;
    async fn send_to_peer(&self, peer_id: &PeerId, message: Message)
        -> crate::adapters::error::Result<()>;
    async fn broadcast(&self, message: Message)
        -> crate::adapters::error::Result<()>;
    async fn receive(&self)
        -> crate::adapters::error::Result<(PeerId, Message)>;
    async fn get_connected_peers(&self)
        -> crate::adapters::error::Result<Vec<PeerId>>;
}
```

**Trait Bounds:**

- `Send`: Can be sent across threads
- `Sync`: Can be shared between threads (typically wrapped in Arc)
- `async_trait`: Enables async methods in traits (via proc macro)

**Methods:**

#### `async fn start(&self) -> Result<()>`

Initializes and starts network services (discovery, listening).

**Behavior:**

- Start mDNS discovery
- Start TCP listener
- Launch background tasks
- Return when initialization complete (not when stopped)

**Errors:** Network binding failures, resource exhaustion

---

#### `async fn stop(&self) -> Result<()>`

Gracefully stops network services.

**Behavior:**

- Stop accepting new connections
- Send Goodbye messages to peers
- Close existing connections
- Shut down background tasks

**Errors:** Cleanup failures (typically logged, not fatal)

---

#### `async fn send_to_peer(&self, peer_id: &PeerId, message: Message) -> Result<()>`

Sends a message to a specific peer.

**Parameters:**

- `peer_id`: Target peer identifier
- `message`: Message to send (see adapters::message::Message)

**Behavior:**

- Look up peer connection by PeerId
- Serialize message
- Encrypt if enabled
- Send over TCP
- Return when send completes (or fails)

**Errors:**

- Peer not connected
- Network I/O error
- Serialization error

---

#### `async fn broadcast(&self, message: Message) -> Result<()>`

Sends a message to all connected peers.

**Behavior:**

- Iterate over all connected peers
- Send message to each peer (like send_to_peer)
- Continue on individual peer failures (best-effort)

**Errors:**

- All sends failed (returns error)
- Partial success: Logs failures, returns Ok (design choice)

---

#### `async fn receive(&self) -> Result<(PeerId, Message)>`

Receives the next incoming message (blocking).

**Returns:**

- `Ok((peer_id, message))`: Received message with sender identification
- `Err(...)`: Network error, adapter stopped

**Behavior:**

- Block until message arrives
- Decrypt if enabled
- Deserialize message
- Return sender PeerId and message

**Cancellation:** Caller should handle async task cancellation

---

#### `async fn get_connected_peers(&self) -> Result<Vec<PeerId>>`

Retrieves list of currently connected peer IDs.

**Returns:** Vector of PeerId for all active connections

**Usage:**

- UI status display
- Determining broadcast targets
- Health monitoring

---

### EncryptionAdapter

Interface for encryption operations.

**File:** `src-tauri/src/domain/ports.rs`

```rust
pub trait EncryptionAdapter: Send + Sync {
    fn encrypt(&self, plaintext: &[u8]) -> crate::adapters::error::Result<Vec<u8>>;
    fn decrypt(&self, ciphertext: &[u8]) -> crate::adapters::error::Result<Vec<u8>>;
    fn derive_key(&self, passphrase: &str) -> crate::adapters::error::Result<Vec<u8>>;
}
```

**Trait Bounds:**

- `Send`: Can be sent across threads
- `Sync`: Can be shared between threads

**Methods:**

#### `fn encrypt(&self, plaintext: &[u8]) -> Result<Vec<u8>>`

Encrypts plaintext bytes using configured algorithm.

**Parameters:** `plaintext` - Raw bytes to encrypt

**Returns:** Encrypted bytes (includes nonce/IV if needed)

**Behavior:**

- Generate nonce/IV (if applicable)
- Encrypt using ChaCha20-Poly1305 (or configured cipher)
- Prepend nonce to ciphertext (or return separately)

**Errors:** Encryption failures (rare, typically programming errors)

---

#### `fn decrypt(&self, ciphertext: &[u8]) -> Result<Vec<u8>>`

Decrypts ciphertext bytes.

**Parameters:** `ciphertext` - Encrypted bytes (with nonce)

**Returns:** Decrypted plaintext bytes

**Behavior:**

- Extract nonce from ciphertext
- Decrypt using ChaCha20-Poly1305
- Verify authentication tag (AEAD)

**Errors:**

- Invalid ciphertext (corrupted data)
- Authentication failure (tampered data)
- Wrong key

---

#### `fn derive_key(&self, passphrase: &str) -> Result<Vec<u8>>`

Derives cryptographic key from passphrase.

**Parameters:** `passphrase` - User-provided password/passphrase

**Returns:** Derived key bytes (32 bytes for ChaCha20)

**Behavior:**

- Apply Argon2 key derivation
- Use configured salt and parameters
- Return fixed-length key

**Errors:** Invalid parameters (rare, configuration error)

**Usage:** Initial setup when user enters passphrase

---

## Design Patterns

### Dependency Inversion

**Principle:** High-level modules depend on abstractions, not concretions

**Implementation:**

```
┌─────────────────┐
│   AppState      │ (owns concrete adapter)
└────────┬────────┘
         │ Arc<dyn NetworkAdapter>
         ↓
┌─────────────────┐
│ Service Layer   │ (depends on trait)
└─────────────────┘
         ↑
         │ implements
┌─────────────────┐
│ mDNS Adapter    │ (concrete implementation)
└─────────────────┘
```

**Benefits:**

- Services testable with mock adapters
- Swap implementations without changing services
- Domain logic independent of infrastructure

---

### Port-Adapter (Hexagonal Architecture)

**Ports:** Defined in domain (NetworkAdapter, EncryptionAdapter)

**Adapters:** Concrete implementations

- `network::mdns::MdnsAdapter` implements NetworkAdapter
- `encryption::chacha20::ChaCha20Encryption` implements EncryptionAdapter

**Application Layer:** Uses ports, never adapters directly

**Testing:**

```rust
#[cfg(test)]
mod tests {
    use super::*;

    struct MockNetworkAdapter {
        // Test doubles
    }

    #[async_trait]
    impl NetworkAdapter for MockNetworkAdapter {
        // Mock implementations
    }

    #[test]
    fn test_service_logic() {
        let mock_adapter = Arc::new(MockNetworkAdapter::new());
        let service = MyService::new(mock_adapter);
        // Test without real network
    }
}
```

---

## Integration Points

### Upstream (Domain as Dependency)

**Service Layer:**

- Uses PeerId for type-safe peer identification
- Returns DomainResult from all methods
- Uses ChatMessage as data structure
- Depends on NetworkAdapter and EncryptionAdapter ports

**Protocol Layer:**

- Type-aliases ChatMessage as protocol::ChatMessage
- Could define separate protocol types if needed for versioning

**Command Layer:**

- Converts AppError to Tauri error responses
- Maps domain results to frontend-friendly formats

---

### Downstream (Domain Dependencies)

**Standard Library:** std (collections, sync primitives)

**Serialization:** serde (for ChatMessage, PeerId)

**Error Handling:**

- thiserror: Derive Error trait for AppError
- anyhow: Wrapped in AppError::Other for lower-level errors

**Async:** async_trait for trait methods (NetworkAdapter)

**No Other Dependencies:** Domain is intentionally minimal

---

## Test Coverage

### Current Tests

**PeerId:** 1 test (`test_peer_id_creation`)

- Tests construction via `new()`
- Verifies `as_str()` returns correct value

**Other Modules:** 0 tests

### Rationale for Limited Testing

**Simple Data Structures:**

- ChatMessage: Plain data, no logic to test
- AppError: Derive macros handle Error trait
- Ports: Traits have no implementations

**Testing Strategy:**

- Test domain entities indirectly via service tests
- Test port implementations in adapter tests
- Focus test effort on business logic (services)

### Potential Additional Tests

**PeerId:**

1. Test Display implementation formatting
2. Test equality and hashing (for HashMap usage)
3. Test serialization/deserialization round-trip
4. Test empty string handling (if validation added)

**AppError:**

1. Test conversion from anyhow::Error
2. Test error message formatting
3. Test thiserror derive macro output

**ChatMessage:**

1. Test serialization/deserialization round-trip
2. Test large content handling
3. Test special characters in fields

**Example PeerId Tests:**

```rust
#[test]
fn test_peer_id_equality() {
    let id1 = PeerId::new("peer-123");
    let id2 = PeerId::new("peer-123");
    assert_eq!(id1, id2);
}

#[test]
fn test_peer_id_as_hashmap_key() {
    let mut map = HashMap::new();
    let id = PeerId::new("peer-1");
    map.insert(id.clone(), "value");
    assert_eq!(map.get(&id), Some(&"value"));
}

#[test]
fn test_peer_id_serde_roundtrip() {
    let id = PeerId::new("peer-456");
    let json = serde_json::to_string(&id).unwrap();
    let deserialized: PeerId = serde_json::from_str(&json).unwrap();
    assert_eq!(id, deserialized);
}
```

---

## Security Considerations

### PeerId Validation

**Current State:** No validation

- Empty strings allowed
- No format checking
- No length limits

**Threats:**

- Extremely long peer IDs (memory exhaustion)
- Special characters causing display issues
- Empty peer IDs causing lookup failures

**Recommendations:**

1. Add validation in `PeerId::new()`
2. Enforce format: `^[a-zA-Z0-9\-]{1,64}$`
3. Reject empty strings
4. Document expected format in docs

---

### Error Information Disclosure

**Current State:** Errors include implementation details

- `AppError::Other` wraps anyhow with full error chain
- May expose internal paths, database details, etc.

**Threats:**

- Information leakage in error messages
- Stack traces exposed to frontend
- Debugging info visible to users

**Recommendations:**

1. Sanitize error messages in command layer
2. Log full errors server-side
3. Return generic messages to frontend
4. Add separate "user-facing message" field

---

### ChatMessage Content

**Current State:** No validation or sanitization

- Any string content accepted
- No length limits
- No encoding validation

**Threats:**

- XSS if content not escaped in UI
- Storage exhaustion with large messages
- Invalid UTF-8 or control characters

**Recommendations:**

1. Add max content length (e.g., 10,000 chars)
2. Validate UTF-8 encoding
3. Sanitize in service layer (not domain)
4. Escape content in UI rendering

---

## Usage Examples

### Creating Domain Entities

```rust
use crate::domain::{ChatMessage, PeerId};

// Create peer ID
let peer_id = PeerId::new("peer-123");

// Create chat message
let msg = ChatMessage {
    id: uuid::Uuid::new_v4().to_string(),
    peer_id: peer_id.to_string(),
    peer_name: "Alice".to_string(),
    content: "Hello world!".to_string(),
    timestamp: crate::utils::current_timestamp(),
};
```

---

### Error Handling

```rust
use crate::domain::{AppError, DomainResult};

pub async fn get_message(&self, id: &str) -> DomainResult<ChatMessage> {
    // Database returns Option<ChatMessage>
    let msg = self.db.find_message(id)
        .map_err(|e| AppError::Other(e.into()))?;

    msg.ok_or(AppError::NotFound)
}

// In command layer
#[tauri::command]
async fn fetch_message(id: String) -> Result<ChatMessage, String> {
    match service.get_message(&id).await {
        Ok(msg) => Ok(msg),
        Err(AppError::NotFound) => Err("Message not found".into()),
        Err(AppError::PermissionDenied) => Err("Access denied".into()),
        Err(AppError::Other(e)) => Err(format!("Error: {}", e)),
    }
}
```

---

### Using Adapter Ports

```rust
use crate::domain::{NetworkAdapter, PeerId};
use crate::adapters::message::Message;

pub struct MyService {
    network: Arc<dyn NetworkAdapter>,
}

impl MyService {
    pub async fn send_greeting(&self, peer_id: &PeerId) -> DomainResult<()> {
        let msg = Message::Presence(/* ... */);
        self.network.send_to_peer(peer_id, msg)
            .await
            .map_err(|e| AppError::Other(e.into()))?;
        Ok(())
    }

    pub async fn announce(&self) -> DomainResult<()> {
        let msg = Message::Presence(/* ... */);
        self.network.broadcast(msg)
            .await
            .map_err(|e| AppError::Other(e.into()))?;
        Ok(())
    }
}
```

---

## Future Improvements

### High Priority

**1. Add PeerId Validation**

- Enforce format constraints in `new()`
- Return Result instead of Self
- Document expected format

**2. Expand AppError Variants**

- Add NetworkError, DatabaseError, ValidationError
- Provide more specific error types
- Enable better error handling in services

**3. Add Domain Tests**

- Serialization round-trip tests
- Error conversion tests
- PeerId validation tests (when added)

---

### Medium Priority

**4. Add Validation Traits**

```rust
pub trait Validate {
    type Error;
    fn validate(&self) -> Result<(), Self::Error>;
}

impl Validate for ChatMessage {
    type Error = ValidationError;
    fn validate(&self) -> Result<(), ValidationError> {
        if self.content.len() > 10_000 {
            return Err(ValidationError::ContentTooLong);
        }
        Ok(())
    }
}
```

**5. Add Domain Events**

```rust
pub enum DomainEvent {
    MessageSent(ChatMessage),
    PeerJoined(PeerId),
    PeerLeft(PeerId),
}
```

- Enable event-driven architecture
- Decouple services
- Support audit logging

**6. Separate Protocol and Domain Types**

- Currently ChatMessage is shared
- Future: Separate types with conversion layer
- Enables independent evolution

---

### Low Priority

**7. Add Value Objects**

- Email, Url, Timestamp wrappers
- Self-validating types
- Prevent invalid state

**8. Add Builder Pattern**

```rust
ChatMessage::builder()
    .id(uuid)
    .peer_id(peer_id)
    .content(content)
    .build()
```

**9. Add Domain Services**

- Logic that doesn't belong to single entity
- Example: MessageValidator, PeerIdGenerator

---

## Related Documentation

### Specifications

- **ChatService:** `spec/backend/services/chat-service.md` - Uses ChatMessage and DomainResult
- **PresenceService:** `spec/backend/services/presence-service.md` - Uses DomainResult
- **ConfigService:** `spec/backend/services/config-service.md` - Uses DomainResult
- **Protocol Messages:** `spec/backend/protocol/messages.md` - Type-aliases ChatMessage
- **Adapters:** (to be documented) - Implement NetworkAdapter and EncryptionAdapter

### Implementation Files

- **ChatMessage:** `src-tauri/src/domain/chat_message.rs` (23 lines)
- **Errors:** `src-tauri/src/domain/errors.rs` (24 lines)
- **PeerId:** `src-tauri/src/domain/peer_id.rs` (33 lines, 1 test)
- **Ports:** `src-tauri/src/domain/ports.rs` (47 lines)
- **Module:** `src-tauri/src/domain/mod.rs` (11 lines)

### External Resources

- **Clean Architecture:** https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **Hexagonal Architecture:** https://alistair.cockburn.us/hexagonal-architecture/
- **Domain-Driven Design:** https://www.domainlanguage.com/ddd/
- **Rust Error Handling:** https://doc.rust-lang.org/book/ch09-00-error-handling.html
- **async-trait:** https://docs.rs/async-trait/latest/async_trait/
