# PresenceService Specification

## Overview

The `PresenceService` manages peer presence information for the application. It tracks the current user's status (light color, note, notification) and maintains a registry of all connected peers with their presence information. The service handles incoming presence updates, manages peer lifecycle (online/offline), and provides cleanup for stale peers.

**File Path:** `src-tauri/src/services/presence_service.rs`

**Key Responsibilities:**

- Track current user's presence state (light color, note, name)
- Maintain registry of connected peers
- Handle incoming presence messages (Online, Goodbye, RequestStatus)
- Clean up stale/timed-out peers
- Manage notification states for peers
- Provide presence data to frontend

---

## Architecture

### Service Structure

```
┌─────────────────────────────────────────┐
│         PresenceService                 │
├─────────────────────────────────────────┤
│  My State:                              │
│  - my_peer_id: String                   │
│  - my_peer_name: Arc<RwLock<String>>    │
│  - my_light_state: Arc<RwLock<...>>     │
│  - my_note: Arc<RwLock<Option<...>>>    │
│  - my_notification_status: Arc<...>     │
├─────────────────────────────────────────┤
│  Peer Registry:                         │
│  - peers: HashMap<PeerId, Presence>     │
├─────────────────────────────────────────┤
│  Operations:                            │
│  - Handle presence messages             │
│  - Update my state                      │
│  - Cleanup stale peers (30s timeout)    │
│  - Get all peers (including self)       │
└─────────────────────────────────────────┘
```

---

## Data Structures

### PeerPresence

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PeerPresence {
    pub peer_id: String,
    pub peer_name: String,
    pub light_state: LightState,
    pub note: Option<String>,
    pub last_seen: u64,              // Unix timestamp
    pub notification_status: Option<Notification>,
}
```

### LightState

```rust
pub struct LightState {
    pub color: String,      // Hex color code
    pub timestamp: u64,     // Unix timestamp
}
```

### Notification

```rust
pub struct Notification {
    pub notification_type: NotificationType,
    pub message: String,
    pub color: Option<String>,
    pub timestamp: u64,
}
```

---

## Constants

### `PEER_TIMEOUT_SECS: u64 = 30`

Peers are considered offline if not seen for 30 seconds (3 missed 10-second heartbeats).

---

## State Management

### My State (Thread-Safe with RwLock)

```rust
my_peer_id: String                                      // Immutable peer ID
my_peer_name: Arc<RwLock<String>>                       // User's display name
my_light_state: Arc<RwLock<LightState>>                 // Current light color/status
my_note: Arc<RwLock<Option<String>>>                    // Optional status note
my_notification_status: Arc<RwLock<Option<Notification>>> // Current notification
```

### Peer Registry (Thread-Safe)

```rust
peers: Arc<RwLock<HashMap<String, PeerPresence>>>       // All known peers (excluding self)
```

**Concurrency:** All mutable state protected by `RwLock` for safe concurrent access.

---

## Public API

### Constructor

#### `new(peer_id: String, peer_name: String) -> Self`

Creates new presence service instance.

**Parameters:**

- `peer_id`: Unique identifier for this peer
- `peer_name`: Initial display name

**Initial State:**

- Light color: Black (`#000000`)
- Note: None
- Notification: None
- Peers: Empty

---

### My Presence Management

#### `async fn get_my_presence(&self) -> PresenceMessage`

Returns current presence as an `Online` message.

**Returns:** `PresenceMessage::Online` with current state

**Used For:** Broadcasting presence to network

#### `async fn get_offline_message(&self) -> PresenceMessage`

Returns `Goodbye` message for shutdown.

**Returns:** `PresenceMessage::Goodbye` with peer ID

**Used For:** Notifying peers of graceful shutdown

#### `async fn set_light_color(&self, color: String)`

Updates current light color.

**Parameters:**

- `color`: Hex color code (e.g., "#ff0000")

**Side Effects:**

- Updates `my_light_state` with new color and current timestamp

#### `async fn set_note(&self, note: Option<String>)`

Updates status note.

**Parameters:**

