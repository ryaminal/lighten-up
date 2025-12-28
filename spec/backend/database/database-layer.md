# Database Layer Specification

## Overview

The **Database Layer** provides SQLite-based persistence for the Lighten-Up application. It includes database connection management, schema migrations, and query functions for settings, light configurations, and chat messages.

**Modules:**

- `src-tauri/src/database/connection.rs` - Thread-safe connection wrapper
- `src-tauri/src/database/migrations.rs` - Schema creation and migration
- `src-tauri/src/database/queries.rs` - Reusable query functions

**Key Responsibilities:**

- Initialize SQLite database with schema
- Provide thread-safe database access
- Execute queries with proper error handling
- Store and retrieve application settings
- Persist light configurations
- Store chat message history with automatic cleanup

## Architecture

### Design Patterns

1. **Repository Pattern**: Centralized data access layer
2. **Connection Wrapper**: Thread-safe `Arc<Mutex<Connection>>` pattern
3. **Migration-Based Schema**: Idempotent schema creation
4. **Query Function Pattern**: Reusable parameterized queries

### Database Technology

**SQLite:**

- Embedded database (no server required)
- ACID transactions
- Single-file storage
- Cross-platform support

**Location:** Application data directory (platform-specific)

### Thread Safety

```rust
type DbConnection = Arc<Mutex<Connection>>;
```

**Rationale:**

- `Arc`: Shared ownership across threads and services
- `Mutex`: Ensures exclusive access during queries
- SQLite connection is not thread-safe by default

## Connection Module

**File:** `src-tauri/src/database/connection.rs`

### execute_query

```rust
pub fn execute_query<F, R>(
    conn: &Arc<Mutex<Connection>>,
    f: F
) -> Result<R, rusqlite::Error>
where
    F: FnOnce(&Connection) -> Result<R, rusqlite::Error>
```

**Purpose:** Executes a database query with automatic lock management.

**Parameters:**

- `conn: &Arc<Mutex<Connection>>` - Shared database connection
- `f: F` - Closure that performs the query

**Returns:** `Result<R, rusqlite::Error>` - Query result or error

**Behavior:**

1. Acquires mutex lock on connection
2. Executes closure with connection reference
3. Returns result
4. Lock released automatically when function exits

**Error Handling:**

- Uses `.expect()` for lock acquisition (panic on poisoned mutex)
- Propagates rusqlite errors from closure

**Location:** `src-tauri/src/database/connection.rs:4`

**Example:**

```rust
let count: i64 = execute_query(&conn, |c| {
    c.query_row("SELECT COUNT(*) FROM chat_messages", [], |row| row.get(0))
})?;
```

**Benefits:**

- Consistent lock management
- RAII-style lock release
- Reduces boilerplate in query functions
- Type-safe (generic over return type)

## Migrations Module

**File:** `src-tauri/src/database/migrations.rs`

### run_migrations

```rust
pub fn run_migrations(conn: &Connection) -> Result<(), rusqlite::Error>
```

**Purpose:** Creates database schema if it doesn't exist.

**Parameters:**

- `conn: &Connection` - Database connection (not Arc/Mutex wrapped)

**Returns:** `Result<(), rusqlite::Error>` - Unit on success

**Behavior:**

- Executes batch SQL using `CREATE TABLE IF NOT EXISTS`
- Creates 3 tables: `my_settings`, `light_config`, `chat_messages`
- Creates trigger for automatic chat message cleanup
- Idempotent (safe to run multiple times)

**Location:** `src-tauri/src/database/migrations.rs:3`

**Schema Details:**

#### my_settings Table

```sql
CREATE TABLE IF NOT EXISTS my_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
```

**Purpose:** Key-value store for application settings

**Columns:**

- `key` (TEXT, PRIMARY KEY): Setting identifier (e.g., "my_peer_id", "my_peer_name")
- `value` (TEXT, NOT NULL): Setting value (stored as text)

**Usage:** Stores peer identity, preferences, encryption keys

#### light_config Table

```sql
CREATE TABLE IF NOT EXISTS light_config (
    id TEXT PRIMARY KEY,
    color TEXT NOT NULL,
    name TEXT NOT NULL,
    enabled INTEGER NOT NULL DEFAULT 1,
    priority INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    updated_by TEXT NOT NULL
);
```

**Purpose:** Stores light color configurations shared across peers

**Columns:**

