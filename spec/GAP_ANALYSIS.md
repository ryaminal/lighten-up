# Specification Gap Analysis

**Generated:** 2025-12-28  
**Status:** All frontend specs complete, backend specs needed

## Overview

This document identifies gaps between existing code/tests and specifications. It serves as a roadmap for completing the spec-driven development approach across the entire codebase.

---

## Summary Statistics

| Category                | Code Files | Test Coverage         | Specs    | Gap         |
| ----------------------- | ---------- | --------------------- | -------- | ----------- |
| **Frontend Components** | 10         | 258 tests (100%)      | 10 specs | ✅ Complete |
| **Frontend Logic**      | 2          | Covered by components | 0 specs  | ⚠️ Missing  |
| **Backend Services**    | 5          | 55 tests              | 0 specs  | ⚠️ Missing  |
| **Backend Network**     | 6          | 55 tests              | 0 specs  | ⚠️ Missing  |
| **Backend Encryption**  | 3          | 55 tests              | 0 specs  | ⚠️ Missing  |
| **Backend Database**    | 3          | 55 tests              | 0 specs  | ⚠️ Missing  |
| **Backend Domain**      | 3          | 55 tests              | 0 specs  | ⚠️ Missing  |
| **Backend Adapters**    | 4          | 55 tests              | 0 specs  | ⚠️ Missing  |
| **Backend Protocol**    | 2          | 55 tests              | 0 specs  | ⚠️ Missing  |
| **Protocols**           | Various    | N/A                   | 0 specs  | ⚠️ Missing  |
| **Data Models**         | Various    | N/A                   | 0 specs  | ⚠️ Missing  |

---

## Frontend (Complete ✅)

### Components - 10/10 Specs

| Component        | Tests         | Spec      | Status   |
| ---------------- | ------------- | --------- | -------- |
| BottomStatusBar  | 25 tests      | ✅        | Complete |
| GlobalChat       | 22 tests      | ✅        | Complete |
| LightColorPicker | 32 tests      | ✅        | Complete |
| LightPickerModal | 48 tests      | ✅        | Complete |
| MyLightStatus    | 30 tests      | ✅        | Complete |
| NavigationBar    | 10 tests      | ✅        | Complete |
| PeerList         | 24 tests      | ✅        | Complete |
| PriorityQueue    | 33 tests      | ✅        | Complete |
| SettingsModal    | 23 tests      | ✅        | Complete |
| Sidebar          | 12 tests      | ✅        | Complete |
| **TOTAL**        | **259 tests** | **10/10** | **100%** |

### Logic Modules - 0/2 Specs (⚠️ Needs Documentation)

| Module            | File                                           | Purpose                            | Tests                          | Spec Needed? |
| ----------------- | ---------------------------------------------- | ---------------------------------- | ------------------------------ | ------------ |
| Chat Formatting   | `src/lib/logic/chat/chatFormatting.ts`         | Format messages, timestamps, names | Covered by GlobalChat tests    | Low priority |
| Light Operations  | `src/lib/logic/settings/useLightOperations.ts` | CRUD operations for lights         | Covered by SettingsModal tests | Low priority |
| Light Color Utils | `src/lib/logic/settings/lightColorUtils.ts`    | Color validation, generation       | Covered by SettingsModal tests | Low priority |

**Recommendation:** These are utility modules well-covered by component tests. Specs are optional but would be useful for reference.

---

## Backend Rust Code (Needs Specs ⚠️)

### Test Coverage Summary

```bash
$ cd src-tauri && cargo test
test result: ok. 55 passed; 0 failed; 0 ignored
```

All backend code has test coverage (55 tests), but no specifications exist.

### Services - 0/5 Specs Needed

| Service             | File                           | Purpose                  | Tests Present? | Spec Priority |
| ------------------- | ------------------------------ | ------------------------ | -------------- | ------------- |
| **PresenceService** | `services/presence_service.rs` | Peer presence tracking   | ✅ Yes         | 🔴 High       |
| **ChatService**     | `services/chat_service.rs`     | Chat message management  | ✅ Yes         | 🔴 High       |
| **ConfigService**   | `services/config_service.rs`   | Configuration management | ❌ Partial     | 🟡 Medium     |
| **ConfigHandlers**  | `services/config_handlers.rs`  | Config Tauri commands    | ✅ Yes         | 🟡 Medium     |
| **PresenceHelpers** | `services/presence_helpers.rs` | Presence utilities       | ❓ Unknown     | 🟢 Low        |

