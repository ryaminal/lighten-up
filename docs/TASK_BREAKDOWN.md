# Task Breakdown - Lighten Up MVP

**Document Date:** 2025-12-23  
**MVP Goal:** Build a filterable and sortable grid/list view for light management with client-server networking  
**Tech Stack:** Flutter/Dart with ConnectRPC

---

## Task Overview

This document breaks down the MVP implementation into discrete, testable tasks. Each task includes:
- Clear requirements
- Acceptance criteria
- Dependencies on other tasks
- Estimated complexity (Low/Medium/High)

---

## Phase 0: Network Architecture & Protocol

### Task 0.1: Setup Protocol Buffers & Buf CLI

**Description:**  
Set up the Protocol Buffers toolchain and Buf CLI for code generation.

**Requirements:**
- Install Buf CLI
- Create proto directory structure
- Create buf.yaml configuration
- Create buf.gen.yaml for Dart code generation
- Verify code generation works

**Acceptance Criteria:**
- [ ] Buf CLI is installed and available in PATH
- [ ] Proto directory structure matches design (proto/lighten/v1/)
- [ ] buf.yaml is configured with linting rules
- [ ] buf.gen.yaml generates both protobuf and ConnectRPC Dart code
- [ ] `buf generate` command runs successfully
- [ ] Generated code appears in lib/gen directory
- [ ] Documentation exists for running code generation

**Dependencies:** None

**Complexity:** Low

---

### Task 0.2: Define Protocol Buffer Messages

**Description:**  
Create all .proto files defining the API contract.

**Requirements:**
- Define common.proto with enums (UserRole, LightPriority, LightState, LightColor)
- Define models.proto with message types (User, Light, Activity, StateSnapshot)
- Define light_service.proto with LightService RPCs
- Define state_service.proto with StateService RPCs
- All messages must be well-documented
- Follow protobuf best practices

**Acceptance Criteria:**
- [ ] common.proto is complete with all enums
- [ ] models.proto is complete with all message types
- [ ] light_service.proto defines all light operations
- [ ] state_service.proto defines connection and sync operations
- [ ] All messages include comments/documentation
- [ ] Proto files follow buf linting rules
- [ ] Code generates without errors
- [ ] Generated Dart code is type-safe

**Dependencies:** Task 0.1

**Complexity:** Medium

---

### Task 0.3: Implement Storage Adapter Interface

**Description:**  
Create abstract storage adapter and implementations for persistence.

**Requirements:**
- Define StorageAdapter abstract interface
- Implement SqliteStorageAdapter using sqflite
- Implement InMemoryStorageAdapter for testing
- Implement StorageFactory for creating adapters
- All operations must be async
- Support key-value storage with prefix queries

**Acceptance Criteria:**
- [ ] StorageAdapter interface is defined
- [ ] SqliteStorageAdapter is fully implemented
- [ ] InMemoryStorageAdapter is fully implemented
- [ ] HiveStorageAdapter is implemented (optional alternative)
- [ ] StorageFactory can create any adapter type
- [ ] All adapters pass same test suite
- [ ] Unit tests cover all adapter implementations
- [ ] Documentation explains adapter pattern

**Dependencies:** None

**Complexity:** Medium

---

### Task 0.4: Implement Offline Message Queue

**Description:**  
Build offline message queue using storage adapter.

**Requirements:**
- Create QueuedMessage model
- Implement OfflineQueue using StorageAdapter
- Support enqueue, dequeue, peek, clear operations
- Messages persisted to storage
- Support replaying queued messages
- Messages ordered by timestamp

**Acceptance Criteria:**
- [ ] QueuedMessage model is defined
- [ ] OfflineQueue accepts any StorageAdapter
- [ ] Messages can be enqueued and persisted
- [ ] Messages can be retrieved in order
- [ ] Messages can be removed after replay
- [ ] Queue survives app restart
- [ ] Unit tests cover queue operations
- [ ] Documentation explains queue behavior

**Dependencies:** Task 0.3

**Complexity:** Medium

---

### Task 0.5: Implement mDNS Service Discovery

**Description:**  
Implement service discovery for automatic server detection.

**Requirements:**
- Server can publish _lighten._tcp.local service
- Client can discover servers on local network
- Support manual server configuration as fallback
- Handle multiple servers discovered
- Include timeout for discovery

