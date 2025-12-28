# ChatService Specification

## Overview

The `ChatService` is a core service responsible for managing chat messages in the Lighten-Up application. It handles both outgoing messages (created by the local peer) and incoming messages (received from remote peers), provides message persistence through SQLite, and enforces ownership-based permissions for editing and deleting messages.

**Module:** `src-tauri/src/services/chat_service.rs`

**Key Responsibilities:**

- Send new chat messages from the local peer
- Receive and persist incoming chat messages from remote peers
- Retrieve all chat messages (ordered by timestamp)
- Edit messages (own messages only)
- Delete messages (own messages only)
- Enforce message length validation (500 character limit)
- Enforce ownership-based permissions

## Architecture

### Service Structure

```rust
pub struct ChatService {
    conn: Arc<Mutex<Connection>>,  // Thread-safe SQLite connection
    my_peer_id: String,             // Local peer identifier
    my_peer_name: String,           // Local peer display name
}
```

### Design Patterns

1. **Repository Pattern**: Delegates database operations to `chat_db` module
2. **Ownership Model**: Only the message author can edit or delete their messages
3. **Async API**: All public methods are async for consistent interface
4. **Thread Safety**: Uses `Arc<Mutex<Connection>>` for safe concurrent access
5. **Validation**: Enforces business rules (length limits, permissions)

### Dependencies

- `domain::ChatMessage` - Message data structure
- `domain::AppError` - Domain-specific error types
- `services::chat_db` - Database operations layer
- `rusqlite` - SQLite database interface
- `uuid` - Message ID generation
- `utils::current_timestamp()` - Timestamp generation

## Data Structures

### ChatMessage

```rust
pub struct ChatMessage {
    pub id: String,          // Unique UUID identifier
    pub peer_id: String,     // Author's peer ID
    pub peer_name: String,   // Author's display name (at send time)
    pub content: String,     // Message text (max 500 chars)
    pub timestamp: i64,      // Unix timestamp in milliseconds
}
```

**Properties:**

- `id`: Generated using `Uuid::new_v4()` for uniqueness
- `peer_id`: Identifies the message author
- `peer_name`: Snapshot of author's name at message creation time
- `content`: UTF-8 text content with 500 character maximum
- `timestamp`: Milliseconds since Unix epoch, used for ordering

### AppError Types Used

```rust
pub enum AppError {
    Other(anyhow::Error),    // Generic errors (validation, DB errors)
    NotFound,                // Message not found in database
    PermissionDenied,        // User tried to edit/delete others' messages
}
```

## Public API

### Constructor

#### `new(conn, my_peer_id, my_peer_name) -> Self`

Creates a new ChatService instance.

**Parameters:**

- `conn: Arc<Mutex<Connection>>` - Shared SQLite connection
- `my_peer_id: String` - Local peer identifier
- `my_peer_name: String` - Local peer display name

**Returns:** `ChatService` instance

**Usage:**

```rust
let service = ChatService::new(
    db_connection,
    "peer-123".to_string(),
    "Alice".to_string()
);
```

### Message Operations

#### `send_message(content) -> Result<ChatMessage>`

Sends a new chat message from the local peer.

**Parameters:**

- `content: String` - Message text content

**Returns:** `Result<ChatMessage>` - Persisted message on success

**Behavior:**

1. Validates content length (max 500 characters)
2. Generates unique message ID using UUID v4
3. Creates ChatMessage with local peer's ID and name
4. Generates current timestamp
5. Persists message to database
6. Returns the complete ChatMessage

**Errors:**

- `AppError::Other` - If content exceeds 500 characters
- `AppError::Other` - If database persistence fails

**Location:** `src-tauri/src/services/chat_service.rs:26`

**Example:**

```rust
let message = service.send_message("Hello team!".to_string()).await?;
// Returns ChatMessage with generated ID and timestamp
```

#### `handle_message(msg) -> Result<()>`

Persists an incoming chat message from a remote peer.

**Parameters:**

- `msg: ChatMessage` - Complete message received from remote peer

**Returns:** `Result<()>` - Unit on success

**Behavior:**

1. Logs incoming message details
2. Persists message to database via `save_chat_message`
3. Returns success

**Errors:**

- `AppError::Other` - If database persistence fails

**Location:** `src-tauri/src/services/chat_service.rs:48`

**Notes:**

- Does not validate message ownership or timestamps
- Accepts pre-constructed ChatMessage with remote peer's data
- Used by network layer when receiving messages

**Example:**

```rust
let remote_msg = ChatMessage {
    id: "uuid-from-remote".to_string(),
    peer_id: "peer-456".to_string(),
    peer_name: "Bob".to_string(),
    content: "Message from remote peer".to_string(),
    timestamp: 1234567890000,
};
service.handle_message(remote_msg).await?;
```

