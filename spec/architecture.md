# Lighten-Up System Architecture

## Overview

Lighten-Up is a peer-to-peer desktop application built with Tauri, combining a SvelteKit frontend with a Rust backend. It enables users to broadcast availability status via colored "lights" and communicate through global chat.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend (SvelteKit)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Components  │  │    Stores    │  │  Tauri API   │      │
│  │  (Svelte)    │──│   (State)    │──│  Bridge      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└────────────────────────────────┬────────────────────────────┘
                                 │ IPC (Tauri Commands)
┌────────────────────────────────┴────────────────────────────┐
│                      Backend (Rust/Tauri)                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Tauri Command Layer                      │   │
│  │  (get_peers, set_light_color, send_chat_message...)  │   │
│  └───────────────────┬──────────────────────────────────┘   │
│                      │                                       │
│  ┌───────────────────┴──────────────────────────────────┐   │
│  │                  Services Layer                       │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │   │
│  │  │  Presence    │  │    Chat      │  │   Config   │ │   │
│  │  │  Service     │  │   Service    │  │  Service   │ │   │
│  │  └──────────────┘  └──────────────┘  └────────────┘ │   │
│  └───────────────────┬──────────────────────────────────┘   │
│                      │                                       │
│  ┌──────────────────┬┴───────────────┬──────────────────┐   │
│  │                  │                │                   │   │
│  │  ┌──────────────▼──────────────┐ │ ┌────────────────▼┐  │
│  │  │      Network Layer          │ │ │    Database    │  │
│  │  │  ┌─────────┐  ┌──────────┐ │ │ │    (SQLite)    │  │
│  │  │  │  mDNS   │  │ Message  │ │ │ └────────────────┘  │
│  │  │  │Discovery│  │   I/O    │ │ │                     │
│  │  │  └─────────┘  └──────────┘ │ │                     │
│  │  │  ┌─────────┐  ┌──────────┐ │ │                     │
│  │  │  │Transport│  │Encryption│ │ │                     │
│  │  │  │(TCP/UDP)│  │(ChaCha20)│ │ │                     │
│  │  │  └─────────┘  └──────────┘ │ │                     │
│  │  └─────────────────────────────┘ │                     │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                      │
                      │ P2P Network
                      ▼
            ┌──────────────────┐
            │   Other Peers    │
            │  (Same Network)  │
            └──────────────────┘
```

## System Layers

### Frontend Layer (TypeScript/Svelte)

**Technology**: SvelteKit + Vite + TypeScript

**Responsibilities**:

- User interface rendering
- User input handling
- Local state management (Svelte stores)
- Real-time UI updates via Tauri events

**Key Components**:

- UI Components: Visual elements (buttons, lists, modals)
- Stores: Reactive state (peers, lights, messages)
- Tauri Integration: IPC bridge to backend

**State Flow**:

```
User Action → Component → Store Update → Tauri Command → Backend
Backend Event → Tauri Event Listener → Store Update → Component Re-render
```

### Backend Layer (Rust)

#### Command Layer (Tauri)

**Purpose**: Exposes backend functionality to frontend via IPC

**Commands**:

- Peer management: `get_peers`, `get_my_peer_name`, `set_peer_name`
- Light status: `set_light_color`, `get_lights`, `create_light`, `update_light`
- Chat: `send_chat_message`, `get_chat_messages`, `edit_chat_message`
- Notifications: `send_notification`, `clear_notification`

**Events** (Backend → Frontend):

- `peers-changed`: Peer list updated
- `lights-changed`: Light config changed
- `chat-message`: New chat message received
- `notification`: Notification received

#### Services Layer

**Purpose**: Core business logic and state management

1. **Presence Service**
   - Manages local peer state (name, light color, note)
   - Broadcasts presence to network
   - Maintains list of discovered peers
   - Cleans up stale peers (30s timeout)

2. **Chat Service**
   - Handles chat message CRUD operations
   - Persists messages to database
   - Broadcasts messages to network
   - Enforces message length limits (500 chars)

3. **Config Service**
   - Manages light configuration (CRDT)
   - Synchronizes config across peers
   - Handles create/update/delete operations
   - Resolves conflicts with LWW (Last-Write-Wins)

#### Network Layer

**Purpose**: P2P communication and discovery

1. **Discovery (mDNS)**
   - Broadcasts service on local network
   - Discovers other peers
   - Service name: `_lightenup._tcp.local`

2. **Transport**
   - TCP for reliable delivery (chat, config sync)
   - UDP for fast broadcasts (presence updates)
   - Port configuration and management

3. **Message I/O**
   - Message serialization/deserialization (JSON)
   - Message routing based on type
   - Connection management

4. **Encryption**
   - ChaCha20 symmetric encryption
   - Argon2 key derivation from passphrase
   - Per-message nonce generation

#### Database Layer

**Purpose**: Data persistence (SQLite)

**Tables**:

- `chat_messages`: Chat message history
- `light_configs`: Light configuration (CRDT)
- `config_states`: Configuration sync state

**Responsibilities**:

- Schema migrations
- Query execution
- Transaction management
- Error handling

### Protocol Layer

Defines wire formats and communication patterns for P2P messaging.

**Message Types**:

1. **Presence Messages**

   ```json
   {
     "Online": {
       "peer_id": "uuid",
       "peer_name": "Alice",
       "light_state": { "color": "#ff0000", "timestamp": 123456 },
       "note": "In a meeting"
     }
   }
   ```

2. **Chat Messages**

   ```json
   {
     "Chat": {
       "id": "uuid",
       "peer_id": "uuid",
       "peer_name": "Alice",
       "content": "Hello!",
       "timestamp": 123456
     }
   }
   ```

3. **Config Sync Messages**
   ```json
   {
     "ConfigUpsert": {
       "id": "uuid",
       "color": "#ff0000",
       "name": "Urgent",
       "enabled": true,
       "priority": 0,
       "updated_at": 123456,
       "updated_by": "peer-uuid"
     }
   }
   ```

## Data Flow Examples

### Example 1: User Sets Light Color

```
Frontend:
  1. User clicks light color button
  2. Component calls setLightColor(color, note)
  3. Store updates optimistically

