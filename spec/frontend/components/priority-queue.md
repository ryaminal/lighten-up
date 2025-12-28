# PriorityQueue Component Specification

## Overview

**Purpose**: A sidebar panel that displays online peers sorted by priority or alphabetically, allowing quick notification sending by clicking on a peer.

**Location**: `src/lib/components/PriorityQueue.svelte`

**Dependencies**:

- `$lib/stores` (peers, lights)
- `$lib/tauri` (PeerPresence type, sendNotification)
- `LightPickerModal.svelte`
- Svelte lifecycle (onMount, onDestroy)

**Used By**: Main application layout as a right sidebar

## Behavior Specification

### Feature: Peer List Display

#### When peers are online

- Given peers store has active peers
- Then render each peer in a card
- And show peer name
- And show peer note or light name
- And show time in current state
- And show priority badge (if status light is on)
- And show status light color indicator (left inset border)
- And show notification indicator (right inset border, if peer has notification)

**Acceptance Criteria**:

- ✅ All peers displayed
- ✅ Priority badges visible
- ✅ Time updates every second
- ✅ Visual indicators clear

#### When no peers online

- Given peers store is empty
- Then show "No peers online..." message
- And center the message

**Acceptance Criteria**:

- ✅ Empty state message shown
- ✅ Message is centered and italic

### Feature: Priority Sorting (Default)

#### When sortByName is false

- Given sortByName is false (default)
- Then sort peers by light priority (ascending: 0 is highest)
- And for same priority, sort by timestamp (oldest first)
- And show "Priority" badge in header
- And show "sort" icon on toggle button

**Priority Calculation**:

