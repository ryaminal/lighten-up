# Refactoring Plan: SOLID Compliance

**Goal**: Reduce complexity and improve maintainability by adhering to AGENTS.md guidelines:

- Target: <100 lines per file
- Target: Cyclomatic complexity ≤3
- Target: Function length <30 lines
- Target: ≤3 parameters per function

**Status**: ✅ 73 passing tests provide safety net for refactoring

---

## Priority 1: Frontend Components

### 1.1 SettingsModal.svelte (529 lines → ~350 lines across 7 files) 🔴 CRITICAL

**Current Issues**:

- 529 lines (5.3x over limit)
- Multiple responsibilities: modal UI, peer management, light CRUD, priority reordering, validation
- Complex color generation logic (HSL→HEX conversion, uniqueness checking)
- Long functions (handleAddLight: 86 lines, handleMoveLightUp/Down: 32 lines each)

**Refactoring Strategy**:

```
src/lib/components/settings/
├── SettingsModal.svelte (~80 lines)           # Modal shell, layout, state coordination
├── PeerIdentitySection.svelte (~60 lines)     # Peer ID/name display and editing
├── LightConfigSection.svelte (~80 lines)      # Light list container, header, add button
├── LightConfigRow.svelte (~70 lines)          # Single light row (priority, color, name, delete)
└── EmptyLightsState.svelte (~20 lines)        # Empty state message

src/lib/logic/settings/
├── useSettingsData.ts (~60 lines)             # Data loading, error handling
├── useLightOperations.ts (~80 lines)          # CRUD operations for lights
└── lightColorUtils.ts (~80 lines)             # Color generation, uniqueness validation
```

**Benefits**:

- Each component has single responsibility
- Color logic testable in isolation
- Light row reusable elsewhere
- Easier to understand and modify

**Tests**: 20 existing tests cover this - should pass after refactor

---

### 1.2 GlobalChat.svelte (339 lines → ~280 lines across 5 files) 🟠 HIGH

**Current Issues**:

- 339 lines (3.4x over limit)
- Multiple responsibilities: chat layout, message display, input handling, event listeners
- Mixed concerns: UI rendering, business logic, state management

**Refactoring Strategy**:

```
src/lib/components/chat/
├── GlobalChat.svelte (~70 lines)              # Layout, header, coordination
├── ChatMessageList.svelte (~60 lines)         # Messages container, loading/empty states
├── ChatMessage.svelte (~60 lines)             # Single message bubble, menu, formatting
├── ChatInput.svelte (~50 lines)               # Input field, send button, edit banner
└── ChatDateDivider.svelte (~20 lines)         # "Today" divider component

src/lib/logic/chat/
├── useChatMessages.ts (~70 lines)             # Message state, event listeners
└── chatFormatting.ts (~30 lines)              # Time formatting, name lookups
```

**Benefits**:

- Message component reusable in other contexts
- Input logic testable separately
- Clearer separation of concerns
- Easier to add features (reactions, threads, etc.)

**Tests**: 22 existing tests cover this - should pass after refactor

---

### 1.3 LightPickerModal.svelte (322 lines) 🟠 HIGH

**Analysis needed**: Similar pattern to SettingsModal

- Extract LightColorGrid component
- Extract color selection logic
- Extract modal shell

**Estimated split**: ~4 files, ~80 lines each

---

### 1.4 BottomStatusBar.svelte (271 lines) 🟠 HIGH

**Analysis needed**: Likely contains:

- Peer status display
- Light color indicators
- Note display

**Estimated split**: ~3 components, separate display logic

---

### 1.5 PriorityQueue.svelte (239 lines) 🟠 HIGH

**Analysis needed**: Priority queue UI

- Extract queue item component
- Extract drag/drop logic
- Extract reordering operations

**Estimated split**: ~3-4 files

---

## Priority 2: Backend Services

### 2.1 presence_service.rs (691 lines → ~400 lines across 4 files) 🔴 CRITICAL

**Current Breakdown**:

- Production code: ~262 lines
- Tests: ~429 lines (18 tests)

**Current Issues**:

- Single file handles peer state, notifications, cleanup, message generation
- Tests are 62% of file (actually good, but file is too large overall)

**Refactoring Strategy**:

```
src-tauri/src/services/presence/
├── mod.rs (~60 lines)                         # Public API, service struct
├── peer_state.rs (~80 lines)                  # Peer state management, updates
├── notification_manager.rs (~50 lines)        # Notification state tracking
├── stale_peer_cleanup.rs (~40 lines)          # Cleanup logic, timeout detection
└── message_builder.rs (~30 lines)             # Presence message construction

tests/ (in each file's #[cfg(test)] module)
├── peer_state_tests.rs (~150 lines)           # 6 tests
├── notification_tests.rs (~100 lines)         # 4 tests
├── cleanup_tests.rs (~100 lines)              # 3 tests
└── integration_tests.rs (~80 lines)           # 5 tests
```

**Benefits**:

- Each module has clear responsibility
- Tests co-located with relevant code
- Easier to understand state transitions
- Cleanup logic isolated and testable