Backend:
  4. Tauri command received: set_light_color
  5. Presence service updates state
  6. Broadcasts presence message to network
  7. Emits "peers-changed" event

Network:
  8. Other peers receive presence message
  9. Other peers update their peer lists
  10. Other peers emit "peers-changed" to their frontends

Frontend:
  11. Event listener receives "peers-changed"
  12. Store updates with new peer data
  13. UI re-renders with new peer states
```

### Example 2: Peer Discovery

```
Backend (Startup):
  1. mDNS service starts broadcasting
  2. mDNS listener discovers other services
  3. TCP connection established to new peer
  4. Exchange presence information

Backend (Runtime):
  5. Presence service maintains peer list
  6. Every few seconds, broadcasts presence
  7. Cleans up peers not seen in 30s
  8. Emits "peers-changed" on updates

Frontend:
  9. Listens to "peers-changed" events
  10. Updates peer store
  11. PeerList component re-renders
```

### Example 3: Chat Message Flow

```
Frontend:
  1. User types message and clicks send
  2. Component calls sendChatMessage(content)

Backend:
  3. Chat service validates message (max 500 chars)
  4. Generates message ID and timestamp
  5. Saves to SQLite database
  6. Broadcasts to network
  7. Emits "chat-message" event

Network:
  8. Other peers receive chat message
  9. Other peers save to their databases
  10. Other peers emit "chat-message" events

Frontend (All Peers):
  11. Event listener receives "chat-message"
  12. Adds message to messages store
  13. GlobalChat component displays new message
  14. Auto-scrolls to bottom
```

## Technology Stack

### Frontend

- **Framework**: SvelteKit 2.x
- **Language**: TypeScript 5.x
- **Build Tool**: Vite 6.x
- **Styling**: TailwindCSS
- **Testing**: Vitest + Testing Library

### Backend

- **Framework**: Tauri 2.x
- **Language**: Rust (stable)
- **Database**: SQLite (via rusqlite)
- **Network**: tokio (async runtime)
- **Encryption**: chacha20, argon2
- **Discovery**: mdns-sd
- **Testing**: Built-in Rust test framework

### Development

- **Package Manager**: pnpm (frontend), cargo (backend)
- **Linting**: ESLint (TS), Clippy (Rust)
- **Formatting**: Prettier (TS), rustfmt (Rust)

## Security Considerations

1. **Network Encryption**: All messages encrypted with ChaCha20
2. **Key Derivation**: Argon2 for password-based key derivation
3. **Local Network Only**: No internet connectivity required
4. **SQLite Security**: Database stored in user data directory
5. **Input Validation**: All user inputs validated and sanitized

## Performance Considerations

1. **Debouncing**: Note inputs debounced (500ms)
2. **Presence Updates**: Broadcast every few seconds (not every keystroke)
3. **Stale Peer Cleanup**: 30-second timeout for offline detection
4. **Database Indexing**: Timestamps indexed for fast queries
5. **Message Limits**: Chat messages limited to 500 characters
6. **CRDT Efficiency**: Light config uses Last-Write-Wins for simplicity

## Scalability Limits

- **Target**: Small teams (5-50 people) on same local network
- **Peer Count**: Tested with up to 20 simultaneous peers
- **Message History**: SQLite handles thousands of messages efficiently
- **Network Bandwidth**: Low (presence broadcasts every few seconds)

## Error Handling

### Frontend

- Toast notifications for user-facing errors
- Console logging for debugging
- Graceful degradation (offline state shows "Searching...")

### Backend

- Result<T, E> pattern throughout
- Error types per domain (ChatError, NetworkError, etc.)
- Logging at appropriate levels (info, warn, error)
- Graceful peer disconnection handling

## References

- See `spec/frontend/` for frontend component details
- See `spec/backend/` for backend service details
- See `spec/protocols/` for communication protocol details
- See `spec/domain/` for data model details