#### `get_all_messages() -> Result<Vec<ChatMessage>>`

Retrieves all chat messages, ordered by timestamp (oldest first).

**Returns:** `Result<Vec<ChatMessage>>` - All messages ordered by timestamp

**Behavior:**

1. Delegates to `chat_db::get_chat_messages`
2. Returns messages ordered by timestamp ascending

**Errors:**

- `AppError::Other` - If database query fails

**Location:** `src-tauri/src/services/chat_service.rs:57`

**Performance:**

- Returns all messages (no pagination in current implementation)
- Messages sorted by database query for efficiency

**Example:**

```rust
let messages = service.get_all_messages().await?;
for msg in messages {
    println!("{}: {} ({})", msg.timestamp, msg.peer_name, msg.content);
}
```

#### `edit_message(id, content) -> Result<ChatMessage>`

Edits an existing message owned by the local peer.

**Parameters:**

- `id: String` - Message ID to edit
- `content: String` - New message content

**Returns:** `Result<ChatMessage>` - Updated message with new timestamp

**Behavior:**

1. Acquires database lock
2. Queries message to verify existence and ownership
3. Checks if message belongs to local peer (`my_peer_id`)
4. Updates content and timestamp in database
5. Returns updated ChatMessage

**Errors:**

- `AppError::NotFound` - If message ID doesn't exist
- `AppError::PermissionDenied` - If message belongs to another peer
- `AppError::Other` - If database operations fail

**Location:** `src-tauri/src/services/chat_service.rs:62`

**Security:**

- Enforces ownership validation before allowing edits
- Updates timestamp to reflect edit time
- Original message ID and author remain unchanged

**Example:**

```rust
// Edit own message
let edited = service.edit_message(
    "msg-id-123".to_string(),
    "Updated content".to_string()
).await?;

// Attempting to edit another peer's message
let result = service.edit_message("their-msg-id".to_string(), "hack".to_string()).await;
assert!(matches!(result, Err(AppError::PermissionDenied)));
```

#### `delete_message(id) -> Result<()>`

Deletes a message owned by the local peer.

**Parameters:**

- `id: String` - Message ID to delete

**Returns:** `Result<()>` - Unit on success

**Behavior:**

1. Acquires database lock
2. Queries message to verify existence and ownership
3. Checks if message belongs to local peer (`my_peer_id`)
4. Deletes message from database

**Errors:**

- `AppError::NotFound` - If message ID doesn't exist
- `AppError::PermissionDenied` - If message belongs to another peer
- `AppError::Other` - If database operations fail

**Location:** `src-tauri/src/services/chat_service.rs:95`

**Security:**

- Enforces ownership validation before allowing deletion
- Permanent deletion (no soft delete in current implementation)

**Example:**

```rust
// Delete own message
service.delete_message("msg-id-123".to_string()).await?;

// Attempting to delete another peer's message
let result = service.delete_message("their-msg-id".to_string()).await;
assert!(matches!(result, Err(AppError::PermissionDenied)));
```

## Business Rules

### Message Length Validation

- **Maximum Length:** 500 characters
- **Enforcement:** Applied in `send_message` only
- **Rationale:** Prevents oversized network payloads
- **Edge Case:** Exactly 500 characters is allowed

**Note:** `handle_message` does not validate length for incoming messages, trusting remote peers to have enforced their own limits.

### Ownership Model

- **Edit Permission:** Only message author (matching `my_peer_id`) can edit
- **Delete Permission:** Only message author (matching `my_peer_id`) can delete
- **Read Permission:** All messages visible to all peers (no read restrictions)

### Timestamp Behavior

- **New Messages:** Timestamp generated at message creation time
- **Edited Messages:** Timestamp updated to current time on edit
- **Incoming Messages:** Timestamp provided by sender (not regenerated)

### Message Ordering

- **Default Order:** Ascending by timestamp (oldest first)
- **Implementation:** Enforced by database query in `chat_db` module
- **Use Case:** Chat history displayed chronologically

## Concurrency & Thread Safety

### Database Access Pattern

```rust
conn: Arc<Mutex<Connection>>
```

**Thread Safety Approach:**

- `Arc` allows shared ownership across threads
- `Mutex` ensures exclusive access during database operations
- Lock acquired explicitly in `edit_message` and `delete_message`
- Lock acquisition uses `.expect()` with clear error messages

**Lock Scope:**

- Minimal lock duration (released at end of operation)
- Read operations delegated to `chat_db` module (lock handled there)
- Write operations hold lock for query + update