**Acceptance Criteria:**
- [ ] ServerDiscovery class publishes mDNS service
- [ ] ClientDiscovery class discovers servers
- [ ] Discovery returns list of ServerInfo (name, host, port)
- [ ] Discovery respects timeout parameter
- [ ] Manual configuration bypasses discovery
- [ ] Works on local network
- [ ] Documentation explains discovery process

**Dependencies:** None

**Complexity:** Medium

---

### Task 0.6: Implement Server Core

**Description:**  
Build the ConnectRPC server implementation.

**Requirements:**
- Implement LightServiceImpl with all RPC methods
- Implement StateServiceImpl with connection management
- Maintain server state (lights, users, activities)
- Broadcast updates to all connected clients
- Handle client connections and disconnections
- Support configurable ports

**Acceptance Criteria:**
- [ ] Server starts and listens on configured port
- [ ] LightService RPCs are implemented
- [ ] StateService RPCs are implemented
- [ ] Server maintains consistent state
- [ ] Updates broadcast to all clients
- [ ] Client connections tracked
- [ ] Client disconnections handled gracefully
- [ ] Server can be configured via ServerConfig
- [ ] Server logs important events
- [ ] Documentation explains server architecture

**Dependencies:** Task 0.2

**Complexity:** High

---

### Task 0.7: Implement Client Connection Management

**Description:**  
Build the ConnectRPC client with connection management.

**Requirements:**
- Create LightenClient class
- Connect to server using Transport
- Initialize LightServiceClient and StateServiceClient
- Handle connection, disconnection, reconnection
- Support both discovered and manual server URLs
- Integrate offline queue
- Support heartbeat mechanism

**Acceptance Criteria:**
- [ ] Client connects to server successfully
- [ ] Client receives initial state on connection
- [ ] Client detects connection loss
- [ ] Client reconnects automatically with backoff
- [ ] Client queues messages when offline
- [ ] Client replays queue on reconnection
- [ ] Heartbeat keeps connection alive
- [ ] Client can be configured via ClientConfig
- [ ] Connection state is observable
- [ ] Documentation explains client lifecycle

**Dependencies:** Task 0.2, Task 0.4, Task 0.5

**Complexity:** High

---

### Task 0.8: Implement Streaming Updates

**Description:**  
Implement bidirectional streaming for real-time updates.

**Requirements:**
- Server streams light updates to all clients
- Server streams state changes to all clients
- Client subscribes to update streams
- Updates processed in real-time
- Handle stream errors and reconnection
- Stream lifecycle tied to connection

**Acceptance Criteria:**
- [ ] Server broadcasts light updates via stream
- [ ] Server broadcasts state changes via stream
- [ ] Client receives updates in real-time
- [ ] Multiple clients receive same updates
- [ ] Stream errors trigger reconnection
- [ ] Stream stops on disconnect
- [ ] Stream resumes on reconnect
- [ ] Update latency is <300ms
- [ ] Documentation explains streaming architecture

**Dependencies:** Task 0.6, Task 0.7

**Complexity:** High

---

### Task 0.9: Implement Authentication Interface

**Description:**  
Create authentication provider interface (no-op for MVP).

**Requirements:**
- Define AuthProvider interface
- Implement NoAuthProvider (no-op for MVP)
- Implement TokenAuthProvider (for future)
- Create AuthInterceptor for ConnectRPC
- Support injecting auth into client

**Acceptance Criteria:**
- [ ] AuthProvider interface is defined
- [ ] NoAuthProvider returns null token
- [ ] TokenAuthProvider stores/retrieves tokens
- [ ] AuthInterceptor adds auth headers
- [ ] Client accepts AuthProvider via constructor
- [ ] MVP uses NoAuthProvider
- [ ] Unit tests cover auth providers
- [ ] Documentation explains auth architecture

**Dependencies:** Task 0.7

**Complexity:** Low

---

### Task 0.10: Network Error Handling & Resilience

**Description:**  
Implement comprehensive error handling for network operations.

**Requirements:**
- Handle all ConnectRPC error codes
- Retry with exponential backoff
- Distinguish transient vs permanent errors
- Show appropriate user feedback
- Graceful degradation when offline
- Support circuit breaker pattern