**Tests**: 18 existing tests - organize by responsibility

---

### 2.2 config_handlers.rs (514 lines → ~350 lines across 3 files) 🔴 CRITICAL

**Current Breakdown**:

- Production code: ~70 lines
- Tests: ~444 lines (12 tests)

**Current Issues**:

- Tests are 86% of file (great coverage, but unwieldy)
- CRDT logic mixed with config management

**Refactoring Strategy**:

```
src-tauri/src/services/config/
├── handlers.rs (~40 lines)                    # Public API, handler functions
├── crdt_resolver.rs (~60 lines)               # LWW CRDT conflict resolution
└── light_operations.rs (~40 lines)            # Light CRUD with CRDT updates

tests/
├── crdt_tests.rs (~250 lines)                 # CRDT conflict resolution (8 tests)
└── operations_tests.rs (~150 lines)           # Light operations (4 tests)
```

**Benefits**:

- CRDT logic isolated and highly testable
- Clear separation of concerns
- Tests organized by functionality
- Easier to understand conflict resolution

**Tests**: 12 existing tests - split by concern

---

### 2.3 chat_service.rs (397 lines → ~250 lines across 3 files) 🔴 CRITICAL

**Current Breakdown**:

- Production code: ~115 lines
- Tests: ~282 lines (14 tests)

**Current Issues**:

- Tests are 71% of file
- Message handling, validation, authorization mixed

**Refactoring Strategy**:

```
src-tauri/src/services/chat/
├── service.rs (~60 lines)                     # ChatService struct, public API
├── message_validator.rs (~30 lines)           # Length validation, sanitization
└── authorization.rs (~25 lines)               # Ownership checks for edit/delete

tests/
├── message_tests.rs (~150 lines)              # CRUD operations (6 tests)
├── validation_tests.rs (~70 lines)            # Validation logic (3 tests)
└── authorization_tests.rs (~70 lines)         # Auth checks (5 tests)
```

**Benefits**:

- Validation logic testable in isolation
- Authorization rules explicit
- Clear API surface
- Tests organized by concern

**Tests**: 14 existing tests - split by responsibility

---

### 2.4 setup/initialization.rs (466 lines) 🔴 CRITICAL

**Analysis needed**: Likely contains:

- Database setup
- Network initialization
- Service construction
- Configuration loading

**Estimated split**: ~4-5 modules

---

### 2.5 commands.rs (342 lines) 🟠 HIGH

**Analysis needed**: 16 Tauri command handlers

- Each command could be ~20 lines
- Extract command handlers into domain-specific modules

**Estimated split**: ~3-4 modules by domain (chat, presence, config, lights)

---

## Priority 3: Supporting Refactors

### 3.1 Long Functions

Identify and refactor functions >30 lines:

- `handleAddLight` in SettingsModal (86 lines) → extract color generation
- `loadData` in SettingsModal (41 lines) → extract normalization
- `handleMoveLightUp/Down` (32 lines each) → extract shared logic

### 3.2 Complex Functions (Cyclomatic Complexity >3)

Target: Identify with complexity analysis tool or manual review

- Color generation logic (nested if/while)
- Message handling with multiple conditions
- Validation functions with multiple branches

### 3.3 Function Parameters

Review functions with >3 parameters:

- Consider configuration objects/structs
- Use builder pattern where appropriate

---

## Implementation Strategy

### Phase 1: Frontend (Weeks 1-2)

1. **Week 1**: SettingsModal + GlobalChat (highest value, best test coverage)
2. **Week 2**: LightPickerModal + BottomStatusBar

### Phase 2: Backend (Weeks 3-4)

1. **Week 3**: presence_service.rs + config_handlers.rs (most complex)
2. **Week 4**: chat_service.rs + initialization.rs

### Phase 3: Polish (Week 5)

1. **Refactor commands.rs**
2. **Review remaining files**
3. **Update documentation**
4. **Final complexity analysis**

---

## Success Metrics

### Code Quality

- ✅ All files <100 lines (excluding test-only files)
- ✅ Function complexity ≤3
- ✅ Function length <30 lines
- ✅ ≤3 parameters per function

### Testing

- ✅ All 73 tests still pass
- ✅ No reduction in test coverage
- ✅ Tests organized by concern

### Maintainability

- ✅ Each module has single responsibility
- ✅ Clear separation of concerns
- ✅ Business logic testable in isolation
- ✅ Easier to understand and modify

---

## Risks & Mitigations

### Risk: Breaking existing functionality

**Mitigation**: Run full test suite after each refactor step

### Risk: Test failures due to imports/paths

**Mitigation**: Update test imports incrementally, one component at a time

### Risk: Introducing new bugs

**Mitigation**: Small, incremental changes with test validation

### Risk: Scope creep

**Mitigation**: Stick to structural refactoring only - no feature changes

---

## Notes

- **Do not modify behavior** - refactoring only
- **Keep commits small** - one component/service per commit
- **Run tests frequently** - after every significant change
- **Update imports** - track all import paths carefully
- **Preserve tests** - move tests with their related code
