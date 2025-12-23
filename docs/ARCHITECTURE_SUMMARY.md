# Lighten Up - Architecture & Implementation Summary

**Document Date:** 2025-12-23  
**Status:** Design Complete - Ready for Implementation

---

## Project Overview

**Lighten Up** is a HIPAA-compliant, real-time intra-office communication system inspired by BlueNote Software. It provides a glanceable, easy-to-use virtual light system for healthcare teams to coordinate patient flow and workflow.

**MVP Goal:** Build a networked application with filterable/sortable grid view of lights, client-server architecture, and real-time updates.

---

## Technology Stack

### Core Technologies
- **Framework:** Flutter/Dart
- **RPC Protocol:** ConnectRPC (with official Dart SDK)
- **Serialization:** Protocol Buffers (protobuf)
- **Code Generation:** Buf CLI
- **Storage:** SQLite (via adapter pattern)
- **Service Discovery:** mDNS/Bonjour

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  connectrpc: ^latest
  multicast_dns: ^latest
  sqflite: ^latest
  path: ^latest
  # State management (choose one):
  # provider: ^latest
  # riverpod: ^latest
  # flutter_bloc: ^latest
```

---

## Architecture Decisions

### ✅ **Client-Server Architecture**
- Manually configured server address with mDNS discovery fallback
- Single server coordinates all client state
- Server implemented in Dart (same codebase as client)
- Future P2P option designed but not implemented in MVP

### ✅ **ConnectRPC Protocol**
- Type-safe APIs via Protocol Buffers
- Bidirectional streaming for real-time updates
- HTTP/1.1 and HTTP/2 support
- <100KB library size
- Excellent debugging support (JSON mode available)

### ✅ **Storage Adapter Pattern**
- Abstract `StorageAdapter` interface
- SQLite implementation for production
- In-memory implementation for testing
- Easy to swap implementations (Hive, IndexedDB, etc.)

### ✅ **Offline-First Design**
- Messages queued when server unavailable
- Queue persisted to storage (survives app restart)
- Automatic replay on reconnection
- Graceful degradation during network issues

### ✅ **Timestamp-Based State Versioning**
- Unix epoch milliseconds as version identifier
- Full state sync on connection
- Delta updates during normal operation
- Conflict resolution via timestamps

### ✅ **Authentication Interface**
- Abstract `AuthProvider` interface
- No-op implementation for MVP
- Ready for future token/OAuth implementations
- Uses ConnectRPC interceptors

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Client (Flutter)                      │
├─────────────────────────────────────────────────────────────┤
│  UI Layer (Widgets)                                          │
│    ├─ Light Grid/List View                                   │
│    ├─ Filter Controls                                        │
│    └─ Sort Controls                                          │
├─────────────────────────────────────────────────────────────┤
│  State Management                                            │
│    ├─ Light Collection (from server)                        │
│    ├─ Filter State                                           │
│    ├─ Sort State                                             │
│    └─ Connection State                                       │
├─────────────────────────────────────────────────────────────┤
│  Network Layer                                               │
│    ├─ LightenClient                                          │
│    ├─ LightServiceClient (ConnectRPC)                       │
│    ├─ StateServiceClient (ConnectRPC)                       │
│    └─ Offline Queue                                          │
├─────────────────────────────────────────────────────────────┤
│  Storage Layer                                               │
│    ├─ StorageAdapter (interface)                            │
│    └─ SqliteStorageAdapter                                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ ConnectRPC/HTTP
                              │ (Bidirectional Streaming)
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Server (Dart)                           │
├─────────────────────────────────────────────────────────────┤
│  Service Layer                                               │
│    ├─ LightServiceImpl                                       │
│    │   ├─ ActivateLight()                                    │
│    │   ├─ DeactivateLight()                                  │
│    │   ├─ UpdateLight()                                      │
│    │   └─ StreamLightUpdates()                               │
│    │                                                          │
│    └─ StateServiceImpl                                       │
│        ├─ Connect()                                           │
│        ├─ SyncState()                                         │
│        └─ StreamStateUpdates()                               │
├─────────────────────────────────────────────────────────────┤
│  State Management                                            │
│    ├─ All Lights                                             │
│    ├─ All Users                                              │
│    ├─ All Activities                                         │
│    └─ Connected Clients                                      │
├─────────────────────────────────────────────────────────────┤
│  Service Discovery                                           │
│    └─ mDNS Publisher (_lighten._tcp.local)                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Protocol Definition

### Services

**LightService** - Light operations
- `ActivateLight()` - Turn on a light
- `DeactivateLight()` - Turn off a light
- `UpdateLight()` - Update light properties
- `AddLightComment()` - Add comment to light
- `StreamLightUpdates()` - Receive real-time light updates
- `GetLightHistory()` - Get activity history

**StateService** - Connection and synchronization
- `Connect()` - Establish connection and receive initial state
- `Disconnect()` - Graceful disconnect
- `SyncState()` - Request state synchronization
- `Heartbeat()` - Keep connection alive
- `StreamStateUpdates()` - Receive real-time state changes

### Key Message Types

**Light** - Core entity
```protobuf
message Light {
  string id = 1;
  string name = 2;
  LightState state = 3;
  LightColor color = 4;
  LightPriority priority = 5;
  repeated string tags = 6;
  optional string comment = 7;
  // timestamps...
}
```

**User** - User entity
```protobuf
message User {
  string id = 1;
  string name = 2;
  UserRole role = 3;
  bool online = 4;
}
```

**Activity** - Event tracking
```protobuf
message Activity {
  string id = 1;
  string light_id = 2;
  string user_id = 3;
  ActivityType type = 4;
  optional string comment = 5;
  google.protobuf.Timestamp timestamp = 6;
}
```

---

## Project Structure

```
lighten-up/
├── proto/                          # Protocol Buffer definitions
│   ├── buf.yaml                    # Buf configuration
│   ├── buf.gen.yaml                # Code generation config
│   └── lighten/
│       └── v1/
│           ├── common.proto        # Common types and enums
│           ├── models.proto        # Data models
│           ├── light_service.proto # Light operations
│           └── state_service.proto # State sync
│
├── lib/
│   ├── gen/                        # Generated protobuf code
│   │   └── lighten/
│   │       └── v1/
│   │           ├── *.pb.dart       # Protobuf messages
│   │           └── *.connect.client.dart  # ConnectRPC clients
│   │
│   ├── src/
│   │   ├── models/                 # Domain models & extensions
│   │   │   ├── light_extensions.dart
│   │   │   ├── user_extensions.dart
│   │   │   └── activity_extensions.dart
│   │   │
│   │   ├── storage/                # Storage layer
│   │   │   ├── storage_adapter.dart
│   │   │   ├── sqlite_adapter.dart
│   │   │   ├── memory_adapter.dart
│   │   │   └── storage_factory.dart
│   │   │
│   │   ├── network/                # Network layer
│   │   │   ├── lighten_client.dart
│   │   │   ├── offline_queue.dart
│   │   │   ├── discovery.dart
│   │   │   └── auth_provider.dart
│   │   │
│   │   ├── server/                 # Server implementation
│   │   │   ├── lighten_server.dart
│   │   │   ├── light_service_impl.dart
│   │   │   ├── state_service_impl.dart
│   │   │   └── server_state.dart
│   │   │
│   │   ├── state/                  # State management
│   │   │   ├── app_state.dart
│   │   │   ├── light_state.dart
│   │   │   └── connection_state.dart
│   │   │
│   │   ├── ui/                     # UI components
│   │   │   ├── widgets/
│   │   │   │   ├── light_card.dart
│   │   │   │   ├── light_grid.dart
│   │   │   │   ├── light_list.dart
│   │   │   │   ├── filter_panel.dart
│   │   │   │   └── sort_controls.dart
│   │   │   │
│   │   │   └── screens/
│   │   │       └── home_screen.dart
│   │   │
│   │   └── utils/                  # Utilities
│   │       ├── filters.dart
│   │       ├── sorters.dart
│   │       └── validators.dart
│   │
│   └── main.dart                   # App entry point
│
├── test/                           # Tests
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── docs/                           # Documentation
│   ├── BLUENOTE_PRD.md
│   ├── WORKFLOW_DETAILS.md
│   ├── PROTOCOL_DESIGN.md
│   ├── TASK_0_NETWORKING_ARCHITECTURE.md
│   └── TASK_BREAKDOWN.md
│
├── pubspec.yaml                    # Dependencies
└── README.md                       # Project overview
```

---

## Development Workflow

### 1. Setup (One-time)
```bash
# Install Buf CLI
brew install bufbuild/buf/buf