**Acceptance Criteria:**
- [ ] All ConnectException codes are handled
- [ ] Transient errors trigger retry with backoff
- [ ] Permanent errors show user message
- [ ] Offline mode is clearly indicated
- [ ] Operations queue when offline
- [ ] Circuit breaker prevents repeated failures
- [ ] Error messages are user-friendly
- [ ] Unit tests cover error scenarios
- [ ] Documentation explains error handling

**Dependencies:** Task 0.7

**Complexity:** Medium

---

### Task 0.11: Network Testing & Integration

**Description:**  
Test networking components with multiple clients.

**Requirements:**
- Test server with 10+ concurrent clients
- Test offline/online transitions
- Test message replay from queue
- Test streaming with high message volume
- Test discovery in various network configs
- Load testing and performance verification

**Acceptance Criteria:**
- [ ] Server handles 20+ concurrent clients
- [ ] Offline queue works correctly
- [ ] Message replay succeeds
- [ ] Streaming works with 100+ messages/min
- [ ] Discovery works on test network
- [ ] No memory leaks detected
- [ ] Latency <300ms for 95th percentile
- [ ] Integration tests pass
- [ ] Performance benchmarks documented

**Dependencies:** Task 0.6, Task 0.7, Task 0.8

**Complexity:** High

---

## Phase 1: Core Data Model & State Management

### Task 1.1: Define Light Data Model

**Description:**  
Create the core data structure for a "Light" entity. This will use the generated Protobuf Light message as the foundation.

**Requirements:**
- Use generated Light message from proto files
- Add computed properties for age calculation
- Add computed properties for color determination
- Create Dart extensions for business logic
- Support JSON serialization via protobuf

**Acceptance Criteria:**
- [ ] Light message is generated from .proto file
- [ ] Dart extensions add computed properties
- [ ] Age calculation works correctly
- [ ] Color determination based on thresholds works
- [ ] Unit tests cover all business logic
- [ ] Documentation explains model usage

**Dependencies:** Task 0.2

**Complexity:** Low

---

### Task 1.2: Define User Data Model

**Description:**  
Create the data structure for users who interact with lights using generated protobuf.

**Requirements:**
- Use generated User message from proto files
- Create Dart extensions for helper methods
- Support role-based logic

**Acceptance Criteria:**
- [ ] User message is generated from .proto file
- [ ] Dart extensions provide helper methods
- [ ] Role enumeration is properly typed
- [ ] Unit tests cover user model
- [ ] Documentation explains model usage

**Dependencies:** Task 0.2

**Complexity:** Low

---

### Task 1.3: Define Activity/Event Data Model

**Description:**  
Create the data structure for tracking light activity history using generated protobuf.

**Requirements:**
- Use generated Activity message from proto files
- Create Dart extensions for querying/filtering
- Support timestamp-based sorting

**Acceptance Criteria:**
- [ ] Activity message is generated from .proto file
- [ ] Activity type enumeration is properly typed
- [ ] Dart extensions provide filtering methods
- [ ] Timestamp sorting works correctly
- [ ] Unit tests cover activity model
- [ ] Documentation explains activity tracking

**Dependencies:** Task 0.2, Task 1.1, Task 1.2

**Complexity:** Low

---

### Task 1.4: Implement State Management Architecture

**Description:**  
Set up the state management system to handle light collection, filtering, and sorting. Integrate with network client for real-time updates.

**Requirements:**
- State must hold collection of all lights from server
- State must track currently applied filters
- State must track current sort configuration
- State must integrate with LightenClient for updates
- State must handle real-time streaming updates
- State must provide methods to apply filters
- State must provide methods to apply sorting
- State changes must be observable/reactive

**Acceptance Criteria:**
- [ ] State management solution is implemented (Provider/Riverpod/Bloc)
- [ ] Light collection syncs with server state
- [ ] Real-time updates from stream are applied to state
- [ ] Filter state can be modified and applied
- [ ] Sort state can be modified and applied
- [ ] State changes trigger UI updates
- [ ] State management is testable in isolation
- [ ] Connection state is tracked (connected/disconnected)
- [ ] Documentation exists for state architecture

**Dependencies:** Task 0.7, Task 1.1

**Complexity:** High

---

## Phase 2: Core Business Logic

### Task 2.1: Implement Filter Logic

**Description:**  
Build the filtering engine that can filter lights based on multiple criteria.

