# Presence Helpers Specification

## Overview

The presence_helpers module provides utility functions for managing peer presence state in a thread-safe manner. It acts as a helper layer for PresenceService, encapsulating common operations on the shared peer presence map and message construction.

**Location:** `src-tauri/src/services/presence_helpers.rs`

**Responsibilities:**

- Construct online presence messages from current state
- Add or update peer entries in the shared presence map
- Remove peer entries from the presence map
- Handle concurrent access to shared state via RwLock
- Log presence lifecycle events

## Architecture

### Design Pattern

**Helper Functions (Pure Utilities)**

- Stateless functions operating on provided references
- No internal state or side effects beyond logging
- Thread-safe through RwLock coordination
- Used by PresenceService for common operations

### Dependencies

```rust
presence_helpers
    ├── protocol::messages::{LightState, Notification, PresenceMessage}
    ├── services::presence_service::PeerPresence
    ├── utils::current_timestamp - Monotonic clock
    ├── std::collections::HashMap - Peer storage
    ├── std::sync::Arc - Shared ownership
    └── tokio::sync::RwLock - Async read-write lock
```

**No External Dependencies:** Uses only standard library and internal types

## Public API

### Message Construction

#### `create_online_message`

```rust
pub async fn create_online_message(
    peer_id: &str,
    peer_name: &Arc<RwLock<String>>,
    light_state: &Arc<RwLock<LightState>>,
    note: &Arc<RwLock<Option<String>>>,
    my_notification_status: &Arc<RwLock<Option<Notification>>>,
) -> PresenceMessage
```

Creates an Online presence message from current peer state.

**Parameters:**

- `peer_id`: Unique identifier for this peer (plain string, already owned by caller)
- `peer_name`: Shared peer name (locked, read to clone)
- `light_state`: Shared light state (locked, read to clone)
- `note`: Shared optional note (locked, read to clone)
- `my_notification_status`: Shared notification status (locked, read to clone)

**Returns:** `PresenceMessage::Online` variant with all fields populated

**Behavior:**

1. Acquires read locks on all shared state (parallel reads possible)
2. Clones all values from locked state
3. Generates current timestamp
4. Constructs PresenceMessage::Online with cloned values
5. Boxes notification_status as per protocol requirement
6. Releases all locks automatically (RAII)

**Lock Ordering:**

- Acquires locks in parameter order (arbitrary but consistent)
- No risk of deadlock (all read locks, acquired once)
- Locks held briefly (only for cloning)

**Example:**

```rust
let msg = create_online_message(
    "peer-123",
    &peer_name,
    &light_state,
    &note,
    &notif_status,
).await;

// msg is PresenceMessage::Online with current state snapshot
match msg {
    PresenceMessage::Online { peer_id, peer_name, light_state, .. } => {
        println!("Peer {} ({}) is {}", peer_id, peer_name, light_state);
    }
    _ => unreachable!(),
}
```

**Performance:**

- Time complexity: O(1) - fixed number of lock acquisitions and clones
- Space complexity: O(1) - allocates single message
- Lock contention: Low (read locks, brief duration)

---

### Peer Map Management

#### `add_or_update_peer`

```rust
pub async fn add_or_update_peer(
    peers: &Arc<RwLock<HashMap<String, PeerPresence>>>,
    peer_id: String,
    peer_name: String,
    light_state: LightState,
    note: Option<String>,
    _timestamp: u64,
    notification_status: Option<Notification>,
) -> ()
```

Adds a new peer or updates an existing peer in the presence map.

**Parameters:**

- `peers`: Shared peer presence map (write lock required)
- `peer_id`: Unique peer identifier (owned, will be cloned)
- `peer_name`: Peer display name (owned)
- `light_state`: Current light state (owned)
- `note`: Optional status note (owned)
- `_timestamp`: Unused parameter (kept for API compatibility)
- `notification_status`: Optional notification preference (owned)

**Returns:** Unit `()` (operation always succeeds)

**Behavior:**

1. Acquires write lock on peers map (exclusive access)
2. Checks if peer_id already exists (for logging purposes)
3. Generates current timestamp for `last_seen`
4. Inserts or overwrites PeerPresence entry
5. Logs info for new peers, debug for updates
6. Releases write lock automatically

**Side Effects:**

