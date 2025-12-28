# mDNS Network Adapter Specification

## Overview

The **MdnsNetwork** adapter implements the `NetworkAdapter` trait, providing a complete peer-to-peer networking solution that combines mDNS service discovery with encrypted TCP transport.

**Module:** `src-tauri/src/network/mdns.rs`

**Key Responsibilities:**

- Implement NetworkAdapter trait for application layer
- Integrate Discovery (mDNS) and Transport (TCP) modules
- Start/stop network services
- Send messages to specific peers
- Broadcast messages to all discovered peers
- Receive messages from any peer
- Track connected peers

## Architecture

### Service Structure

```rust
pub struct MdnsNetwork<E: EncryptionAdapter + Send + Sync + 'static> {
    _encryption: Arc<E>,
    my_peer_id: PeerId,
    discovery: Arc<Mutex<Option<Discovery>>>,
    transport: Arc<Transport<E>>,
    receiver: Arc<Mutex<TransportReceiver>>,
}
```

### Design Patterns

1. **Adapter Pattern**: Implements NetworkAdapter trait
2. **Facade Pattern**: Simplifies Discovery + Transport interaction
3. **Dependency Injection**: Accepts generic EncryptionAdapter
4. **Lazy Initialization**: Discovery created on start()

### Component Integration

```
┌──────────────────────────────────────────┐
│ MdnsNetwork (NetworkAdapter)            │
│  ┌────────────┐      ┌────────────┐    │
│  │ Discovery  │      │ Transport  │    │
│  │ (mDNS)     │◄────►│ (TCP)      │    │
│  └────────────┘      └────────────┘    │
└──────────────────────────────────────────┘
         │                      │
         ↓                      ↓
    Peer Addresses          Message I/O
```

**Discovery:** Provides peer address resolution
**Transport:** Handles encrypted message transmission

## Public API

### Constructor

#### `new(my_peer_id, encryption) -> Self`

Creates a new mDNS network adapter.

**Parameters:**

- `my_peer_id: PeerId` - Local peer identifier
- `encryption: E` - Encryption adapter instance

**Returns:** `MdnsNetwork<E>` instance

**Behavior:**

1. Wraps encryption in Arc for sharing
2. Creates Transport and receiver
3. Wraps components for thread-safe sharing
4. Discovery not initialized yet (lazy)

**Location:** `src-tauri/src/network/mdns.rs:20`

**Example:**

```rust
let encryption = ChaCha20Encryption::new(key);
let network = MdnsNetwork::new(
    PeerId::new("alice"),
    encryption
);
```

## NetworkAdapter Implementation

### Starting Network

#### `start() -> Result<()>`

Starts both transport and discovery services.

**Returns:** `Result<()>` - Unit on success

**Behavior:**

1. Start transport listening (get random port)
2. Create discovery with peer ID and port
3. Register mDNS service (make discoverable)
4. Start browsing for peers
5. Store discovery instance

**Errors:**

- `AdapterError::Network` - If listening or mDNS registration fails

**Location:** `src-tauri/src/network/mdns.rs:36`

**Sequence:**

```
1. transport.listen() → port
2. Discovery::new(peer_id, port)
3. discovery.register()
4. discovery.browse()
5. Store discovery
```

**Example:**

```rust
network.start().await?;
// Now discoverable and discovering other peers
```

### Sending Messages

#### `send_to_peer(peer_id, message) -> Result<()>`

Sends a message to a specific peer.

**Parameters:**

- `peer_id: &PeerId` - Target peer identifier
- `message: Message` - Message to send

**Returns:** `Result<()>` - Unit on success

**Behavior:**

1. Lock discovery
2. Get all discovered peers
3. Find peer matching peer_id
4. Send message to peer's address via transport
5. Log warning if peer not found

**Errors:**

- `AdapterError::Network` - If send fails

**Silent Failures:**

- If peer not found in discovery (logs warning, returns Ok)
- If discovery not initialized (logs warning, returns Ok)

**Location:** `src-tauri/src/network/mdns.rs:52`

**Example:**

```rust
let message = Message::Chat(chat_msg);
network.send_to_peer(&PeerId::new("bob"), message).await?;
```

#### `broadcast(message) -> Result<()>`

Sends a message to all discovered peers.

**Parameters:**

