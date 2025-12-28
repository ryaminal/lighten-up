# ConfigService Specification

## Overview

The ConfigService provides distributed light configuration management with conflict-free replication using Last-Write-Wins (LWW) semantics. It handles CRUD operations on light configurations, processes incoming configuration messages from peers, and ensures eventual consistency across the distributed system.

**Location:** `src-tauri/src/services/config_service.rs` and `src-tauri/src/services/config_handlers.rs`

**Responsibilities:**

- Create, update, delete, and retrieve light configurations
- Apply Last-Write-Wins conflict resolution for concurrent updates
- Generate ConfigMessage events for network broadcast
- Process incoming configuration messages from remote peers
- Handle full configuration sync requests
- Maintain eventual consistency without coordination

## Architecture

### Design Pattern

**CRDT (Conflict-free Replicated Data Type) with LWW (Last-Write-Wins)**

- Uses timestamps to resolve conflicts deterministically
- No coordination required between peers
- Eventual consistency guarantee
- Simple but effective for light configuration use case

**Service Layer Pattern**

- Encapsulates business logic for configuration management
- Separates CRDT logic (`config_handlers.rs`) from service orchestration (`config_service.rs`)
- Delegates database operations to the Database layer
- Returns domain messages for network propagation

### Dependencies

```rust
ConfigService
    ├── Database (Arc<Database>) - Persistence layer
    ├── database::queries - CRUD operations
    ├── protocol::messages::{ConfigMessage, ConfigOp, LightConfig}
    ├── domain::{AppError, DomainResult}
    ├── config_handlers::{apply_upsert_with_lww, apply_delete_if_newer}
    └── utils::current_timestamp - Clock for timestamps
```

### Module Structure

**config_service.rs**: High-level service API

- Local operations: get_all_lights, upsert_light, delete_light
- Network operations: handle_config_message, get_all_config_messages
- Message construction and peer ID management

**config_handlers.rs**: CRDT implementation

- apply_upsert_with_lww: Last-write-wins upsert logic
- apply_delete_if_newer: Conditional delete logic
- Pure functions for testability

## Data Structures

### ConfigService

```rust
pub struct ConfigService {
    db: Arc<Database>,
    my_peer_id: String,
}
```

**Fields:**

- `db`: Shared database connection (thread-safe via Arc)
- `my_peer_id`: Unique identifier for this peer (used in message attribution)

### LightConfig (from protocol)

```rust
pub struct LightConfig {
    pub id: String,           // Unique light identifier
    pub color: String,        // Color value (e.g., "red", "#FF0000")
    pub name: String,         // Human-readable name
    pub enabled: bool,        // Whether light is active
    pub priority: i32,        // Display priority
    pub updated_at: u64,      // Last update timestamp (milliseconds)
    pub updated_by: String,   // Peer ID that last modified this config
}
```

### ConfigMessage (from protocol)

```rust
pub struct ConfigMessage {
    pub op: ConfigOp,
    pub peer_id: String,
    pub timestamp: u64,
}

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
        requester_peer_id: String,
    },
}
```

## Public API

### Constructor

#### `new(db: Arc<Database>, my_peer_id: String) -> Self`

Creates a new ConfigService instance.

**Parameters:**

- `db`: Shared database connection
- `my_peer_id`: Unique identifier for this peer

**Returns:** ConfigService instance

**Example:**

```rust
let db = Arc::new(Database::new(db_path)?);
let my_peer_id = "peer-123".to_string();
let service = ConfigService::new(db, my_peer_id);
```

---

### Local Operations

#### `async fn get_all_lights(&self) -> Result<Vec<LightConfig>>`

Retrieves all light configurations from the database.

**Returns:**

- `Ok(Vec<LightConfig>)`: All stored light configurations
- `Err(AppError)`: Database query failure

**Behavior:**

- Queries database for all lights
- Logs fetch operation
- Returns empty vector if no lights exist

**Example:**

```rust
let lights = service.get_all_lights().await?;
for light in lights {
    println!("Light {}: {} ({})", light.id, light.name, light.color);
}
```

---

#### `async fn upsert_light(&self, mut light: LightConfig) -> Result<ConfigMessage>`

Creates or updates a light configuration locally and returns a message for broadcast.

**Parameters:**

- `light`: Light configuration to upsert (mutated with timestamp and peer ID)

**Returns:**

