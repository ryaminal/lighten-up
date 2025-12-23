# Task 0: Network Architecture & Client Discovery

**Priority:** CRITICAL - Must be decided before all other implementation  
**Document Date:** 2025-12-23

---

## Overview

Before implementing any features, we must determine how clients discover each other and communicate. This foundational decision impacts:
- System architecture
- Deployment complexity
- Scalability
- Reliability
- Security model
- Implementation complexity
- Operational costs

---

## Architecture Options

### Option 1: Client-Server Architecture

**Description:**  
Traditional client-server model with a central server managing all state and routing messages.

#### How It Works:
1. **Bootstrap Process:**
   - Admin deploys server on local network (or cloud)
   - Server has known IP address or hostname
   - Clients connect to server using configured address
   - Server maintains registry of all connected clients
   - Server broadcasts state changes to all clients

2. **Communication Flow:**
   ```
   Client A → Server → Client B, C, D...
   ```

3. **State Management:**
   - Server is source of truth for all lights
   - Clients send actions to server
   - Server validates, processes, and broadcasts updates
   - Server persists state to database/file

#### Advantages:
- ✅ **Simpler to implement** - Well-understood patterns
- ✅ **Easier debugging** - Centralized logging and monitoring
- ✅ **Single source of truth** - No conflict resolution needed
- ✅ **Easier access control** - Server enforces permissions
- ✅ **Simpler client code** - Clients are "dumb terminals"
- ✅ **Easy analytics** - Server sees all activity
- ✅ **Easier to scale vertically** - Upgrade server hardware
- ✅ **Works across subnets** - Can route across network segments
- ✅ **Remote access easier** - Single endpoint to expose

#### Disadvantages:
- ❌ **Single point of failure** - If server down, system is down
- ❌ **Server must be maintained** - Requires dedicated hardware/VM
- ❌ **Higher latency** - Every message goes through server
- ❌ **Server bottleneck** - Limited by server resources
- ❌ **Deployment complexity** - Must set up and configure server
- ❌ **Cost** - May require dedicated hardware or hosting

#### Technical Requirements:
- Server software (needs to run 24/7)
- Database for persistence
- Network configuration (firewall rules, port forwarding)
- Client-server protocol (WebSocket, HTTP, custom TCP)
- Authentication/authorization system
- Server monitoring and logging

#### Best For:
- Organizations with IT staff
- Larger deployments (20+ workstations)
- Multi-location deployments
- Need for centralized control and auditing
- Remote access requirements

---

### Option 2: Peer-to-Peer with Discovery (Decentralized)

**Description:**  
Clients discover each other on the local network and communicate directly without a central server.

#### How It Works:
1. **Bootstrap Process:**
   - Client starts and broadcasts discovery message on local network
   - Other clients respond with their presence
   - Clients build a peer list dynamically
   - Each client maintains local copy of state
   - State changes are broadcast to all peers

2. **Communication Flow:**
   ```
   Client A ⟷ Client B
            ⟷ Client C
            ⟷ Client D
   
   (mesh network - everyone talks to everyone)
   ```

3. **State Management:**
   - Distributed state across all clients
   - Consensus mechanism for conflict resolution
   - Each client can operate independently
   - State synchronization via gossip protocol or CRDT

#### Discovery Mechanisms:
- **mDNS/Bonjour** - Apple's zero-configuration networking
- **UDP Broadcast** - Broadcast on local subnet
- **Multicast DNS** - Service discovery protocol
- **WebRTC** - Browser-based peer discovery

#### Advantages:
- ✅ **No single point of failure** - System works if any peer is alive
- ✅ **Zero infrastructure** - No server to deploy or maintain
- ✅ **Lower latency** - Direct peer-to-peer communication
- ✅ **Easy deployment** - Just install client, it auto-discovers
- ✅ **No ongoing costs** - No server hosting fees
- ✅ **Resilient** - Peers can join/leave without coordination
- ✅ **Privacy** - All data stays on local network

#### Disadvantages:
- ❌ **Complex implementation** - Distributed systems are hard
- ❌ **Conflict resolution** - Need consensus protocol (CRDTs, vector clocks)
- ❌ **Harder debugging** - No centralized logs
- ❌ **Network chattier** - More broadcast traffic
- ❌ **Limited by broadcast domain** - Only works on same subnet
- ❌ **Partial state** - New clients must sync from peers
- ❌ **NAT/Firewall issues** - Discovery may not work in complex networks
- ❌ **Analytics harder** - No central collection point
- ❌ **Remote access harder** - Must connect to specific peer

#### Technical Requirements:
- Network discovery protocol implementation
- Distributed state synchronization (CRDT or similar)
- Conflict resolution strategy
- Peer connection management
- Message ordering and delivery guarantees
- Local state persistence on each client