**Requirements:**
- Support filtering by light state (on/off/all)
- Support filtering by status color (green/yellow/red)
- Support filtering by priority level
- Support filtering by name/label (text search)
- Support filtering by elapsed time ranges
- Filters should be combinable (multiple filters active simultaneously)
- Filter results should be immediate

**Acceptance Criteria:**
- [ ] Filter functions are implemented for each criterion
- [ ] Multiple filters can be combined using AND logic
- [ ] Filter logic correctly handles edge cases (empty lists, no matches)
- [ ] Filter performance is acceptable for 100+ lights
- [ ] Unit tests cover all filter scenarios
- [ ] Filter state is serializable for persistence

**Dependencies:** Task 1.1, Task 1.4

**Complexity:** Medium

---

### Task 2.2: Implement Sort Logic

**Description:**  
Build the sorting engine that can order lights by various properties.

**Requirements:**
- Support sorting by name (alphabetical)
- Support sorting by activation time (oldest/newest first)
- Support sorting by elapsed time (longest/shortest first)
- Support sorting by priority (high to low, low to high)
- Support sorting by status color
- Support ascending/descending order
- Default sort should be by activation time (newest first)

**Acceptance Criteria:**
- [ ] Sort functions are implemented for each property
- [ ] Sort direction (asc/desc) is configurable
- [ ] Sort logic correctly handles equal values
- [ ] Sort performance is acceptable for 100+ lights
- [ ] Unit tests cover all sort scenarios
- [ ] Sort state is serializable for persistence

**Dependencies:** Task 1.1, Task 1.4

**Complexity:** Medium

---

### Task 2.3: Implement Light Aging Logic

**Description:**  
Build the logic that determines light color based on elapsed time.

**Requirements:**
- Each light should have configurable age thresholds
- System should support default thresholds (e.g., <5min=green, 5-10min=yellow, >10min=red)
- Age calculation should be based on current time vs. activation time
- Age status should update automatically over time
- Inactive (off) lights should not age

**Acceptance Criteria:**
- [ ] Age calculation function correctly determines color
- [ ] Thresholds are configurable per light or globally
- [ ] Age status updates trigger state changes
- [ ] Unit tests cover threshold edge cases
- [ ] Performance allows for frequent age recalculation
- [ ] Documentation explains aging behavior

**Dependencies:** Task 1.1

**Complexity:** Low

---

### Task 2.4: Implement Search/Text Filter Logic

**Description:**  
Build text-based search functionality for finding lights by name or comments.

**Requirements:**
- Support case-insensitive search
- Support partial matching
- Search should apply to light name
- Search should apply to light comments
- Search results should update as user types (with debouncing)

**Acceptance Criteria:**
- [ ] Search function correctly matches partial text
- [ ] Search is case-insensitive
- [ ] Search handles special characters safely
- [ ] Search performance is acceptable with 100+ lights
- [ ] Debouncing prevents excessive filtering during typing
- [ ] Unit tests cover search scenarios

**Dependencies:** Task 1.1, Task 2.1

**Complexity:** Low

---

## Phase 3: User Interface Components

### Task 3.1: Create Light Card/Tile Component

**Description:**  
Build the visual component that displays a single light's information.

**Requirements:**
- Display light name prominently
- Show current state (on/off) visually
- Display status color (green/yellow/red)
- Show elapsed time since activation
- Display priority indicator if high priority
- Show preview of most recent comment if present
- Component should be tappable/clickable
- Component should adapt to grid and list layouts

**Acceptance Criteria:**
- [ ] Component displays all required information
- [ ] Visual design matches accessibility standards
- [ ] Component responds to user interaction
- [ ] Component handles missing/null data gracefully
- [ ] Component is reusable across different views
- [ ] Component visual state updates reactively
- [ ] Component is testable in isolation

**Dependencies:** Task 1.1

**Complexity:** Medium

---

### Task 3.2: Create Grid View Layout

**Description:**  
Build the grid layout that displays multiple light cards in a responsive grid.

**Requirements:**
- Display lights in a multi-column grid
- Grid should be responsive to screen size
- Support scrolling for large numbers of lights
- Grid should efficiently render large lists (virtualization)
- Empty state should be displayed when no lights match filters

**Acceptance Criteria:**
- [ ] Grid displays multiple light cards
- [ ] Grid adapts to different screen sizes
- [ ] Grid scrolls smoothly with 100+ items
- [ ] Grid uses efficient rendering techniques
- [ ] Empty state is clear and helpful
- [ ] Grid layout is visually balanced

