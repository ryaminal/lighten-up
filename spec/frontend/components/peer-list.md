# PeerList Component Specification

## Overview

**Purpose**: Displays a real-time list of all connected peers with their current light status, notes, and time elapsed since last seen.

**Location**: `src/lib/components/PeerList.svelte`

**Dependencies**:

- `$lib/stores` (peers, lights)
- Svelte lifecycle (onMount, onDestroy)

**Used By**: Main dashboard view

## Behavior Specification

### Feature: Empty State Display

#### When no peers are connected

- Given the peers list is empty
- Then display "Searching for peers..." message centered
- And display "0 Active" badge in header
- And show "Active Lights" header
- And show "Sort by Priority" dropdown

**Acceptance Criteria**:

- ✅ Empty state message is visible
- ✅ Badge shows correct count (0)
- ✅ UI remains responsive

### Feature: Peer Display

#### When peers are connected

- Given one or more peers in the list
- Then display each peer as a card with:
  - Peer name (bold, prominent)
  - Time elapsed since last seen (MM:SS format)
  - Colored left border matching light color
  - Light name (if enabled and matching)
  - Note (if present)
  - Hover effect (shadow increase)

**Acceptance Criteria**:

- ✅ All peers visible in list
- ✅ Peer count badge accurate
- ✅ Colors match peer light states
- ✅ Names truncated if too long

#### When peer has a matching light

- Given peer's light color matches an enabled light in config
- Then display the light name above the note
- And truncate if name is too long

**Acceptance Criteria**:

- ✅ Light name shown only if enabled
- ✅ Light name shown only if color matches
- ✅ Light name not shown if no match

#### When peer has a note

- Given peer has a note field with content
- Then display the note below the light name (or name if no light)
- And truncate if note is too long

**Acceptance Criteria**:

- ✅ Note visible when present
- ✅ Note not visible when null/empty
- ✅ Note truncated with ellipsis

### Feature: Time Elapsed Formatting

#### When less than 60 seconds elapsed

- Given peer was last seen 45 seconds ago
- Then display "00:45"
- And update every second

**Acceptance Criteria**:

- ✅ Format is MM:SS with zero-padding
- ✅ Updates in real-time (1 second interval)
- ✅ Accurate calculation

#### When more than 60 seconds elapsed

- Given peer was last seen 125 seconds ago
- Then display "02:05" (2 minutes, 5 seconds)
- And continue updating

**Acceptance Criteria**:

- ✅ Minutes calculated correctly
- ✅ Seconds wrap at 60
- ✅ Both values zero-padded

### Feature: Real-time Updates

#### When peer list changes

- Given peers store updates
- Then immediately re-render the list
- And update peer count badge
- And maintain scroll position

**Acceptance Criteria**:

- ✅ Reactive to store changes
- ✅ No flicker or jank
- ✅ Smooth transitions

#### When time passes

- Given component is mounted
- Then update time displays every 1 second
- And force re-render with new time values

**Acceptance Criteria**:

- ✅ Interval set on mount
- ✅ Interval cleared on destroy
- ✅ No memory leaks

### Feature: Sorting (UI Only)

#### When sort dropdown is visible

- Given component is rendered
- Then show dropdown with options:
  - Sort by Priority
  - Sort by Time Elapsed
  - Sort by Room Number

**Note**: Sorting logic is not currently implemented, only UI is present.

**Acceptance Criteria**:

- ✅ Dropdown visible
- ✅ All options present
- ⚠️ Sorting logic not implemented

### Feature: UI Layout

#### Desktop layout

- Given screen width >= 768px (md breakpoint)
- Then render at 400px width
- And show as sidebar panel

#### Large desktop layout

- Given screen width >= 1280px (xl breakpoint)
- Then render at 450px width

**Acceptance Criteria**:

- ✅ Responsive width
- ✅ Scrollable peer list
- ✅ Fixed header

## State Management

### Input (Store Subscriptions)

- `peers`: Array of PeerPresence objects
  ```typescript
  {
    peer_id: string;
    peer_name: string;
    light_state: { color: string; timestamp: number };
    last_seen: number; // Unix timestamp in seconds
    note?: string | null;
    notification_status?: Notification | null;
  }
  ```
- `lights`: Array of LightConfig objects
  ```typescript
  {
    id: string;
    name: string;
    color: string; // Hex color
    enabled: boolean;
    priority: number;
    updated_at: number;
    updated_by: string;
  }
  ```

### Output

- No direct outputs (display only)

### Internal State

- `currentTime`: Current timestamp for elapsed time calculation
- `intervalId`: Timer ID for cleanup
- `peersWithTime`: Computed reactive list with render keys

## Edge Cases

### Null/Undefined Handling

- **Empty peers array**: Show empty state
- **Null lights array**: Don't crash, skip light name lookup
- **Peer without note**: Don't show note section
- **Peer with disabled light**: Don't show light name
- **Peer with mismatched color**: Don't show light name

### Timing Edge Cases

- **lastSeen is 0**: Show "00:00"
- **lastSeen is null/undefined**: Show empty string
- **Very large elapsed time**: Continue formatting (99:59+)

### Performance

- **Many peers (50+)**: List should remain smooth
- **Rapid updates**: Should not cause jank
- **Component unmount**: Clean up interval timer

## Integration Points

### Store Dependencies

- Subscribes to `peers` store (reactive)
- Subscribes to `lights` store (reactive)

### Lifecycle

- `onMount`: Starts 1-second interval timer
- `onDestroy`: Clears interval timer

### No External Events

- Display only, no user interactions (except hover)
- No Tauri commands called

## Visual Design

### Colors

- Background: `slate-50` (light) / `#15202b` (dark)
- Cards: `white` (light) / `slate-800` (dark)
- Text primary: `slate-900` (light) / `white` (dark)
- Text secondary: `slate-500` (light) / `slate-400` (dark)
- Border left: Peer's light color
- Badge: `blue-100/blue-700` (light) / `blue-900/blue-300` (dark)

### Typography

- Header: Bold, uppercase, small (sm), wide tracking
- Peer name: Bold, base size
- Light name: Small (xs), medium weight
- Note: Small (sm), normal weight
- Time: Extra small (xs), mono font

### Spacing

- Card padding: 4 (16px)
- Card gaps: 3 (12px)
- List padding: 4 (16px)
- Header padding: 6 (24px)

## Accessibility

- Semantic HTML structure
- Proper heading hierarchy
- Truncation with ellipsis for long content
- Hover states for interactive feel
- Color not sole indicator (text labels present)

## Testing Strategy

Tests verify:

- ✅ Empty state rendering
- ✅ Peer display with all fields
- ✅ Light name matching logic
- ✅ Time formatting (under/over 60s)
- ✅ Multiple peer display
- ✅ UI elements presence
- ✅ Badge count accuracy
- ✅ Note conditional rendering

## Future Enhancements

- [ ] Implement sorting logic (Priority, Time, Room)
- [ ] Add click handlers for peer cards
- [ ] Add peer detail modal
- [ ] Add filtering capabilities
- [ ] Add peer status indicators (typing, away, etc.)