- `note`: Optional status message (e.g., "In a meeting")

#### `async fn set_peer_name(&self, name: String)`

Updates display name.

**Parameters:**

- `name`: New display name

#### `async fn get_peer_name(&self) -> String`

Returns current display name.

#### `fn get_my_peer_id(&self) -> String`

Returns peer ID (non-async, clones string).

---

### Peer Registry Management

#### `async fn handle_presence(&self, msg: PresenceMessage)`

Processes incoming presence messages.

**Message Types:**

1. **PresenceMessage::Online**
   - Adds new peer or updates existing peer
   - Updates: name, light_state, note, timestamp, notification
   - Logs: `[PRESENCE] Received Online from peer {id} ({name})`

2. **PresenceMessage::Goodbye**
   - Removes peer from registry
   - Logs: `[PRESENCE] Peer {id} is going offline`

3. **PresenceMessage::RequestStatus**
   - Lightweight ping, no state update
   - Logs: `[PRESENCE] Received RequestStatus from peer {id}`
   - Response handled by routing layer

**Concurrency:** Thread-safe with write locks

#### `async fn cleanup_stale_peers(&self) -> bool`

Removes peers not seen within `PEER_TIMEOUT_SECS`.

**Returns:** `true` if any peers removed, `false` otherwise

**Behavior:**

- Calculates timeout: `now - last_seen >= 30 seconds`
- Removes stale peers from registry
- Logs removed peers: `[CLEANUP] Removed {count} stale peer(s): {names}`
- Logs when all active: `[CLEANUP] All {count} peers still active`

**Used For:** Periodic cleanup task (typically every 10 seconds)

#### `async fn get_all_peers(&self) -> Vec<PeerPresence>`

Returns all peers including self.

**Returns:** Vector of `PeerPresence` (self + all known peers)

**Used For:** Frontend display, showing complete peer list

---

### Notification Management

#### `async fn set_peer_notification(&self, peer_id: String, notification: Notification)`

Sets notification status for a peer.

**Parameters:**

- `peer_id`: Target peer ID
- `notification`: Notification details

**Behavior:**

- If `peer_id` matches self: Updates `my_notification_status`
- Otherwise: Updates notification in `peers` HashMap
- Silently ignores if peer not found (remote peer)

#### `async fn clear_peer_notification(&self, peer_id: &str)`

Clears notification status for a peer.

**Parameters:**

- `peer_id`: Target peer ID

**Behavior:**

- If `peer_id` matches self: Clears `my_notification_status`
- Otherwise: Clears notification in `peers` HashMap
- Silently ignores if peer not found

---

## Integration Points

### Dependencies

**Internal:**

- `protocol::messages::{LightState, Notification, PresenceMessage}`
- `services::presence_helpers::{add_or_update_peer, create_online_message, remove_peer}`
- `utils::current_timestamp()`

**External:**

- `tokio::sync::RwLock` - Thread-safe state management
- `serde` - Serialization for network messages
- `log` - Structured logging

### Used By

- **Network Layer:** Receives `PresenceMessage` from network
- **Tauri Commands:** Exposes peer data to frontend
- **Heartbeat Task:** Periodically calls `cleanup_stale_peers()`
- **Shutdown Handler:** Calls `get_offline_message()` on exit

---

## Concurrency & Thread Safety

### RwLock Strategy

**Read-Heavy Operations:**

- `get_my_presence()` - Multiple concurrent reads
- `get_all_peers()` - Multiple concurrent reads
- `get_peer_name()` - Multiple concurrent reads

**Write Operations:**

- `set_light_color()` - Exclusive write lock
- `set_note()` - Exclusive write lock
- `set_peer_name()` - Exclusive write lock
- `handle_presence()` - Exclusive write lock on peers map
- `cleanup_stale_peers()` - Exclusive write lock

**Lock Granularity:**

- Separate locks for different state components
- Minimizes lock contention
- Allows concurrent reads of different state

---

## Test Coverage

### Test Cases (7 tests)