**Files to document:**

- `spec/backend/services/presence-service.md`
- `spec/backend/services/chat-service.md`
- `spec/backend/services/config-service.md`
- `spec/backend/services/config-handlers.md`
- `spec/backend/services/presence-helpers.md`

### Network - 0/6 Specs Needed

| Module               | File                           | Purpose                       | Tests Present? | Spec Priority |
| -------------------- | ------------------------------ | ----------------------------- | -------------- | ------------- |
| **Discovery**        | `network/discovery.rs`         | Peer discovery coordination   | ❓ Unknown     | 🔴 High       |
| **DiscoveryHandler** | `network/discovery_handler.rs` | Handle discovery events       | ❓ Unknown     | 🔴 High       |
| **mDNS**             | `network/mdns.rs`              | mDNS implementation           | ❓ Unknown     | 🔴 High       |
| **MessageIO**        | `network/message_io.rs`        | Message transport layer       | ❓ Unknown     | 🔴 High       |
| **Transport**        | `network/transport.rs`         | Network transport abstraction | ❓ Unknown     | 🟡 Medium     |
| **PeerInfo**         | `network/peer_info.rs`         | Peer information structure    | ❓ Unknown     | 🟢 Low        |

**Files to document:**

- `spec/backend/network/discovery.md`
- `spec/backend/network/discovery-handler.md`
- `spec/backend/network/mdns.md`
- `spec/backend/network/message-io.md`
- `spec/backend/network/transport.md`
- `spec/backend/network/peer-info.md`

### Encryption - 0/3 Specs Needed

| Module                | File                           | Purpose                 | Tests Present? | Spec Priority |
| --------------------- | ------------------------------ | ----------------------- | -------------- | ------------- |
| **ChaCha20**          | `encryption/chacha20.rs`       | ChaCha20 encryption     | ✅ Yes         | 🔴 High       |
| **KeyDerivation**     | `encryption/key_derivation.rs` | PBKDF2 key derivation   | ✅ Yes         | 🔴 High       |
| **Encryption Module** | `encryption/mod.rs`            | Encryption coordination | ❓ Unknown     | 🟡 Medium     |

**Files to document:**

- `spec/backend/encryption/chacha20.md`
- `spec/backend/encryption/key-derivation.md`
- `spec/backend/encryption/encryption-module.md`

### Database - 0/3 Specs Needed

| Module         | File                     | Purpose                      | Tests Present? | Spec Priority |
| -------------- | ------------------------ | ---------------------------- | -------------- | ------------- |
| **Connection** | `database/connection.rs` | SQLite connection management | ❓ Unknown     | 🔴 High       |
| **Migrations** | `database/migrations.rs` | Database schema migrations   | ❓ Unknown     | 🔴 High       |
| **Queries**    | `database/queries.rs`    | SQL query implementations    | ❓ Unknown     | 🔴 High       |

**Files to document:**

- `spec/backend/database/connection.md`
- `spec/backend/database/migrations.md`
- `spec/backend/database/queries.md`

### Domain - 0/3 Specs Needed

| Module          | File                     | Purpose                       | Tests Present? | Spec Priority |
| --------------- | ------------------------ | ----------------------------- | -------------- | ------------- |
| **ChatMessage** | `domain/chat_message.rs` | Chat message model            | ❓ Unknown     | 🟡 Medium     |
| **PeerId**      | `domain/peer_id.rs`      | Peer ID generation/validation | ✅ Yes         | 🟡 Medium     |
| **Errors**      | `domain/errors.rs`       | Domain error types            | ❓ Unknown     | 🟢 Low        |
| **Ports**       | `domain/ports.rs`        | Hexagonal architecture ports  | ❓ Unknown     | 🟡 Medium     |

**Files to document:**

- `spec/domain/chat-message.md`
- `spec/domain/peer-id.md`
- `spec/domain/errors.md`
- `spec/domain/ports.md`

### Adapters - 0/4 Specs Needed