#### Best For:
- Small to medium deployments (5-20 workstations)
- Single location with simple network
- Organizations without IT staff
- Privacy-sensitive environments
- Need for system resilience

---

### Option 3: Hybrid Architecture

**Description:**  
Combination of client-server and P2P. Server exists for coordination but clients can communicate directly.

#### How It Works:
1. **Bootstrap Process:**
   - Optional server provides discovery assistance
   - Clients register with server (if available)
   - Clients also discover peers directly via mDNS
   - If server unavailable, fall back to P2P mode
   - Server helps with NAT traversal

2. **Communication Flow:**
   ```
   Normal mode: Client → Server → All Clients
   Fallback mode: Client A ⟷ Client B (direct P2P)
   ```

3. **State Management:**
   - Server is preferred source of truth when available
   - Clients maintain local state as backup
   - Graceful degradation if server offline
   - Re-sync when server comes back online

#### Advantages:
- ✅ **Best of both worlds** - Server benefits when available
- ✅ **Resilient** - Works without server in degraded mode
- ✅ **Flexible deployment** - Optional server for larger sites
- ✅ **Easier scaling** - Add server when organization grows

#### Disadvantages:
- ❌ **Most complex** - Must implement both architectures
- ❌ **More edge cases** - Server/P2P mode transitions
- ❌ **Harder to test** - Must test both modes and transitions
- ❌ **State synchronization complexity** - Merge conflicts between modes

#### Best For:
- Organizations that may grow
- Want resilience but need server features
- Multi-site deployments with local resilience

---

## Comparison Matrix

| Factor | Client-Server | P2P | Hybrid |
|--------|--------------|-----|--------|
| **Implementation Complexity** | Low | High | Very High |
| **Deployment Complexity** | Medium | Low | Medium |
| **Operational Complexity** | Medium | Low | High |
| **Resilience** | Low (SPOF) | High | High |
| **Scalability** | High | Medium | High |
| **Latency** | Medium | Low | Low-Medium |
| **Network Traffic** | Low | Medium | Medium |
| **Remote Access** | Easy | Hard | Easy |
| **Analytics** | Easy | Hard | Easy |
| **Cost** | Medium | Low | Medium |
| **Time to MVP** | Fast | Medium | Slow |

---

## Recommendation Based on BlueNote Analysis

Looking at the original BlueNote PRD and workflow documentation:

### What BlueNote Does:
- Mentions "Local network-based (peer-to-peer or client/server)" in technical requirements
- Emphasizes "Quick onboarding for new computers"
- Notes "Automatic license/registration propagation"
- States "System must function if one workstation is offline"
- Mentions "Central service managing license, configuration, global state"
- Emphasizes zero-configuration discovery

### BlueNote Appears to Use: **Client-Server with Resilience Features**

Evidence:
1. "Central service managing license, configuration, global state" - implies server
2. "System must function if one workstation is offline" - not "if server offline"
3. "Automatic license/registration propagation" - suggests central authority
4. "Quick onboarding" - auto-discovery of server via mDNS/Bonjour

---

## Recommended Approach for MVP

### Phase 1 MVP: **Simple Client-Server**

**Rationale:**
1. **Faster to implement** - Get to working product quicker
2. **Easier to debug** - Centralized logging during development
3. **Simpler state management** - No distributed consensus needed
4. **Matches BlueNote's model** - Proven approach
5. **Can add P2P later** - Not a one-way door decision

**Implementation:**
- Lightweight server (could be embedded in one client as "primary")
- WebSocket or HTTP-based protocol
- Server auto-discovery via mDNS/Bonjour
- SQLite or JSON file for persistence
- Simple token-based auth

### Future Phases: **Add Resilience**
- Implement server failover
- Allow any client to become "primary" if server fails
- Add P2P fallback mode
- Transition toward hybrid architecture if needed

---

## Task Breakdown for Network Architecture

### Task 0.1: Define Network Protocol

**Requirements:**
- Define message format (JSON, Protocol Buffers, etc.)
- Define message types (light_activated, light_deactivated, user_joined, etc.)
- Define versioning strategy
- Define error handling

**Acceptance Criteria:**
- [ ] Protocol specification document exists
- [ ] All message types are defined
- [ ] Message schema is versioned
- [ ] Error cases are documented

**Complexity:** Medium

---

### Task 0.2: Implement Server Discovery

**Requirements:**
- Client can discover server on local network automatically
- Support manual server configuration (IP/hostname)
- Graceful fallback if no server found
- Handle multiple servers (choose one)