- `Ok(ConfigMessage)`: Message to broadcast to peers
- `Err(AppError)`: Database operation failure

**Behavior:**

1. Sets `updated_at` to current timestamp
2. Sets `updated_by` to `my_peer_id`
3. Persists to database
4. Constructs ConfigMessage with Upsert operation
5. Returns message for network broadcast

**Side Effects:**

- Modifies database state
- Mutates input `light` (timestamp and peer ID)

**Example:**

```rust
let light = LightConfig {
    id: "light-1".to_string(),
    color: "red".to_string(),
    name: "Conference Room".to_string(),
    enabled: true,
    priority: 1,
    updated_at: 0,  // Will be set by service
    updated_by: String::new(),  // Will be set by service
};

let msg = service.upsert_light(light).await?;
// Broadcast msg to network
```

---

#### `async fn delete_light(&self, id: String) -> Result<ConfigMessage>`

Deletes a light configuration locally and returns a message for broadcast.

**Parameters:**

- `id`: Unique identifier of the light to delete

**Returns:**

- `Ok(ConfigMessage)`: Message to broadcast to peers
- `Err(AppError)`: Database operation failure

**Behavior:**

1. Deletes light from database
2. Constructs ConfigMessage with Delete operation
3. Includes current timestamp as `deleted_at`
4. Returns message for network broadcast

**Notes:**

- No error if light doesn't exist (idempotent)
- Deletion is immediate; tombstone only exists in message

**Example:**

```rust
let msg = service.delete_light("light-1".to_string()).await?;
// Broadcast msg to network
```

---

### Network Operations

#### `async fn handle_config_message(&self, msg: ConfigMessage) -> Result<bool>`

Processes an incoming configuration message from a remote peer.

**Parameters:**

- `msg`: Configuration message received from network

**Returns:**

- `Ok(true)`: Sync response is needed (RequestSync received)
- `Ok(false)`: Message processed successfully, no response needed
- `Err(AppError)`: Processing failure

**Behavior:**

**For Upsert operations:**

1. Calls `apply_upsert_with_lww` with message fields
2. Applies LWW conflict resolution
3. Returns `Ok(false)`

**For Delete operations:**

1. Calls `apply_delete_if_newer` with ID and timestamp
2. Applies conditional deletion
3. Returns `Ok(false)`

**For RequestSync operations:**

1. Returns `Ok(true)` immediately
2. Caller should respond with `get_all_config_messages()`

**Example:**

```rust
let msg = receive_message_from_network();
let needs_sync = service.handle_config_message(msg).await?;
if needs_sync {
    let all_configs = service.get_all_config_messages().await?;
    send_to_network(all_configs);
}
```

---

#### `async fn get_all_config_messages(&self) -> Result<Vec<ConfigMessage>>`

Converts all stored light configurations into ConfigMessages for sync response.

**Returns:**

- `Ok(Vec<ConfigMessage>)`: All lights as Upsert messages
- `Err(AppError)`: Database query failure

**Behavior:**

1. Fetches all lights from database
2. Converts each to ConfigMessage with Upsert operation
3. Sets `peer_id` to `my_peer_id`
4. Sets `timestamp` to current time (message creation time)

**Use Cases:**

- Responding to RequestSync from new peer
- Full state synchronization during reconnection

**Example:**

```rust
let sync_messages = service.get_all_config_messages().await?;
for msg in sync_messages {
    send_to_peer(peer_id, msg);
}
```

---

## CRDT Handler Functions (Internal)

### `apply_upsert_with_lww`

```rust
pub(crate) async fn apply_upsert_with_lww(
    db: &Arc<Database>,
    id: String,
    color: String,
    name: String,
    enabled: bool,
    priority: i32,
    updated_at: u64,
    updated_by: String,
) -> Result<()>
```

Applies a light configuration update using Last-Write-Wins semantics.

**Conflict Resolution Logic:**

```
IF no existing light with this ID:
    CREATE light with incoming data
ELSE IF incoming.updated_at >= existing.updated_at:
    UPDATE light with incoming data
ELSE:
    IGNORE incoming data (older)
```

**Parameters:**

- `db`: Database reference
- All LightConfig fields individually

**Returns:**

- `Ok(())`: Update applied or safely ignored
- `Err(AppError)`: Database operation failure

**Behavior:**

1. Fetches all lights from database (finds existing by ID)
2. Determines if update should apply:
   - New light: Always apply
   - Existing light: Apply if `incoming.updated_at >= existing.updated_at`
