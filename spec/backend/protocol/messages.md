# Protocol Messages Specification

## Overview

The protocol module defines the message types exchanged between peers in the Lighten-Up P2P network. It provides serializable data structures for presence updates, chat messages, light configuration synchronization, and notifications using serde for JSON serialization.

**Location:** `src-tauri/src/protocol/`

- `messages.rs` (100 lines): Message type definitions
- `mod.rs` (4 lines): Module exports

**Responsibilities:**

- Define network message formats
- Provide serialization/deserialization via serde
- Establish protocol semantics and field requirements
- Support multiple message categories (presence, config, chat, notifications)
- Enable versioning and extensibility

## Architecture

### Design Pattern

**Data Transfer Objects (DTOs)**

- Pure data structures (no business logic)
- Serializable via serde (JSON format)
- Enum-based message discrimination
- Nested structures for complex messages

**Protocol Separation**

- Protocol types separate from domain types
- Enables protocol evolution without changing domain
- Example: `ChatMessage` is type alias to domain::ChatMessage (currently)

### Dependencies

```rust
protocol
    ├── serde::{Serialize, Deserialize} - JSON serialization
    ├── domain::ChatMessage - Domain chat message (type alias)
    └── utils::current_timestamp - Clock for timestamp generation
```

**No Runtime Dependencies:** All types are compile-time constructs

### Module Structure

```
protocol/
  ├── mod.rs         - Public exports
  └── messages.rs    - All message definitions
```

**Exports:**

```rust
pub use messages::{
    ChatMessage,      // Type alias to domain::ChatMessage
    ConfigMessage,    // Light config sync messages
    ConfigOp,         // Config operation variants
    LightState,       // Peer light status
    PresenceMessage,  // Presence lifecycle messages
};
```

## Message Types

### 1. PresenceMessage

Communicates peer availability and status updates.

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PresenceMessage {
    Online {
        peer_id: String,
        peer_name: String,
        light_state: LightState,
        note: Option<String>,
        timestamp: u64,
        notification_status: Box<Option<Notification>>,
    },
    Goodbye {
        peer_id: String,
    },
    RequestStatus {
        peer_id: String,
    },
}
```

#### Online Variant

Announces peer is online with current status.

**Fields:**

- `peer_id`: Unique peer identifier (sender)
- `peer_name`: Display name for UI
- `light_state`: Current availability status (color + timestamp)
- `note`: Optional status message (e.g., "In a meeting")
- `timestamp`: Message creation time (milliseconds)
- `notification_status`: Boxed to reduce enum size (notification preferences)

**Semantics:**

- Sent on initial connection (announce presence)
- Sent periodically as heartbeat (every N seconds)
- Sent when status changes (light color, name, note)

**Example JSON:**

```json
{
  "Online": {
    "peer_id": "peer-123",
    "peer_name": "Alice",
    "light_state": {
      "color": "green",
      "timestamp": 1234567890
    },
    "note": "Available",
    "timestamp": 1234567890,
    "notification_status": {
      "type": "general-message",
      "message": "Hello",
      "target_peer_id": "peer-456",
      "sender_peer_id": "peer-123",
      "timestamp": 1234567890,
      "priority": null,
      "color": null
    }
  }
}
```

**Design Decision: Boxed notification_status**

- Reduces Online variant size (Box is pointer-sized)
- Most peers have no active notification (None is common)
- Trade-off: Extra indirection when accessing, but better memory layout

---

#### Goodbye Variant

Announces peer is going offline gracefully.

**Fields:**

- `peer_id`: Unique peer identifier (sender)

**Semantics:**

- Sent on application shutdown (clean disconnect)
- Sent when deliberately going offline
- Allows peers to immediately remove from presence list
- No response expected

**Example JSON:**

```json
{
  "Goodbye": {
    "peer_id": "peer-123"
  }
}
```

**Use Case:** Distinguish graceful shutdown from network failure

- Goodbye: Immediate removal from UI
- Timeout: Wait for heartbeat timeout before removal

---

#### RequestStatus Variant

Requests current online status from all peers.

**Fields:**

- `peer_id`: Requester's peer identifier

**Semantics:**

- Sent on initial connection (discover existing peers)
- Broadcast to all peers
- Each peer responds with Online message
- Enables fast synchronization without waiting for heartbeats

**Example JSON:**

```json
{
  "RequestStatus": {
    "peer_id": "peer-789"
  }
}
```

**Response:** Each peer sends Online message to requester

---

### 2. ConfigMessage

Synchronizes light configuration across peers using CRDT.

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConfigMessage {
    pub op: ConfigOp,
    pub peer_id: String,
    pub timestamp: u64,
}
```

