# Lighten-Up Protocol Specification v2.0

**Status:** Implemented
**Date:** 2025-12-26
**Network Stack:** TCP + mDNS + ChaCha20 (LAN-only)

## Overview

Lighten-Up uses a simple broadcast-based protocol over TCP for peer-to-peer communication on LAN networks. The protocol is designed for simplicity, with minimal persistent state and automatic conflict resolution via CRDTs.

### Design Principles

1. **Ephemeral by default** - Most state is transient (peer presence, light status)
2. **No central coordinator** - Fully distributed, no controller/follower roles
3. **Offline-first** - Works offline, syncs when online
4. **Immediate broadcast** - Announce current state immediately when online
5. **CRDT for shared config** - Automatic conflict resolution for configuration
6. **Simple identity** - UUID peer_id with user-editable name (defaults to hostname)

---

## Data Model

### Persistent Data (Stored in SQLite)

#### 1. My Settings

```sql
CREATE TABLE my_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- Keys:
-- • peer_id: Unique UUID identifier (e.g., "a3f9c8d2-4b1e-...")
-- • peer_name: Display name (e.g., "Alice", defaults to hostname)
```

**Identity Generation:**

- On first launch, use hostname as `peer_name`
- Generate `peer_id` as UUID v4
- User can change `peer_name` anytime in settings
- `peer_id` never changes (ensures stable network identity)

#### 2. Light Configuration (CRDT)

```sql
CREATE TABLE light_config (
    id TEXT PRIMARY KEY,              -- UUID
    color TEXT NOT NULL,              -- Hex color: "#FF0000", "#00FF00", etc.
    name TEXT NOT NULL,               -- "Doctor", "Emergency", "Nurse Call"
    enabled INTEGER NOT NULL,         -- 0 (disabled) or 1 (enabled)
    priority INTEGER NOT NULL,        -- Lower = higher priority (1 is highest)
    updated_at INTEGER NOT NULL,      -- Unix timestamp (seconds)
    updated_by TEXT NOT NULL,         -- peer_id who made this change
    UNIQUE(priority)                  -- Each priority value must be unique
);

-- Sorting: ORDER BY priority ASC, updated_at ASC
```

**Conflict Resolution:**

- Uses Last-Write-Wins (LWW) based on `updated_at` timestamp
- If timestamps equal, use `updated_by` lexicographic comparison
- CRDT operations broadcast to all connected peers
- All peers eventually converge to same config

#### 3. Chat Messages

```sql
CREATE TABLE chat_messages (
    id TEXT PRIMARY KEY,              -- UUID
    peer_id TEXT NOT NULL,            -- Who sent it
    peer_name TEXT NOT NULL,          -- Display name
    content TEXT NOT NULL,            -- Message text
    timestamp INTEGER NOT NULL,       -- Unix timestamp
    INDEX idx_timestamp (timestamp DESC)
);

-- Retention: 24 hours
-- Cleanup trigger:
CREATE TRIGGER cleanup_old_chat
AFTER INSERT ON chat_messages
BEGIN
    DELETE FROM chat_messages
    WHERE timestamp < (strftime('%s', 'now') - 86400);
END;
```

---

### Ephemeral Data (Memory Only)

#### 1. Peer Presence

```rust
struct PeerPresence {
    peer_id: String,
    peer_name: String,
    light_state: LightState,
    note: Option<String>,
    last_seen: u64,  // Unix timestamp
}

// Stored in: HashMap<PeerId, PeerPresence>
// Auto-removed if no Presence received in 60 seconds
```

#### 2. Light State

```rust
struct LightState {
    color: String,       // Hex color
    timestamp: u64,      // When set
}

// Simple LWW - always reflects current state of peer
```

---

## Network Protocol

### Transport Layer

**Stack:**

```
┌──────────────────────────┐
│  Application Messages    │
├──────────────────────────┤
│  JSON (serde_json)       │
├──────────────────────────┤
│  ChaCha20 Encryption     │
├──────────────────────────┤
│  TCP (length-prefixed)   │
├──────────────────────────┤
│  mDNS Discovery          │
└──────────────────────────┘
```