3. If should apply: Constructs LightConfig and upserts to database
4. If should not apply: No-op (returns Ok)

**Examples:**

**Creating new light:**

```rust
apply_upsert_with_lww(
    &db,
    "light-1".into(),
    "red".into(),
    "Room 1".into(),
    true,
    1,
    1000,
    "peer-1".into()
).await?;
// Light created with timestamp 1000
```

**Updating with newer timestamp:**

```rust
// Existing: updated_at = 1000
apply_upsert_with_lww(
    &db,
    "light-1".into(),
    "blue".into(),
    "Room 1 Updated".into(),
    false,
    2,
    2000,
    "peer-2".into()
).await?;
// Light updated to blue with timestamp 2000
```

**Ignoring older timestamp:**

```rust
// Existing: updated_at = 2000
apply_upsert_with_lww(
    &db,
    "light-1".into(),
    "green".into(),
    "Room 1 Old".into(),
    true,
    1,
    1000,
    "peer-3".into()
).await?;
// Light unchanged (1000 < 2000)
```

---

### `apply_delete_if_newer`

```rust
pub(crate) async fn apply_delete_if_newer(
    db: &Arc<Database>,
    id: &str,
    deleted_at: u64,
) -> Result<()>
```

Deletes a light if the deletion timestamp is newer than or equal to the existing light's timestamp.

**Conflict Resolution Logic:**

```
IF no existing light with this ID:
    IGNORE (no-op)
ELSE IF deleted_at >= existing.updated_at:
    DELETE light
ELSE:
    IGNORE (delete is older than current state)
```

**Parameters:**

- `db`: Database reference
- `id`: Light identifier
- `deleted_at`: Deletion timestamp

**Returns:**

- `Ok(())`: Delete applied or safely ignored
- `Err(AppError)`: Database operation failure

**Behavior:**

1. Fetches all lights from database (finds existing by ID)
2. Determines if delete should apply:
   - No existing light: Ignore (no-op)
   - Existing light: Apply if `deleted_at >= existing.updated_at`
3. If should delete: Removes light from database
4. If should not delete: No-op (returns Ok)

**Examples:**

**Deleting with newer timestamp:**

```rust
// Existing: updated_at = 1000
apply_delete_if_newer(&db, "light-1", 2000).await?;
// Light deleted (2000 >= 1000)
```

**Ignoring older delete:**

```rust
// Existing: updated_at = 2000
apply_delete_if_newer(&db, "light-1", 1000).await?;
// Light preserved (1000 < 2000)
```

**Ignoring nonexistent light:**

```rust
apply_delete_if_newer(&db, "nonexistent", 1000).await?;
// No error, no-op
```

---

## Business Rules

### Last-Write-Wins (LWW) Semantics

**Core Principle:** The operation with the highest timestamp wins conflicts.

**Rules:**

1. **Newer Always Wins:** If `incoming.updated_at > existing.updated_at`, apply incoming
2. **Equal Timestamps Win:** If `incoming.updated_at == existing.updated_at`, apply incoming (bias toward acceptance)
3. **Older Ignored:** If `incoming.updated_at < existing.updated_at`, ignore incoming
4. **No Existing Always Applies:** New lights are always created

**Rationale for Equal Timestamp Handling:**

- Network messages may arrive out of order
- Multiple peers may update at same millisecond
- Bias toward accepting updates ensures convergence
- In practice, ties are rare with millisecond precision

### Timestamp Management

**Source:** `utils::current_timestamp()`

- Millisecond precision (Unix epoch)
- Must be monotonically increasing per peer
- Clock skew between peers is tolerated (LWW handles it)

**Responsibility:**

- Local operations: ConfigService sets `updated_at`
- Remote operations: Uses timestamp from incoming message

### Delete vs Update Conflicts

**Scenario 1: Delete Newer Than Update**

```
Time: 1000 - Create light
Time: 2000 - Delete light
Time: 1500 (late arrival) - Update light
Result: Light remains deleted (2000 > 1500)
```

**Scenario 2: Update Newer Than Delete**

```
Time: 1000 - Create light
Time: 1500 - Delete light
Time: 2000 (late arrival) - Update light
Result: Light is recreated (2000 > 1500)
```

**Known Limitation: Tombstone Problem**