**Fields:**

- `op`: Configuration operation (Upsert, Delete, or RequestSync)
- `peer_id`: Message sender identifier
- `timestamp`: Message creation time (for debugging, not used in LWW)

**Semantics:**

- Broadcast to all peers on config changes
- Processed using Last-Write-Wins (LWW) conflict resolution
- Ensures eventual consistency of light configurations

---

### 3. ConfigOp

Operation types for configuration synchronization.

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ConfigOp {
    Upsert {
        id: String,
        color: String,
        name: String,
        enabled: bool,
        priority: i32,
        updated_at: u64,
        updated_by: String,
    },
    Delete {
        id: String,
        deleted_at: u64,
    },
    RequestSync {
        peer_id: String,
    },
}
```

#### Upsert Variant

Creates or updates a light configuration.

**Fields:**

- `id`: Unique light identifier (key for LWW)
- `color`: Color value (e.g., "red", "#FF0000")
- `name`: Human-readable light name
- `enabled`: Whether light is active
- `priority`: Display order priority
- `updated_at`: **Critical for LWW** - timestamp of this update
- `updated_by`: Peer ID that made this update

**LWW Semantics:**

- Higher `updated_at` wins conflicts
- Equal `updated_at` applies update (bias toward acceptance)
- Lower `updated_at` is ignored

**Example JSON:**

```json
{
  "op": {
    "Upsert": {
      "id": "light-1",
      "color": "#00FF00",
      "name": "Conference Room A",
      "enabled": true,
      "priority": 10,
      "updated_at": 1234567890,
      "updated_by": "peer-123"
    }
  },
  "peer_id": "peer-123",
  "timestamp": 1234567890
}
```

---

#### Delete Variant

Deletes a light configuration.

**Fields:**

- `id`: Light identifier to delete
- `deleted_at`: **Critical for LWW** - timestamp of deletion

**LWW Semantics:**

- If `deleted_at >= existing.updated_at`: Delete light
- If `deleted_at < existing.updated_at`: Ignore delete (update is newer)
- **Limitation:** No tombstone, so late updates can resurrect deleted lights

**Example JSON:**

```json
{
  "op": {
    "Delete": {
      "id": "light-1",
      "deleted_at": 1234567900
    }
  },
  "peer_id": "peer-123",
  "timestamp": 1234567900
}
```

---

#### RequestSync Variant

Requests full configuration state from peers.

**Fields:**

- `peer_id`: Requester's peer identifier

**Semantics:**

- Sent on initial connection (sync configurations)
- Each peer responds with all LightConfig as Upsert messages
- Enables fast convergence on join

**Example JSON:**

```json
{
  "op": {
    "RequestSync": {
      "peer_id": "peer-789"
    }
  },
  "peer_id": "peer-789",
  "timestamp": 1234567850
}
```

**Response:** Series of ConfigMessage with Upsert operations for each light

---

### 4. LightConfig

Represents a light configuration (used in database and sync).

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LightConfig {
    pub id: String,
    pub color: String,
    pub name: String,
    pub enabled: bool,
    pub priority: i32,
    pub updated_at: u64,
    pub updated_by: String,
}
```

**Fields:** Identical to ConfigOp::Upsert (no duplication)

**Usage:**

- Database persistence (stored as-is)
- Conversion to ConfigOp::Upsert for network transmission
- Service layer operations (upsert_light, get_all_lights)

**Example:**