- Off status (#000000) → priority 1000 (lowest)
- Light not found → priority 0 (highest)
- Otherwise → light's configured priority

**Acceptance Criteria**:

- ✅ Peers sorted by priority first
- ✅ Same priority sorted by time (oldest first)
- ✅ "Priority" badge shown
- ✅ "sort" icon shown

### Feature: Alphabetical Sorting

#### When sortByName is true

- Given sortByName is true
- Then sort peers alphabetically by peer_name
- And show "A-Z" text in header
- And show "swap_vert" icon on toggle button

**Acceptance Criteria**:

- ✅ Peers sorted A-Z by name
- ✅ "A-Z" text shown
- ✅ "swap_vert" icon shown

#### When toggle button clicked

- Given user clicks sort toggle button
- Then toggle sortByName state
- And re-sort peer list immediately

**Acceptance Criteria**:

- ✅ Sort order toggles
- ✅ Icon changes
- ✅ List re-renders

### Feature: Time Display

#### When component mounts

- Given component has just mounted
- Then start interval timer (1 second)
- And update currentTime every second
- And re-render time ago strings

**Time Format**:

- < 60s → "Xs ago"
- < 60m → "Xm ago"
- < 24h → "Xh ago"
- > = 24h → "Xd ago"

**Acceptance Criteria**:

- ✅ Timer starts on mount
- ✅ Time updates every second
- ✅ Format correct for all ranges

#### When component unmounts

- Given component is being destroyed
- Then clear interval timer
- And stop time updates

**Acceptance Criteria**:

- ✅ Timer cleaned up
- ✅ No memory leaks

### Feature: Priority Badges

#### For priority 0 (Critical)

- Given peer's light has priority 0
- Then show "Critical" badge
- And use red theme (bg-red-100, text-red-600)

#### For priority 1 (Urgent)

- Given peer's light has priority 1
- Then show "Urgent" badge
- And use orange theme

#### For priority 2 (High)

- Given peer's light has priority 2
- Then show "High" badge
- And use yellow theme

#### For priority 3 (Medium)

- Given peer's light has priority 3
- Then show "Medium" badge
- And use blue theme

#### For priority >= 4 (Low)

- Given peer's light has priority >= 4
- Then show "Low" badge
- And use gray theme

**Acceptance Criteria**:

- ✅ All priority levels mapped
- ✅ Colors match theme
- ✅ Dark mode support

### Feature: Visual Indicators

#### Status light indicator

- Given peer's status light is on (not #000000)
- Then show left inset border in light color (4px)
- And include in box shadow

**Acceptance Criteria**:

- ✅ Left border shows light color
- ✅ Border only when light is on

#### Notification indicator

- Given peer has active notification
- Then show right inset border in notification color (4px)
- And include in box shadow

**Acceptance Criteria**:

- ✅ Right border shows notification color
- ✅ Border only when notification exists

#### Hover effect

- Given user hovers over peer card
- Then enhance box shadow
- And maintain inset borders

**Acceptance Criteria**:

- ✅ Shadow enhances on hover
- ✅ Colored borders persist

### Feature: Notification Modal

#### When peer clicked

- Given user clicks a peer card
- Then set selectedPeer to that peer
- And open LightPickerModal
- And set modal title to "Send Notification"
- And set subtitle to "To: {peer_name}"
- And configure message input (optional, max 30 chars)

**Acceptance Criteria**:

- ✅ Modal opens on peer click
- ✅ Correct peer info displayed
- ✅ Message input configured

#### When modal closed

- Given user closes modal (cancel or backdrop)
- Then set isModalOpen to false
- And clear selectedPeer

**Acceptance Criteria**:

- ✅ Modal closes
- ✅ State reset

#### When notification sent

- Given user selects light and optional message
- Then get light name from selected color
- And use message if provided, or light name as default
- And call sendNotification with peer_id, type, message, color
- And close modal

**Acceptance Criteria**:

- ✅ Notification sent with correct params
- ✅ Default message is light name
- ✅ Custom message used if provided

### Feature: Keyboard Navigation

#### When peer card focused

- Given peer card has keyboard focus
- And Enter key pressed
- Then open notification modal

**Acceptance Criteria**:

- ✅ Enter opens modal
- ✅ Card is focusable (tabindex=0)

## State Management

### Input (Store Subscriptions)

- `peers`: Array of PeerPresence objects
- `lights`: Array of LightConfig objects

### Internal State

- `currentTime`: Number - Current timestamp (updates every 1s)
- `intervalId`: Number - Interval timer ID
- `isModalOpen`: Boolean - Modal visibility
- `selectedPeer`: PeerPresence | null - Currently selected peer for notification
- `sortByName`: Boolean - Sort mode (false = priority, true = alphabetical)

### Computed

- `sortedPeers`: Peers sorted by priority or name
- `peersWithTime`: Peers with render key for reactivity

### Output (Events)

- None (handles notifications via sendNotification function)

## Edge Cases

### Null/Undefined Handling

- **peers null/undefined**: Show empty state
- **lights null/undefined**: Default to priority 0, "Unknown" name
- **peer.note empty**: Show light name instead
- **light not found**: Use "Unknown" name, priority 0

### Priority Edge Cases

- **Off status (#000000)**: Priority 1000 (lowest)
- **Light not enabled**: Not matched, default to Unknown
- **Multiple peers same priority**: Sort by timestamp (oldest first)

### Time Edge Cases

- **Just now (0s)**: Shows "0s ago"
- **Exactly 1 minute**: Shows "1m ago" (not 60s)
- **Negative elapsed (clock skew)**: Would show negative, but shouldn't happen in practice

### Notification Edge Cases

- **No selectedPeer**: Guard clause returns early
- **Light not found for color**: Use "Notification" as default message
- **Empty message**: Use light name as message

## Integration Points

### Store Dependencies

- Subscribes to peers (reactive)
- Subscribes to lights (reactive)

### Tauri Commands

- `sendNotification(peer_id, type, message, priority?, color?)`

### Component Dependencies

- Uses LightPickerModal for notification sending

## Visual Design

### Sidebar

- Width: 320px (w-80)
- Background: White/gray-950
- Border: Left border gray-200/gray-800
- Shadow: Soft shadow
- Hidden on mobile, flex on md+

### Header

- Height: 64px (h-16)
- Sticky top
- Shows peer count and sort mode
- Toggle button on right

### Peer Card

- Background: White/gray-900
- Border: gray-200/gray-700
- Rounded: lg
- Padding: 12px (p-3)
- Cursor: pointer
- Transition: all
- Hover: Enhanced shadow

### Inset Borders

- Status light: 4px left inset in light color
- Notification: 4px right inset in notification color
- Applied via box-shadow

### Priority Badges

- Size: text-[10px]
- Font: Bold, uppercase, tracked
- Padding: px-2 py-0.5
- Rounded: Full
- Theme colors per priority

## Accessibility

- role="button" on peer cards
- tabindex="0" for keyboard navigation
- aria-label for each peer card: "Notify {name} that patient is ready"
- aria-label for sort button: "Sort by priority" or "Sort alphabetically"
- title on sort button (tooltip)

## Testing Strategy

Tests should verify:

- [ ] Peer list display (name, note, time, badge)
- [ ] Empty state when no peers
- [ ] Priority sorting (default)
- [ ] Alphabetical sorting
- [ ] Sort toggle functionality
- [ ] Time formatting (s, m, h, d)
- [ ] Time updates every second
- [ ] Priority badge display (Critical, Urgent, High, Medium, Low)
- [ ] Status light indicator (left border)
- [ ] Notification indicator (right border)
- [ ] Modal opens on peer click
- [ ] Modal closes properly
- [ ] Notification sending with correct params
- [ ] Default message uses light name
- [ ] Custom message passed through
- [ ] Keyboard navigation (Enter on card)
- [ ] Timer cleanup on unmount

## Performance Considerations

- 1-second interval for time updates (not too aggressive)
- Computed sortedPeers uses reactive statement
- peersWithTime forces reactivity with \_renderKey
- Custom scrollbar for smooth overflow

## Future Enhancements

- [ ] Filter peers by status (urgent only, etc.)
- [ ] Search/filter by name
- [ ] Quick actions menu (right-click context menu)
- [ ] Bulk notifications
- [ ] Notification history per peer
- [ ] Sound alerts for new peers
- [ ] Drag-to-reorder override