# Install Flutter dependencies
flutter pub get

# Generate code from proto files
cd proto && buf generate
```

### 2. Development Cycle
```bash
# 1. Make changes to .proto files
vim proto/lighten/v1/*.proto

# 2. Regenerate code
cd proto && buf generate

# 3. Implement business logic in Dart
# 4. Run tests
flutter test

# 5. Run app
flutter run
```

### 3. Running Server
```bash
# Option 1: Embedded in client (one client acts as server)
# Option 2: Standalone server
dart run lib/server/main.dart --port 8080
```

---

## Implementation Phases

### **Phase 0: Network Architecture (2 weeks)**
Focus: Get client-server communication working
- Setup protobuf and code generation
- Implement storage adapter
- Build server core
- Build client with offline queue
- Implement mDNS discovery
- Test basic RPC calls

### **Phase 1: Data Models & State (1 week)**
Focus: Integrate protobuf models with state management
- Extend generated models with business logic
- Implement state management
- Connect to network client
- Test real-time updates

### **Phase 2: Business Logic (1 week)**
Focus: Filtering and sorting
- Implement all filter types
- Implement all sort options
- Add search functionality
- Test with various data sets

### **Phase 3: User Interface (2 weeks)**
Focus: Build all UI components
- Light card component
- Grid and list views
- Filter and sort controls
- Main layout

### **Phase 4: Integration (1 week)**
Focus: Wire everything together
- Connect UI to state
- Test end-to-end flows
- Handle edge cases

### **Phase 5-7: Polish, Testing, Docs (2 weeks)**
Focus: Quality and documentation
- UX improvements
- Comprehensive testing
- Complete documentation

**Total Timeline: ~8-10 weeks**

---

## Key Design Patterns

1. **Repository Pattern** - Storage abstraction
2. **Factory Pattern** - Storage and client creation
3. **Observer Pattern** - State change notifications
4. **Strategy Pattern** - Filter and sort strategies
5. **Adapter Pattern** - Storage implementations
6. **Singleton Pattern** - Server state management
7. **Dependency Injection** - Testing and flexibility

---

## Testing Strategy

### Unit Tests
- All data models and extensions
- All business logic (filters, sorts)
- Storage adapters
- Network client (with mocks)

### Widget Tests
- All UI components in isolation
- User interactions
- State changes

### Integration Tests
- Complete user workflows
- Client-server communication
- Offline/online transitions
- Multiple client scenarios

### Performance Tests
- 100+ lights rendering
- Network latency
- Storage operations
- Memory usage

---

## Security Considerations (Future)

While MVP has no authentication, the architecture supports:
- Token-based authentication (JWT)
- Role-based access control (RBAC)
- TLS encryption (HTTPS)
- Audit logging (already tracked in Activity)
- HIPAA compliance features

---

## Deployment Options

### MVP: Single Location
- One server per office/clinic
- 5-20 client workstations
- Local network only
- mDNS for discovery

### Future: Multi-Location
- Central cloud server
- Location-based routing
- VPN or secure tunneling
- Load balancing

---

## References

- **Protocol Design:** `docs/PROTOCOL_DESIGN.md`
- **Task Breakdown:** `docs/TASK_BREAKDOWN.md`
- **Network Architecture:** `docs/TASK_0_NETWORKING_ARCHITECTURE.md`
- **BlueNote PRD:** `docs/BLUENOTE_PRD.md`
- **Workflow Details:** `docs/WORKFLOW_DETAILS.md`
- **ConnectRPC Docs:** https://connectrpc.com/docs/dart/getting-started/
- **Protocol Buffers:** https://protobuf.dev/

---

## Getting Started

Ready to begin implementation? Start here:

1. **Read the protocol design** - `docs/PROTOCOL_DESIGN.md`
2. **Review task breakdown** - `docs/TASK_BREAKDOWN.md`
3. **Install prerequisites** - Buf CLI, Flutter, dependencies
4. **Create project structure** - Follow structure above
5. **Begin Task 0.1** - Setup Protocol Buffers & Buf CLI

**First Milestone:** Complete Phase 0 (Network Architecture) and demonstrate:
- Server accepting client connections
- Client sending RPC requests
- Bidirectional streaming working
- Offline queue persisting and replaying messages

---

*This document summarizes all design decisions and provides a roadmap for implementation. Update as the project evolves.*