- `message: Message` - Message to broadcast

**Returns:** `Result<()>` - Unit on success

**Behavior:**

1. Lock discovery
2. Get all discovered peers
3. Release discovery lock (avoid holding during sends)
4. Send message to each peer sequentially
5. Ignore individual send failures (best-effort)

**Errors:**

- None propagated (individual failures logged)

**Location:** `src-tauri/src/network/mdns.rs:75`

**Best-Effort Delivery:**

```rust
for peer in peers {
    let _ = self.transport.send(peer.addr, &message).await;
    // Failures ignored, broadcast continues
}
```

**Example:**

```rust
let presence = Message::Presence(PresenceMessage::Online { ... });
network.broadcast(presence).await?;
// All discovered peers notified
```

### Receiving Messages

#### `receive() -> Result<(PeerId, Message)>`

Receives next incoming message from any peer.

**Returns:** `Result<(PeerId, Message)>` - Sender and message

**Behavior:**

- Locks receiver
- Waits for next message on channel
- Returns message or error if channel closed

**Errors:**

- `AdapterError::Network("Channel closed")` - If receiver closed

**Location:** `src-tauri/src/network/mdns.rs:97`

**Blocking:** Waits asynchronously until message arrives

**Example:**

```rust
loop {
    let (peer_id, message) = network.receive().await?;
    handle_message(peer_id, message).await;
}
```

### Peer Management

#### `get_connected_peers() -> Result<Vec<PeerId>>`

Returns list of currently discovered peer IDs.

**Returns:** `Result<Vec<PeerId>>` - List of peer IDs

**Behavior:**

1. Lock discovery
2. Get all peers
3. Extract and return peer IDs
4. Returns empty vector if discovery not initialized

**Location:** `src-tauri/src/network/mdns.rs:111`

**Example:**

```rust
let peers = network.get_connected_peers().await?;
println!("Online peers: {}", peers.len());
for peer_id in peers {
    println!("  - {}", peer_id);
}
```

### Stopping Network

#### `stop() -> Result<()>`

Stops network services.

**Returns:** `Result<()>` - Unit on success

**Behavior:**

- Sets discovery to None (drops Discovery instance)
- Transport continues running (no explicit stop)

**Location:** `src-tauri/src/network/mdns.rs:106`

**Cleanup:**

- mDNS service deregistered (when Discovery dropped)
- Transport listener continues (limitation)
- Existing connections remain active

**Example:**

```rust
network.stop().await?;
// No longer discoverable, but can still receive connections
```

## State Management

### Discovery Lifecycle

```rust
discovery: Arc<Mutex<Option<Discovery>>>
```

**States:**

- **None**: Before start() or after stop()
- **Some(Discovery)**: Active discovery service

**Why Option:**

- Allows lazy initialization
- Supports clean shutdown
- Enables restart capability

### Locking Strategy

**Discovery Lock:**

- Held during peer lookups (send_to_peer, get_connected_peers)
- Released quickly after getting peer list
- Held during start/stop operations

**Receiver Lock:**

- Held during receive() call
- Only one task should call receive() (single consumer)

**Transport:**

- No lock (Arc-shared, internally thread-safe)

## Message Routing

### Outgoing Messages

```
Application → send_to_peer → Discovery (resolve) → Transport (send) → TCP → Peer
```

**Steps:**

1. Application calls send_to_peer(peer_id, message)
2. Discovery resolves peer_id to SocketAddr
3. Transport establishes TCP connection
4. Message encrypted and sent
5. Connection closed

### Incoming Messages

```
Peer → TCP → Transport (accept) → read_message → Channel → Application
```

**Steps:**

1. Transport accepts TCP connection
2. Reads encrypted message
3. Decrypts and deserializes
4. Forwards to channel
5. Application receives via receive()

### Broadcast Flow

```
Application → broadcast → Discovery (get all) → Transport (send to each) → Peers
```

**Parallel vs Sequential:**

- Current: Sequential sends
- Future: Parallel sends with join_all

## Error Handling

### Send Failures

**Peer Not Found:**

```rust
if let Some(peer) = peers.iter().find(|p| &p.peer_id == peer_id) {
    self.transport.send(peer.addr, &message).await?;
} else {
    log::warn!("Peer {} not found", peer_id.as_str());
}
```