**Acceptance Criteria:**
- [ ] Client auto-discovers server via mDNS/Bonjour
- [ ] Client supports manual server configuration
- [ ] Client handles "no server found" gracefully
- [ ] Discovery works across common network configurations

**Complexity:** Medium

---

### Task 0.3: Implement Server Core

**Requirements:**
- Server accepts client connections
- Server maintains registry of connected clients
- Server broadcasts messages to all clients
- Server persists state to storage
- Server handles client disconnections

**Acceptance Criteria:**
- [ ] Server accepts WebSocket/TCP connections
- [ ] Server tracks connected clients
- [ ] Server routes messages correctly
- [ ] Server persists state
- [ ] Server handles disconnections gracefully
- [ ] Server logs important events

**Complexity:** High

---

### Task 0.4: Implement Client Connection Management

**Requirements:**
- Client connects to discovered server
- Client maintains persistent connection
- Client reconnects on connection loss
- Client handles connection state changes
- Client queues messages during disconnection

**Acceptance Criteria:**
- [ ] Client establishes connection to server
- [ ] Client detects connection loss
- [ ] Client auto-reconnects with backoff
- [ ] Client queues messages during offline period
- [ ] Client UI shows connection status

**Complexity:** Medium

---

### Task 0.5: Implement Authentication & Authorization

**Requirements:**
- Server authenticates clients
- Support simple token or password auth
- Per-client identity and role
- Graceful handling of auth failures

**Acceptance Criteria:**
- [ ] Server requires authentication
- [ ] Client provides credentials
- [ ] Server validates credentials
- [ ] Failed auth is handled gracefully
- [ ] User roles are enforced

**Complexity:** Medium

---

### Task 0.6: Implement State Synchronization

**Requirements:**
- New clients receive full state on connection
- State changes broadcast to all clients
- Clients update local state from broadcasts
- Handle out-of-order messages
- Handle duplicate messages

**Acceptance Criteria:**
- [ ] New clients sync full state
- [ ] State updates propagate to all clients
- [ ] Clients handle message ordering
- [ ] Clients handle duplicates
- [ ] State stays consistent across clients

**Complexity:** High

---

### Task 0.7: Network Testing & Reliability

**Requirements:**
- Test with multiple clients (10+)
- Test connection loss and recovery
- Test network partitions
- Test high message volume
- Test discovery in various network configs

**Acceptance Criteria:**
- [ ] System works with 20+ concurrent clients
- [ ] Reconnection works reliably
- [ ] Messages don't get lost
- [ ] Performance is acceptable
- [ ] Discovery works in test environments

**Complexity:** High

---

## Open Questions to Decide

1. **Server Deployment Model:**
   - Dedicated server application?
   - One client acts as "primary/server"?
   - Server embedded in client with auto-election?

2. **Discovery Protocol:**
   - mDNS/Bonjour (Apple ecosystem)?
   - SSDP (Universal Plug and Play)?
   - Custom UDP broadcast?
   - Manual configuration only?

3. **Communication Protocol:**
   - WebSocket (bidirectional, real-time)?
   - HTTP with Server-Sent Events?
   - Raw TCP sockets?
   - gRPC?

4. **State Persistence:**
   - SQLite database?
   - JSON/YAML files?
   - Cloud database (future)?
   - No persistence (in-memory only)?

5. **Security Model:**
   - No auth (trust local network)?
   - Simple shared password?
   - Per-user accounts?
   - Certificate-based (TLS)?

6. **Cross-Platform Considerations:**
   - If using Flutter: can run server in Dart?
   - Need separate server in different language?
   - Browser support needed (limits discovery options)?

---

## Next Steps

1. **Discuss and decide on architecture approach**
2. **Answer open questions above**
3. **Select specific technologies for protocol/discovery**
4. **Create detailed network protocol specification**
5. **Implement Task 0.1 - 0.7 before starting Phase 1**
6. **Update TASK_BREAKDOWN.md to include Task 0 dependencies**

---

## Decision Template

Use this template to document the final decision:

```
## Network Architecture Decision

**Date:** [Date]
**Decided By:** [Names]

**Architecture Chosen:** [Client-Server / P2P / Hybrid]

**Rationale:**
- [Reason 1]
- [Reason 2]
- [Reason 3]

**Technology Choices:**
- Discovery: [mDNS / SSDP / UDP Broadcast / Manual]
- Communication: [WebSocket / HTTP / TCP / gRPC]
- Server: [Dedicated / Embedded in Client / One Client as Primary]
- Persistence: [SQLite / JSON / None]
- Security: [None / Password / Accounts / Certificates]

**Implementation Plan:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Risks & Mitigations:**
- Risk: [Description]
  Mitigation: [How we'll handle it]
```