```
Time: 1000 - Create light
Time: 2000 - Delete light (deleted from DB, no tombstone)
Time: 1500 (late arrival) - Update light
Result: Light is recreated (no tombstone to prevent resurrection)
```

See Test `delete_vs_update_older_update_resurrects_after_delete` for details.

### Conflict Resolution Examples

**Example 1: Concurrent Updates**

```
Peer A (timestamp 1500): Set light to "blue"
Peer B (timestamp 1200): Set light to "green"
Peer C (timestamp 2000): Set light to "yellow"

Processing order (may vary per node):
1. Peer B's "green" (1200) - applied first
2. Peer A's "blue" (1500) - overwrites green
3. Peer C's "yellow" (2000) - overwrites blue

Final state: "yellow" (highest timestamp)
```

**Example 2: Multiple Lights Independence**

```
Light-1 (timestamp 1000): "red"
Light-2 (timestamp 2000): "blue"

Incoming: Light-1 update (timestamp 500)
Result: Light-1 stays "red", Light-2 unaffected
```

## Concurrency and Thread Safety

### Thread Safety

**ConfigService:**

- Not thread-safe itself (no internal synchronization)
- Relies on `Arc<Database>` for safe shared access
- Typically wrapped in `Arc<ConfigService>` at AppState level
- All methods use `&self` (shared reference)

**Database Access:**

- `Arc<Database>` provides thread-safe shared ownership
- SQLite connection managed by Database layer
- Read-write operations serialized by rusqlite's internal locking

### Async Operations

**All operations are async:** Allows integration with Tokio runtime

- Database operations: Blocking I/O (wrapped in async context)
- No CPU-intensive work (conflict resolution is simple comparison)

**Concurrency Model:**

- Multiple async tasks can call ConfigService concurrently
- Database layer serializes actual writes
- Read operations can proceed concurrently (SQLite behavior)

### Race Conditions

**Scenario: Concurrent Local Updates**

```rust
// Two tasks updating same light concurrently
tokio::spawn(async move {
    service.upsert_light(light_with_color_red).await
});
tokio::spawn(async move {
    service.upsert_light(light_with_color_blue).await
});
```

**Result:** Both updates succeed; higher timestamp wins in DB

- Both get same or similar timestamp (millisecond precision)
- Database layer serializes writes
- Final state depends on database write order
- Both generate ConfigMessages (peers will converge using LWW)

**Mitigation:** Application-level coordination if needed (not in ConfigService)

## Error Handling

### Error Types

```rust
pub enum AppError {
    Other(anyhow::Error),
    // Other variants...
}
```

**All errors wrapped as:** `AppError::Other(anyhow::Error)`

### Error Sources

**Database Query Failures:**

- Connection issues
- SQL execution errors
- Constraint violations

**Error Conversion:**

```rust
crate::database::queries::get_all_lights(&conn)
    .map_err(|e| AppError::Other(anyhow::anyhow!("Failed to get lights: {}", e)))
```

### Error Handling Strategy

**At ConfigService Level:**