**Strategy:** Log and return Ok (silent failure)

**Rationale:**

- Peer might have just disconnected
- Discovery updates asynchronous
- Caller doesn't need to handle

### Broadcast Failures

```rust
for peer in peers {
    let _ = self.transport.send(peer.addr, &message).await;
    // Ignore failures, continue broadcasting
}
```

**Strategy:** Best-effort delivery

**Tradeoff:** No feedback on partial failures

### Receive Failures

```rust
.ok_or_else(|| AdapterError::Network("Channel closed".to_string()))
```

**Strategy:** Convert None to error

**When:** Channel closed (all senders dropped, transport shut down)

## Performance Considerations

### Discovery Lock Contention

**Potential Bottleneck:**

```rust
let discovery = self.discovery.lock().await;  // Lock held
let peers = disc.get_peers().await;
drop(discovery);  // Explicitly released before sends
```

**Mitigation:** Drop lock before slow operations (network sends)

### Sequential Broadcasts

**Current:**

```rust
for peer in peers {
    let _ = self.transport.send(peer.addr, &message).await;
}
```

**Improvement:**

```rust
use futures::future::join_all;

let sends = peers.iter().map(|peer| {
    self.transport.send(peer.addr, &message)
});
join_all(sends).await;
```

**Benefit:** 10x+ faster for 10 peers

### Connection Per Message

**Cost:** TCP handshake per message (~10-50ms)

**Volume:** Acceptable for low-frequency messages (presence updates, chat)

**Improvement:** Connection pooling (see transport spec)

## Security Considerations

### Peer Validation

**Current:**

- Peer ID extracted from message payload (not connection)
- No authentication of peer identity
- Relies on shared encryption key

**Risk:** Peer spoofing (send messages claiming to be another peer)

**Mitigation:**

- Application-level validation
- CRDT conflict resolution (last-write-wins)

### Network Exposure

**Scope:** Local network only (mDNS limitation)

**Visibility:**

- All peers on LAN can discover service
- Encrypted traffic prevents eavesdropping
- IP addresses visible to network

### DoS Protection

**Risks:**

1. **Broadcast Amplification**: Attacker sends message, all peers receive
2. **Discovery Flooding**: Many fake mDNS announcements
3. **Connection Flooding**: Many TCP connections

**Current Protection:**

- Shared key limits attackers to local network with key
- OS-level connection limits
- mDNS rate limiting (protocol-level)

**Recommendations:**

- Rate limit broadcasts (e.g., max 10/second)
- Peer reputation system
- Connection limits per IP

## Integration Points

### Application Layer

**Typical Usage:**

```rust
let network = Arc::new(MdnsNetwork::new(my_peer_id, encryption));

// Start network
network.start().await?;

// Spawn receiver task
let network_clone = network.clone();
tokio::spawn(async move {
    loop {
        match network_clone.receive().await {
            Ok((peer_id, message)) => dispatch_message(peer_id, message).await,
            Err(e) => {
                log::error!("Network receive error: {}", e);
                break;
            }
        }
    }
});

// Send presence updates
let presence = PresenceMessage::Online { ... };
network.broadcast(Message::Presence(presence)).await?;

// Send chat message to specific peer
let chat = ChatMessage { ... };
network.send_to_peer(&bob_peer_id, Message::Chat(chat)).await?;
```

### Service Layer

**PresenceService:**

```rust
impl PresenceService {
    async fn broadcast_status(&self) {
        let message = Message::Presence(self.get_my_presence());
        self.network.broadcast(message).await.ok();
    }
}
```

**ChatService:**

```rust
impl ChatService {
    async fn send_message(&self, content: String) -> Result<ChatMessage> {
        let msg = self.create_message(content)?;
        self.network.broadcast(Message::Chat(msg.clone())).await?;
        Ok(msg)
    }
}
```

## Test Coverage

**Current Status:** No unit tests (0 tests)

**Testing Challenges:**

- Requires mDNS (network access)
- Async trait testing
- Integration of multiple components

**Recommended Tests:**

### Integration Tests (Future)

