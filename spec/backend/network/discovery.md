# Network Discovery Specification

## Overview

The **Discovery** module provides mDNS-based (Multicast DNS) service discovery for peer-to-peer networking in Lighten-Up. It enables peers on the same local network to automatically discover each other without requiring centralized coordination or manual configuration.

**Module:** `src-tauri/src/network/discovery.rs`

**Key Responsibilities:**

- Register local peer as an mDNS service
- Browse and discover remote peers on the local network
- Maintain a registry of discovered peers
- Filter out self-discovery events
- Handle peer connection and disconnection events

## Architecture

### Service Structure

```rust
pub struct Discovery {
    daemon: ServiceDaemon,                           // mdns-sd service daemon
    my_peer_id: PeerId,                              // Local peer identifier
    my_port: u16,                                    // Local port for connections
    peers: Arc<Mutex<HashMap<String, PeerConnection>>>, // Discovered peers
}
```

### Design Patterns

1. **Service Discovery Pattern**: Uses mDNS/Bonjour for zero-config networking
2. **Observer Pattern**: Asynchronously handles mDNS events
3. **Registry Pattern**: Maintains central registry of discovered peers
4. **Thread Bridge**: Bridges synchronous mDNS callbacks to async Tokio runtime

### Dependencies

- `mdns-sd` - mDNS service discovery implementation
- `if-addrs` - Network interface address discovery
- `tokio` - Async runtime for event handling
- `domain::PeerId` - Strongly-typed peer identifier
- `network::peer_info::PeerConnection` - Peer connection information
- `network::discovery_handler` - Event processing logic

## Data Structures

### Discovery

```rust
pub struct Discovery {
    daemon: ServiceDaemon,
    my_peer_id: PeerId,
    my_port: u16,
    peers: Arc<Mutex<HashMap<String, PeerConnection>>>,
}
```

**Fields:**

- `daemon`: mDNS service daemon managing service registration and browsing
- `my_peer_id`: Unique identifier for this peer (e.g., "alice", "bob")
- `my_port`: TCP port where this peer listens for connections
- `peers`: Thread-safe registry of discovered peers (key: peer_id string)

### PeerConnection

```rust
pub struct PeerConnection {
    pub peer_id: PeerId,
    pub addr: SocketAddr,
}
```

**Fields:**

- `peer_id`: Unique peer identifier (wrapped String)
- `addr`: Network socket address (IP + port)

### PeerId

```rust
pub struct PeerId(String);
```

**Properties:**

- Strongly-typed wrapper around String
- Implements `PartialEq`, `Eq`, `Hash` for use as HashMap keys
- Implements `Clone` for sharing across threads
- Serializable via Serde

## Constants

### SERVICE_TYPE

```rust
const SERVICE_TYPE: &str = "_lightenup._tcp.local.";
```

**Purpose:** mDNS service type identifier for Lighten-Up applications

**Format:** `_<service>._<protocol>.local.`

- `lightenup`: Application-specific service name
- `tcp`: Transport protocol
- `local`: mDNS local domain

**Usage:** Used for both service registration and browsing to ensure all Lighten-Up instances use the same service type.

## Public API

### Constructor

#### `new(my_peer_id, my_port) -> Result<Self>`

Creates a new Discovery manager instance.

**Parameters:**

- `my_peer_id: PeerId` - Unique identifier for this peer
- `my_port: u16` - TCP port for incoming connections

**Returns:** `Result<Discovery>` - New Discovery instance or error

**Behavior:**

1. Creates mDNS service daemon
2. Initializes peer registry (empty HashMap)
3. Returns Discovery instance (does not start browsing yet)

**Errors:**

- `AdapterError::Network` - If mDNS daemon creation fails

**Location:** `src-tauri/src/network/discovery.rs:23`

**Example:**

```rust
let discovery = Discovery::new(
    PeerId::new("alice"),
    3030
)?;
```

### Service Registration

#### `register() -> Result<()>`

Registers this peer as an mDNS service, making it discoverable by other peers.