**Dependencies:** Task 3.1

**Complexity:** Medium

---

### Task 3.3: Create List View Layout

**Description:**  
Build the list layout that displays lights in a vertical list format.

**Requirements:**
- Display lights in a single-column list
- List should show more detail than grid view
- Support scrolling for large numbers of lights
- List should efficiently render large lists (virtualization)
- Empty state should be displayed when no lights match filters

**Acceptance Criteria:**
- [ ] List displays light information in rows
- [ ] List shows additional details compared to grid
- [ ] List scrolls smoothly with 100+ items
- [ ] List uses efficient rendering techniques
- [ ] Empty state is clear and helpful
- [ ] List is easy to scan visually

**Dependencies:** Task 3.1

**Complexity:** Medium

---

### Task 3.4: Create View Toggle Component

**Description:**  
Build the control that allows users to switch between grid and list views.

**Requirements:**
- Provide clear visual toggle between grid/list modes
- Toggle should maintain current filter and sort state
- Toggle should persist user preference
- Toggle should be accessible

**Acceptance Criteria:**
- [ ] Toggle is visually clear and intuitive
- [ ] Switching views maintains data state
- [ ] User preference is saved
- [ ] Toggle is keyboard accessible
- [ ] Toggle provides visual feedback

**Dependencies:** Task 3.2, Task 3.3

**Complexity:** Low

---

### Task 3.5: Create Filter Control Panel

**Description:**  
Build the UI that allows users to configure active filters.

**Requirements:**
- Display all available filter options
- Show currently active filters clearly
- Allow users to add/remove filters
- Provide clear affordance for each filter type
- Show count of matching results
- Allow users to clear all filters quickly

**Acceptance Criteria:**
- [ ] All filter options are accessible
- [ ] Active filters are visually distinct
- [ ] Filter controls update light display immediately
- [ ] Result count updates as filters change
- [ ] "Clear all" function works correctly
- [ ] Filter panel is collapsible or hideable
- [ ] Filter controls are keyboard accessible

**Dependencies:** Task 2.1

**Complexity:** Medium

---

### Task 3.6: Create Sort Control Component

**Description:**  
Build the UI that allows users to configure sorting.

**Requirements:**
- Display all available sort options
- Show currently active sort clearly
- Allow users to change sort property
- Allow users to toggle sort direction (asc/desc)
- Provide clear visual feedback of current sort

**Acceptance Criteria:**
- [ ] All sort options are accessible
- [ ] Active sort is visually indicated
- [ ] Sort changes update display immediately
- [ ] Sort direction is clearly shown
- [ ] Sort controls are intuitive
- [ ] Sort controls are keyboard accessible

**Dependencies:** Task 2.2

**Complexity:** Low

---

### Task 3.7: Create Search Input Component

**Description:**  
Build the search input field with appropriate behavior.

**Requirements:**
- Provide text input for search
- Show search icon/indicator
- Provide clear button to reset search
- Show search hint/placeholder text
- Implement debouncing to avoid excessive filtering

**Acceptance Criteria:**
- [ ] Search input is visually clear
- [ ] Search triggers filtering correctly
- [ ] Debouncing prevents performance issues
- [ ] Clear button resets search
- [ ] Placeholder text is helpful
- [ ] Search input is keyboard accessible
- [ ] Search works with other active filters

**Dependencies:** Task 2.4

**Complexity:** Low

---

### Task 3.8: Create Main Layout/Shell

**Description:**  
Build the main application layout that contains all UI components.

**Requirements:**
- Arrange filter controls, sort controls, search, and view toggle
- Display grid/list view area
- Support responsive layout for different screen sizes
- Provide consistent spacing and alignment
- Support mobile and desktop layouts

**Acceptance Criteria:**
- [ ] All components are arranged logically
- [ ] Layout is responsive to screen size
- [ ] Layout works on mobile and desktop
- [ ] Layout uses consistent spacing
- [ ] Layout is visually balanced
- [ ] Layout supports accessibility features

**Dependencies:** Task 3.2, Task 3.3, Task 3.4, Task 3.5, Task 3.6, Task 3.7

**Complexity:** Medium

---

## Phase 4: Integration & Data Flow