- `id` (TEXT, PRIMARY KEY): Unique light identifier (UUID)
- `color` (TEXT, NOT NULL): Hex color code (e.g., "#FF0000")
- `name` (TEXT, NOT NULL): Light display name (e.g., "Urgent", "Available")
- `enabled` (INTEGER, NOT NULL): Boolean flag (1=enabled, 0=disabled)
- `priority` (INTEGER, NOT NULL): Sort order (lower = higher priority)
- `updated_at` (INTEGER, NOT NULL): Last update timestamp (Unix milliseconds)
- `updated_by` (TEXT, NOT NULL): Peer ID that last updated this config

**CRDT Semantics:**

- Last-write-wins based on `updated_at` timestamp
- `updated_by` tracks which peer made the change
- All peers converge to same configuration eventually

#### chat_messages Table

```sql
CREATE TABLE IF NOT EXISTS chat_messages (
    id TEXT PRIMARY KEY,
    peer_id TEXT NOT NULL,
    peer_name TEXT NOT NULL,
    content TEXT NOT NULL,
    timestamp INTEGER NOT NULL
);
```

**Purpose:** Stores chat message history

**Columns:**

- `id` (TEXT, PRIMARY KEY): Unique message identifier (UUID)
- `peer_id` (TEXT, NOT NULL): Author's peer ID
- `peer_name` (TEXT, NOT NULL): Author's display name (snapshot at send time)
- `content` (TEXT, NOT NULL): Message text content
- `timestamp` (INTEGER, NOT NULL): Message timestamp (Unix milliseconds)

**Retention:** Messages older than 24 hours automatically deleted (see trigger)

#### cleanup_old_chat Trigger

```sql
CREATE TRIGGER cleanup_old_chat
AFTER INSERT ON chat_messages
BEGIN
    DELETE FROM chat_messages
    WHERE timestamp < (strftime('%s', 'now') - 86400);
END;
```

**Purpose:** Automatically delete chat messages older than 24 hours

**Behavior:**

- Triggers after every message insertion
- Calculates cutoff timestamp (current time - 86400 seconds)
- Deletes messages with timestamp before cutoff

**Rationale:**

- Prevents unbounded database growth
- Chat history is ephemeral (designed for real-time communication)
- 24-hour retention sufficient for most use cases

**Performance:**

- Executes on every insert (minimal overhead for small table)
- Uses indexed timestamp column for efficient deletion
- Recommendation: Add index on timestamp if performance issues arise

## Queries Module

**File:** `src-tauri/src/database/queries.rs`

### Settings Queries

#### get_setting

```rust
pub fn get_setting(
    conn: &Arc<Mutex<Connection>>,
    key: &str
) -> Result<Option<String>, rusqlite::Error>
```

**Purpose:** Retrieves a setting value by key.

**Parameters:**

- `conn: &Arc<Mutex<Connection>>` - Database connection
- `key: &str` - Setting key

**Returns:** `Result<Option<String>, rusqlite::Error>` - Setting value if exists

**Behavior:**

- Queries `my_settings` table
- Returns `Some(value)` if key exists
- Returns `None` if key not found
- Uses `.optional()` to convert "not found" error to None

**Location:** `src-tauri/src/database/queries.rs:7`

**Example:**

```rust
match get_setting(&conn, "my_peer_id")? {
    Some(peer_id) => println!("Peer ID: {}", peer_id),
    None => println!("Peer ID not set"),
}
```

#### set_setting

```rust
pub fn set_setting(
    conn: &Arc<Mutex<Connection>>,
    key: &str,
    value: &str
) -> Result<(), rusqlite::Error>
```

**Purpose:** Stores or updates a setting value.

**Parameters:**

- `conn: &Arc<Mutex<Connection>>` - Database connection
- `key: &str` - Setting key
- `value: &str` - Setting value

**Returns:** `Result<(), rusqlite::Error>` - Unit on success

**Behavior:**

- Uses `INSERT OR REPLACE` for upsert semantics
- Creates new setting if key doesn't exist
- Updates existing setting if key exists

**Location:** `src-tauri/src/database/queries.rs:21`

**Example:**

```rust
set_setting(&conn, "my_peer_id", "alice")?;
set_setting(&conn, "my_peer_name", "Alice Smith")?;
```

### Light Configuration Queries

#### get_all_lights

```rust
pub fn get_all_lights(
    conn: &Arc<Mutex<Connection>>
) -> Result<Vec<LightConfig>, rusqlite::Error>
```

**Purpose:** Retrieves all light configurations ordered by priority.

**Returns:** `Result<Vec<LightConfig>, rusqlite::Error>` - List of lights

**Behavior:**