**Returns:** `Result<()>` - Unit on success

**Behavior:**

1. Constructs instance name from peer ID (e.g., "alice")
2. Constructs hostname: `<peer_id>.local.` (e.g., "alice.local.")
3. Detects local IP address (non-loopback IPv4)
4. Falls back to 127.0.0.1 if detection fails
5. Creates ServiceInfo with all parameters
6. Registers service with mDNS daemon
7. Logs registration details

**Errors:**

- `AdapterError::Network` - If service registration fails

**Location:** `src-tauri/src/network/discovery.rs:36`

**IP Address Detection:**

- Uses `if-addrs` crate to enumerate network interfaces
- Filters for non-loopback interfaces
- Prefers IPv4 addresses
- Falls back to localhost (127.0.0.1) if no suitable interface found

**Example:**

```rust
discovery.register()?;
// Now discoverable as "alice._lightenup._tcp.local." on the network
```

### Service Browsing

#### `browse() -> Result<()>`

Starts browsing for other Lighten-Up peers on the local network.

**Returns:** `Result<()>` - Unit on success (browsing happens in background)

**Behavior:**

1. Starts mDNS browsing for `SERVICE_TYPE`
2. Spawns background thread for event processing
3. Bridges synchronous mDNS receiver to async Tokio runtime
4. Delegates event handling to `discovery_handler::handle_event`
5. Returns immediately (browsing continues in background)

**Errors:**

- `AdapterError::Network` - If browsing initialization fails

**Location:** `src-tauri/src/network/discovery.rs:79`

**Threading Model:**

- Creates std::thread for synchronous mDNS event receiver
- Uses `tokio::runtime::Handle::current()` to spawn async tasks
- Each event handled in separate Tokio task
- Thread continues until mDNS daemon stops

**Concurrency:**

- Multiple events can be processed concurrently
- Peer registry protected by `Arc<Mutex<_>>`
- Self-filtering handled per-event

**Example:**

```rust
discovery.browse()?;
// Background thread now listening for peer discovery events
```

### Peer Retrieval

#### `get_peers() -> Vec<PeerConnection>`

Returns a snapshot of all currently discovered peers.

**Returns:** `Vec<PeerConnection>` - List of discovered peers

**Behavior:**

1. Acquires lock on peer registry
2. Clones all peer connections
3. Returns as vector

**Location:** `src-tauri/src/network/discovery.rs:110`

**Performance:**

- Creates owned copies of peer connections (clone)
- Lock held only during clone operation
- Safe to iterate without holding lock

**Example:**

```rust
let peers = discovery.get_peers().await;
for peer in peers {
    println!("Peer: {} at {}", peer.peer_id, peer.addr);
}
```

## Event Handling

### Discovery Handler Module

**Module:** `src-tauri/src/network/discovery_handler.rs`

The discovery handler processes mDNS events and updates the peer registry.

#### Event Types

##### ServiceResolved

**Trigger:** mDNS successfully resolves a peer's service information

**Handling:**

1. Extract peer ID from service fullname
2. Extract IP address from resolved addresses
3. Create `PeerConnection` with peer ID and socket address
4. Filter out self (if peer ID matches `my_peer_id`)
5. Insert peer into registry
6. Log peer discovery

**Location:** `discovery_handler.rs:17`

##### ServiceRemoved

**Trigger:** Previously discovered peer disappears from network

**Handling:**

1. Extract peer ID from service fullname
2. Remove peer from registry
3. Log peer removal

**Location:** `discovery_handler.rs:33`

##### Other Events

**Trigger:** Other mDNS events (SearchStarted, SearchStopped, etc.)

**Handling:**

- Log event at debug level
- No action taken

**Location:** `discovery_handler.rs:39`

### Self-Filtering

**Purpose:** Prevent adding own service to peer list

**Implementation:**

```rust
if peer_id == *my_peer_id {
    log::debug!("Skipping self: {}", peer_id.as_str());
    return None;
}
```

**Location:** `discovery_handler.rs:49`

**Rationale:**