| Module                 | File                     | Purpose                        | Tests Present? | Spec Priority |
| ---------------------- | ------------------------ | ------------------------------ | -------------- | ------------- |
| **Encryption Adapter** | `adapters/encryption.rs` | Encryption port implementation | ❓ Unknown     | 🟡 Medium     |
| **Message Adapter**    | `adapters/message.rs`    | Message serialization          | ✅ Yes         | 🟡 Medium     |
| **Network Adapter**    | `adapters/network.rs`    | Network port implementation    | ❓ Unknown     | 🔴 High       |
| **Error Adapter**      | `adapters/error.rs`      | Error conversions              | ✅ Yes         | 🟢 Low        |

**Files to document:**

- `spec/backend/adapters/encryption.md`
- `spec/backend/adapters/message.md`
- `spec/backend/adapters/network.md`
- `spec/backend/adapters/error.md`

### Protocol - 0/2 Specs Needed

| Module              | File                   | Purpose                      | Tests Present? | Spec Priority |
| ------------------- | ---------------------- | ---------------------------- | -------------- | ------------- |
| **Messages**        | `protocol/messages.rs` | Protocol message definitions | ❓ Unknown     | 🔴 High       |
| **Protocol Module** | `protocol/mod.rs`      | Protocol coordination        | ❓ Unknown     | 🔴 High       |

**Files to document:**

- `spec/protocols/message-protocol.md`
- `spec/protocols/protocol-coordination.md`

### Setup - 0/2 Specs Needed

| Module             | File                      | Purpose            | Tests Present? | Spec Priority |
| ------------------ | ------------------------- | ------------------ | -------------- | ------------- |
| **Initialization** | `setup/initialization.rs` | App initialization | ❓ Unknown     | 🟡 Medium     |
| **Setup Module**   | `setup/mod.rs`            | Setup coordination | ❓ Unknown     | 🟢 Low        |

**Files to document:**

- `spec/backend/setup/initialization.md`

---

## Protocol Specifications (Missing ⚠️)

These should describe the wire protocols and communication patterns.

### Needed Protocol Specs

| Protocol                  | Purpose                                | Priority  | File                                      |
| ------------------------- | -------------------------------------- | --------- | ----------------------------------------- |
| **Peer Discovery**        | How peers find each other (mDNS)       | 🔴 High   | `spec/protocols/peer-discovery.md`        |
| **Presence Protocol**     | How presence/status updates are shared | 🔴 High   | `spec/protocols/presence-protocol.md`     |
| **Chat Protocol**         | How chat messages are exchanged        | 🔴 High   | `spec/protocols/chat-protocol.md`         |
| **Notification Protocol** | How notifications are sent             | 🟡 Medium | `spec/protocols/notification-protocol.md` |
| **Config Sync**           | How configuration syncs between peers  | 🟡 Medium | `spec/protocols/config-sync.md`           |

---

## Data Model Specifications (Missing ⚠️)

These should describe the core data structures.

### Needed Data Model Specs

| Model                  | Purpose                       | Priority  | File                                      |
| ---------------------- | ----------------------------- | --------- | ----------------------------------------- |
| **PeerPresence**       | Peer status and metadata      | 🔴 High   | `spec/data-models/peer-presence.md`       |
| **LightConfig**        | Light configuration structure | 🔴 High   | `spec/data-models/light-config.md`        |
| **ChatMessage**        | Chat message structure        | 🔴 High   | `spec/data-models/chat-message.md`        |
| **NotificationStatus** | Notification state            | 🟡 Medium | `spec/data-models/notification-status.md` |

---

## Recommended Priority Order

### Phase 1: Core Backend Services (High Priority)

1. ✅ **Presence Service** - Central to the app
2. ✅ **Chat Service** - Core feature
3. ✅ **Network Discovery** - Critical for peer connectivity
4. ✅ **Network MessageIO** - Core transport
5. ✅ **Database Connection** - Foundation
6. ✅ **Database Queries** - Data access

### Phase 2: Security & Infrastructure (High Priority)

7. ✅ **Encryption (ChaCha20)** - Security critical
8. ✅ **Key Derivation** - Security critical
9. ✅ **Database Migrations** - Schema management
10. ✅ **Network Adapter** - Port implementation

### Phase 3: Protocols (High Priority)

11. ✅ **Peer Discovery Protocol** - How peers find each other
12. ✅ **Presence Protocol** - Status sharing
13. ✅ **Chat Protocol** - Message exchange

### Phase 4: Data Models (High Priority)

14. ✅ **PeerPresence Model** - Core data structure
15. ✅ **LightConfig Model** - Core data structure
16. ✅ **ChatMessage Model** - Core data structure