### Async API Design

All public methods are `async` despite synchronous SQLite operations:

- **Rationale:** Consistent API for future async database support
- **Current Behavior:** No `.await` points internally (synchronous SQLite)
- **Future-Proofing:** Allows migration to async database without API changes

## Error Handling

### Error Types & Meanings

```rust
// Content validation error
AppError::Other(anyhow::anyhow!("Message content exceeds maximum length"))

// Message not found
AppError::NotFound

// Permission denied
AppError::PermissionDenied

// Database errors
AppError::Other(e.into())  // From rusqlite errors
```

### Error Propagation

- Database errors wrapped in `AppError::Other` via `.map_err(|e| AppError::Other(e.into()))`
- Validation errors created directly as `AppError::Other`
- Permission errors created directly as `AppError::PermissionDenied`
- Not found errors created directly as `AppError::NotFound`

## Integration Points

### Database Layer

**Module:** `services::chat_db`

**Functions Used:**

```rust
save_chat_message(conn: &Arc<Mutex<Connection>>, msg: &ChatMessage) -> Result<()>
get_chat_messages(conn: &Arc<Mutex<Connection>>) -> Result<Vec<ChatMessage>>
```

### Network Layer

**Used By:** Network handlers receiving chat protocol messages

**Integration Flow:**

1. Network receives encrypted chat message
2. Decrypts and deserializes to `ChatMessage`
3. Calls `service.handle_message(msg).await`
4. Message persisted to database
5. Frontend notified via Tauri event

### Command Layer

**Used By:** Tauri commands for frontend interaction

**Commands:**

- `send_chat_message` → calls `send_message()`
- `get_chat_messages` → calls `get_all_messages()`
- `edit_chat_message` → calls `edit_message()`
- `delete_chat_message` → calls `delete_message()`

## Test Coverage

**Location:** `src-tauri/src/services/chat_service.rs:116-397`

**Total Tests:** 16 comprehensive integration tests

### Test Categories

#### Message Creation (2 tests)

1. ✅ `send_message_creates_message_with_correct_fields` - Validates message structure
2. ✅ `send_message_persists_to_database` - Verifies database persistence

#### Validation (2 tests)

3. ✅ `send_message_rejects_content_over_500_chars` - Enforces max length
4. ✅ `send_message_accepts_content_at_500_chars` - Validates boundary condition

#### Incoming Messages (1 test)

5. ✅ `handle_message_persists_incoming_message` - Tests remote message handling

#### Message Retrieval (3 tests)

6. ✅ `get_all_messages_returns_empty_when_no_messages` - Empty state
7. ✅ `get_all_messages_returns_messages_ordered_by_timestamp` - Ordering verification
8. ✅ `multiple_messages_from_different_peers` - Multi-peer scenarios

#### Message Editing (3 tests)

9. ✅ `edit_message_updates_content_and_timestamp` - Successful edit
10. ✅ `edit_message_denies_editing_other_peers_message` - Permission enforcement
11. ✅ `edit_message_returns_not_found_for_nonexistent_message` - Error handling

#### Message Deletion (3 tests)

12. ✅ `delete_message_removes_own_message` - Successful deletion
13. ✅ `delete_message_denies_deleting_other_peers_message` - Permission enforcement
14. ✅ `delete_message_returns_not_found_for_nonexistent_message` - Error handling

### Test Infrastructure

**Setup Functions:**

```rust
fn setup_test_db() -> Arc<Mutex<Connection>>
fn create_test_service() -> ChatService
```

**Test Database:**

- Uses in-memory SQLite (`Connection::open_in_memory()`)
- Runs migrations before each test
- Isolated per test (no shared state)

**Test Peer:**

- ID: `"test-peer-id"`
- Name: `"Test Peer"`

### Coverage Analysis

**Covered Scenarios:**

- ✅ Happy path for all operations
- ✅ Validation errors (length limits)
- ✅ Permission errors (ownership checks)
- ✅ Not found errors (nonexistent messages)
- ✅ Boundary conditions (exactly 500 characters)
- ✅ Message ordering (chronological)
- ✅ Multi-peer message handling
- ✅ Timestamp updates on edit

**Edge Cases:**

- ✅ Empty message list
- ✅ Out-of-order message insertion
- ✅ Concurrent message creation from different peers

## Performance Considerations

### Database Operations

**Write Operations:**

- `send_message`: 1 INSERT
- `handle_message`: 1 INSERT
- `edit_message`: 1 SELECT + 1 UPDATE
- `delete_message`: 1 SELECT + 1 DELETE

**Read Operations:**

- `get_all_messages`: 1 SELECT with ORDER BY