1. **Start and Discovery**

   ```rust
   #[tokio::test]
   async fn test_two_peers_discover() {
       let network1 = MdnsNetwork::new(PeerId::new("alice"), encryption1);
       let network2 = MdnsNetwork::new(PeerId::new("bob"), encryption2);

       network1.start().await?;
       network2.start().await?;

       tokio::time::sleep(Duration::from_secs(2)).await;

       let peers1 = network1.get_connected_peers().await?;
       assert!(peers1.contains(&PeerId::new("bob")));
   }
   ```

2. **Send and Receive**

   ```rust
   #[tokio::test]
   async fn test_send_receive() {
       // Setup two networks
       // Send message from network1 to network2
       // Verify network2 receives message
   }
   ```

3. **Broadcast**
   ```rust
   #[tokio::test]
   async fn test_broadcast_to_multiple() {
       // Setup 3 networks
       // Broadcast from network1
       // Verify network2 and network3 both receive
   }
   ```

## Usage Examples

### Complete Setup

```rust
use network::mdns::MdnsNetwork;
use encryption::ChaCha20Encryption;

// Setup encryption
let key = derive_key_from_passphrase("my-secret-passphrase")?;
let encryption = ChaCha20Encryption::new(key);

// Create network
let network = Arc::new(MdnsNetwork::new(
    PeerId::new("alice"),
    encryption
));

// Start services
network.start().await?;
println!("Network started, discoverable on local network");

// Spawn receiver
let network_clone = network.clone();
tokio::spawn(async move {
    loop {
        match network_clone.receive().await {
            Ok((peer_id, message)) => {
                println!("Received from {}: {:?}", peer_id, message);
            }
            Err(e) => {
                eprintln!("Receive error: {}", e);
                break;
            }
        }
    }
});

// Use network
let peers = network.get_connected_peers().await?;
println!("Connected peers: {:?}", peers);
```

### Graceful Shutdown

```rust
// Stop network
network.stop().await?;
println!("Network stopped");

// Wait for receiver task to finish
// (will error when channel closes)
```

## Future Improvements

### Parallel Broadcasts

```rust
async fn broadcast(&self, message: Message) -> Result<()> {
    let peers = self.get_peers().await;

    let sends: Vec<_> = peers.iter()
        .map(|peer| self.transport.send(peer.addr, &message))
        .collect();

    let results = join_all(sends).await;

    // Report partial failures
    let failed = results.iter().filter(|r| r.is_err()).count();
    if failed > 0 {
        log::warn!("Broadcast: {}/{} peers failed", failed, peers.len());
    }

    Ok(())
}
```

### Connection Pooling

```rust
pub struct MdnsNetwork<E> {
    transport: Arc<Transport<E>>,
    connections: Arc<Mutex<HashMap<PeerId, TcpStream>>>,
}

async fn send_to_peer(&self, peer_id: &PeerId, message: Message) -> Result<()> {
    let addr = self.resolve_peer(peer_id).await?;

    let mut connections = self.connections.lock().await;
    let stream = connections.entry(peer_id.clone())
        .or_insert_with(|| self.transport.connect(addr).await?);

    message_io::write_message(stream, &message, &self.encryption).await
}
```

### Metrics and Monitoring

```rust
pub struct NetworkMetrics {
    messages_sent: AtomicUsize,
    messages_received: AtomicUsize,
    broadcasts: AtomicUsize,
    active_peers: AtomicUsize,
}

impl MdnsNetwork<E> {
    pub fn metrics(&self) -> NetworkMetrics {
        // Return snapshot of metrics
    }
}
```

### Retry Logic

```rust
async fn send_to_peer_with_retry(
    &self,
    peer_id: &PeerId,
    message: Message
) -> Result<()> {
    let mut attempts = 0;
    loop {
        match self.send_to_peer(peer_id, message.clone()).await {
            Ok(_) => return Ok(()),
            Err(e) if attempts < 3 => {
                attempts += 1;
                tokio::time::sleep(Duration::from_millis(100 * attempts)).await;
            }
            Err(e) => return Err(e),
        }
    }
}
```

## Related Documentation

- **Network Adapter Trait:** `spec/backend/domain/ports.md` (to be created)
- **Transport:** `spec/backend/network/transport.md`
- **Discovery:** `spec/backend/network/discovery.md`
- **Message I/O:** `spec/backend/network/message-io.md`
- **Encryption:** `spec/backend/encryption/chacha20.md` (to be created)