- Modifies shared peers HashMap
- Logs to info/debug channels
- Updates `last_seen` to current time (ignores incoming timestamp)

**Key Design Decision:**

- **Ignores `_timestamp` parameter:** Uses `current_timestamp()` instead
- Rationale: `last_seen` represents "last time we processed update", not "time peer sent message"
- This provides accurate local timeout detection

**Idempotency:** Safe to call multiple times with same peer_id (overwrites)

**Example:**

```rust
add_or_update_peer(
    &peers_map,
    "peer-456".to_string(),
    "Alice".to_string(),
    LightState::Green,
    Some("In a meeting".to_string()),
    1234567890, // Ignored
    Some(Notification::All),
).await;

// Peer is now in map with current timestamp
```

**Logging:**

```
[PRESENCE] Added new peer: peer-456 (Alice)           // First call
[PRESENCE] Updated existing peer: peer-456 (Alice)    // Subsequent calls
```

---

#### `remove_peer`

```rust
pub async fn remove_peer(
    peers: &Arc<RwLock<HashMap<String, PeerPresence>>>,
    peer_id: &str,
) -> ()
```

Removes a peer from the presence map.

**Parameters:**

- `peers`: Shared peer presence map (write lock required)
- `peer_id`: Unique peer identifier to remove (borrowed)

**Returns:** Unit `()` (operation always succeeds)

**Behavior:**

1. Acquires write lock on peers map (exclusive access)
2. Removes entry by peer_id (no-op if not present)
3. Releases write lock automatically

**Idempotency:** Safe to call on non-existent peer (HashMap::remove is idempotent)

**No Logging:** Silent operation (caller logs if needed)

**Example:**

```rust
// Peer goes offline
remove_peer(&peers_map, "peer-456").await;

// Safe to call again (no error)
remove_peer(&peers_map, "peer-456").await;
```

**Use Cases:**

- Processing PresenceMessage::Offline
- Timeout-based peer eviction
- Graceful disconnection cleanup

## Data Structures

### PeerPresence (from presence_service)

```rust
pub struct PeerPresence {
    pub peer_id: String,
    pub peer_name: String,
    pub light_state: LightState,
    pub note: Option<String>,
    pub last_seen: u64,
    pub notification_status: Option<Notification>,
}
```

**Fields:**

- `peer_id`: Unique identifier (used as HashMap key)
- `peer_name`: Display name for UI
- `light_state`: Current availability status (Red/Yellow/Green)
- `note`: Optional status message
- `last_seen`: Timestamp of last update (milliseconds since epoch)
- `notification_status`: Notification preferences (All, Mentions, None)