- mDNS broadcasts include own service
- Connecting to self would create confusion
- Filter at extraction stage before registry insertion

## Concurrency & Thread Safety

### Thread Architecture

```
┌─────────────────────────────────────────────┐
│ Main Thread (Tokio Async Runtime)          │
│  - browse() called                          │
│  - get_peers() called                       │
└──────────────────┬──────────────────────────┘
                   │
                   │ spawns
                   ↓
┌─────────────────────────────────────────────┐
│ mDNS Event Thread (std::thread)             │
│  - Synchronous receiver.recv() loop         │
│  - Blocks waiting for mDNS events           │
└──────────────────┬──────────────────────────┘
                   │
                   │ spawns (per event)
                   ↓
┌─────────────────────────────────────────────┐
│ Event Handler Tasks (Tokio)                │
│  - discovery_handler::handle_event()        │
│  - Updates peer registry                    │
└─────────────────────────────────────────────┘
```

### Synchronization Mechanisms

#### Peer Registry

```rust
peers: Arc<Mutex<HashMap<String, PeerConnection>>>
```

**Thread Safety:**

- `Arc`: Allows shared ownership across threads
- `Mutex`: Ensures exclusive access during reads/writes
- Cloned before passing to background thread

**Lock Scope:**

- Minimal lock duration
- Lock acquired only during registry operations
- Clones data before releasing lock

**Contention:**

- Low contention expected (infrequent discovery events)
- Read operations (get_peers) clone entire registry
- Write operations (insert/remove) hold lock briefly

### Runtime Bridge

**Challenge:** mdns-sd library uses synchronous blocking I/O, but application uses Tokio async runtime

**Solution:**

```rust
let runtime_handle = tokio::runtime::Handle::current();
std::thread::spawn(move || {
    while let Ok(event) = receiver.recv() {
        runtime_handle.spawn(async move {
            discovery_handler::handle_event(event, &peers, &my_peer_id).await;
        });
    }
});
```

**Benefits:**

- Synchronous mDNS events handled in dedicated thread
- Async event processing leverages Tokio runtime
- Non-blocking: events processed concurrently
- Clean separation of concerns

## Error Handling

### Error Types

All Discovery errors wrapped in `AdapterError::Network`:

```rust
AdapterError::Network(String)
```

### Error Scenarios

#### mDNS Daemon Creation Failure

**Cause:** System resources unavailable, permissions issue

**Error:** `"Failed to create mDNS daemon: <underlying error>"`

**Recovery:** Cannot proceed without daemon; return error to caller

#### Service Registration Failure

**Cause:** Invalid service parameters, network unavailable

**Errors:**

- `"Failed to create service info: <error>"`
- `"Failed to register service: <error>"`

**Recovery:** Log error, return to caller (app may still browse without registering)

#### Browse Initialization Failure

**Cause:** mDNS daemon not ready, service type invalid

**Error:** `"Failed to browse services: <error>"`

**Recovery:** Return error to caller (app may still accept connections)

### Error Propagation

```rust
pub fn register(&self) -> Result<()> {
    self.daemon
        .register(service_info)
        .map_err(|e| AdapterError::Network(format!("Failed to register service: {}", e)))?;
    Ok(())
}
```

**Pattern:**

- Use `.map_err()` to wrap underlying errors
- Add context-specific error messages
- Propagate with `?` operator

## Integration Points

### Application Startup

**Typical Initialization Sequence:**

```rust
// 1. Create discovery manager
let discovery = Discovery::new(my_peer_id, my_port)?;

// 2. Register our service (make ourselves discoverable)
discovery.register()?;

// 3. Start browsing for peers
discovery.browse()?;

// 4. Periodically check for peers
let peers = discovery.get_peers().await;
```

### Network Layer

**Used By:** Network connection manager

**Integration Flow:**

1. Discovery finds peer via mDNS
2. Peer connection info stored in registry
3. Network layer retrieves peers via `get_peers()`
4. Network layer initiates TCP connection to peer's address
5. Handshake and message exchange begin

### Frontend