```rust
let config = LightConfig {
    id: "light-1".to_string(),
    color: "green".to_string(),
    name: "Room 1".to_string(),
    enabled: true,
    priority: 1,
    updated_at: 1234567890,
    updated_by: "peer-123".to_string(),
};
```

---

### 5. LightState

Represents a peer's current availability status.

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LightState {
    pub color: String,
    pub timestamp: u64,
}

impl LightState {
    pub fn new(color: String) -> Self {
        Self {
            color,
            timestamp: crate::utils::current_timestamp(),
        }
    }
}
```

**Fields:**

- `color`: Availability indicator (e.g., "red", "yellow", "green")
- `timestamp`: When this state was set (milliseconds)

**Constructor:**

- `new(color)`: Creates LightState with current timestamp

**Usage:**

- Embedded in PresenceMessage::Online
- Stored in PeerPresence
- Updated when user changes availability

**Color Semantics (Application-Level):**

- Red: Busy / Do Not Disturb
- Yellow: Away / Be Back Soon
- Green: Available
- Other: Custom states

**Example:**

```rust
let state = LightState::new("green".to_string());
// state.timestamp is current time
```

---

### 6. Notification

Structured notification with type and routing information.

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Notification {
    #[serde(rename = "type")]
    pub notification_type: NotificationType,
    pub message: String,
    pub target_peer_id: String,
    pub sender_peer_id: String,
    pub timestamp: u64,
    pub priority: Option<String>,
    pub color: Option<String>,
}
```

**Fields:**

- `notification_type`: Category of notification (enum)
- `message`: Notification content
- `target_peer_id`: Recipient peer ID
- `sender_peer_id`: Sender peer ID
- `timestamp`: Creation time (milliseconds)
- `priority`: Optional priority level (e.g., "high", "urgent")
- `color`: Optional color override for display

**Serde Note:** `#[serde(rename = "type")]` for "type" field in JSON (reserved keyword in Rust)

**Example JSON:**

```json
{
  "type": "urgent-assist",
  "message": "Need help in Room 3",
  "target_peer_id": "peer-456",
  "sender_peer_id": "peer-123",
  "timestamp": 1234567890,
  "priority": "high",
  "color": "#FF0000"
}
```

---

### 7. NotificationType

Categories of notifications.

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum NotificationType {
    PatientReady,
    RoomReady,
    UrgentAssist,
    GeneralMessage,
}
```

**Variants:**

- `PatientReady`: Patient ready for examination/procedure
- `RoomReady`: Room prepared and available
- `UrgentAssist`: Urgent assistance needed
- `GeneralMessage`: Generic notification

**Serde:** `#[serde(rename_all = "kebab-case")]` serializes as "patient-ready", "room-ready", etc.

**Example JSON:**

```json
"patient-ready"
```

**Extensibility:** Add variants for new notification types (non-breaking with proper versioning)

---

### 8. ChatMessage

Chat message type (re-exported from domain).

```rust
pub type ChatMessage = crate::domain::ChatMessage;
```

**Definition (in domain):**

```rust
pub struct ChatMessage {
    pub id: String,
    pub peer_id: String,
    pub peer_name: String,
    pub content: String,
    pub timestamp: u64,
}
```

**Rationale for Type Alias:**

- Protocol and domain use same structure (currently)
- Allows future divergence without breaking changes
- Example: Protocol could add encryption metadata while domain stays simple

**Usage:**

- Network transmission (serialized as JSON)
- Database persistence (via chat_db)
- Service layer operations (ChatService)

---

## Serialization Format

### JSON with Serde

**Configuration:**

- `#[derive(Serialize, Deserialize)]` on all types
- Default serde settings (no custom serializers)
- Enum variants as objects with variant name as key

**Enum Serialization (Default):**

```rust
// Rust
PresenceMessage::Online { peer_id: "peer-1", ... }

// JSON
{
  "Online": {
    "peer_id": "peer-1",
    ...
  }
}
```

**Struct Serialization:**

```rust
// Rust
LightState { color: "green".into(), timestamp: 1234567890 }

// JSON
{
  "color": "green",
  "timestamp": 1234567890
}
```

### Wire Format