**Configuration:**

- **Discovery:** mDNS service `_lightenup._tcp.local.`
- **Transport:** TCP with ChaCha20 encryption
- **Message Format:** Length-prefixed JSON
  - 4-byte message length (u32, network byte order)
  - Encrypted JSON payload
- **LAN-only:** No relay servers or NAT traversal
- **Port:** Random ephemeral port (advertised via mDNS)

**Peer Discovery Flow:**

```
1. Peer starts → Register mDNS service "_lightenup._tcp.local."
2. Browse for other peers via mDNS
3. When peer discovered → Connect via TCP
4. Send initial messages (Presence + current state)
5. Maintain persistent connections to all peers
```

---

### Message Types

All messages are broadcast to all connected peers immediately.

#### Message: `Presence`

**Purpose:** Announce peer presence and current light status
**Frequency:** Every 30 seconds OR on status change

```rust
enum PresenceMessage {
    /// Peer is online with current state
    Online {
        peer_id: String,
        peer_name: String,
        light_state: LightState,
        note: Option<String>,
        timestamp: u64,
    },

    /// Peer is gracefully shutting down
    Goodbye {
        peer_id: String,
    },
}
```

**Behavior:**

- On join: Send `Online` immediately
- Every 30s: Re-send `Online` (heartbeat)
- On status change: Send `Online` immediately
- On shutdown: Send `Goodbye` (best effort)
- If no `Online` received in 60s: Remove peer from map

---

#### Message: `Config`

**Purpose:** Synchronize light configuration (CRDT)
**Frequency:** On admin changes

```rust
struct ConfigMessage {
    op: ConfigOp,
    peer_id: String,
    timestamp: u64,
}

enum ConfigOp {
    /// Create or update a light definition
    Upsert {
        id: String,
        color: String,
        name: String,
        enabled: bool,
        priority: i32,
        updated_at: u64,
        updated_by: String,
    },

    /// Delete a light definition
    Delete {
        id: String,
        deleted_at: u64,
    },
}
```

**Behavior:**

- Any peer can modify config (no permissions)
- Changes broadcast as CRDT operations to all peers
- Receiving peer applies operation to local CRDT
- Automatic conflict resolution via LWW
- All peers eventually converge

**Conflict Resolution:**

```rust
fn should_replace(local: &Definition, incoming: &Definition) -> bool {
    if incoming.updated_at != local.updated_at {
        return incoming.updated_at > local.updated_at;
    }
    // Tiebreaker: lexicographic comparison
    incoming.updated_by > local.updated_by
}
```

---

#### Message: `Chat`

**Purpose:** Realtime chat messages
**Frequency:** On user message

```rust
struct ChatMessage {
    id: String,          // UUID
    peer_id: String,
    peer_name: String,
    content: String,
    timestamp: u64,
}
```

**Behavior:**

- User sends message → Store locally → Broadcast to all peers
- Receiving peer checks duplicate (by `id`)
- Store in local SQLite
- Display in UI (ordered by timestamp)
- Auto-cleanup messages older than 24 hours

---

## Message Flow Examples

### Example 1: App Startup

```
1. User launches app

2. Load from SQLite:
   - my_settings (peer_id, peer_name)
   - light_config (definitions)
   - chat_messages (last 24h)

3. Initialize in-memory state:
   - online_peers = HashMap::new()
   - my_light_state = LightState { color: "#000000" } // Off

4. Start network services:
   - Register mDNS service
   - Start TCP listener
   - Browse for peers via mDNS

5. Connect to discovered peers via TCP

6. Announce presence to all connections:
   Broadcast Message::Presence(PresenceMessage::Online {
       peer_id: "a3f9c8d2-...",
       peer_name: "Alice",
       light_state: { color: "#000000" },
       note: None,
       timestamp: 1703520000,
   })

7. Start heartbeat timer (30s interval)

8. Listen for incoming messages on all connections
```

---

### Example 2: User Changes Light Status

