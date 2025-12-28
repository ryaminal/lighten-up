# BottomStatusBar Component Specification

## Overview

**Purpose**: Displays the user's current status, peer count, and active notifications in a fixed footer bar.

**Location**: `src/lib/components/BottomStatusBar.svelte`

**Dependencies**:

- `$lib/stores` (myLightColor, lights, peers, notification)
- `$lib/tauri` (clearNotification, getMyPeerId)
- Svelte lifecycle (onMount, onDestroy)

**Used By**: Main application layout (always visible)

## Behavior Specification

### Feature: Status Display

#### When no light is selected (Off state)

- Given myLightColor is '#9ca3af' or default
- Then display "Off" as status name
- And show static gray dot (no animation)
- And enable click to open status picker

**Acceptance Criteria**:

- ✅ "Off" text displayed
- ✅ No pulsing animation
- ✅ "Current Status" label present
- ✅ Clickable button

#### When light is selected (Active state)

- Given myLightColor matches an enabled light
- Then display light name (e.g., "Urgent")
- And show colored dot with light color
- And no pulsing animation (unless urgent)

**Acceptance Criteria**:

- ✅ Light name displayed correctly
- ✅ Dot color matches light color
- ✅ Hover effects active

#### When urgent light is selected

- Given current light has priority === 0
- Then show pulsing animation on status dot
- And display light name
- And red color (#ef4444)

**Acceptance Criteria**:

- ✅ Pulsing animation present
- ✅ Urgent indicator visible
- ✅ Correct priority detection

#### When light is disabled

- Given myLightColor matches a disabled light
- Then display "Off"
- And treat as no light selected

**Acceptance Criteria**:

- ✅ Disabled lights ignored
- ✅ Falls back to "Off"

### Feature: Status Picker Interaction

#### When status button is clicked

- Given user clicks the status display button
- Then call onOpenStatusPicker callback
- And modal/picker should open (handled by parent)

**Acceptance Criteria**:

- ✅ Click handler fires
- ✅ Callback receives event
- ✅ Button has accessible label

### Feature: Peer Count Display

#### When no peers online

- Given peers array is empty or null
- Then display "0 Online"
- And show groups icon
- And show "Peers Online" label

**Acceptance Criteria**:

- ✅ Shows "0 Online"
- ✅ Handles null/undefined peers
- ✅ Icon visible

#### When peers are online

- Given peers array has 2 items
- Then display "2 Online"
- And update reactively when peers change

**Acceptance Criteria**:

- ✅ Count accurate
- ✅ Real-time updates
- ✅ Plural handling

### Feature: Notification Display

#### When no notification exists

- Given notification store is null
- Then show only status and peer count
- And center section is empty

**Acceptance Criteria**:

- ✅ No notification UI visible
- ✅ Layout centered properly

#### When notification exists

- Given notification with message and timestamp
- Then display notification in center section
- And show pulsing dot indicator
- And show message text
- And show time ago ("30s ago")
- And show dismiss button

**Acceptance Criteria**:

- ✅ Message visible
- ✅ Time updates every second
- ✅ Dismiss button clickable
- ✅ Pulsing indicator present

#### When notification has custom color

- Given notification.color is set
- Then use custom color for:
  - Background tint
  - Border color
  - Dot color
  - Text color (if needed)
- And show light name if color matches enabled light

**Acceptance Criteria**:

- ✅ Custom colors applied
- ✅ Light name shown when match
- ✅ Light name not duplicated if same as message

#### When notification has no custom color

- Given notification.color is null/undefined
- Then use type-based styling:
  - `patient-ready`: Blue theme
  - `room-ready`: Green theme
  - `urgent-assist`: Red theme
  - `general-message`: Gray theme

**Acceptance Criteria**:

- ✅ Type-based colors correct
- ✅ All types handled
- ✅ Default fallback exists

### Feature: Notification Time Formatting

#### When notification is recent (< 60s)

- Given notification was sent 30 seconds ago
- Then display "30s ago"
- And update every second

**Acceptance Criteria**:

- ✅ Seconds format correct
- ✅ Updates in real-time

#### When notification is minutes old (60s - 3600s)

- Given notification was sent 120 seconds ago
- Then display "2m ago"

**Acceptance Criteria**:

- ✅ Minutes format correct
- ✅ Conversion accurate

#### When notification is hours old (> 3600s)

- Given notification was sent 7200 seconds ago
- Then display "2h ago"

**Acceptance Criteria**:

- ✅ Hours format correct
- ✅ Conversion accurate

### Feature: Notification Dismissal

#### When dismiss button is clicked

- Given active notification exists
- Then call getMyPeerId() to get current peer ID
- And call clearNotification(myPeerId) to clear on backend
- And set notification store to null
- And remove from UI

**Acceptance Criteria**:

- ✅ Backend notified
- ✅ Store updated
- ✅ UI updated immediately
- ✅ No errors on dismiss

## State Management

### Input (Store Subscriptions)

- `myLightColor`: Current user's light color (hex string)
- `lights`: Array of light configurations
- `peers`: Array of online peers
- `notification`: Current notification object or null
  ```typescript
  {
    type: NotificationType;
    message: string;
    targetPeerId: string;
    senderPeerId?: string;
    timestamp: number; // seconds
    priority?: string;
    color?: string; // hex color
  }
  ```

### Output (Props)

- `onOpenStatusPicker`: Callback function to open status picker

### Internal State

- `currentTime`: Current timestamp for time ago calculation
- `intervalId`: Timer ID for cleanup
- `notificationWithTime`: Computed notification with render key

## Edge Cases

### Null/Undefined Handling

- **myLightColor null**: Default to '#9ca3af'
- **lights undefined**: Show "Off"
- **peers null/undefined**: Show "0 Online"
- **notification null**: Hide notification section

### Notification Edge Cases

- **Light name equals message**: Don't duplicate text
- **Very old notification**: Continue showing time (hours+)
- **Missing sender/target**: Still display message
- **Invalid color**: Fall back to type-based styling

### Performance

- **Rapid notification updates**: Should not flicker
- **Timer cleanup**: Must clear interval on unmount

## Integration Points

### Store Dependencies

- Subscribes to 4 stores (reactive)
- Updates notification store on dismiss

### Tauri Commands

- `get_my_peer_id()`: Get current peer ID for notification clear
- `clear_notification(peerId)`: Clear notification on backend

### Lifecycle

- `onMount`: Start 1-second interval for time updates
- `onDestroy`: Clear interval timer

## Visual Design

### Layout

- Fixed footer bar (h-16, 64px)
- Three sections: Status (left), Notification (center), Peers (right)
- Shadow on top edge
- Z-index 30 (above content)

### Colors

- Background: `white` (light) / `#111827` (dark)
- Border: `gray-200` (light) / `gray-800` (dark)
- Status text: `gray-900` (light) / `white` (dark)
- Hover: `gray-100` (light) / `gray-800/50` (dark)

### Notification Colors

Type-based themes with background, border, dot, icon, text colors.

### Responsive

- Notification section hidden on mobile (< 768px)
- Status and peers always visible

## Accessibility

- Semantic footer element
- Button aria-labels ("Change status", "Dismiss notification")
- Keyboard accessible
- Color not sole indicator (text present)
- Icon alternatives (Material Symbols)

## Testing Strategy

Tests verify:

- ✅ Status display (Off/Active/Urgent)
- ✅ Peer count display (0, multiple)
- ✅ Notification display (with/without color)
- ✅ Time ago formatting (seconds/minutes/hours)
- ✅ Notification dismissal
- ✅ Light name display for custom colors
- ✅ Click handlers
- ✅ Edge cases (null values)

## Performance Considerations

- Interval limited to 1 second
- Notification styling computed once per render
- Store subscriptions efficient (reactive)
- No unnecessary re-renders

## Future Enhancements

- [ ] Notification queue (multiple notifications)
- [ ] Notification sounds/vibration
- [ ] Status picker inline (no modal)
- [ ] Quick note edit
- [ ] Notification history