**Integration:** Discovered peers displayed in UI

**Event Flow:**

1. Discovery updates peer registry
2. Application polls `get_peers()` periodically
3. Peers list sent to frontend via Tauri events
4. UI displays online peers

## Test Coverage

**Current Status:** No unit tests (0 tests)

**Testing Challenges:**

- mDNS requires actual network interfaces
- Timing-dependent (async event handling)
- Difficult to mock mdns-sd library

**Recommended Test Strategy:**

### Unit Tests (Future)

1. **Self-Filtering Test**
   - Mock service events with own peer ID
   - Verify peer not added to registry

2. **Peer Addition Test**
   - Mock ServiceResolved event
   - Verify peer added to registry
   - Verify `get_peers()` returns new peer

3. **Peer Removal Test**
   - Add peer, then mock ServiceRemoved event
   - Verify peer removed from registry

4. **IP Address Selection Test**
   - Mock multiple network interfaces
   - Verify non-loopback IPv4 selected

### Integration Tests (Future)

1. **Two-Peer Discovery**
   - Launch two instances on same network
   - Verify mutual discovery

2. **Network Disconnection**
   - Discover peer, then disconnect network
   - Verify peer removed event

3. **Port Conflict**
   - Attempt registration with occupied port
   - Verify appropriate error

## Performance Considerations

### Memory Usage

**Peer Registry:**

- Each peer: ~50 bytes (PeerId + SocketAddr)
- Expected max peers: 10-20 on local network
- Total memory: < 1KB (negligible)

**Event Queue:**

- mDNS receiver uses internal buffer
- No application-level queue needed

### CPU Usage

**mDNS Operations:**

- Registration: One-time cost (minimal)
- Browsing: Background thread blocks on recv()
- Event handling: Spawns task per event (lightweight)

**Scalability:**

- Designed for small local networks (< 100 peers)
- No performance issues expected in typical use

### Network Traffic

**mDNS Bandwidth:**

- Multicast announcements: ~1KB per peer
- Queries: ~500 bytes
- Frequency: Every few seconds (managed by mdns-sd)

**Optimization:**

- Uses standard mDNS protocol (RFC 6762)
- No additional polling or keep-alive messages

## Security Considerations

### Attack Vectors

#### mDNS Spoofing

**Risk:** Malicious actor announces fake peer

**Impact:** Application might connect to malicious endpoint

**Mitigation:**

- Use encryption for all peer communication
- Verify peer identity during handshake
- Trust on first use (TOFU) model

#### Service Name Collision

**Risk:** Another application uses same service type

**Impact:** Discover non-Lighten-Up services

**Mitigation:**

- Use unique service type: `_lightenup._tcp.local.`
- Validate peer during handshake protocol

#### Denial of Service

**Risk:** Flood network with mDNS announcements

**Impact:** High CPU usage processing events

**Mitigation:**

- mDNS protocol includes rate limiting
- OS-level mDNS handling provides some protection
- Consider adding application-level rate limiting

### Network Exposure

**Visibility:** All peers on local network can see service announcement

**Information Disclosed:**

- Peer ID (username)
- IP address
- Port number

**Privacy Implications:**

- No sensitive data in service announcement
- Peer ID may reveal identity
- Consider allowing custom peer IDs

## Usage Examples

### Basic Discovery Setup

```rust
use crate::network::Discovery;
use crate::domain::PeerId;

// Create discovery manager
let my_peer_id = PeerId::new("alice");
let my_port = 3030;
let discovery = Discovery::new(my_peer_id, my_port)?;

// Register our service
discovery.register()?;
println!("Registered as 'alice' on port 3030");

// Start browsing for peers
discovery.browse()?;
println!("Now browsing for peers...");

// Wait a moment for discovery
tokio::time::sleep(tokio::time::Duration::from_secs(2)).await;

// Get discovered peers
let peers = discovery.get_peers().await;
println!("Found {} peers:", peers.len());
for peer in peers {
    println!("  - {} at {}", peer.peer_id, peer.addr);
}
```