**Transport Layer Responsibilities:**

- Length-prefixed messages (see message_io.rs)
- Optional encryption (see encryption layer)
- TCP streaming (see transport.rs)

**Protocol Layer Scope:**

- JSON serialization only
- No framing or encryption at this layer

---

## Field Semantics

### Timestamps

**Format:** Unix timestamp in milliseconds (u64)
**Source:** `utils::current_timestamp()`
**Precision:** Millisecond (sufficient for conflict resolution)

**Usage:**

- **Message timestamps:** Creation time (for logging, debugging)
- **LWW timestamps:** (updated_at, deleted_at) - critical for conflict resolution
- **LightState timestamps:** When status was set
- **Notification timestamps:** When notification was created

**Clock Skew:** Tolerated by LWW (higher timestamp wins, regardless of clock accuracy)

### Peer IDs

**Format:** String (no validation at protocol level)
**Typical Pattern:** UUID or "peer-{UUID}" format
**Uniqueness:** Application's responsibility (usually network layer generates)

**Usage:**

- Message routing (sender, target)
- Presence tracking
- Ownership attribution (updated_by)

### Optional Fields

**Design Philosophy:** Minimize optional fields for clarity

- `note` in PresenceMessage: Truly optional status message
- `notification_status` in PresenceMessage: Often None (no active notification)
- `priority` and `color` in Notification: Display hints (not required)

## Protocol Versioning

### Current State

**No Explicit Versioning:** All peers must use same protocol version

- Breaking changes require coordinated upgrade
- Not suitable for heterogeneous deployments

### Future Versioning Strategy

**Option 1: Version Field in Messages**

```rust
pub struct VersionedMessage {
    pub version: u32,
    pub payload: serde_json::Value,
}
```

**Option 2: Capability Negotiation**

```rust
pub enum PresenceMessage {
    // Existing variants
    Capabilities {
        peer_id: String,
        supported_features: Vec<String>,
    },
}
```

**Option 3: Protocol Buffers**

- Replace serde JSON with protobuf
- Built-in versioning and backward compatibility
- More efficient (binary format)
- Trade-off: More complex, less debuggable

### Backward Compatibility

**Current Approach:** None (breaking changes allowed during development)

**Future Approach (recommendations):**

1. Add optional fields only (existing parsers ignore unknown fields)
2. Add new enum variants with caution (existing parsers may fail)
3. Deprecate old variants (keep for N versions, then remove)
4. Use version negotiation for major changes

## Performance Considerations

### Message Size

**Typical Sizes (JSON):**

- PresenceMessage::Online: 200-500 bytes (with note and notification)
- PresenceMessage::Goodbye: 30-50 bytes
- ConfigMessage (Upsert): 150-300 bytes
- ChatMessage: 100-1000 bytes (depends on content length)

**Optimization Opportunities:**

1. Use MessagePack instead of JSON (30-50% smaller)
2. Compress large messages (gzip, zstd)
3. Delta encoding for repeated presence updates
4. Binary protocol (protobuf, capnproto)

### Serialization Overhead

**JSON (serde_json):**

- Fast serialization (microseconds per message)
- Human-readable (good for debugging)
- Larger size than binary formats

**Benchmarks (typical hardware):**

- Serialize PresenceMessage::Online: ~5-10 µs
- Deserialize PresenceMessage::Online: ~10-20 µs
- Throughput: ~50,000-100,000 messages/second per core

### Memory Allocation

**Clone-heavy Protocol:**

- All messages are `Clone` (required for distribution to multiple peers)
- Frequent cloning increases allocations
- Mitigation: Use `Arc<Message>` for broadcast (share single allocation)

**String Allocations:**

- Every field is owned String (not borrowed)
- Necessary for network messages (lifetime constraints)
- Mitigation: Consider `Arc<str>` for large, shared strings

## Security Considerations

### Authentication

**Current State:** None at protocol level

- No peer identity verification
- Any peer can claim any peer_id
- Trust-based system

**Threats:**

- Peer ID spoofing (impersonation)
- Replay attacks (old messages re-sent)
- Man-in-the-middle (message modification)