```
1. User clicks "Red" light with note "In meeting"

2. Update local state:
   my_light_state = LightState {
       color: "#FF0000",
       timestamp: now(),
   }
   my_note = Some("In meeting")

3. Update UI immediately (optimistic)

4. Broadcast to all peers:
   Message::Presence(PresenceMessage::Online {
       peer_id: "a3f9c8d2-...",
       peer_name: "Alice",
       light_state: { color: "#FF0000" },
       note: Some("In meeting"),
       timestamp: 1703520100,
   })

5. Other peers receive message:
   - Update online_peers["a3f9c8d2-..."]
   - Update UI to show Alice's red light
```

---

### Example 3: Admin Updates Config

```
1. Admin changes "Red" light priority from 2 to 1

2. Load current definition from SQLite

3. Update local CRDT:
   definition.priority = 1
   definition.updated_at = now()
   definition.updated_by = "b2c4d5e6-..."

4. Save to local SQLite:
   UPDATE light_config
   SET priority = 1,
       updated_at = 1703520200,
       updated_by = "b2c4d5e6-..."
   WHERE id = "red-light-uuid"

5. Update UI immediately

6. Broadcast to all peers:
   Message::Config(ConfigMessage {
       op: ConfigOp::Upsert {
           id: "red-light-uuid",
           color: "#FF0000",
           name: "Emergency",
           enabled: true,
           priority: 1,
           updated_at: 1703520200,
           updated_by: "b2c4d5e6-...",
       },
       peer_id: "b2c4d5e6-...",
       timestamp: 1703520200,
   })

7. Other peers receive operation:
   - Check should_replace() using timestamp
   - If newer, apply to local CRDT
   - Save to SQLite
   - Update UI
```

---

### Example 4: Peer Goes Offline

**Graceful shutdown:**

```
1. User closes app

2. Broadcast goodbye to all connections:
   Message::Presence(PresenceMessage::Goodbye {
       peer_id: "a3f9c8d2-..."
   })

3. Close all TCP connections

4. Unregister mDNS service

5. Other peers receive Goodbye:
   - Remove from online_peers map
   - Update UI (peer disappears)
```

**Crash/network failure:**

```
1. Peer crashes (no Goodbye sent)

2. TCP connection breaks

3. Other peers:
   - Detect broken connection
   - Stop receiving Presence messages
   - After 60s timeout:
     - if now() - peer.last_seen > 60:
         online_peers.remove(peer_id)
   - Update UI (peer disappears)
```

---

## Network Characteristics

### Connection Management

- **Persistent connections:** TCP connections maintained to all discovered peers
- **Bidirectional:** Each peer can send/receive on same connection
- **Auto-reconnect:** If connection drops, reconnect on next mDNS discovery
- **Connection pool:** Manage connections per peer (deduplicate by peer_id)

### Message Delivery

- **Broadcast:** All messages sent to all connected peers
- **At-most-once:** No retry logic, TCP handles reliability
- **Ordered:** TCP guarantees ordering per connection
- **No buffering:** Messages sent immediately

### Performance

**Typical LAN latency:**

- mDNS discovery: 1-5 seconds
- TCP connection: 10-50ms
- Message delivery: 10-50ms
- Total peer-to-peer: 20-100ms

**Scalability:**

- Tested: 10 peers
- Expected: 50-100 peers on LAN
- Bottleneck: Connection count (N-1 connections per peer)

---

## Security Considerations

### Encryption

- **ChaCha20** symmetric encryption for all messages
- **Shared passphrase:** All peers must use same passphrase
- **Key derivation:** PBKDF2 with random salt
- **No perfect forward secrecy:** Same key used for all messages

### Trust Model

- **Fully trusted LAN**
- All peers with passphrase can read/write all data
- No malicious peer protection
- Suitable for closed office/medical environments
- NOT suitable for untrusted networks

### Authentication

- **None** - Peer identity is self-asserted
- Passphrase provides network access control only
- No verification of peer_name or peer_id

---

## Error Handling