### Continuous Peer Monitoring

```rust
// Poll for peers periodically
let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(5));
loop {
    interval.tick().await;
    let peers = discovery.get_peers().await;

    if peers.is_empty() {
        println!("No peers online");
    } else {
        println!("Online peers:");
        for peer in peers {
            println!("  - {}", peer.peer_id);
        }
    }
}
```

### Error Handling

```rust
// Handle registration errors gracefully
match discovery.register() {
    Ok(_) => println!("Successfully registered service"),
    Err(e) => {
        eprintln!("Failed to register: {}", e);
        eprintln!("You may still discover peers, but won't be discoverable");
    }
}

// Handle browse errors
match discovery.browse() {
    Ok(_) => println!("Started browsing for peers"),
    Err(e) => {
        eprintln!("Failed to start browsing: {}", e);
        eprintln!("You may still accept incoming connections");
    }
}
```

## Protocol Details

### mDNS Service Format

**Full Service Name:**

```
<instance>._lightenup._tcp.local.
```

**Example:**

```
alice._lightenup._tcp.local.
```

**Components:**

- **Instance:** Peer ID (e.g., "alice")
- **Service:** Application identifier ("lightenup")
- **Protocol:** Transport protocol ("tcp")
- **Domain:** Local network domain ("local.")

### Service Info Fields

```rust
ServiceInfo {
    type: "_lightenup._tcp.local.",
    instance: "alice",
    host: "alice.local.",
    address: 192.168.1.100,
    port: 3030,
    properties: None,
}
```

### Discovery Timeline

```
T+0s:  Service registers with mDNS daemon
T+0s:  mDNS sends multicast announcement
T+1s:  Other peers receive announcement
T+1s:  Peers query for service details (optional)
T+2s:  Service info fully resolved
T+2s:  ServiceResolved event triggered
T+2s:  Peer added to registry
```

**Notes:**

- Timing varies based on network conditions
- mDNS protocol includes caching and refresh logic
- Peers re-announce periodically (handled by mdns-sd)

## Future Improvements

### Features

1. **Peer Metadata** - Include additional info in mDNS TXT records:
   - Peer display name
   - Application version
   - Supported features

2. **Discovery Events** - Expose event stream to application:
   - `PeerDiscovered(PeerConnection)`
   - `PeerLost(PeerId)`
   - Enable reactive UI updates

3. **Manual Peer Addition** - Allow adding peers by IP address:
   - Fallback when mDNS unavailable
   - Cross-subnet connections

4. **IPv6 Support** - Expand beyond IPv4:
   - Detect IPv6 addresses
   - Handle dual-stack scenarios

### Performance

1. **Peer Caching** - Persist discovered peers across app restarts:
   - Faster initial connection
   - Reconnect to known peers

2. **Connection Pooling** - Reuse discovered peer connections:
   - Avoid redundant TCP handshakes
   - Maintain persistent connections

### Reliability

1. **Health Checks** - Verify peer connectivity:
   - Periodic ping/pong
   - Remove unresponsive peers

2. **Reconnection Logic** - Handle transient network issues:
   - Exponential backoff
   - Automatic reconnection

### Security

1. **Service Authentication** - Verify peer legitimacy:
   - Challenge-response during handshake
   - Prevent unauthorized peers

2. **Encryption** - Protect mDNS announcements:
   - Optional encrypted peer ID
   - Privacy-preserving discovery

### Testing

1. **Mock mDNS Daemon** - Enable unit testing:
   - Simulate discovery events
   - Test error scenarios

2. **Integration Test Harness** - Automated discovery testing:
   - Launch multiple test peers
   - Verify mutual discovery

## Related Documentation

- **Network Layer:** `spec/backend/network/message-io.md` (to be created)
- **Peer Connection:** `spec/backend/network/peer-info.md` (to be created)
- **Domain Models:** `spec/backend/domain/peer-id.md` (to be created)
- **Error Handling:** `spec/backend/adapters/error.md` (to be created)
- **Protocol:** `docs/PROTOCOL.md`