**Mitigations (future):**

1. Add cryptographic signatures to messages
2. Use TLS for transport encryption and peer authentication
3. Add nonce/sequence numbers to prevent replay

### Data Validation

**Current State:** Minimal validation

- No length limits on strings
- No format validation on peer_id, color values
- No range validation on timestamps

**Threats:**

- Memory exhaustion (extremely long strings)
- Invalid data causing panics (unlikely with current code)
- Malicious content (XSS in UI if not escaped)

**Mitigations:**

- Add max length validation in service layer
- Sanitize strings before UI display
- Validate color formats (hex, named colors)

### Denial of Service

**Threats:**

1. Message flooding (send millions of messages)
2. Large message payloads (MB-sized strings)
3. Malformed JSON (cause parsing errors)

**Mitigations:**

- Rate limiting at network layer
- Message size limits at transport layer
- Graceful error handling for parse failures

## Integration Points

### Producers (Message Creators)

**PresenceService:** `src-tauri/src/services/presence_service.rs`

- Creates PresenceMessage::Online (via presence_helpers)
- Creates PresenceMessage::Goodbye
- Creates PresenceMessage::RequestStatus

**ConfigService:** `src-tauri/src/services/config_service.rs`

- Creates ConfigMessage with Upsert/Delete operations
- Converts LightConfig to ConfigOp::Upsert

**ChatService:** `src-tauri/src/services/chat_service.rs`

- Uses domain::ChatMessage (aliased in protocol)

### Consumers (Message Processors)

**Network Layer:** `src-tauri/src/network/`

- Serializes messages to JSON bytes
- Deserializes JSON bytes to messages
- Routes messages to appropriate handlers

**Service Layer:**

- PresenceService: Processes incoming PresenceMessage
- ConfigService: Processes incoming ConfigMessage
- ChatService: Processes incoming ChatMessage

### Data Flow

**Outbound (Local to Network):**

```
Service Layer (create message)
  ↓
Protocol::Serialize (to JSON)
  ↓
Network Layer (add framing)
  ↓
Encryption Layer (optional)
  ↓
Transport Layer (TCP send)
```

**Inbound (Network to Local):**

```
Transport Layer (TCP receive)
  ↓
Encryption Layer (optional decrypt)
  ↓
Network Layer (remove framing)
  ↓
Protocol::Deserialize (from JSON)
  ↓
Service Layer (process message)
```

## Test Coverage

**Current Status:** No dedicated tests for protocol types

**Rationale:**

- Simple data structures with derive macros
- Serialization tested by serde (well-tested library)
- Integration tested via service layer tests

**What Would Be Tested (if tests existed):**

**Serialization Round-Trip Tests:**

1. Serialize each message type to JSON, deserialize, verify equality
2. Test enum variants serialize to correct JSON format
3. Test optional fields serialize correctly (Some vs None)
4. Test kebab-case conversion for NotificationType

**Example Test:**

```rust
#[test]
fn presence_online_round_trip() {
    let msg = PresenceMessage::Online {
        peer_id: "peer-1".into(),
        peer_name: "Alice".into(),
        light_state: LightState::new("green".into()),
        note: Some("Available".into()),
        timestamp: 1234567890,
        notification_status: Box::new(None),
    };

    let json = serde_json::to_string(&msg).unwrap();
    let deserialized: PresenceMessage = serde_json::from_str(&json).unwrap();

    // Compare fields (requires PartialEq)
}
```

**Schema Validation Tests:**

- Ensure JSON matches expected schema
- Detect breaking changes in serialization format
- Validate against JSON Schema (if defined)

## Usage Examples

### Creating Presence Messages

```rust
use crate::protocol::messages::{PresenceMessage, LightState};

// Announce online status
let online_msg = PresenceMessage::Online {
    peer_id: "peer-123".to_string(),
    peer_name: "Alice".to_string(),
    light_state: LightState::new("green".to_string()),
    note: Some("Available for consults".to_string()),
    timestamp: crate::utils::current_timestamp(),
    notification_status: Box::new(None),
};

// Graceful disconnect
let goodbye_msg = PresenceMessage::Goodbye {
    peer_id: "peer-123".to_string(),
};

// Request status from all peers
let request_msg = PresenceMessage::RequestStatus {
    peer_id: "peer-123".to_string(),
};
```

