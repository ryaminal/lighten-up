# Chat Database Helpers Specification

## Overview

The chat_db module provides low-level database operations for chat message persistence. It acts as a thin wrapper around rusqlite operations, handling SQL execution and result mapping for ChatService.

**Location:** `src-tauri/src/services/chat_db.rs`

**Responsibilities:**

- Save chat messages to SQLite database
- Retrieve all chat messages ordered by timestamp
- Handle database connection locking
- Map between ChatMessage domain objects and database rows
- Provide idempotent insert operations

## Architecture

### Design Pattern

**Data Access Helper (Internal)**

- Module-private functions (`pub(crate)`) used only by ChatService
- Stateless functions operating on provided connection reference
- Direct SQL execution (no ORM overhead)
- Simple error propagation (rusqlite::Error)

### Dependencies

```rust
chat_db
    ├── domain::ChatMessage - Domain object for chat messages
    ├── rusqlite::{Connection, params} - SQLite interface
    └── std::sync::{Arc, Mutex} - Thread-safe connection sharing
```

**No External Dependencies:** Uses only standard library and rusqlite

### Module Visibility

**Internal Helper:** Not exposed outside services module

- `pub(crate)` visibility (crate-private)
- Called only by ChatService
- No direct external usage

## Data Model

### Database Schema

```sql
CREATE TABLE IF NOT EXISTS chat_messages (
    id TEXT PRIMARY KEY,
    peer_id TEXT NOT NULL,
    peer_name TEXT NOT NULL,
    content TEXT NOT NULL,
    timestamp INTEGER NOT NULL
);
```

**Columns:**

- `id`: Unique message identifier (primary key)
- `peer_id`: Sender's peer identifier
- `peer_name`: Sender's display name (denormalized for performance)
- `content`: Message text content
- `timestamp`: Unix timestamp in milliseconds (INTEGER for SQLite)

**Indexes:** Primary key on `id` (implicit)

**Ordering:** Results ordered by `timestamp ASC` for chronological display

### ChatMessage Domain Object

```rust
pub struct ChatMessage {
    pub id: String,
    pub peer_id: String,
    pub peer_name: String,
    pub content: String,
    pub timestamp: u64,
}
```

**Mapping:** Direct 1:1 mapping between struct fields and table columns

## Public API

### `save_chat_message`

```rust
pub(crate) fn save_chat_message(
    conn: &Arc<Mutex<Connection>>,
    msg: &ChatMessage,
) -> Result<(), rusqlite::Error>
```

Saves a chat message to the database with idempotent insert semantics.

**Parameters:**

- `conn`: Thread-safe SQLite connection (Arc<Mutex<Connection>>)
- `msg`: Chat message to persist (borrowed)

**Returns:**

- `Ok(())`: Message saved successfully (or already exists)
- `Err(rusqlite::Error)`: Database operation failed

**Behavior:**

1. Acquires mutex lock on connection (blocks if held by another thread)
2. Executes INSERT OR IGNORE with message fields
3. Releases lock automatically (RAII)

**SQL Operation:**

```sql
INSERT OR IGNORE INTO chat_messages (id, peer_id, peer_name, content, timestamp)
VALUES (?1, ?2, ?3, ?4, ?5)
```

**Idempotency:** `INSERT OR IGNORE` prevents duplicate ID errors

- If message ID exists: No-op, no error
- If message ID is new: Insert succeeds
- Result: Function can be called multiple times safely

**Lock Semantics:**

- Uses `.expect("Failed to acquire lock")` on lock acquisition
- **Panics if lock is poisoned** (previous holder panicked)
- Rationale: Poisoned lock indicates unrecoverable state

**Example:**

```rust
let msg = ChatMessage {
    id: "msg-123".to_string(),
    peer_id: "peer-456".to_string(),
    peer_name: "Alice".to_string(),
    content: "Hello!".to_string(),
    timestamp: 1234567890,
};

save_chat_message(&conn, &msg)?;
// Message now in database

// Safe to call again (idempotent)
save_chat_message(&conn, &msg)?;
// No error, no duplicate
```

**Performance:**

- Time complexity: O(1) - single row insert
- Space complexity: O(1) - no allocation (borrows message)
- Lock contention: Blocks other operations while holding lock

---

### `get_chat_messages`