### PresenceMessage (from protocol)

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
    Offline {
        peer_id: String,
        timestamp: u64,
    },
}
```

## Concurrency and Thread Safety

### Locking Strategy

**Read Locks (create_online_message):**

- Multiple readers can acquire simultaneously
- No blocking between read operations
- Brief lock duration (clone operations only)
- No deadlock risk (read-only, single acquisition per lock)

**Write Locks (add_or_update_peer, remove_peer):**

- Exclusive access to peers HashMap
- Blocks all readers and other writers
- Brief lock duration (single HashMap operation)
- No nested locks (single lock per function)

### Lock Contention

**Low Contention Scenarios:**

- Infrequent presence updates (seconds to minutes apart)
- Fast operations under lock (nanoseconds to microseconds)
- Read-heavy workload (many reads, few writes)

**High Contention Scenarios:**

- Peer storm (many peers joining/leaving simultaneously)
- Rapid presence updates (multiple per second)
- Large peer name strings (slower clone operations)

**Mitigation:**

- Operations are optimized (single HashMap operation)
- No I/O under lock (logging is buffered)
- No complex computation under lock

### Data Races

**No Data Races:**

- All shared state protected by RwLock
- No raw pointer access
- No unsafe code
- Rust guarantees memory safety

**Coordination:**

- RwLock ensures happens-before relationship
- Writers see effects of previous writers
- Readers see consistent snapshot

## Performance Considerations

### Time Complexity

- `create_online_message`: O(1) - fixed number of clones
- `add_or_update_peer`: O(1) - HashMap insert/update
- `remove_peer`: O(1) - HashMap remove

### Space Complexity

- `create_online_message`: O(1) - single message allocation
- `add_or_update_peer`: O(1) - single PeerPresence entry
- `remove_peer`: O(1) - deallocation only

### Memory Allocation

**create_online_message:**

- Allocates: String clones (peer_name, note), LightState clone, Notification clone, message struct
- Typical size: 100-500 bytes per message

**add_or_update_peer:**

- Allocates: PeerPresence struct, String keys/values
- Typical size: 200-800 bytes per peer
- Memory growth: O(n) with peer count

**remove_peer:**

- Deallocates: PeerPresence entry and all owned data
- No fragmentation concerns (Rust allocator handles it)

### Optimization Opportunities

**Current Implementation:**

- HashMap has good average-case performance
- RwLock is efficient for read-heavy workloads
- Cloning is necessary for message passing

**Potential Improvements:**

- Use `Arc<String>` for peer_name to avoid clones (trade-off: extra indirection)
- Pre-allocate HashMap capacity if peer count is known
- Use `DashMap` for lock-free concurrent access (trade-off: more complex, not always faster)

## Usage Patterns

### Pattern 1: Broadcasting Presence (PresenceService)

```rust
// In PresenceService
pub async fn broadcast_my_presence(&self) {
    let msg = create_online_message(
        &self.my_peer_id,
        &self.peer_name,
        &self.my_light_state,
        &self.note,
        &self.my_notification_status,
    ).await;

    // Send msg to all peers via network
}
```

### Pattern 2: Processing Incoming Presence (PresenceService)

```rust
// In PresenceService::handle_presence_message
pub async fn handle_presence_message(&self, msg: PresenceMessage) {
    match msg {
        PresenceMessage::Online { peer_id, peer_name, light_state, note, notification_status, .. } => {
            add_or_update_peer(
                &self.peers,
                peer_id,
                peer_name,
                light_state,
                note,
                0, // Ignored
                *notification_status,
            ).await;
        }
        PresenceMessage::Offline { peer_id, .. } => {
            remove_peer(&self.peers, &peer_id).await;
        }
    }
}
```

### Pattern 3: Timeout-Based Cleanup (PresenceService)

```rust
// In PresenceService timeout handler
pub async fn remove_stale_peers(&self, timeout_ms: u64) {
    let now = current_timestamp();
    let mut peers_to_remove = Vec::new();

    {
        let peers = self.peers.read().await;
        for (peer_id, presence) in peers.iter() {
            if now - presence.last_seen > timeout_ms {
                peers_to_remove.push(peer_id.clone());
            }
        }
    } // Release read lock

    for peer_id in peers_to_remove {
        remove_peer(&self.peers, &peer_id).await;
        log::info!("Removed stale peer: {}", peer_id);
    }
}
```

## Error Handling

**No Errors Returned:**

- All functions return `()` or `PresenceMessage` (never `Result`)
- Operations cannot fail (HashMap operations are infallible)
- Logging errors go to log system (not propagated)

**Rationale:**

- Presence updates are best-effort (failures are tolerable)
- No I/O or fallible operations
- Simpler API for callers (no error handling needed)

## Integration Points

### Upstream Dependencies

**1. PresenceService** (`src-tauri/src/services/presence_service.rs`)

- Calls all three helper functions
- Provides shared state references (RwLock-wrapped data)
- Owns the peer HashMap

**2. Protocol Layer** (`src-tauri/src/protocol/messages.rs`)

- PresenceMessage: Constructed by create_online_message
- LightState, Notification: Used in PeerPresence

**3. Utilities** (`src-tauri/src/utils.rs`)

- current_timestamp(): Used for last_seen and message timestamps

### Downstream Consumers

**Primary Consumer:** PresenceService only

- Not exposed outside services module
- Internal helpers (not pub at crate level)

**Usage Sites:**

- Broadcasting presence updates
- Processing incoming presence messages
- Timeout-based peer eviction
- Responding to state queries

## Test Coverage

**Current Status:** No dedicated tests for presence_helpers

**Rationale:**

- Simple pass-through functions
- Tested indirectly via PresenceService tests (7 tests in PresenceService)
- No complex logic requiring isolated testing

**What Would Be Tested (if tests existed):**

**Unit Tests (Potential):**

1. `create_online_message` constructs correct message
2. `add_or_update_peer` inserts new peer correctly
3. `add_or_update_peer` updates existing peer
4. `add_or_update_peer` updates last_seen timestamp
5. `remove_peer` removes existing peer
6. `remove_peer` is idempotent (no error on missing peer)
7. Concurrent add/remove operations don't deadlock

**Current Test Coverage (via PresenceService tests):**

- ✅ Integration with PresenceService
- ✅ Message construction with real state
- ✅ Peer map updates during message handling
- ✅ Concurrent access patterns

**Testing Recommendation:**

- Current indirect testing is sufficient
- Add unit tests only if bugs are discovered
- Focus test effort on PresenceService (higher value)

## Security Considerations

### Trust Model

**Assumption:** Callers are trusted (internal module)

- No validation of peer_id format
- No validation of peer_name content
- No rate limiting or abuse prevention
- Caller's responsibility to sanitize inputs

### Threats

**1. Memory Exhaustion (Peer Flooding)**

- **Attack:** Add millions of fake peers
- **Impact:** Uncontrolled HashMap growth, OOM crash
- **Mitigation:** PresenceService should enforce peer limit (not helpers' responsibility)
- **Severity:** High (DoS)

**2. Large String Allocation**

- **Attack:** Extremely long peer_name or note strings
- **Impact:** Memory exhaustion, slow cloning
- **Mitigation:** PresenceService should validate lengths (not helpers' responsibility)
- **Severity:** Medium (DoS)

**3. Lock Contention DoS**

- **Attack:** Rapid add/remove operations to block readers
- **Impact:** Presence updates delayed, UI freezes
- **Mitigation:** Rate limiting in PresenceService
- **Severity:** Low (temporary)

**4. Timestamp Manipulation**

- **Attack:** Ignored (timestamp parameter unused)
- **Impact:** None (we use local clock for last_seen)
- **Severity:** None

### Defensive Programming

**Current Protections:**

- Uses local timestamp (ignores external timestamp)
- No unsafe code or raw pointers
- No panic-inducing operations (HashMap methods are safe)

**Recommendations:**

- Add peer count limit in PresenceService
- Add string length limits in PresenceService
- Consider logging peer_id in remove_peer for auditability

## Future Improvements

### High Priority

**1. Add Observability**

- Add metrics: peer_add_count, peer_remove_count, peer_update_count
- Track lock acquisition times
- Monitor HashMap size

**2. Optimize for Large Peer Counts**

- Pre-allocate HashMap capacity based on expected peer count
- Consider DashMap for lock-free concurrent access (if profiling shows contention)

### Medium Priority

**3. Add Unit Tests**

- Test concurrent add/remove operations
- Verify last_seen timestamp behavior
- Test idempotency guarantees

**4. Add Validation Hooks**

- Optional callback for peer_name validation
- Optional callback for peer count limits
- Keep helpers pure but allow PresenceService to inject policy

### Low Priority

**5. Use Arc<String> for peer_name**

- Avoid cloning in create_online_message
- Trade-off: Extra indirection, more complex ownership
- Only beneficial if peer_name is large or cloned frequently

**6. Add Structured Logging**

- Use tracing instead of log for better context
- Include peer_id in log spans
- Add counters for new vs updated peers

**7. Support Custom Timestamp Sources**

- Allow injecting timestamp function (for testing)
- Keep default as current_timestamp()
- Enables deterministic testing

## Related Documentation

### Specifications

- **PresenceService:** `spec/backend/services/presence-service.md` - Primary consumer of these helpers
- **ChatService:** `spec/backend/services/chat-service.md` - Similar helper pattern (chat_db.rs)

### Implementation Files

- **Presence Helpers:** `src-tauri/src/services/presence_helpers.rs` (73 lines)
- **PresenceService:** `src-tauri/src/services/presence_service.rs` - Calls these helpers
- **Protocol Messages:** `src-tauri/src/protocol/messages.rs` - PresenceMessage and related types

### Design Resources

- **RwLock Documentation:** https://docs.rs/tokio/latest/tokio/sync/struct.RwLock.html
- **HashMap Performance:** https://doc.rust-lang.org/std/collections/struct.HashMap.html
- **Presence Protocols:** XMPP Presence, WebRTC presence signaling
