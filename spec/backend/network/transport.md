# Network Transport Specification

## Overview

The **Transport** module provides encrypted TCP connection management for peer-to-peer communication. It handles listening for incoming connections, spawning connection handlers, and sending messages to remote peers.

**Module:** `src-tauri/src/network/transport.rs`

**Key Responsibilities:**

- Listen for incoming TCP connections on random port
- Accept and handle multiple concurrent connections
- Spawn async handler per connection
- Read encrypted messages from connections
- Send encrypted messages to peers
- Channel incoming messages to application layer
- Graceful connection lifecycle management

## Architecture

### Service Structure

```rust
pub struct Transport<E: EncryptionAdapter> {
    encryption: Arc<E>,
    incoming_tx: mpsc::UnboundedSender<(PeerId, Message)>,
}

pub struct TransportReceiver {
    incoming_rx: mpsc::UnboundedReceiver<(PeerId, Message)>,
}
```

### Design Patterns

1. **Split Send/Receive**: Transport handles sending, TransportReceiver handles receiving
2. **Channel-Based**: MPSC channel for message passing from handlers to application
3. **Spawn-Per-Connection**: Each connection gets dedicated async task
4. **Shared Encryption**: Arc-wrapped encryption adapter shared across handlers

### Dependencies

- `tokio::net::{TcpListener, TcpStream}` - Async TCP networking
- `tokio::sync::mpsc` - Multi-producer, single-consumer channel
- `adapters::EncryptionAdapter` - Encryption trait
- `network::message_io` - Message reading/writing functions
- `domain::PeerId` - Strongly-typed peer identifier

## Public API

### Constructor

#### `new(encryption) -> (Self, TransportReceiver)`

Creates a new Transport and its associated receiver.

**Parameters:**

- `encryption: Arc<E>` - Shared encryption adapter

**Returns:** `(Transport<E>, TransportReceiver)` - Tuple of transport and receiver

**Behavior:**

1. Creates unbounded MPSC channel
2. Wraps encryption in Arc for sharing
3. Returns transport (send side) and receiver (receive side)

**Rationale for Split:**