### Phase 5: Supporting Backend (Medium Priority)

17. Config Service & Handlers
18. Domain models (PeerId, Ports)
19. Network Transport & mDNS details
20. Adapters (Message, Encryption)

### Phase 6: Utilities & Edge Cases (Low Priority)

21. Frontend logic modules (if needed)
22. Error types and conversions
23. Setup/initialization details
24. Helper modules

---

## Test Coverage Gaps

### Current State

- **Frontend:** 259 tests, 100% component coverage ✅
- **Backend:** 55 tests, unknown coverage distribution ⚠️

### Unknown Test Distribution

We need to analyze which backend modules have tests:

```bash
# Known to have tests:
- adapters/error.rs (✅ tests present)
- adapters/message.rs (✅ tests present)
- encryption/mod.rs (✅ tests present)
- services/presence_service.rs (✅ tests present)
- services/chat_service.rs (✅ tests present)
- services/config_handlers.rs (✅ tests present)
- domain/peer_id.rs (✅ tests present)

# Unknown/No tests:
- network/* (❓ needs investigation)
- database/* (❓ needs investigation)
- protocol/* (❓ needs investigation)
- Many others...
```

### Recommendation

Run detailed test coverage analysis:

```bash
# Generate coverage report
cargo tarpaulin --workspace --out Html

# Or use llvm-cov
cargo llvm-cov --html
```

This will identify:

1. Which modules lack test coverage
2. Which functions/branches are untested
3. Where to add tests before writing specs

---

## Action Items

### Immediate (This Session)

- [x] Complete all frontend component specs ✅
- [ ] Create backend service specs (Presence, Chat)
- [ ] Create network specs (Discovery, MessageIO)
- [ ] Create encryption specs (ChaCha20, KeyDerivation)
- [ ] Create database specs (Connection, Migrations, Queries)

### Short Term (Next Session)

- [ ] Run cargo coverage analysis
- [ ] Identify untested backend code
- [ ] Write tests for uncovered code
- [ ] Create protocol specifications
- [ ] Create data model specifications

### Medium Term

- [ ] Complete all backend specs
- [ ] Add integration tests for protocols
- [ ] Create architecture decision records (ADRs)
- [ ] Document deployment and operations

---

## Metrics & Goals

### Current State

- **Total Tests:** 314 (259 frontend + 55 backend)
- **Specs Completed:** 12 (10 frontend components + 2 architecture docs)
- **Spec Coverage:** ~25% of codebase documented

### Target Goals

- **Total Tests:** 400+ (maintain frontend, expand backend)
- **Specs Completed:** 50+ (complete all modules)
- **Spec Coverage:** 100% of public APIs and key modules

### Success Criteria

- ✅ Every component/module has a spec
- ✅ Every spec has corresponding tests
- ✅ All tests are passing
- ✅ New developers can understand the system from specs
- ✅ Specs accurately reflect implementation

---

## Notes

### What Makes a Good Spec?

Based on our frontend specs, a good specification includes:

1. **Overview** - Purpose and responsibilities
2. **Structure** - Visual layout/architecture
3. **Props/API** - Inputs and outputs
4. **State Management** - Internal state
5. **User Interactions** - How users interact
6. **Functions** - Key methods and logic
7. **Styling** - Visual design decisions
8. **Accessibility** - A11y considerations
9. **Error Handling** - How errors are managed
10. **Test Coverage** - What tests exist
11. **Integration Points** - External dependencies
12. **Implementation Notes** - Key decisions
13. **Future Considerations** - Potential improvements

Backend specs should adapt this format for services, focusing on:

- **Interface/API** instead of Props
- **Dependencies** instead of User Interactions
- **Concurrency** and **Performance** considerations
- **Database Schema** for data modules
- **Protocol Messages** for network modules

---

## Conclusion

The frontend is in excellent shape with complete test coverage and specifications. The backend has solid test coverage (55 tests) but lacks documentation.

**Priority:** Document the backend, starting with core services (Presence, Chat) and network layer (Discovery, MessageIO), then move to encryption and database layers.

**Estimated Effort:**

- High priority specs: ~6-8 hours
- Medium priority specs: ~4-6 hours
- Low priority specs: ~2-3 hours
- **Total: ~12-17 hours** for complete backend documentation

This will bring the project to 100% specification coverage with comprehensive documentation for all modules.
