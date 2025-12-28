# Sidebar Component Specification

## Overview

The `Sidebar` component provides primary navigation for the application. It is a vertical sidebar displayed on the left side of the screen with navigation buttons and a settings button.

**Component Path:** `src/lib/components/Sidebar.svelte`

**Key Responsibilities:**

- Display navigation options for dashboard and configuration views
- Indicate current active view
- Provide access to settings modal

---

## Component Structure

### Layout

```
┌─────────────────────┐
│      Logo Area      │
│    (Lighten Up)     │
├─────────────────────┤
│                     │
│  ┌───────────────┐  │
│  │ Active Lights │  │ ← Dashboard button (active state)
│  └───────────────┘  │
│                     │
│  ┌───────────────┐  │
│  │    Config     │  │ ← Configuration button
│  └───────────────┘  │
│                     │
├─────────────────────┤
│        [ME]         │ ← Settings button
└─────────────────────┘
```

### Visual Design

- **Width:** Fixed at 80px (w-20)
- **Background:** Dark slate (#0f172a)
- **Text Color:** Slate-400 for inactive items
- **Active State:** Blue primary color with shadow
- **Borders:** Slate-700 borders between sections

---

## Props

This component has no props. It manages its own internal state and uses the `currentView` store.

---

## State Management

### Local State

```typescript
let showSettings = false; // Controls settings modal visibility
```

### Store Dependencies

```typescript
import { currentView } from '$lib/stores'; // Tracks active view
```

---

## User Interactions

### Navigation Buttons

#### Dashboard Button

- **Label:** "Active Lights"
- **Icon:** Material icon "Light"
- **Behavior:** Clicking navigates to dashboard view
- **Active State:** Blue background when `currentView === 'dashboard'`
- **Inactive State:** Dark slate background with hover effect

#### Configuration Button

- **Label:** "Light Configuration"
- **Icon:** Material icon "Settings"
- **Behavior:** Clicking navigates to configuration view
- **Active State:** Blue background when `currentView === 'config'`
- **Inactive State:** Dark slate background with hover effect

### Settings Button

- **Label:** "ME" text inside button
- **Position:** Bottom of sidebar
- **Behavior:** Clicking opens settings modal
- **Visual:** Circular button with ring border

---

## Functions

### `navigate(view: 'dashboard' | 'config'): void`

Updates the `currentView` store to switch between views.

**Parameters:**

- `view`: The target view to navigate to

**Implementation:**

```typescript
function navigate(view: 'dashboard' | 'config') {
  currentView.set(view);
}
```

### `openSettings(): void`

Opens the settings modal by setting `showSettings` to true.

### `closeSettings(): void`

Closes the settings modal by setting `showSettings` to false.

---

## Child Components

### SettingsModal

Conditionally rendered based on `showSettings` state.

**Props:**

- `isOpen`: Boolean controlling modal visibility
- `onClose`: Callback to close modal

---

## Styling

### Container

- Dark blue-slate background (#0f172a)
- Fixed width of 80px
- Full height with flex column layout
- Right border with slate-700 color

### Logo Area

- Height: 80px (h-20)
- Centered content
- Bottom border separator
- Primary color accent on logo icon

### Navigation Buttons

- Size: 48x48px (h-12 w-12)
- Rounded corners (rounded-xl)
- Active state: Primary blue with shadow
- Inactive state: Dark slate with hover
- Smooth transitions

### Settings Button

- Size: 40x40px (h-10 w-10)
- Circular shape (rounded-full)
- Fixed at bottom with top border separator
- Ring border for emphasis

---

## Accessibility

### Button Labels

All buttons have descriptive `title` attributes:

- Dashboard button: "Active Lights"
- Configuration button: "Light Configuration"
- Logo area: "Lighten Up"
- Settings button: "Settings"

### Keyboard Navigation

All interactive elements are focusable buttons with proper `type="button"` attributes.

### Visual Feedback

- Hover states provide visual feedback
- Active navigation button clearly indicated
- Smooth transitions for state changes

---

## Test Coverage Requirements

### Navigation Tests

1. Should render all navigation buttons
2. Should navigate to dashboard when dashboard button clicked
3. Should navigate to config when config button clicked
4. Should highlight dashboard button when on dashboard view
5. Should highlight config button when on config view

### Settings Modal Tests

6. Should open settings modal when ME button clicked
7. Should close settings modal when close callback triggered
8. Settings modal should not be visible initially

### Visual State Tests

9. Should apply active styles to current view button
10. Should apply inactive styles to non-current view buttons

---

## Edge Cases

### Store Initialization

- Component should handle undefined or null `currentView` gracefully
- Default state should be handled by store initialization

### Rapid Navigation

- Multiple rapid clicks should update view correctly
- No race conditions in state updates

---

## Integration Points

### Store Integration

- Reads from `currentView` store for active state
- Writes to `currentView` store on navigation

### Component Integration

- Includes `SettingsModal` component
- Passes state and callbacks to modal

---

## Implementation Notes

1. **Simple Design:** No complex state management needed
2. **Reactive UI:** Uses Svelte's reactive declarations for styling
3. **Modal Pattern:** Settings modal managed through local state
4. **No External Dependencies:** Uses only Svelte stores and components

---

## Future Considerations

- Could add tooltips with hover delay for better UX
- Could add keyboard shortcuts for navigation
- Could add notification badges for updates
- Could add collapse/expand functionality for mobile