- Avoids mutex contention (separate ownership)
- Allows receiving on different task than sending
- Cleaner API (receiver can't accidentally send)

**Location:** `src-tauri/src/network/transport.rs:29`

**Example:**

```rust
let encryption = Arc::new(ChaCha20Encryption::new(key));
let (transport, mut receiver) = Transport::new(encryption);

// Use transport to send
transport.send(peer_addr, &message).await?;

// Use receiver to receive
if let Some((peer_id, message)) = receiver.receive().await {
    println!("Received from {}", peer_id);
}
```

### Listening

#### `listen() -> Result<u16>`

Starts listening for incoming connections on a random available port.

**Returns:** `Result<u16>` - Port number bound to

**Behavior:**

1. Binds TCP listener to `0.0.0.0:0` (any address, random port)
2. Queries actual port assigned by OS
3. Spawns accept loop in background task
4. Returns port number immediately

**Errors:**

- `AdapterError::Network` - If binding fails (port unavailable, permissions)

**Location:** `src-tauri/src/network/transport.rs:43`

**Background Task:**

- Accept loop runs indefinitely in spawned task
- Each accepted connection spawns dedicated handler task
- Continues until transport dropped

**Example:**

```rust
let port = transport.listen().await?;
println!("Listening on port {}", port);
// Now discoverable at this port via mDNS
```

### Connection Handling

#### `start_accept_loop(listener)` (private)

Spawns background task that accepts incoming connections.

**Parameters:**

- `listener: TcpListener` - Bound TCP listener

**Behavior:**

1. Spawns tokio task
2. Loops indefinitely accepting connections
3. Spawns handler for each accepted connection
4. Continues even if individual handlers fail

**Location:** `src-tauri/src/network/transport.rs:58`

**Concurrency:**

- Multiple connections handled concurrently
- Each connection has dedicated task
- No limit on concurrent connections (OS-limited)

#### `spawn_handler(stream, tx, encryption)` (private)

Spawns task to handle a single connection's message stream.

**Parameters:**

- `stream: TcpStream` - Accepted TCP connection
- `tx: mpsc::UnboundedSender` - Channel for forwarding messages
- `encryption: Arc<E>` - Encryption adapter

**Behavior:**

1. Spawns tokio task
2. Loops reading messages from stream
3. Forwards messages to channel
4. Breaks on error or connection close
5. Logs connection lifecycle events

**Location:** `src-tauri/src/network/transport.rs:71`

**Error Handling:**

- Treats "unexpected EOF" as normal closure
- Logs other errors as errors
- Always terminates cleanly

**Message Flow:**

```
TCP Stream → read_message → (PeerId, Message) → Channel → Application
```

### Sending Messages

#### `connect(addr) -> Result<TcpStream>`

Establishes TCP connection to remote peer.

**Parameters:**

- `addr: SocketAddr` - Peer's socket address (IP + port)

**Returns:** `Result<TcpStream>` - Connected stream

**Errors:**

- `AdapterError::Network` - Connection refused, timeout, network unreachable

**Location:** `src-tauri/src/network/transport.rs:116`

**Example:**

```rust
let stream = transport.connect(peer.addr).await?;
// Stream ready for writing messages
```

#### `send(addr, message) -> Result<()>`

Sends an encrypted message to a peer.

**Parameters:**

- `addr: SocketAddr` - Peer's socket address
- `message: &Message` - Message to send

**Returns:** `Result<()>` - Unit on success

**Behavior:**

1. Connects to peer
2. Writes encrypted message
3. Closes connection (no connection reuse currently)

**Errors:**

- `AdapterError::Network` - Connection or write failure
- `AdapterError::Encryption` - Encryption failure
- `AdapterError::Serialization` - Serialization failure

**Location:** `src-tauri/src/network/transport.rs:123`

**Performance Note:** Creates new TCP connection per message (no pooling)

**Example:**

```rust
let message = Message::Chat(chat_msg);
transport.send(peer.addr, &message).await?;
```

### Receiving Messages

#### `TransportReceiver::receive() -> Option<(PeerId, Message)>`

Receives next message from any connected peer.

**Returns:** `Option<(PeerId, Message)>` - Message or None if channel closed

**Behavior:**

- Waits asynchronously for message
- Returns first available message
- Order not guaranteed (multiple concurrent connections)
- Returns None when all senders dropped

**Location:** `src-tauri/src/network/transport.rs:22`

**Example:**

```rust
loop {
    match receiver.receive().await {
        Some((peer_id, message)) => {
            handle_message(peer_id, message).await;
        }
        None => {
            println!("Transport shut down");
            break;
        }
    }
}
```

## Connection Lifecycle

### Incoming Connections

```
1. TcpListener accepts connection
2. spawn_handler creates task for connection
3. Loop: read_message → forward to channel
4. On error/close: log and exit task
```

**Lifecycle States:**

- **Accepted**: Connection established
- **Active**: Reading messages in loop
- **Closed**: Error occurred or peer disconnected
- **Cleaned Up**: Task terminated

### Outgoing Connections

```
1. connect() establishes TCP connection
2. write_message sends encrypted message
3. Connection closed immediately
```

**Current Limitation:** No connection reuse (new connection per message)

**Future Improvement:** Connection pooling

## Concurrency & Thread Safety

### Shared State

```rust
encryption: Arc<E>           // Shared across all handlers (read-only)
incoming_tx: mpsc::Sender    // Cloned for each handler (thread-safe)
```

### Threading Model

```
Main Task
  ├─ Accept Loop (spawned)
  │   ├─ Handler 1 (per connection)
  │   ├─ Handler 2 (per connection)
  │   └─ Handler N (per connection)
  └─ Receiver Task (application)
```

**No Locks:** Uses message passing instead of shared mutable state

**Scalability:**

- Handlers run concurrently (Tokio async)
- No contention between handlers
- Channel buffering handles bursts

### Channel Characteristics

**Type:** `mpsc::unbounded_channel`

- Multiple producers (handlers)
- Single consumer (receiver)
- Unbounded buffer (no backpressure)

**Rationale:**

- Handlers shouldn't block on full buffer
- Memory growth bounded by connection count
- Simplifies error handling

## Error Handling

### Connection Errors

**Accept Failures:**

```rust
if let Ok((stream, _)) = listener.accept().await {
    // Spawn handler
}
// Failures logged, loop continues
```

**Strategy:** Best-effort (ignore individual accept failures)

### Read Errors

**EOF Handling:**

```rust
if format!("{}", e).contains("unexpected end of file") {
    log::info!("Connection closed (normal)");
} else {
    log::error!("Read error: {}", e);
}
break; // Always exit handler on error
```

**Strategy:** Treat EOF as normal, log others, always terminate handler

### Send Errors

**Propagation:**

```rust
pub async fn send(&self, addr: SocketAddr, message: &Message) -> Result<()> {
    let mut stream = self.connect(addr).await?;
    message_io::write_message(&mut stream, message, &*self.encryption).await
}
```

**Strategy:** Propagate errors to caller for handling

## Performance Considerations

### Connection Reuse

**Current:** New TCP connection per message
**Cost:** 3-way handshake + TLS handshake per message
**Typical:** ~10-50ms overhead per message

**Recommendation:** Implement connection pooling:

```rust
struct ConnectionPool {
    connections: HashMap<SocketAddr, TcpStream>,
}
```

### Handler Count

**Current:** One task per active connection
**Typical:** 5-20 concurrent connections (small network)
**Tokio Overhead:** ~2KB per task (negligible)

**Scalability:** Can handle hundreds of connections

### Channel Capacity

**Current:** Unbounded channel
**Risk:** Memory growth if consumer slow
**Typical:** 10-100 messages buffered (low memory)

**Recommendation:** Add bounded channel with backpressure if needed

## Security Considerations

### Encryption

**All Traffic Encrypted:**

- Every message encrypted before sending
- Every message decrypted after receiving
- No plaintext on wire

**Shared Key Model:**

- All peers share same encryption key
- No per-peer keys
- No key rotation

### Unauthenticated Connections

**Current Risk:** Any peer with encryption key can connect

**Mitigation:**

- Peer ID validated after first message
- Application-level authentication
- mDNS limits to local network

**Future:** Add connection-level authentication

### Resource Exhaustion

**DoS Risks:**

1. **Connection Flood**: Accept many connections
2. **Message Flood**: Send many messages per connection
3. **Slow Read**: Keep connections open without sending

**Current Protection:**

- OS limits on file descriptors (connections)
- No rate limiting
- No timeout on idle connections

**Recommendation:**

```rust
// Add connection limits
const MAX_CONNECTIONS: usize = 100;

// Add idle timeout
tokio::time::timeout(Duration::from_secs(300), handler_loop).await;
```

## Integration Points

### mDNS Network Adapter

**Usage:**

```rust
pub struct MdnsNetwork<E: EncryptionAdapter> {
    transport: Arc<Transport<E>>,
    receiver: Arc<Mutex<TransportReceiver>>,
}

impl NetworkAdapter for MdnsNetwork<E> {
    async fn start(&self) -> Result<()> {
        let port = self.transport.listen().await?;
        // Register port with mDNS discovery
    }

    async fn send_to_peer(&self, peer_id: &PeerId, message: Message) -> Result<()> {
        // Resolve peer_id to SocketAddr
        // Call transport.send(addr, message)
    }
}
```

### Application Layer

**Message Dispatch:**

```rust
let (transport, mut receiver) = Transport::new(encryption);
transport.listen().await?;

tokio::spawn(async move {
    while let Some((peer_id, message)) = receiver.receive().await {
        match message {
            Message::Presence(p) => presence_service.handle(peer_id, p).await,
            Message::Chat(c) => chat_service.handle(c).await,
            // ...
        }
    }
});
```

## Test Coverage

**Current Status:** No unit tests (0 tests)

**Testing Challenges:**

- Requires actual TCP connections
- Async testing complexity
- Timing-dependent behavior

**Recommended Tests:**

### Unit Tests (Future)

1. **Listen and Accept**

   ```rust
   #[tokio::test]
   async fn test_listen_accepts_connections() {
       let (transport, _rx) = Transport::new(Arc::new(mock_encryption()));
       let port = transport.listen().await?;

       // Connect from test client
       let client = TcpStream::connect(("127.0.0.1", port)).await?;
       // Verify connection accepted
   }
   ```

2. **Message Roundtrip**

   ```rust
   #[tokio::test]
   async fn test_send_and_receive() {
       let (transport, mut rx) = Transport::new(encryption);
       let port = transport.listen().await?;

       let message = Message::Presence(...);
       transport.send(("127.0.0.1", port).into(), &message).await?;

       let (peer_id, received) = rx.receive().await.unwrap();
       assert_eq!(received, message);
   }
   ```

3. **Concurrent Connections**

   ```rust
   #[tokio::test]
   async fn test_multiple_connections() {
       // Open 10 connections simultaneously
       // Send messages on all
       // Verify all received
   }
   ```

4. **Connection Close Handling**
   ```rust
   #[tokio::test]
   async fn test_connection_close_graceful() {
       // Accept connection
       // Close from client side
       // Verify handler terminates cleanly
   }
   ```

## Usage Examples

### Basic Setup

```rust
use network::transport::Transport;
use encryption::ChaCha20Encryption;

// Setup encryption
let key = derive_key_from_passphrase("shared-secret")?;
let encryption = Arc::new(ChaCha20Encryption::new(key));

// Create transport
let (transport, mut receiver) = Transport::new(encryption);

// Start listening
let port = transport.listen().await?;
println!("Listening on port {}", port);

// Spawn receiver task
tokio::spawn(async move {
    while let Some((peer_id, message)) = receiver.receive().await {
        println!("Message from {}: {:?}", peer_id, message);
    }
});
```

### Sending Messages

```rust
// Discover peer
let peer = discovery.get_peer("alice")?;

// Send message
let message = Message::Chat(ChatMessage {
    id: Uuid::new_v4().to_string(),
    peer_id: my_peer_id.to_string(),
    peer_name: my_peer_name.to_string(),
    content: "Hello!".to_string(),
    timestamp: current_timestamp(),
});

transport.send(peer.addr, &message).await?;
```

### Error Handling

```rust
match transport.send(peer.addr, &message).await {
    Ok(_) => println!("Message sent"),
    Err(AdapterError::Network(e)) => {
        eprintln!("Network error: {}", e);
        // Mark peer offline, retry later
    }
    Err(e) => eprintln!("Unexpected error: {}", e),
}
```

## Future Improvements

### Connection Pooling

```rust
struct ConnectionPool {
    connections: Arc<Mutex<HashMap<SocketAddr, TcpStream>>>,
}

impl ConnectionPool {
    async fn get_or_connect(&self, addr: SocketAddr) -> Result<TcpStream> {
        let mut pool = self.connections.lock().await;
        if let Some(stream) = pool.get(&addr) {
            return Ok(stream.clone());
        }
        let stream = TcpStream::connect(addr).await?;
        pool.insert(addr, stream.clone());
        Ok(stream)
    }
}
```

### Connection Limits

```rust
const MAX_CONNECTIONS: usize = 100;

fn start_accept_loop(&self, listener: TcpListener) {
    let connection_count = Arc::new(AtomicUsize::new(0));

    tokio::spawn(async move {
        loop {
            if connection_count.load(Ordering::Relaxed) >= MAX_CONNECTIONS {
                tokio::time::sleep(Duration::from_millis(100)).await;
                continue;
            }

            if let Ok((stream, _)) = listener.accept().await {
                connection_count.fetch_add(1, Ordering::Relaxed);
                // Spawn handler with connection_count.fetch_sub on drop
            }
        }
    });
}
```

### Idle Timeout

```rust
fn spawn_handler(mut stream: TcpStream, ...) {
    tokio::spawn(async move {
        let result = tokio::time::timeout(
            Duration::from_secs(300),
            message_loop(&mut stream, tx, encryption)
        ).await;

        if result.is_err() {
            log::info!("Connection timed out after 300s of inactivity");
        }
    });
}
```

### Metrics

```rust
struct TransportMetrics {
    connections_accepted: AtomicUsize,
    messages_received: AtomicUsize,
    messages_sent: AtomicUsize,
    bytes_received: AtomicUsize,
    bytes_sent: AtomicUsize,
}
```

## Related Documentation

- **Message I/O:** `spec/backend/network/message-io.md`
- **mDNS Network:** `spec/backend/network/mdns.md` (this file)
- **Discovery:** `spec/backend/network/discovery.md`
- **Encryption:** `spec/backend/encryption/chacha20.md` (to be created)
- **Network Adapter:** `spec/backend/domain/ports.md` (to be created)