- Queries `light_config` table
- Orders by `priority ASC` (lower priority first)
- Maps rows to `LightConfig` structs
- Returns empty vector if no lights exist

**Location:** `src-tauri/src/database/queries.rs:36`

**Example:**

```rust
let lights = get_all_lights(&conn)?;
for light in lights {
    println!("{}: {} (priority: {})", light.name, light.color, light.priority);
}
```

#### upsert_light

```rust
pub fn upsert_light(
    conn: &Arc<Mutex<Connection>>,
    light: &LightConfig
) -> Result<(), rusqlite::Error>
```

**Purpose:** Inserts new light or updates existing light configuration.

**Parameters:**

- `conn: &Arc<Mutex<Connection>>` - Database connection
- `light: &LightConfig` - Light configuration to store

**Returns:** `Result<(), rusqlite::Error>` - Unit on success

**Behavior:**

- Uses `INSERT OR REPLACE` for upsert semantics
- Replaces existing light if `id` matches
- Inserts new light if `id` doesn't exist
- All fields updated (no partial updates)

**Location:** `src-tauri/src/database/queries.rs:62`

**Example:**

```rust
let light = LightConfig {
    id: "light-1".to_string(),
    color: "#FF0000".to_string(),
    name: "Urgent".to_string(),
    enabled: true,
    priority: 0,
    updated_at: current_timestamp(),
    updated_by: "alice".to_string(),
};
upsert_light(&conn, &light)?;
```

#### delete_light

```rust
pub fn delete_light(
    conn: &Arc<Mutex<Connection>>,
    id: &str
) -> Result<(), rusqlite::Error>
```

**Purpose:** Deletes a light configuration by ID.

**Parameters:**

- `conn: &Arc<Mutex<Connection>>` - Database connection
- `id: &str` - Light ID to delete

**Returns:** `Result<(), rusqlite::Error>` - Unit on success

**Behavior:**

- Deletes row with matching `id`
- No error if light doesn't exist (0 rows affected)
- Permanent deletion (no soft delete)

**Location:** `src-tauri/src/database/queries.rs:85`

**Example:**

```rust
delete_light(&conn, "light-1")?;
```

## Error Handling

### Error Types

All database functions return `rusqlite::Error`:

```rust
pub enum Error {
    QueryReturnedNoRows,
    InvalidColumnIndex(i32),
    // ... many other variants
}
```

### Error Scenarios

#### Lock Acquisition Failure

```rust
let connection = conn.lock().expect("Failed to acquire database lock");
```

**Behavior:** Panics if mutex is poisoned (rare, indicates bug)

**Rationale:**

- Poisoned mutex means another thread panicked while holding lock
- Database is in unknown state
- Recovery not possible; panic is appropriate

#### Query Errors

Common errors:

- `QueryReturnedNoRows` - Expected row not found
- `InvalidColumnIndex` - Programming error (wrong column index)
- `SqliteFailure` - Database constraint violation, I/O error

**Propagation:**

- All functions use `?` operator to propagate errors
- Caller responsible for handling errors

### Transaction Support

**Current State:** No explicit transaction support

**Manual Transactions:**

```rust
execute_query(&conn, |c| {
    c.execute("BEGIN TRANSACTION", [])?;

    // Multiple operations
    c.execute("INSERT INTO ...", params![...])?;
    c.execute("UPDATE ...", params![...])?;

    c.execute("COMMIT", [])?;
    Ok(())
})
```

**Recommendation:** Add transaction helper functions for multi-operation updates.

## Concurrency & Thread Safety

### Connection Sharing

```rust
type DbConnection = Arc<Mutex<Connection>>;
```

**Usage Pattern:**

```rust
// Shared across multiple services
let conn = Arc::new(Mutex::new(Connection::open(db_path)?));
let chat_service = ChatService::new(conn.clone(), ...);
let config_service = ConfigService::new(conn.clone(), ...);
```

### Lock Contention

**Potential Bottleneck:**

- Single connection lock shared by all operations
- Concurrent operations must wait for lock

**Mitigation:**

- SQLite is fast for local operations
- Lock held only during query execution
- Most operations complete in microseconds

**Alternative:** Connection pooling (overkill for single-user desktop app)

### WAL Mode

**Recommendation:** Enable Write-Ahead Logging for better concurrency:

```rust
conn.execute_batch("PRAGMA journal_mode=WAL;")?;
```

**Benefits:**

- Readers don't block writers
- Writers don't block readers
- Improves performance for concurrent access

## Integration Points

### Application Startup

**Initialization Sequence:**