```rust
pub(crate) fn get_chat_messages(
    conn: &Arc<Mutex<Connection>>,
) -> Result<Vec<ChatMessage>, rusqlite::Error>
```

Retrieves all chat messages from the database, ordered chronologically.

**Parameters:**

- `conn`: Thread-safe SQLite connection (Arc<Mutex<Connection>>)

**Returns:**

- `Ok(Vec<ChatMessage>)`: All messages ordered by timestamp (ascending)
- `Err(rusqlite::Error)`: Database query failed or row mapping failed

**Behavior:**

1. Acquires mutex lock on connection
2. Prepares SELECT statement with ORDER BY clause
3. Executes query and maps rows to ChatMessage objects
4. Collects all results into Vec
5. Releases lock automatically

**SQL Operation:**

```sql
SELECT id, peer_id, peer_name, content, timestamp
FROM chat_messages
ORDER BY timestamp ASC
```

**Ordering:** Oldest messages first (chronological order)

- Critical for chat UI display
- Ensures consistent ordering across reads

**Error Handling:**

- Query preparation errors: Propagated immediately
- Row mapping errors: Collected via `?` operator, first error returns
- Empty table: Returns `Ok(Vec::new())` (not an error)

**Example:**

```rust
let messages = get_chat_messages(&conn)?;

for msg in messages {
    println!("[{}] {}: {}", msg.timestamp, msg.peer_name, msg.content);
}
// Output:
// [1234567890] Alice: Hello!
// [1234567891] Bob: Hi there!
```

**Performance:**

- Time complexity: O(n) - full table scan with sort
- Space complexity: O(n) - allocates Vec of all messages
- Memory usage: ~150-300 bytes per message (depends on content length)

**Optimization Opportunity:**

- Add index on `timestamp` column for faster sorting
- Consider pagination for large message counts (>10,000)

## Concurrency and Thread Safety

### Locking Strategy

**Mutex-Based Serialization:**

- All database operations serialized by `Mutex<Connection>`
- One operation at a time (no concurrent reads or writes)
- Simple but effective for SQLite (which is not designed for concurrent writes)

**Lock Acquisition:**

```rust
let connection = conn.lock().expect("Failed to acquire lock");
```

**Panic on Poison:**

- `.expect()` panics if mutex is poisoned
- Poisoned mutex = previous holder panicked while holding lock
- Rationale: Database may be in inconsistent state, recovery not possible

**Alternative Design (not used):**

```rust
// Could use try_lock for non-blocking attempt
match conn.try_lock() {
    Ok(connection) => { /* ... */ },
    Err(_) => return Err(/* lock busy */),
}
```

### Lock Contention

**Scenarios:**

- Saving messages while loading messages (save blocks load, or vice versa)
- Multiple saves from concurrent network messages (serialized)
- UI refresh while background save (UI blocks briefly)

**Mitigation:**

- Operations are fast (typically <1ms for single message)
- SQLite is optimized for small transactions
- Blocking is acceptable for chat workload (low frequency)

### Thread Safety Guarantees

**Arc<Mutex<Connection>>:**

- `Arc`: Multiple threads can hold references
- `Mutex`: Ensures exclusive access to Connection
- `Connection`: Not thread-safe itself, requires external synchronization

**Rust Guarantees:**

- No data races (enforced at compile time)
- No use-after-free
- No concurrent mutation without synchronization

## Error Handling

### Error Type

```rust
rusqlite::Error
```

**Common Error Cases:**

**1. Lock Poisoning:**

- Cause: Previous thread panicked while holding lock
- Behavior: `.expect()` panics immediately
- Recovery: None (application should restart)

**2. SQL Execution Errors:**