### Network Errors

**Connection failure:**

- Log error and continue with other connections
- Will reconnect on next mDNS discovery cycle
- Peer marked offline after 60s timeout

**Message serialization failure:**

- Log error and drop message
- Continue processing other messages

### Data Conflicts

**Config conflicts:**

- Resolved via Last-Write-Wins timestamp
- If exact timestamp collision: Use `updated_by` string comparison
- All peers converge to same state

**Priority conflicts:**

- SQLite UNIQUE constraint prevents duplicate priorities
- On conflict: Reject local change, show error to user
- User must choose different priority value

### Storage Errors

**SQLite write failure:**

- Log error
- Show notification to user
- Continue operating with in-memory state

**SQLite corruption:**

- On startup, if database corrupt:
  - Delete database
  - Recreate schema
  - Start fresh
  - Config will sync from network

---

## Wire Format

### Message Envelope

```rust
// Length-prefixed message
struct WireMessage {
    length: u32,           // Network byte order (big-endian)
    encrypted_payload: Vec<u8>,  // ChaCha20 encrypted JSON
}
```

### Serialization

- **Format:** JSON (serde_json)
- **Encoding:** UTF-8
- **Encryption:** ChaCha20 (encrypted before sending)

### Example: Presence Message (before encryption)

```json
{
  "type": "Presence",
  "payload": {
    "Online": {
      "peer_id": "a3f9c8d2-4b1e-4a7d-8e2f-1c3d5e6f7a8b",
      "peer_name": "Alice",
      "light_state": {
        "color": "#FF0000",
        "timestamp": 1703520000
      },
      "note": "In meeting",
      "timestamp": 1703520000
    }
  }
}
```

---

## Complete Schema

```sql
-- My identity and settings
CREATE TABLE my_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- Shared light configuration (CRDT)
CREATE TABLE light_config (
    id TEXT PRIMARY KEY,
    color TEXT NOT NULL,
    name TEXT NOT NULL,
    enabled INTEGER NOT NULL DEFAULT 1,
    priority INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    updated_by TEXT NOT NULL,
    UNIQUE(priority)
);
CREATE INDEX idx_config_priority ON light_config(priority ASC);

-- Chat messages (24h retention)
CREATE TABLE chat_messages (
    id TEXT PRIMARY KEY,
    peer_id TEXT NOT NULL,
    peer_name TEXT NOT NULL,
    content TEXT NOT NULL,
    timestamp INTEGER NOT NULL
);
CREATE INDEX idx_chat_timestamp ON chat_messages(timestamp DESC);

-- Auto-cleanup old chat messages
CREATE TRIGGER cleanup_old_chat
AFTER INSERT ON chat_messages
BEGIN
    DELETE FROM chat_messages
    WHERE timestamp < (strftime('%s', 'now') - 86400);
END;
```

---

## Message Types (Rust)

```rust
// Top-level message enum
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "type", content = "payload")]
pub enum Message {
    Presence(PresenceMessage),
    Config(ConfigMessage),
    Chat(ChatMessage),
}

// Presence messages
#[derive(Serialize, Deserialize, Debug, Clone)]
pub enum PresenceMessage {
    Online {
        peer_id: String,
        peer_name: String,
        light_state: LightState,
        note: Option<String>,
        timestamp: u64,
    },
    Goodbye {
        peer_id: String,
    },
}

// Config messages
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ConfigMessage {
    pub op: ConfigOp,
    pub peer_id: String,
    pub timestamp: u64,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
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
}

// Chat messages
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ChatMessage {
    pub id: String,
    pub peer_id: String,
    pub peer_name: String,
    pub content: String,
    pub timestamp: u64,
}

// Light state
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LightState {
    pub color: String,  // Hex color
    pub timestamp: u64,
}
```

---

## Document History

- **v2.0 (2025-12-26):** TCP+mDNS implementation (current)
- **v2.0-draft (2025-12-25):** iroh-gossip design (not implemented)
- **v1.0 (2025-12-24):** Controller-based architecture (deprecated)