```rust
// 1. Open database connection
let db_path = app_data_dir().join("lightenup.db");
let conn = Connection::open(&db_path)?;

// 2. Run migrations
run_migrations(&conn)?;

// 3. Wrap in Arc<Mutex> for sharing
let conn = Arc::new(Mutex::new(conn));

// 4. Initialize services
let chat_service = ChatService::new(conn.clone(), ...);
let config_service = ConfigService::new(conn.clone(), ...);
```

### Service Layer

**Used By:**

- `ChatService` - Chat message persistence
- `ConfigService` - Light configuration management
- `PresenceService` - Settings storage (peer identity)

**Pattern:**

```rust
pub struct ChatService {
    conn: Arc<Mutex<Connection>>,
    // ...
}

impl ChatService {
    pub async fn get_all_messages(&self) -> Result<Vec<ChatMessage>> {
        get_chat_messages(&self.conn)
            .map_err(|e| AppError::Other(e.into()))
    }
}
```

### Commands Layer

**Tauri Commands:**

```rust
#[tauri::command]
async fn get_lights(state: State<'_, AppState>) -> Result<Vec<LightConfig>, String> {
    get_all_lights(&state.db_connection)
        .map_err(|e| e.to_string())
}
```

## Test Coverage

**Current Status:** No direct unit tests (0 tests)

**Indirect Testing:**

- `ChatService` tests use database (16 tests)
- Other services test database operations indirectly

**Testing Challenges:**

- Requires actual SQLite database
- Difficult to mock rusqlite Connection

**Recommended Test Strategy:**

### Unit Tests (Future)

1. **Migration Idempotence Test**

   ```rust
   #[test]
   fn test_migrations_idempotent() {
       let conn = Connection::open_in_memory()?;
       run_migrations(&conn)?;
       run_migrations(&conn)?; // Should not error
       // Verify tables exist
   }
   ```

2. **Settings CRUD Test**

   ```rust
   #[test]
   fn test_settings_roundtrip() {
       let conn = setup_test_db();
       set_setting(&conn, "key1", "value1")?;
       assert_eq!(get_setting(&conn, "key1")?, Some("value1".to_string()));
   }
   ```

3. **Light Configuration Test**

   ```rust
   #[test]
   fn test_lights_ordering() {
       let conn = setup_test_db();
       // Insert lights with different priorities
       // Verify get_all_lights returns in priority order
   }
   ```

4. **Chat Cleanup Trigger Test**
   ```rust
   #[test]
   fn test_old_messages_deleted() {
       let conn = setup_test_db();
       // Insert message with old timestamp
       // Insert new message (triggers cleanup)
       // Verify old message deleted
   }
   ```

## Performance Considerations

### Query Performance

**Current State:**

- No indexes beyond primary keys
- Small data volumes (< 1000 rows per table)
- Performance adequate for desktop application

**Optimization Opportunities:**

1. **Add Indexes:**

   ```sql
   CREATE INDEX idx_chat_timestamp ON chat_messages(timestamp);
   CREATE INDEX idx_light_priority ON light_config(priority);
   ```

2. **Prepared Statements:**
   - Currently created per query
   - Could be cached for repeated queries

3. **Batch Operations:**
   - Insert multiple lights in single transaction
   - Use `execute_batch` for bulk operations

### Memory Usage

**Connection Overhead:**

- Single SQLite connection: ~1MB
- Query result sets: Depends on data size
- In-memory database possible for testing

**Mitigation:**

- Keep result sets small (pagination if needed)
- Close connections when app terminates
- No connection pooling needed

### Disk Usage

**Database Growth:**

- Settings: < 1KB
- Lights: ~100 bytes per light × 20 lights = 2KB
- Chat messages: ~200 bytes per message × 100 messages = 20KB
- Total: < 50KB typical

**Cleanup:**

- Chat messages auto-deleted after 24 hours
- No archival or backup needed

## Security Considerations

### SQL Injection

**Protection:**

- All queries use parameterized statements (`params![]` macro)
- No string concatenation in SQL
- rusqlite handles parameter escaping

**Example (Safe):**

```rust
c.execute("SELECT * FROM my_settings WHERE key = ?1", params![key])?;
```

**Anti-pattern (Never do this):**

```rust
// UNSAFE - SQL injection vulnerability
c.execute(&format!("SELECT * FROM my_settings WHERE key = '{}'", key), [])?;
```

### Database Encryption

**Current State:** Database stored in plaintext on disk

**Risks:**

- Chat history readable if device compromised
- Settings (including peer identity) exposed

**Mitigation Options:**