- Invalid SQL syntax (compile-time bug)
- Constraint violations (shouldn't happen with INSERT OR IGNORE)
- Database file corruption

**3. Row Mapping Errors:**

- Type mismatch (schema changed, code out of sync)
- Null values in NOT NULL columns

**4. Connection Errors:**

- Database file locked by another process (rare with in-process SQLite)
- Disk full or I/O errors

### Error Propagation

**Strategy:** Immediate propagation with `?` operator

```rust
connection.execute(...)?;  // Propagate on error
Ok(())  // Success
```

**No Error Recovery:**

- Functions do not catch or handle errors
- Caller (ChatService) decides how to handle
- Simple and predictable error flow

### Idempotency and Error Safety

**save_chat_message:**

- Idempotent via `INSERT OR IGNORE`
- Safe to retry on error (no duplicate messages)
- Atomic (single SQL statement)

**get_chat_messages:**

- Read-only, no side effects
- Safe to retry on error
- Atomic (single transaction)

## Performance Considerations

### Time Complexity

**save_chat_message:**

- INSERT: O(1) with primary key
- Duplicate check: O(1) with primary key index
- Total: O(1) per message

**get_chat_messages:**

- SELECT: O(n) - full table scan
- ORDER BY: O(n log n) with sort (or O(n) with timestamp index)
- Row mapping: O(n) - iterate all rows
- Total: O(n log n) worst case, O(n) with index

### Space Complexity

**save_chat_message:**

- Stack: O(1) - no allocations
- Database: O(1) - single row added

**get_chat_messages:**

- Stack/Heap: O(n) - Vec of all messages
- Temporary: O(n) - query result set

### Bottlenecks

**1. Full Table Scan on get_chat_messages**

- Current: No index on timestamp
- Impact: Slower as message count grows
- Threshold: Noticeable at >10,000 messages

**2. Mutex Contention**

- Single lock for all operations
- Reads block writes, writes block everything
- Impact: Higher latency under concurrent load

**3. No Pagination**

- Loads all messages into memory
- Memory usage: ~200 bytes \* message_count
- Impact: Significant with >100,000 messages

### Optimization Recommendations

**Short Term:**

1. Add index on timestamp column:
   ```sql
   CREATE INDEX idx_chat_timestamp ON chat_messages(timestamp);
   ```
2. Add message count limit (e.g., keep last 10,000)
3. Consider WAL mode for better concurrency

**Long Term:**

1. Implement pagination (offset/limit in queries)
2. Use `r2d2` connection pool (though SQLite doesn't benefit much)
3. Consider separate read/write connections for concurrency

## Security Considerations

### SQL Injection

**Protection:** Parameterized queries

```rust
params![msg.id, msg.peer_id, msg.peer_name, msg.content, msg.timestamp]
```

**Safety:**

- All values passed as parameters (not string concatenation)
- Rusqlite handles escaping and quoting
- No user-controlled SQL syntax

### Data Validation

**Current State:** No validation in this module

- No length limits on strings
- No sanitization of content
- No validation of peer_id format

**Responsibility:** ChatService should validate before calling

- Enforce max content length (e.g., 10,000 chars)
- Validate peer_id format
- Sanitize for display (XSS prevention in UI)

### Threats

**1. Storage Exhaustion**

- **Attack:** Send unlimited messages to fill disk
- **Impact:** Database file grows unbounded, disk full
- **Mitigation:** ChatService should enforce message count limit
- **Severity:** High (DoS)

**2. Large Message Payload**

- **Attack:** Send extremely long message content
- **Impact:** Memory exhaustion on load, slow queries
- **Mitigation:** ChatService should enforce content length limit
- **Severity:** Medium (DoS)

**3. Malicious Content**

- **Attack:** Insert XSS payloads, SQL syntax in content
- **Impact:** XSS in UI (if not escaped), no SQL injection risk
- **Mitigation:** UI must escape content, SQL injection already prevented
- **Severity:** Low (UI responsibility)

## Integration Points

### Upstream Dependency

**ChatService** (`src-tauri/src/services/chat_service.rs`)

- Calls `save_chat_message` when receiving messages
- Calls `get_chat_messages` for UI queries
- Wraps errors with AppError
- Provides connection reference

**Database Layer** (`src-tauri/src/database/`)

- Provides `Arc<Mutex<Connection>>` via Database::connection()
- Manages schema migrations (creates chat_messages table)
- Handles database initialization

### Downstream (None)

**No consumers outside ChatService:**

- Module-private (`pub(crate)`) functions
- Direct SQL access is encapsulated
- ChatService is sole consumer

## Usage Pattern

### Typical Usage (in ChatService)

```rust
use crate::services::chat_db::{save_chat_message, get_chat_messages};

// In ChatService
pub async fn store_message(&self, msg: ChatMessage) -> Result<()> {
    let conn = self.db.connection();
    chat_db::save_chat_message(&conn, &msg)
        .map_err(|e| AppError::Other(anyhow::anyhow!("Failed to save message: {}", e)))?;
    Ok(())
}

pub async fn get_all_messages(&self) -> Result<Vec<ChatMessage>> {
    let conn = self.db.connection();
    chat_db::get_chat_messages(&conn)
        .map_err(|e| AppError::Other(anyhow::anyhow!("Failed to get messages: {}", e)))
}
```

## Test Coverage

**Current Status:** No dedicated tests for chat_db module

**Rationale:**

- Simple wrappers around rusqlite operations
- Tested indirectly via ChatService tests (16 tests in ChatService)
- No complex logic requiring isolated testing

**What Would Be Tested (if tests existed):**

**Potential Unit Tests:**

1. `save_chat_message` inserts new message
2. `save_chat_message` is idempotent (duplicate ID ignored)
3. `save_chat_message` persists all fields correctly
4. `get_chat_messages` returns empty Vec for empty table
5. `get_chat_messages` returns messages in chronological order
6. `get_chat_messages` handles multiple messages correctly
7. SQL errors propagate correctly

**Current Test Coverage (via ChatService tests):**

- ✅ Integration with ChatService
- ✅ Message persistence across service operations
- ✅ Query operations return correct data
- ✅ Error handling at service level

**Testing Recommendation:**

- Current indirect testing is sufficient for stable code
- Add unit tests if bugs are discovered
- Focus test effort on ChatService (higher value)

## Future Improvements

### High Priority

**1. Add Timestamp Index**

```sql
CREATE INDEX idx_chat_timestamp ON chat_messages(timestamp);
```

- Improves ORDER BY performance from O(n log n) to O(n)
- Critical for large message counts

**2. Implement Message Pagination**

```rust
pub(crate) fn get_chat_messages_page(
    conn: &Arc<Mutex<Connection>>,
    limit: usize,
    offset: usize,
) -> Result<Vec<ChatMessage>, rusqlite::Error>
```

- Reduces memory usage
- Improves load time for UI
- Enables infinite scroll pattern

**3. Add Message Count Limit**

```rust
pub(crate) fn delete_old_messages(
    conn: &Arc<Mutex<Connection>>,
    keep_count: usize,
) -> Result<usize, rusqlite::Error>
```

- Prevents unbounded database growth
- Keep most recent N messages (e.g., 10,000)

### Medium Priority

**4. Add Query for Message Range**

```rust
pub(crate) fn get_messages_since(
    conn: &Arc<Mutex<Connection>>,
    since_timestamp: u64,
) -> Result<Vec<ChatMessage>, rusqlite::Error>
```

- Efficient incremental updates
- Supports "load more" UI pattern

**5. Enable WAL Mode**

```rust
// In database initialization
connection.execute("PRAGMA journal_mode=WAL", [])?;
```

- Improves concurrency (readers don't block writers)
- Better performance for mixed read/write workloads

**6. Add Prepared Statement Caching**

- Reuse prepared statements across calls
- Reduces parsing overhead
- Requires refactoring to stateful design

### Low Priority

**7. Add Metrics/Logging**

- Log slow queries (>100ms)
- Track message count over time
- Monitor lock contention

**8. Support Message Deletion**

```rust
pub(crate) fn delete_message(
    conn: &Arc<Mutex<Connection>>,
    id: &str,
) -> Result<(), rusqlite::Error>
```

- Enable message retraction
- Support moderation features

**9. Support Message Editing**

- Track edit history
- Requires schema changes (edit timestamp, original content)

## Related Documentation

### Specifications

- **ChatService:** `spec/backend/services/chat-service.md` - Primary consumer, message ownership model
- **Database Layer:** `spec/backend/database/database-layer.md` - Schema management, migrations

### Implementation Files

- **Chat DB Helpers:** `src-tauri/src/services/chat_db.rs` (50 lines)
- **ChatService:** `src-tauri/src/services/chat_service.rs` - Uses these helpers
- **ChatMessage:** `src-tauri/src/domain/chat_message.rs` - Domain object definition

### External Resources

- **Rusqlite Documentation:** https://docs.rs/rusqlite/latest/rusqlite/
- **SQLite Best Practices:** https://www.sqlite.org/bestpractice.html
- **SQLite Concurrency:** https://www.sqlite.org/lockingv3.html