### Creating Config Messages

```rust
use crate::protocol::messages::{ConfigMessage, ConfigOp};

// Create light configuration
let upsert_msg = ConfigMessage {
    op: ConfigOp::Upsert {
        id: "light-1".to_string(),
        color: "green".to_string(),
        name: "Conference Room A".to_string(),
        enabled: true,
        priority: 10,
        updated_at: crate::utils::current_timestamp(),
        updated_by: "peer-123".to_string(),
    },
    peer_id: "peer-123".to_string(),
    timestamp: crate::utils::current_timestamp(),
};

// Delete light configuration
let delete_msg = ConfigMessage {
    op: ConfigOp::Delete {
        id: "light-1".to_string(),
        deleted_at: crate::utils::current_timestamp(),
    },
    peer_id: "peer-123".to_string(),
    timestamp: crate::utils::current_timestamp(),
};

// Request sync
let sync_msg = ConfigMessage {
    op: ConfigOp::RequestSync {
        peer_id: "peer-123".to_string(),
    },
    peer_id: "peer-123".to_string(),
    timestamp: crate::utils::current_timestamp(),
};
```

### Serialization

```rust
use serde_json;

// Serialize to JSON
let json_bytes = serde_json::to_vec(&online_msg)?;
// Send json_bytes over network

// Deserialize from JSON
let received_msg: PresenceMessage = serde_json::from_slice(&json_bytes)?;
```

## Future Improvements

### High Priority

**1. Add Protocol Versioning**

- Include version field in all messages
- Enable backward compatibility checking
- Support gradual protocol evolution

**2. Add Message Validation**

- Max length constraints on strings
- Format validation (peer_id, colors)
- Timestamp bounds checking

**3. Add Serialization Tests**

- Round-trip tests for all message types
- JSON schema validation
- Regression tests for breaking changes

### Medium Priority

**4. Consider Binary Format**

- Evaluate protobuf, capnproto, or MessagePack
- Benchmark serialization performance
- Measure size reduction

**5. Add Compression**

- Compress messages over threshold size (e.g., >1KB)
- Use zstd or similar fast compression
- Transparent to application layer

**6. Add Message Signatures**

- Cryptographically sign messages
- Prevent tampering and impersonation
- Use ed25519 or similar

### Low Priority

**7. Add Batching Support**

```rust
pub struct MessageBatch {
    pub messages: Vec<ProtocolMessage>,
}
```

- Reduce network overhead for multiple messages
- Improve throughput

**8. Add Schema Evolution Support**

- Define upgrade/downgrade functions
- Enable mixed-version deployments
- Document migration paths

**9. Generate JSON Schema**

- Auto-generate from Rust types
- Use for validation and documentation
- Enable client generation for other languages

## Related Documentation

### Specifications

- **ConfigService:** `spec/backend/services/config-service.md` - Uses ConfigMessage and LightConfig
- **PresenceService:** `spec/backend/services/presence-service.md` - Uses PresenceMessage and LightState
- **ChatService:** `spec/backend/services/chat-service.md` - Uses ChatMessage
- **Message I/O:** `spec/backend/network/message-io.md` - Serializes/deserializes protocol messages
- **Transport:** `spec/backend/network/transport.md` - TCP layer for message delivery

### Implementation Files

- **Messages:** `src-tauri/src/protocol/messages.rs` (100 lines)
- **Module:** `src-tauri/src/protocol/mod.rs` (4 lines)
- **Domain ChatMessage:** `src-tauri/src/domain/chat_message.rs` - Aliased in protocol

### External Resources

- **Serde Documentation:** https://serde.rs/
- **JSON Specification:** https://www.json.org/
- **Protocol Buffers:** https://protobuf.dev/ - Alternative serialization format
- **CRDT Literature:** https://crdt.tech/ - For understanding config sync design