### Task 4.1: Connect State to UI Components

**Description:**  
Wire up state management to UI components so data flows correctly.

**Requirements:**
- Light collection updates trigger UI re-renders
- Filter changes update displayed lights
- Sort changes update displayed lights
- User interactions update state correctly
- State changes are efficient (no unnecessary re-renders)

**Acceptance Criteria:**
- [ ] UI displays data from state correctly
- [ ] User interactions update state
- [ ] State changes update UI
- [ ] No memory leaks from state subscriptions
- [ ] Performance is acceptable with frequent updates
- [ ] Data flow is unidirectional and predictable

**Dependencies:** Task 1.4, Task 3.8

**Complexity:** Medium

---

### Task 4.2: Implement Mock Data Generation

**Description:**  
Create mock data generator for testing and development.

**Requirements:**
- Generate realistic sample lights
- Support generating different quantities (10, 50, 100+ lights)
- Include variety of states, ages, priorities
- Generate sample comments and activities
- Mock data should be deterministic for testing

**Acceptance Criteria:**
- [ ] Mock data generator creates valid lights
- [ ] Generated data covers all edge cases
- [ ] Generator supports configurable quantity
- [ ] Generated data is realistic
- [ ] Generator is used in development environment
- [ ] Generator is used in automated tests

**Dependencies:** Task 1.1, Task 1.3

**Complexity:** Low

---

### Task 4.3: Implement Automatic Age Updates

**Description:**  
Set up background process to recalculate light ages periodically.

**Requirements:**
- Age status should update automatically over time
- Updates should occur at reasonable intervals (e.g., every 30 seconds)
- Updates should only affect active lights
- Updates should be efficient
- Updates should pause when app is backgrounded

**Acceptance Criteria:**
- [ ] Age updates occur automatically
- [ ] Update interval is configurable
- [ ] Only active lights are processed
- [ ] Performance impact is minimal
- [ ] Updates stop when app is not active
- [ ] Age color changes are smooth

**Dependencies:** Task 2.3, Task 4.1

**Complexity:** Medium

---

## Phase 5: Polish & UX Enhancements

### Task 5.1: Implement Empty States

**Description:**  
Design and implement helpful empty states for various scenarios.

**Requirements:**
- Show helpful message when no lights exist
- Show helpful message when filters produce no results
- Suggest actions user can take
- Empty states should be visually consistent
- Empty states should include relevant iconography

**Acceptance Criteria:**
- [ ] Empty state appears when appropriate
- [ ] Messages are clear and helpful
- [ ] Suggested actions are relevant
- [ ] Visual design is consistent
- [ ] Empty states are accessible

**Dependencies:** Task 3.2, Task 3.3

**Complexity:** Low

---

### Task 5.2: Implement Loading States

**Description:**  
Design and implement loading indicators for async operations.

**Requirements:**
- Show loading indicator during initial data load
- Show loading indicator during data refresh
- Loading states should not block UI unnecessarily
- Loading indicators should be visually consistent

**Acceptance Criteria:**
- [ ] Loading states appear during async operations
- [ ] Loading indicators are visually clear
- [ ] UI remains responsive during loading
- [ ] Loading states are accessible
- [ ] Loading does not flash for quick operations

**Dependencies:** Task 3.8

**Complexity:** Low

---

### Task 5.3: Implement Filter/Sort Persistence

**Description:**  
Save and restore user's filter and sort preferences.

**Requirements:**
- Persist active filters across app sessions
- Persist active sort configuration across sessions
- Persist view mode preference (grid/list)
- Load saved preferences on app start
- Handle migration if preference format changes

**Acceptance Criteria:**
- [ ] Preferences are saved correctly
- [ ] Preferences are restored on app start
- [ ] Invalid/corrupted preferences don't crash app
- [ ] User can reset to defaults
- [ ] Persistence works across app updates

**Dependencies:** Task 2.1, Task 2.2, Task 3.4

**Complexity:** Low

---

### Task 5.4: Implement Accessibility Features

**Description:**  
Ensure application is accessible to all users.

**Requirements:**
- All interactive elements are keyboard accessible
- All interactive elements have semantic labels
- Proper focus management throughout app
- Support screen readers
- Sufficient color contrast for all text
- Support system font size preferences

