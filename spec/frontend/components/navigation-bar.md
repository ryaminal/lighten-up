# NavigationBar Component Specification

## Overview

The `NavigationBar` component provides a compact vertical navigation menu for the application. It displays a logo and navigation buttons for different sections of the app.

**Component Path:** `src/lib/components/NavigationBar.svelte`

**Key Responsibilities:**

- Display navigation options for dashboard, tasks, people, chat, and settings
- Navigate to different views via `currentView` store
- Trigger settings modal via prop callback

---

## Component Structure

### Layout

```
┌───────┐
│   L   │ ← Logo
├───────┤
│       │
│  📊   │ ← Dashboard button
│       │
│  📋   │ ← Tasks button (active/highlighted)
│       │
│  👥   │ ← People button
│       │
│  💬   │ ← Chat button
│       │
├───────┤
│  ⚙️   │ ← Settings button
└───────┘
```

### Visual Design

- **Width:** Fixed at 64px (w-16)
- **Background:** White/dark (#111827 in dark mode)
- **Logo:** Blue square with "L" text
- **Active Button:** Blue background with shadow
- **Inactive Buttons:** Gray with hover effects
- **Borders:** Gray border on right side

---

## Props

### `onOpenSettings: () => void`

Callback function invoked when the settings button is clicked.

**Required:** Yes

---

## State Management

### Store Dependencies

```typescript
import { currentView } from '$lib/stores'; // Controls active view
```

### Types

```typescript
type ViewType = 'dashboard' | 'tasks' | 'people' | 'chat' | 'settings';
```

---

## User Interactions

### Navigation Buttons

#### Dashboard Button

- **Icon:** Material icon "dashboard"
- **Aria-label:** "Dashboard"
- **Behavior:** Sets `currentView` to 'dashboard'
- **Styling:** Inactive state with hover effects

#### Tasks Button

- **Icon:** Material icon "list_alt"
- **Aria-label:** "Tasks"
- **Behavior:** No action (visual only)
- **Styling:** Active/highlighted state (blue background)

#### People Button

- **Icon:** Material icon "people"
- **Aria-label:** "People"
- **Behavior:** No action (visual only)
- **Styling:** Inactive state with hover effects

#### Chat Button

- **Icon:** Material icon "chat_bubble"
- **Aria-label:** "Chat"
- **Behavior:** Sets `currentView` to 'chat'
- **Styling:** Inactive state with hover effects

#### Settings Button

- **Icon:** Material icon "settings"
- **Aria-label:** "Settings"
- **Behavior:** Calls `onOpenSettings()` callback
- **Styling:** Inactive state with hover effects
- **Position:** Bottom of navigation bar

---

## Functions

### `setView(view: ViewType): void`

Handles view navigation based on button clicks.

**Parameters:**

- `view`: The target view to navigate to

**Behavior:**

- If `view === 'settings'`: Calls `onOpenSettings()` callback
- If `view === 'dashboard' || view === 'chat'`: Updates `currentView` store
- Other views: No action

**Implementation:**

```typescript
function setView(view: ViewType) {
  if (view === 'settings') {
    onOpenSettings();
  } else if (view === 'dashboard' || view === 'chat') {
    currentView.set(view as 'dashboard' | 'config');
  }
}
```

---

## Styling

### Container

- Width: 64px (w-16)
- Full height vertical flex column
- White background (dark mode: #111827)
- Right border with gray-200 (dark: gray-800)
- Padding: py-4 (16px top/bottom)

### Logo

- Size: 40x40px (w-10 h-10)
- Blue background (#3b82f6)
- Rounded corners (rounded-lg)
- White "L" text
- Box shadow

### Navigation Buttons

- Padding: p-3 (12px)
- Rounded corners (rounded-xl)
- Inactive: Gray text with hover effects
- Active (Tasks): Blue background with shadow
- Hover: Light gray background, blue text
- Smooth color transitions

### Button Layout

- Main navigation: Centered, space-y-4 (16px gap)
- Settings button: Fixed at bottom with mt-auto

---

## Accessibility

### ARIA Labels

All buttons have descriptive `aria-label` attributes:

- Dashboard button: "Dashboard"
- Tasks button: "Tasks"
- People button: "People"
- Chat button: "Chat"
- Settings button: "Settings"

### Keyboard Navigation

All navigation items are focusable buttons.

### Visual Feedback

- Hover states provide visual feedback
- Active button clearly indicated with color
- Icon-only design with aria-labels for screen readers

---

## Test Coverage Requirements

### Button Rendering Tests

1. Should render all navigation buttons (Dashboard, Tasks, People, Chat, Settings)
2. Should render logo with "L" text

### Navigation Tests

3. Should call currentView.set('dashboard') when dashboard button clicked
4. Should call currentView.set('chat') when chat button clicked
5. Should call onOpenSettings callback when settings button clicked

### Non-functional Button Tests

6. Tasks button should not trigger navigation (visual only)
7. People button should not trigger navigation (visual only)

### Styling Tests

8. Tasks button should have active/highlighted styling
9. Other buttons should have inactive styling
10. Settings button should be at bottom of navigation

---

## Edge Cases

### Missing Callback

- Component requires `onOpenSettings` prop
- Should handle gracefully if callback is not provided

### Store State

- Should handle undefined/null `currentView` store state
- Should not break if store is not initialized

---

## Integration Points

### Store Integration

- Writes to `currentView` store for dashboard and chat navigation
- Does not read from store (stateless component)

### Parent Integration

- Requires `onOpenSettings` callback from parent
- Parent must handle settings modal display

---

## Implementation Notes

1. **Partial Implementation:** Some buttons (Tasks, People) have no functionality
2. **Icon-Only:** Relies on material icons for visual representation
3. **Minimal State:** No internal state, all interactions via props/stores
4. **Type Mismatch:** Chat view sets `currentView` to 'chat', but store type is `'dashboard' | 'config'`

---

## Known Issues

### Type Inconsistency

The `currentView` store expects `'dashboard' | 'config'`, but the component tries to set it to `'chat'`. This may cause TypeScript errors or unexpected behavior.

**Current Code:**

```typescript
currentView.set(view as 'dashboard' | 'config'); // 'chat' cast to wrong type
```

**Potential Fix:**
Either update the store type to include 'chat', or handle chat navigation differently.

---

## Future Considerations

- Implement Tasks and People navigation
- Fix type inconsistency for chat view
- Add active state indicators based on currentView
- Add notification badges for chat/tasks
- Consider responsive design for mobile
- Add keyboard shortcuts for navigation