- Propagate database errors immediately
- No retry logic (caller's responsibility)
- Log info messages before operations

**At Handler Level:**

- Convert errors using `.map_err(|e| AppError::Other(e.into()))`
- No recovery attempts
- Errors prevent state mutation (atomic operations)

### No Partial Failures

**Atomic Operations:**

- Each operation is single database transaction
- Success or complete rollback
- No partial state changes

## Test Coverage

### Overview

**Total Tests:** 12 (all in `config_handlers` module)
**Test File:** `src-tauri/src/services/config_handlers.rs` lines 72-514
**Framework:** tokio::test with temporary SQLite database

### Test Setup

```rust
fn setup_test_db() -> Arc<Database> {
    let temp_dir = TempDir::new().expect("Failed to create temp dir");
    let db_path = temp_dir.path().join("test.db");
    let db = Database::new(db_path).expect("Failed to create database");
    std::mem::forget(temp_dir);  // Prevent cleanup during test
    Arc::new(db)
}
```

### Test Categories

#### 1. Basic Upsert Operations (2 tests)

**`apply_upsert_creates_new_light`**

- Creates new light with all fields
- Verifies all fields persisted correctly
- Validates timestamp and peer ID attribution

**`apply_upsert_updates_existing_light_with_newer_timestamp`**

- Creates light, then updates with newer timestamp
- Verifies all fields updated
- Confirms newer timestamp overwrites older

#### 2. Timestamp Conflict Resolution (2 tests)

**`apply_upsert_updates_with_equal_timestamp`**

- Creates light, then updates with equal timestamp
- Verifies update is applied (bias toward acceptance)
- Tests edge case of simultaneous updates

**`apply_upsert_ignores_older_timestamp`**

- Creates light, then attempts update with older timestamp
- Verifies original state preserved
- Confirms LWW rejects stale updates

#### 3. Basic Delete Operations (3 tests)

**`apply_delete_removes_light_with_newer_timestamp`**

- Creates light, then deletes with newer timestamp
- Verifies light removed from database

**`apply_delete_removes_light_with_equal_timestamp`**

- Creates light, then deletes with equal timestamp
- Verifies delete succeeds (bias toward acceptance)

**`apply_delete_ignores_older_timestamp`**

- Creates light, then attempts delete with older timestamp
- Verifies light preserved

#### 4. Edge Cases (2 tests)

**`apply_delete_ignores_nonexistent_light`**

- Attempts to delete non-existent light
- Verifies no error (idempotent operation)

**`delete_vs_update_older_update_resurrects_after_delete`**

- Documents known tombstone limitation
- Deletes light, then applies older update
- Verifies light is resurrected (undesired but accepted)
- Includes detailed comment explaining limitation

#### 5. Complex Scenarios (3 tests)

**`concurrent_updates_last_write_wins`**

- Creates light with timestamp 1000
- Applies updates with timestamps: 1500, 1200, 2000
- Verifies final state has highest timestamp (2000)
- Tests out-of-order message delivery

**`delete_vs_update_update_wins_with_newer_timestamp`**

- Creates light, deletes, then updates with newer timestamp
- Verifies light is recreated (update timestamp > delete timestamp)
- Tests resurrection with valid ordering

**`multiple_lights_independent_timestamps`**

- Creates two lights with different timestamps
- Applies old update to first light
- Verifies first light unchanged, second light unaffected
- Tests per-light timestamp independence

### Test Coverage Analysis

**What's Tested:**

- ✅ Create operations
- ✅ Update operations with all timestamp orderings
- ✅ Delete operations with all timestamp orderings
- ✅ Edge cases (nonexistent lights, equal timestamps)
- ✅ Out-of-order message delivery
- ✅ Multiple lights independence
- ✅ Known limitations (tombstone problem)

**What's Not Tested:**

- ❌ ConfigService high-level methods (upsert_light, delete_light, handle_config_message)
- ❌ Message construction and field mapping
- ❌ RequestSync handling
- ❌ get_all_config_messages conversion logic
- ❌ Error conditions (database failures, invalid data)
- ❌ Concurrent access from multiple threads
- ❌ Clock skew scenarios with extreme time differences

**Test Quality:**

- Tests are focused and isolated
- Good use of descriptive names
- Known limitations documented in test comments
- Uses realistic timestamps and data
- No mocking (integration tests with real database)

### Running Tests

```bash
# Run all config handler tests
cd src-tauri && cargo test config_handlers

# Run specific test
cd src-tauri && cargo test apply_upsert_creates_new_light

# Run with output
cd src-tauri && cargo test config_handlers -- --nocapture
```

## Performance Considerations

### Time Complexity

**Local Operations:**

- `get_all_lights`: O(n) - full table scan
- `upsert_light`: O(1) - single INSERT/UPDATE
- `delete_light`: O(1) - single DELETE

**Remote Operations:**

- `handle_config_message` with Upsert: O(n) - fetches all lights to find existing
- `handle_config_message` with Delete: O(n) - fetches all lights to compare timestamp
- `get_all_config_messages`: O(n) - fetch and convert all lights

### Space Complexity

**Memory:**

- `get_all_lights`: O(n) - loads all configs into memory
- `get_all_config_messages`: O(n) - duplicates all configs as messages
- Per-light storage: ~200-300 bytes (strings + metadata)

**Database:**

- No indexes on `updated_at` (could improve conflict checks)
- No tombstones (known limitation)

### Bottlenecks

**1. O(n) Conflict Resolution**

- Current implementation: Fetch all lights, search for ID
- Better: Direct query for specific light ID
- Impact: Significant with large light counts (>1000)

**Example Improvement:**

```rust
// Current (O(n)):
let all_lights = get_all_lights(&conn)?;
let existing = all_lights.into_iter().find(|l| l.id == id);

// Better (O(1)):
let existing = queries::get_light_by_id(&conn, &id)?;
```

**2. No Bulk Operations**

- Processing multiple messages requires multiple O(n) operations
- Sync with 100 messages = 100 full table scans

**3. Database Layer**

- SQLite serializes writes (no concurrent updates)
- Read operations can block on writes
- No connection pooling (single connection)

### Optimization Opportunities

**Short Term:**

1. Add `get_light_by_id` query to avoid full scans
2. Add index on `id` column (if not already primary key)
3. Batch processing for sync operations

**Long Term:**

1. Implement tombstones for correct delete semantics
2. Add TTL for tombstone cleanup
3. Use prepared statements for repeated queries
4. Consider PostgreSQL for better concurrent write performance

### Scalability Limits

**Light Configuration Count:**

- Practical limit: ~10,000 lights (current implementation)
- Performance degradation beyond 1,000 lights
- Memory usage: ~3MB per 10,000 lights

**Message Throughput:**

- Current: ~100-1000 messages/second (depends on light count)
- Bottleneck: Per-message full table scan

**Peer Count:**

- No direct impact on ConfigService performance
- Higher peer count = more messages = more conflict resolution

## Security Considerations

### Trust Model

**Assumption:** All peers are trusted

- No authentication of `peer_id`
- No validation of `updated_by` field
- Any peer can modify any light configuration
- No peer-specific permissions

### Threats

**1. Timestamp Manipulation**

- **Attack:** Malicious peer sends future timestamp
- **Impact:** Locks out legitimate updates until clock catches up
- **Mitigation:** None currently; consider timestamp bounds checking
- **Severity:** Medium (requires compromised peer)

**Example Attack:**

```rust
// Attacker sends update with year 2100 timestamp
apply_upsert_with_lww(
    &db,
    "light-1".into(),
    "malicious".into(),
    "Locked".into(),
    false,
    0,
    4102444800000,  // Jan 1, 2100
    "attacker".into()
).await?;
// All legitimate updates ignored until 2100
```

**2. Configuration Spam**

- **Attack:** Create thousands of fake lights
- **Impact:** Performance degradation, memory exhaustion
- **Mitigation:** None currently; consider rate limiting
- **Severity:** Low (requires sustained attack)

**3. Deletion Attack**

- **Attack:** Delete all lights with future timestamp
- **Impact:** Prevents light creation until clock catches up
- **Mitigation:** None currently; consider tombstone limits
- **Severity:** Medium (easily detectable but disruptive)

**4. Peer ID Spoofing**

- **Attack:** Use another peer's ID in `updated_by`
- **Impact:** Attribution confusion (cosmetic)
- **Mitigation:** None currently; requires network-layer authentication
- **Severity:** Low (no functional impact)

### Data Validation

**Current State:** Minimal validation

- No validation on color format
- No validation on name length
- No validation on priority range
- No validation on ID format

**Risks:**

- SQL injection: Mitigated by parameterized queries
- XSS: Frontend responsibility
- Data corruption: Possible with invalid values

### Recommendations

**High Priority:**

1. Add timestamp bounds checking (e.g., ±1 year from current time)
2. Validate light configuration fields (max lengths, format)
3. Implement tombstones with TTL

**Medium Priority:**

1. Add peer authentication at network layer
2. Rate limiting on configuration changes per peer
3. Maximum light count enforcement

**Low Priority:**

1. Audit logging of configuration changes
2. Cryptographic signatures on ConfigMessages
3. Peer reputation system

## Integration Points

### Upstream Dependencies

**1. Database Layer** (`src-tauri/src/database/`)

- `Database::new()`: Initialization
- `Database::connection()`: Access to rusqlite connection
- `queries::get_all_lights()`: Fetch all lights
- `queries::upsert_light()`: Create/update light
- `queries::delete_light()`: Remove light

**2. Protocol Layer** (`src-tauri/src/protocol/messages.rs`)

- `LightConfig`: Data structure for light configurations
- `ConfigMessage`: Network message envelope
- `ConfigOp`: Operation variants (Upsert, Delete, RequestSync)

**3. Domain Layer** (`src-tauri/src/domain/`)

- `AppError`: Error type for result propagation
- `DomainResult<T>`: Type alias for `Result<T, AppError>`

**4. Utilities** (`src-tauri/src/utils.rs`)

- `current_timestamp()`: Monotonic millisecond clock

### Downstream Consumers

**1. Main Application** (`src-tauri/src/main.rs`)

- Creates ConfigService in AppState
- Provides to command handlers

**2. Tauri Commands** (`src-tauri/src/commands.rs`)

- Frontend-facing API for light management
- Calls ConfigService methods
- Broadcasts returned ConfigMessages

**3. Network Layer** (likely `src-tauri/src/network/`)

- Receives ConfigMessages from peers
- Calls `handle_config_message()`
- Broadcasts messages from local operations
- Handles sync requests

### Data Flow

**Local Update Flow:**

```
Frontend
  ↓ (Tauri command)
Command Handler
  ↓ (upsert_light)
ConfigService
  ↓ (upsert_light DB query)
Database
  ↓ (ConfigMessage)
Command Handler
  ↓ (broadcast)
Network Layer → Remote Peers
```

**Remote Update Flow:**

```
Network Layer
  ↓ (receive ConfigMessage)
Message Handler
  ↓ (handle_config_message)
ConfigService
  ↓ (apply_upsert_with_lww / apply_delete_if_newer)
Database
  ↓ (Result<bool>)
Message Handler
  ↓ (if needs_sync: get_all_config_messages)
Network Layer → Requesting Peer
```

**Sync Request Flow:**

```
New Peer → Network Layer
  ↓ (ConfigOp::RequestSync)
ConfigService::handle_config_message
  ↓ (returns true)
Message Handler
  ↓ (get_all_config_messages)
ConfigService
  ↓ (Vec<ConfigMessage>)
Network Layer → New Peer
```

## Usage Examples

### Example 1: Creating a Light Configuration

```rust
use crate::services::ConfigService;
use crate::protocol::messages::LightConfig;
use std::sync::Arc;

async fn create_light(service: Arc<ConfigService>) {
    let light = LightConfig {
        id: "conf-room-1".to_string(),
        color: "#FF0000".to_string(),
        name: "Conference Room A".to_string(),
        enabled: true,
        priority: 10,
        updated_at: 0,  // Will be set by service
        updated_by: String::new(),  // Will be set by service
    };

    match service.upsert_light(light).await {
        Ok(msg) => {
            println!("Light created, broadcasting to peers");
            // Broadcast msg to network
        }
        Err(e) => eprintln!("Failed to create light: {}", e),
    }
}
```

### Example 2: Handling Incoming Message

```rust
async fn handle_network_message(
    service: Arc<ConfigService>,
    msg: ConfigMessage,
    peer_id: String,
) {
    match service.handle_config_message(msg).await {
        Ok(true) => {
            println!("Sync requested by peer {}", peer_id);
            // Send full configuration state
            if let Ok(all_configs) = service.get_all_config_messages().await {
                for config_msg in all_configs {
                    // Send each config to requesting peer
                }
            }
        }
        Ok(false) => {
            println!("Message processed successfully");
        }
        Err(e) => eprintln!("Failed to process message: {}", e),
    }
}
```

### Example 3: Full Synchronization on Peer Join

```rust
async fn sync_with_new_peer(
    service: Arc<ConfigService>,
    new_peer_id: String,
) -> Result<()> {
    let all_configs = service.get_all_config_messages().await?;

    println!("Sending {} configurations to peer {}",
             all_configs.len(), new_peer_id);

    for config_msg in all_configs {
        // Send to new peer via network layer
        send_message_to_peer(&new_peer_id, config_msg)?;
    }

    Ok(())
}
```

### Example 4: Displaying All Lights

```rust
async fn list_all_lights(service: Arc<ConfigService>) {
    match service.get_all_lights().await {
        Ok(lights) => {
            println!("Current light configurations:");
            for light in lights {
                println!(
                    "  [{}] {} - {} (priority: {}, enabled: {})",
                    light.id,
                    light.name,
                    light.color,
                    light.priority,
                    if light.enabled { "yes" } else { "no" }
                );
                println!("    Last updated: {} by {}",
                         light.updated_at, light.updated_by);
            }
        }
        Err(e) => eprintln!("Failed to fetch lights: {}", e),
    }
}
```

### Example 5: Conflict Resolution in Action

```rust
// Simulating concurrent updates from multiple peers
async fn demonstrate_lww_conflict_resolution(db: Arc<Database>) {
    let service1 = ConfigService::new(db.clone(), "peer-1".to_string());
    let service2 = ConfigService::new(db.clone(), "peer-2".to_string());

    // Peer 1 creates initial light
    let light = LightConfig {
        id: "shared-light".to_string(),
        color: "red".to_string(),
        name: "Shared Conference Room".to_string(),
        enabled: true,
        priority: 1,
        updated_at: 0,
        updated_by: String::new(),
    };
    let msg1 = service1.upsert_light(light).await?;

    // Simulate time passing
    tokio::time::sleep(Duration::from_millis(100)).await;

    // Peer 2 updates to blue
    let mut light_blue = LightConfig {
        id: "shared-light".to_string(),
        color: "blue".to_string(),
        name: "Shared Conference Room".to_string(),
        enabled: true,
        priority: 1,
        updated_at: 0,
        updated_by: String::new(),
    };
    let msg2 = service2.upsert_light(light_blue).await?;

    // Peer 1 receives peer 2's blue message
    service1.handle_config_message(msg2).await?;

    // Result: Light is now blue (peer 2's timestamp is newer)
    let final_state = service1.get_all_lights().await?;
    assert_eq!(final_state[0].color, "blue");
    assert_eq!(final_state[0].updated_by, "peer-2");
}
```

## Future Improvements

### High Priority

**1. Implement Tombstones for Deletes**

- Track deletion timestamps in database
- Prevent resurrection of deleted lights
- Add TTL for tombstone cleanup (e.g., 30 days)
- See test `delete_vs_update_older_update_resurrects_after_delete` for current limitation

**2. Optimize Conflict Resolution Queries**

- Replace full table scans with direct ID lookups
- Add `get_light_by_id` query
- Improves performance from O(n) to O(1) per message
- Critical for deployments with >1000 lights

**3. Add Validation Layer**

- Validate color format (hex, CSS color names)
- Enforce name length limits (e.g., 1-100 chars)
- Validate priority range
- Sanitize ID format

### Medium Priority

**4. Timestamp Bounds Checking**

- Reject updates with timestamps too far in future (e.g., +1 year)
- Reject updates with timestamps too far in past (e.g., -1 year)
- Mitigates timestamp manipulation attacks
- Log warnings for suspicious timestamps

**5. Batch Processing for Sync**

- Process multiple messages in single transaction
- Reduce database round-trips during full sync
- Improves sync performance with many lights

**6. Add Integration Tests for ConfigService**

- Test high-level methods (upsert_light, delete_light, handle_config_message)
- Test message construction and field mapping
- Test error scenarios (database failures, invalid data)
- Test concurrent access patterns

### Low Priority

**7. Metrics and Monitoring**

- Track conflict resolution outcomes (accepted, rejected)
- Monitor message processing latency
- Count active lights, total operations
- Track per-peer contribution

**8. Vector Clocks for Causality**

- Replace LWW with vector clocks for better conflict resolution
- Detect concurrent updates without timestamp comparison
- More complex but handles clock skew better
- Requires protocol change

**9. Peer-Specific Permissions**

- Allow/deny list for light modifications
- Read-only peers
- Admin peers with delete privileges
- Requires authentication layer

**10. Configuration Versioning**

- Track history of configuration changes
- Enable rollback to previous states
- Audit trail for debugging
- Requires schema changes

## Related Documentation

### Specifications

- **Database Layer:** `spec/backend/database/database-layer.md` - Underlying storage
- **PresenceService:** `spec/backend/services/presence-service.md` - Similar service pattern
- **ChatService:** `spec/backend/services/chat-service.md` - Message-based service pattern
- **Network Layer:** `spec/backend/network/transport.md` - Message delivery

### Implementation Files

- **ConfigService:** `src-tauri/src/services/config_service.rs` (114 lines)
- **Config Handlers:** `src-tauri/src/services/config_handlers.rs` (515 lines, 12 tests)
- **Protocol Messages:** `src-tauri/src/protocol/messages.rs` - LightConfig and ConfigMessage definitions
- **Database Queries:** `src-tauri/src/database/queries.rs` - Light CRUD operations

### External Resources

- **CRDT Overview:** https://crdt.tech/ - Conflict-free replicated data types
- **Last-Write-Wins:** https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#LWW-Element-Set
- **Distributed Systems:** https://www.amazon.com/Designing-Data-Intensive-Applications-Reliable-Maintainable/dp/1449373321