**Acceptance Criteria:**
- [ ] App is fully keyboard navigable
- [ ] Screen reader provides complete information
- [ ] Focus order is logical
- [ ] Color contrast meets WCAG AA standards
- [ ] Interactive elements are properly labeled
- [ ] App respects system accessibility settings

**Dependencies:** All UI tasks (Phase 3)

**Complexity:** Medium

---

### Task 5.5: Implement Visual Polish & Animations

**Description:**  
Add subtle animations and visual polish to improve UX.

**Requirements:**
- Smooth transitions when switching views
- Animate filter/sort changes
- Subtle hover states for interactive elements
- Loading animations that don't distract
- Animations should be performant
- Animations should respect reduced motion preference

**Acceptance Criteria:**
- [ ] Animations enhance rather than distract
- [ ] Transitions are smooth and performant
- [ ] Hover states provide clear feedback
- [ ] Reduced motion preference is respected
- [ ] Animations work consistently across platforms
- [ ] No animation performance issues with many lights

**Dependencies:** All UI tasks (Phase 3)

**Complexity:** Low

---

## Phase 6: Testing & Quality

### Task 6.1: Unit Test Data Models

**Description:**  
Write comprehensive unit tests for all data models.

**Requirements:**
- Test all validation logic
- Test serialization/deserialization
- Test calculated properties
- Test edge cases
- Achieve high code coverage

**Acceptance Criteria:**
- [ ] All data models have unit tests
- [ ] Tests cover happy path scenarios
- [ ] Tests cover edge cases and errors
- [ ] Code coverage >80% for data models
- [ ] Tests are maintainable and clear

**Dependencies:** Task 1.1, Task 1.2, Task 1.3

**Complexity:** Low

---

### Task 6.2: Unit Test Business Logic

**Description:**  
Write comprehensive unit tests for filter, sort, and age logic.

**Requirements:**
- Test all filter combinations
- Test all sort configurations
- Test age calculation logic
- Test search functionality
- Achieve high code coverage

**Acceptance Criteria:**
- [ ] All business logic has unit tests
- [ ] Tests cover all filter/sort combinations
- [ ] Tests cover edge cases
- [ ] Code coverage >80% for business logic
- [ ] Tests are maintainable and clear

**Dependencies:** Task 2.1, Task 2.2, Task 2.3, Task 2.4

**Complexity:** Medium

---

### Task 6.3: Component Testing

**Description:**  
Write tests for UI components in isolation.

**Requirements:**
- Test component rendering with various props
- Test component interaction handling
- Test component edge cases
- Use appropriate testing utilities

**Acceptance Criteria:**
- [ ] All major components have tests
- [ ] Tests verify rendering logic
- [ ] Tests verify interaction handling
- [ ] Tests are isolated and fast
- [ ] Tests use best practices for component testing

**Dependencies:** All UI tasks (Phase 3)

**Complexity:** Medium

---

### Task 6.4: Integration Testing

**Description:**  
Write tests that verify components work together correctly.

**Requirements:**
- Test complete filter/sort workflows
- Test view switching maintains state
- Test data flow from state to UI
- Test user scenarios end-to-end

**Acceptance Criteria:**
- [ ] Integration tests cover major workflows
- [ ] Tests verify state and UI integration
- [ ] Tests catch integration issues
- [ ] Tests are maintainable
- [ ] Tests run reliably

**Dependencies:** Task 4.1, Task 6.3

**Complexity:** Medium

---

### Task 6.5: Performance Testing

**Description:**  
Verify application performance with realistic data loads.

**Requirements:**
- Test with 100+ lights
- Test filter/sort performance
- Test scroll performance
- Test age update performance
- Identify and document performance bottlenecks

**Acceptance Criteria:**
- [ ] Performance benchmarks are established
- [ ] App performs acceptably with 100+ lights
- [ ] No UI jank during interactions
- [ ] Performance issues are documented
- [ ] Performance tests are automated

**Dependencies:** Task 4.2, All Phase 3 and 4 tasks

**Complexity:** Medium

---

## Phase 7: Documentation

### Task 7.1: Write Technical Documentation

**Description:**  
Document architecture, patterns, and technical decisions.

**Requirements:**
- Document state management approach
- Document data models and relationships
- Document component hierarchy
- Document filter/sort algorithms
- Include architecture diagrams