1. **SQLCipher:** Encrypted SQLite extension
2. **Full Disk Encryption:** OS-level (recommended)
3. **Selective Encryption:** Encrypt sensitive fields before storage

**Recommendation:** Rely on OS full-disk encryption; add SQLCipher if needed.

### File Permissions

**Platform-specific:**

- Unix: Ensure database file has mode 0600 (owner read/write only)
- Windows: Use NTFS permissions to restrict access

**Implementation:**

```rust
#[cfg(unix)]
{
    use std::os::unix::fs::PermissionsExt;
    let mut perms = std::fs::metadata(&db_path)?.permissions();
    perms.set_mode(0o600);
    std::fs::set_permissions(&db_path, perms)?;
}
```

## Usage Examples

### Application Initialization

```rust
use database::{run_migrations, queries};
use rusqlite::Connection;
use std::sync::{Arc, Mutex};

// Setup database
let db_path = app_data_dir().join("lightenup.db");
let conn = Connection::open(&db_path)?;
run_migrations(&conn)?;
let conn = Arc::new(Mutex::new(conn));

// Store peer identity
queries::set_setting(&conn, "my_peer_id", "alice")?;
queries::set_setting(&conn, "my_peer_name", "Alice Smith")?;

// Retrieve peer identity
let peer_id = queries::get_setting(&conn, "my_peer_id")?
    .expect("Peer ID not set");
println!("Peer ID: {}", peer_id);
```

### Managing Light Configurations

```rust
use database::queries;
use protocol::messages::LightConfig;

// Insert lights
let urgent = LightConfig {
    id: "light-1".to_string(),
    color: "#FF0000".to_string(),
    name: "Urgent".to_string(),
    enabled: true,
    priority: 0,
    updated_at: current_timestamp(),
    updated_by: "alice".to_string(),
};
queries::upsert_light(&conn, &urgent)?;

// Retrieve all lights
let lights = queries::get_all_lights(&conn)?;
for light in lights {
    if light.enabled {
        println!("{} - {}", light.name, light.color);
    }
}

// Delete light
queries::delete_light(&conn, "light-1")?;
```

### Error Handling

```rust
use rusqlite::Error;

match queries::get_setting(&conn, "encryption_key") {
    Ok(Some(key)) => {
        // Use key
        println!("Key: {}", key);
    }
    Ok(None) => {
        // Key not set, handle first-time setup
        println!("No encryption key found, generating new one");
    }
    Err(Error::SqliteFailure(e, _)) => {
        eprintln!("Database error: {}", e);
    }
    Err(e) => {
        eprintln!("Unexpected error: {}", e);
    }
}
```

## Future Improvements

### Features

1. **Schema Versioning** - Track migration version:

   ```sql
   CREATE TABLE schema_version (version INTEGER PRIMARY KEY);
   ```

2. **Query Builder** - Type-safe query construction:

   ```rust
   Query::select().from("light_config").where_eq("enabled", true).execute(conn)?;
   ```

3. **ORM Integration** - Use Diesel or SeaORM for better ergonomics

4. **Connection Pooling** - If concurrency becomes bottleneck

### Performance

1. **Indexes** - Add indexes on frequently queried columns:
   - `chat_messages.timestamp`
   - `light_config.priority`

2. **Prepared Statement Caching** - Reuse compiled queries

3. **WAL Mode** - Enable Write-Ahead Logging for better concurrency

### Reliability

1. **Backup & Restore** - Automated database backups:

   ```rust
   conn.backup(BackupDatabase::Main, backup_path, None)?;
   ```

2. **Integrity Checks** - Periodic database validation:

   ```rust
   conn.pragma_query(None, "integrity_check", |row| {
       row.get::<_, String>(0)
   })?;
   ```

3. **Migration Rollback** - Support for reverting schema changes

### Security

1. **Database Encryption** - Use SQLCipher for at-rest encryption

2. **Field-Level Encryption** - Encrypt sensitive values before storage:

   ```rust
   let encrypted_value = encryption.encrypt(value.as_bytes())?;
   set_setting(&conn, key, &hex::encode(encrypted_value))?;
   ```

3. **Audit Logging** - Track all database modifications

## Related Documentation

- **Services:** `spec/backend/services/chat-service.md`
- **Services:** `spec/backend/services/config-service.md` (to be created)
- **Domain Models:** `spec/backend/domain/chat-message.md` (to be created)
- **Protocol:** `spec/backend/protocol/messages.md` (to be created)
- **Setup:** `spec/backend/setup/initialization.md` (to be created)
