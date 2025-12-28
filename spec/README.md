# Lighten-Up Specifications

This directory contains formal specifications for the Lighten-Up application. These specs serve as the source of truth for feature requirements and behavior.

## Purpose

Following **Spec-Driven Development** principles:

1. **Single Source of Truth**: Specs define how features should behave
2. **AI-Friendly**: Clear, structured specs help AI assistants understand requirements
3. **Change Management**: When requirements change, update the spec first, then code
4. **Documentation**: Specs serve as both requirements and documentation
5. **Test Generation**: Specs guide test creation to verify behavior

## Structure

```
spec/
├── README.md                       # This file
├── architecture.md                 # Overall system architecture
│
├── frontend/                       # Frontend specifications
│   ├── components/                 # UI component specifications
│   │   ├── peer-list.md
│   │   ├── bottom-status-bar.md
│   │   ├── my-light-status.md
│   │   ├── global-chat.md
│   │   ├── settings-modal.md
│   │   ├── light-color-picker.md
│   │   ├── light-picker-modal.md
│   │   ├── priority-queue.md
│   │   ├── sidebar.md
│   │   └── navigation-bar.md
│   ├── stores.md                   # Svelte store specifications
│   └── tauri-integration.md        # Frontend-backend bridge
│
├── backend/                        # Backend (Rust) specifications
│   ├── services/                   # Core business logic services
│   │   ├── presence-service.md     # Peer presence management
│   │   ├── chat-service.md         # Chat message handling
│   │   └── config-service.md       # Light configuration (CRDT)
│   ├── network/                    # Network layer specifications
│   │   ├── discovery.md            # mDNS peer discovery
│   │   ├── transport.md            # TCP/UDP transport
│   │   └── message-io.md           # Message serialization
│   ├── encryption/                 # Security specifications
│   │   ├── chacha20.md             # ChaCha20 encryption
│   │   └── key-derivation.md       # Argon2 key derivation
│   ├── database/                   # Data persistence specifications
│   │   ├── connection.md           # SQLite connection management
│   │   ├── migrations.md           # Schema migrations
│   │   └── queries.md              # Query layer
│   ├── commands.md                 # Tauri command interface
│   └── app-state.md                # Application state management
│
├── protocols/                      # Communication protocol specifications
│   ├── peer-discovery.md           # How peers find each other
│   ├── presence-protocol.md        # Presence broadcast protocol
│   ├── chat-protocol.md            # Chat message protocol
│   ├── config-sync.md              # Light config CRDT sync
│   └── notification-protocol.md    # Notification system
│
└── domain/                         # Domain model specifications
    ├── peer-presence.md            # Peer presence data model
    ├── light-config.md             # Light configuration CRDT
    ├── chat-message.md             # Chat message model
    └── peer-id.md                  # Peer identification
```

## Spec Format

Each spec should include:

### 1. Overview

- **Purpose**: What this component/service does
- **Dependencies**: What it requires
- **Used By**: What depends on it

### 2. Behavior Specification

Organized by feature/capability with clear acceptance criteria:

```markdown
## Feature: [Feature Name]

### When [condition]

- Given [initial state]
- Then [expected behavior]
- And [additional behavior]

### Example Scenarios

- Scenario 1: [description]
- Scenario 2: [description]
```

### 3. State Management

- **Input**: What data flows in
- **Output**: What data flows out
- **State**: What internal state exists

### 4. Edge Cases

- Null/undefined handling
- Empty states
- Error conditions
- Boundary conditions

### 5. Integration Points

- API calls
- Store subscriptions
- Event listeners
- Child components

## Workflow

### Adding a New Feature

1. Write/update the spec first in `spec/`
2. Review spec for clarity and completeness
3. Implement the feature to match the spec
4. Write tests that verify the spec
5. Update docs if needed

### Changing an Existing Feature

1. Update the spec to reflect new requirements
2. Review the spec changes
3. Update implementation to match new spec
4. Update tests to verify new behavior
5. Update docs if needed

### Using Specs with AI

When working with AI assistants:

- Reference the relevant spec file(s)
- AI can read the spec to understand requirements
- AI can suggest spec changes when requirements evolve
- AI can generate implementation matching the spec
- AI can generate tests verifying the spec

## Spec Quality Guidelines

Good specs are:

- **Clear**: Unambiguous behavior descriptions
- **Testable**: Can be verified with automated tests
- **Complete**: Cover normal and edge cases
- **Focused**: One component/service per spec
- **Maintainable**: Easy to update as requirements change

Bad specs:

- ❌ Implementation details (how it's coded)
- ❌ Vague requirements ("should be fast")
- ❌ Missing edge cases
- ❌ Mixing multiple concerns

## Validation

Each spec should be validated by:

1. ✅ Can be implemented without ambiguity
2. ✅ Can be tested automatically
3. ✅ Covers all edge cases
4. ✅ Matches existing tests (if component exists)
5. ✅ Clear integration points defined

## References

- [Spec-Driven Development with AI](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [Behavior-Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development)
- [Given-When-Then](https://en.wikipedia.org/wiki/Given-When-Then)