**Acceptance Criteria:**
- [ ] Technical documentation is complete
- [ ] Documentation is clear and helpful
- [ ] Diagrams illustrate architecture
- [ ] Documentation is kept up to date
- [ ] Documentation includes examples

**Dependencies:** All previous tasks

**Complexity:** Low

---

### Task 7.2: Write User Documentation

**Description:**  
Create user-facing documentation for the MVP features.

**Requirements:**
- Document how to use filters
- Document how to use sorting
- Document how to switch views
- Document how to use search
- Include screenshots and examples

**Acceptance Criteria:**
- [ ] User documentation covers all features
- [ ] Documentation is clear and concise
- [ ] Screenshots illustrate features
- [ ] Documentation is accessible
- [ ] Documentation is suitable for end users

**Dependencies:** All Phase 3 tasks

**Complexity:** Low

---

### Task 7.3: Create Developer Setup Guide

**Description:**  
Document how to set up development environment.

**Requirements:**
- Document prerequisites
- Document installation steps
- Document how to run development build
- Document how to run tests
- Document common troubleshooting

**Acceptance Criteria:**
- [ ] Setup guide is complete
- [ ] Guide works for new developers
- [ ] All commands are documented
- [ ] Troubleshooting section is helpful
- [ ] Guide is kept up to date

**Dependencies:** None (can be done early)

**Complexity:** Low

---

## Summary

### Total Tasks: 46

**By Phase:**
- Phase 0 (Network Architecture): 11 tasks
- Phase 1 (Data Model & State): 4 tasks
- Phase 2 (Business Logic): 4 tasks
- Phase 3 (UI Components): 8 tasks
- Phase 4 (Integration): 3 tasks
- Phase 5 (Polish & UX): 5 tasks
- Phase 6 (Testing): 5 tasks
- Phase 7 (Documentation): 3 tasks

**By Complexity:**
- Low: 18 tasks
- Medium: 20 tasks
- High: 8 tasks

### Critical Path (Minimum MVP with Networking):

**Network Foundation (Phase 0):**
1. Task 0.1: Setup Protocol Buffers & Buf CLI
2. Task 0.2: Define Protocol Buffer Messages
3. Task 0.3: Implement Storage Adapter Interface
4. Task 0.4: Implement Offline Message Queue
5. Task 0.5: Implement mDNS Service Discovery
6. Task 0.6: Implement Server Core
7. Task 0.7: Implement Client Connection Management
8. Task 0.8: Implement Streaming Updates

**Application Foundation (Phase 1-4):**
9. Task 1.1: Light Data Model (uses protobuf)
10. Task 1.4: State Management (integrates with network client)
11. Task 2.1: Filter Logic
12. Task 2.2: Sort Logic
13. Task 3.1: Light Card Component
14. Task 3.2: Grid View Layout
15. Task 3.5: Filter Control Panel
16. Task 3.6: Sort Control Component
17. Task 3.8: Main Layout/Shell
18. Task 4.1: Connect State to UI

**Total Critical Path: 18 tasks**

This represents the minimum viable product: a networked application with client-server architecture, real-time updates, offline support, and a filterable/sortable grid view of lights.

### Recommended Development Order:

**Week 1-2: Network Foundation**
- Complete Phase 0 tasks (0.1 through 0.8)
- Get basic client-server communication working
- Test with simple protobuf messages

**Week 3: Data Models & State**
- Complete Phase 1 tasks
- Integrate with network client
- Test real-time state updates

**Week 4: Business Logic**
- Complete Phase 2 tasks
- Implement all filtering and sorting

**Week 5-6: User Interface**
- Complete Phase 3 tasks
- Build all UI components
- Connect to state management

**Week 7: Integration & Polish**
- Complete Phase 4 and 5 tasks
- End-to-end testing
- UX improvements

**Week 8: Testing & Documentation**
- Complete Phase 6 and 7 tasks
- Comprehensive testing
- Complete documentation

---

## Next Steps

1. ✅ Review and approve task breakdown
2. ✅ Select technology stack - **Flutter/Dart with ConnectRPC**
3. ⬜ Install prerequisites (Buf CLI, Flutter, dependencies)
4. ⬜ Create project structure
5. ⬜ Begin Phase 0: Setup protobuf and buf configuration
6. ⬜ Define all .proto files
7. ⬜ Generate initial code with `buf generate`
8. ⬜ Begin implementing network architecture