### Lock Contention

**Potential Bottlenecks:**

- Single database lock shared across all operations
- Edit/delete operations hold lock for 2 queries (SELECT + UPDATE/DELETE)

**Mitigation Strategies:**

- Keep lock scope minimal
- Use database transactions for multi-query operations
- Consider connection pooling for high-concurrency scenarios

### Scalability

**Current Limitations:**

- No pagination on `get_all_messages` (loads all messages)
- No message pruning or archival
- Single SQLite connection (no connection pooling)

**Recommended Improvements:**

- Add pagination support (limit + offset parameters)
- Implement message retention policy (auto-delete old messages)
- Add indexes on `peer_id` and `timestamp` columns

## Security Considerations

### Ownership Validation

**Critical Security Checks:**

1. Edit operations verify `peer_id` matches `my_peer_id`
2. Delete operations verify `peer_id` matches `my_peer_id`
3. Verification happens before any modifications

**Attack Prevention:**

- Prevents unauthorized message modification
- Prevents message deletion by non-authors
- Uses database as source of truth (not client-provided data)

### Input Validation

**Current Validations:**

- Message content length (500 character limit)

**Missing Validations:**

- No content sanitization (XSS prevention in frontend)
- No profanity filtering
- No rate limiting
- No duplicate message detection

### SQL Injection

**Protection:**

- All queries use parameterized statements (`params![]` macro)
- No string concatenation in SQL queries
- rusqlite library handles parameter escaping

## Usage Examples

### Basic Chat Flow

```rust
// Initialize service
let service = ChatService::new(
    db_connection,
    "peer-alice".to_string(),
    "Alice".to_string()
);

// Send a message
let msg = service.send_message("Hello everyone!".to_string()).await?;
println!("Sent message with ID: {}", msg.id);

// Receive message from network
let incoming = ChatMessage {
    id: Uuid::new_v4().to_string(),
    peer_id: "peer-bob".to_string(),
    peer_name: "Bob".to_string(),
    content: "Hi Alice!".to_string(),
    timestamp: current_timestamp(),
};
service.handle_message(incoming).await?;

// Get all messages
let messages = service.get_all_messages().await?;
for msg in messages {
    println!("[{}] {}: {}", msg.timestamp, msg.peer_name, msg.content);
}
```

### Editing Messages

```rust
// Send a message
let msg = service.send_message("Initial content".to_string()).await?;

// Edit the message
let edited = service.edit_message(
    msg.id.clone(),
    "Corrected content".to_string()
).await?;

assert_eq!(edited.content, "Corrected content");
assert!(edited.timestamp > msg.timestamp);
```

### Error Handling

```rust
// Attempting to edit another peer's message
match service.edit_message("foreign-msg-id".to_string(), "hack".to_string()).await {
    Ok(_) => panic!("Should not allow editing others' messages"),
    Err(AppError::PermissionDenied) => println!("Permission correctly denied"),
    Err(e) => panic!("Unexpected error: {:?}", e),
}

// Handling validation errors
match service.send_message("a".repeat(501)).await {
    Ok(_) => panic!("Should reject oversized messages"),
    Err(AppError::Other(e)) if e.to_string().contains("exceeds maximum") => {
        println!("Validation working correctly");
    }
    Err(e) => panic!("Unexpected error: {:?}", e),
}
```

## Future Improvements

### Features

1. **Message Reactions** - Allow peers to react to messages with emojis
2. **Message Threads** - Support threaded conversations
3. **Message Search** - Full-text search across message history
4. **Message Attachments** - Support file sharing in chat
5. **Read Receipts** - Track which peers have seen messages

### Performance

1. **Pagination** - Add limit/offset parameters to `get_all_messages`
2. **Caching** - Cache recent messages in memory
3. **Batch Operations** - Support bulk message insertion
4. **Database Indexes** - Add indexes on frequently queried columns

### Security

1. **Content Filtering** - Sanitize message content
2. **Rate Limiting** - Prevent message spam
3. **Encryption** - Encrypt messages at rest in database
4. **Audit Logging** - Log all edit/delete operations

### Reliability

1. **Soft Delete** - Mark messages as deleted instead of removing
2. **Message Versioning** - Keep edit history
3. **Conflict Resolution** - Handle concurrent edits
4. **Message Delivery** - Track delivery status per peer

## Related Documentation

- **Domain Models:** `spec/backend/domain/chat-message.md` (to be created)
- **Database Layer:** `spec/backend/database/queries.md` (to be created)
- **Protocol:** `spec/backend/protocol/messages.md` (to be created)
- **Frontend Integration:** `spec/frontend/components/global-chat.md`