1. **`new_creates_service_with_initial_state`**
   - Verifies constructor initializes correctly
   - Checks peer ID, name, and initial peer list

2. **`set_light_color_updates_state`**
   - Sets light color
   - Verifies presence message contains new color

3. **`set_note_updates_state`**
   - Sets status note
   - Verifies presence message contains note

4. **`set_peer_name_updates_name`**
   - Changes display name
   - Verifies name in get_peer_name() and presence

5. **`get_offline_message_returns_goodbye`**
   - Verifies Goodbye message format

6. **`handle_presence_adds_new_peer`**
   - Sends Online message for new peer
   - Verifies peer added to registry with correct data

7. **Additional tests** (inferred from test module presence)

**Coverage:** Core functionality well-tested, thread safety tested implicitly through async operations.

---

## Error Handling

### No Explicit Errors

This service does not return `Result` types. All operations succeed or fail silently:

- **Missing peers:** Ignored (e.g., clearing notification for unknown peer)
- **Invalid data:** Stored as-is (validation done at protocol layer)
- **Lock poisoning:** Would panic (expected in Tokio runtime)

**Rationale:** Presence is best-effort; dropped updates are acceptable.

---

## Performance Considerations

### Lock Contention

- **Read-heavy workload:** RwLock allows concurrent reads
- **Separate locks:** Different state components don't block each other
- **Short critical sections:** Lock held only for data copy/update

### Memory Usage

- **HashMap overhead:** O(n) memory for n peers
- **Arc cloning:** Cheap reference counting
- **String cloning:** Used for API boundaries (acceptable overhead)

### Cleanup Performance

- **O(n) iteration:** Checks all peers for timeout
- **Infrequent:** Runs every ~10 seconds
- **Batched logging:** Collects stale peer names before logging

---

## Logging

### Log Levels

**Info:**

- Peer online: `[PRESENCE] Received Online from peer {id} ({name})`
- Peer offline: `[PRESENCE] Peer {id} is going offline`
- Status request: `[PRESENCE] Received RequestStatus from peer {id}`
- Cleanup: `[CLEANUP] Removed {count} stale peer(s): {names}`

**Debug:**

- Active peers: `[CLEANUP] All {count} peers still active`

---

## Usage Example

```rust
// Create service
let service = PresenceService::new("peer-123".to_string(), "Alice".to_string());

// Update my state
service.set_light_color("#ff0000".to_string()).await;
service.set_note(Some("In a meeting".to_string())).await;

// Broadcast presence
let presence = service.get_my_presence().await;
network.broadcast(presence).await;

// Handle incoming presence
service.handle_presence(incoming_message).await;

// Get all peers for UI
let peers = service.get_all_peers().await;
frontend.update_peers(peers);

// Periodic cleanup
tokio::spawn(async move {
    loop {
        tokio::time::sleep(Duration::from_secs(10)).await;
        service.cleanup_stale_peers().await;
    }
});
```

---

## Design Decisions

### Why HashMap for Peers?

- **O(1) lookups** by peer ID
- **Efficient updates** when peer state changes
- **Memory overhead acceptable** for expected peer counts (<100)

### Why RwLock Instead of Mutex?

- **Read-heavy workload:** Many frontend queries, fewer updates
- **Concurrent reads:** Multiple threads can read simultaneously
- **Separate locks:** Reduces contention across state components

### Why No Error Handling?

- **Best-effort protocol:** Missing updates are acceptable
- **Simpler API:** No Result propagation needed
- **Crash-on-corruption:** Lock poisoning indicates serious bug

### Why 30-Second Timeout?

- **3 missed heartbeats:** Conservative to handle network hiccups
- **Balance:** Quick enough to remove departed peers, forgiving enough for transient issues

---

## Future Considerations

- Add metrics (peer count, update rate, cleanup frequency)
- Implement peer persistence for restart recovery
- Add TTL per peer (configurable timeout)
- Implement partial updates (delta encoding)
- Add batch operations for efficiency
- Consider LRU eviction for large peer counts
- Add peer priority/favorites
- Implement presence history/analytics
