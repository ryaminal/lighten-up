# SettingsModal Component Specification

## Overview

The `SettingsModal` component provides a comprehensive settings interface for managing user identity and light configurations. It allows users to update their display name and manage their custom light statuses including colors, names, priorities, and enabled states.

**Component Path:** `src/lib/components/SettingsModal.svelte`

**Key Responsibilities:**

- Manage user peer identity (name and ID)
- Configure custom light statuses
- Add, edit, delete, and reorder lights
- Validate light configurations (unique colors, non-empty names)
- Save changes to backend via Tauri commands
- Display loading and error states

---

## Component Structure

### Layout

```
┌───────────────────────────────────────────┐
│  ⚙️ Settings                          [X] │ ← Header
├───────────────────────────────────────────┤
│                                           │
│  Your Identity                            │ ← Peer section
│  ┌─────────────────────────────────────┐ │
│  │ Display Name:  [John Doe        ]  │ │
│  │ Peer ID:       abc123...            │ │
│  └─────────────────────────────────────┘ │
│                                           │
│  Light Configuration                      │ ← Lights section
│  ┌─────────────────────────────────────┐ │
│  │ Priority │ Color │ Name    │ Actions │ │
│  ├─────────────────────────────────────┤ │
│  │    1     │  🔴   │ Urgent  │ ↑↓ 🗑️  │ │
│  │    2     │  🟡   │ Busy    │ ↑↓ 🗑️  │ │
│  │    3     │  🟢   │ Free    │ ↑↓ 🗑️  │ │
│  └─────────────────────────────────────┘ │
│  [+ Add New Light]                        │
│                                           │
└───────────────────────────────────────────┘
```

### Modal States

- **Closed:** Not rendered in DOM
- **Loading:** Shows loading spinner
- **Loaded:** Shows peer info and light configuration
- **Error:** Shows error message banner
- **Empty Lights:** Shows empty state prompt

---

## Props

### `isOpen: boolean`

Controls modal visibility.

- `true`: Modal is rendered and visible
- `false`: Modal is not rendered

**Required:** Yes

### `onClose: () => void`

Callback function invoked when modal should close.

**Required:** Yes  
**Triggers:**

- Close button (X) clicked
- Escape key pressed
- After saving peer name on close

---

## State Management

### Local State

```typescript
let peerId = ''; // User's peer ID (read-only)
let peerName = ''; // User's editable display name
let initialPeerName = ''; // Original name for change detection
let lights: LightConfig[] = []; // Array of light configurations
let isLoading = true; // Loading state
let errorMessage = ''; // Error display message
let lightTableContainer: HTMLDivElement | undefined; // Scroll container ref
```

### Type Definitions

```typescript
interface LightConfig {
  id: string;
  name: string;
  color: string; // Hex color code
  enabled: boolean;
  priority: number; // 0-based priority (0 = highest)
  updated_at: number; // Timestamp in milliseconds
  updated_by: string; // Peer ID who last updated
}
```

---

## Lifecycle Management

### `onMount`

Loads initial data when component mounts:

1. Fetch peer ID via `get_my_peer_id`
2. Fetch peer name via `get_my_peer_name`
3. Fetch lights via `getLights()`
4. Sort lights by priority
5. Normalize priorities if needed
6. Handle errors and set loading state

---

## User Interactions

### Peer Identity Management

#### Update Display Name

- **Input Field:** Text input bound to `peerName`
- **Auto-save:** On blur (focus loss)
- **Validation:**
  - Cannot be empty (reverts to initial)
  - Must be different from initial (skips save if unchanged)
- **Save Trigger:** Blur or modal close
- **Error Handling:** Shows error message, reverts to initial name

### Light Configuration Management

#### Add New Light

- **Trigger:** Click "+ Add New Light" button
- **Behavior:**
  - Calls `addNewLight()` helper
  - Generates unique color (not black, not used)
  - Creates new light with default values
  - Adds to end of list (lowest priority)
  - Auto-scrolls table to bottom
- **Error:** Shows error message if fails

#### Delete Light

- **Trigger:** Click delete (trash) icon
- **Behavior:**
  - Calls `removeLight(id)` helper
  - Removes light from backend and list
  - Re-normalizes priorities
- **Error:** Shows error message if fails

#### Edit Light Name

- **Trigger:** Type in name input field
- **Behavior:**
  - Updates local state immediately
  - Calls `updateLightDetails()` on blur
  - Validates name is not empty
- **Validation:** Reverts to previous if empty
- **Error:** Shows error message if save fails

#### Change Light Color

- **Trigger:** Select from color picker dropdown
- **Behavior:**
  - Updates local state immediately
  - Calls `updateLightDetails()` after selection
  - Validates color is unique
  - Cannot select black (#000000)
- **Validation:** Shows error if color already used
- **Error:** Shows error message if save fails

#### Toggle Light Enabled

- **Trigger:** Click checkbox
- **Behavior:**
  - Toggles enabled state immediately
  - Calls `updateLightDetails()` after toggle
- **Error:** Shows error message if save fails

#### Move Light Priority

- **Up Arrow:** Moves light higher (lower priority number)
- **Down Arrow:** Moves light lower (higher priority number)
- **Disabled States:**
  - Up arrow disabled for first light
  - Down arrow disabled for last light
- **Behavior:**
  - Swaps priorities with adjacent light
  - Updates both lights in backend
  - Re-sorts list by priority
- **Error:** Shows error message if fails

---

## Functions

### Data Loading

#### `loadData(): Promise<void>`

Loads all settings data from backend.

**Steps:**

1. Set loading state
2. Fetch peer ID, name, and lights in parallel
3. Sort lights by priority
4. Normalize priorities if needed
5. Handle errors
6. Clear loading state

### Peer Management

#### `savePeerName(): Promise<void>`

Saves peer name to backend.

**Validation:**

- Trims whitespace
- Checks for empty (shows error, reverts)
- Checks for unchanged (skips save)

**Steps:**

1. Trim and validate name
2. Call `set_peer_name` Tauri command
3. Update `initialPeerName` on success
4. Handle errors (show message, revert)

#### `handleClose(): Promise<void>`

Handles modal close action.

**Steps:**

1. Save peer name (if changed)
2. Call `onClose()` callback

### Light Management

#### `handleAddLight(): Promise<void>`

Adds new light to configuration.

**Steps:**

1. Call `addNewLight()` helper
2. Update lights array
3. Auto-scroll to bottom (100ms delay)
4. Handle errors

#### `handleDeleteLight(id: string): Promise<void>`

Deletes light from configuration.

**Steps:**

1. Call `removeLight(id)` helper
2. Update lights array
3. Handle errors

#### `handleLightNameChange(id: string, newName: string): Promise<void>`

Updates light name.

**Validation:**

- Trims whitespace
- Reverts if empty

**Steps:**

1. Validate name
2. Call `updateLightDetails()` helper
3. Update lights array
4. Handle errors

#### `handleLightColorChange(id: string, newColor: string): Promise<void>`

Updates light color.

**Validation:**

- Checks for uniqueness via `validateUniqueColor()`
- Shows error if duplicate

**Steps:**

1. Validate color uniqueness
2. Call `updateLightDetails()` helper
3. Update lights array
4. Handle errors

#### `handleLightEnabledToggle(id: string, enabled: boolean): Promise<void>`

Toggles light enabled state.

**Steps:**

1. Update enabled state
2. Call `updateLightDetails()` helper
3. Update lights array
4. Handle errors

#### `handleMoveLightUp(id: string): Promise<void>`

Moves light higher in priority list.

**Steps:**

1. Call `moveLightPriority()` helper with -1 direction
2. Update lights array
3. Re-sort by priority
4. Handle errors

#### `handleMoveLightDown(id: string): Promise<void>`

Moves light lower in priority list.

**Steps:**

1. Call `moveLightPriority()` helper with +1 direction
2. Update lights array
3. Re-sort by priority
4. Handle errors

### Keyboard Handlers

#### `handleKeyDown(e: KeyboardEvent): void`

Handles Escape key to close modal.

**Behavior:**

- If Escape pressed: calls `handleClose()`

---

## Child Components

### PeerIdentitySection

Displays and allows editing of peer identity.

**Props:**

- `peerId`: User's peer ID (read-only)
- `peerName`: User's editable name
- `onNameChange`: Callback for name changes
- `onNameSave`: Callback for save (on blur)

### LightConfigSection

Displays and manages light configurations.

**Props:**

- `lights`: Array of light configs
- `isLoading`: Loading state
- `errorMessage`: Error to display
- `onAddLight`: Add light callback
- `onDeleteLight`: Delete light callback
- `onNameChange`: Name edit callback
- `onColorChange`: Color change callback
- `onEnabledToggle`: Enabled toggle callback
- `onMoveUp`: Move up callback
- `onMoveDown`: Move down callback
- `lightTableContainer`: Scroll container binding

### EmptyLightsState

Shows when no lights are configured.

**Content:**

- Icon and prompt to add lights
- "Add New Light" button

---

## Helper Functions (Imported)

### `addNewLight(lights: LightConfig[], peerId: string): Promise<LightConfig[]>`

Creates and adds new light with unique color.

### `removeLight(id: string): Promise<LightConfig[]>`

Deletes light and re-normalizes priorities.

### `updateLightDetails(light: LightConfig): Promise<LightConfig[]>`

Updates light properties in backend.

### `moveLightPriority(lights: LightConfig[], id: string, direction: -1 | 1): Promise<LightConfig[]>`

Swaps light priority with adjacent light.

### `normalizePriorities(lights: LightConfig[], peerId: string): Promise<LightConfig[]>`

Ensures priorities are sequential (0, 1, 2, ...).

### `validateUniqueColor(lights: LightConfig[], id: string, color: string): boolean`

Checks if color is unique among lights.

---

## Styling

### Modal Container

- Fixed overlay with backdrop blur
- Centered modal with max width
- White background (dark: gray-900)
- Rounded corners with shadow
- Z-index for layering

### Header

- Title "Settings" with gear icon
- Close button (X) on right
- Border bottom separator

### Sections

- Peer Identity: Top section
- Light Configuration: Scrollable table section
- Add Light Button: Below table

### Light Table

- Scrollable container (max-height)
- Headers: Priority, Color, Name, Enabled, Actions
- Row hover effects
- Alternating row colors (optional)
- Disabled state styling for arrows

### States

- **Loading:** Shows spinner overlay
- **Error:** Red banner at top
- **Empty:** Centered empty state

---

## Accessibility

### Modal Semantics

- `role="dialog"` on modal container
- `aria-labelledby` pointing to title
- `aria-modal="true"` attribute

### Keyboard Navigation

- Escape key closes modal
- Tab order: Name input → table inputs → buttons
- Arrow buttons have aria-labels
- Disabled arrows not focusable

### Form Labels

- All inputs have associated labels
- Checkbox has descriptive text
- Color picker has aria-label

### Focus Management

- Traps focus within modal when open
- Returns focus to trigger on close

---

## Error Handling

### Load Errors

- Catches errors during `loadData()`
- Displays error message banner
- Still renders modal UI

### Save Errors

- Catches errors for each operation
- Displays specific error messages
- Reverts changes on failure
- Logs errors to console

### Validation Errors

- Empty name: Shows error, reverts
- Duplicate color: Shows error, prevents save
- Empty lights: Shows empty state (not error)

---

## Test Coverage Requirements

### Modal Visibility Tests

1. Does not render when `isOpen` is false
2. Renders when `isOpen` is true

### Modal Close Tests

3. Calls `onClose` when close button clicked
4. Calls `onClose` when Escape key pressed

### Data Loading Tests

5. Shows loading state initially
6. Loads and displays peer information
7. Loads and displays lights
8. Sorts lights by priority

### Peer Name Tests

9. Saves peer name on blur
10. Does not save peer name if unchanged
11. Prevents empty peer name
12. Saves peer name on modal close

### Light Management Tests

13. Adds a new light with unique color
14. Deletes a light
15. Updates light name on change
16. Toggles light enabled state
17. Changes light color (with validation)

### Priority Management Tests

18. Moves light up in priority
19. Moves light down in priority
20. Disables move up for first light
21. Disables move down for last light

### Edge Case Tests

22. Shows empty state when no lights exist
23. Displays error message on load failure
24. Displays error when peer name save fails
25. Handles color uniqueness validation

---

## Integration Points

### Tauri Commands

- `get_my_peer_id`: Fetch user's peer ID
- `get_my_peer_name`: Fetch user's display name
- `set_peer_name`: Update display name
- `getLights()`: Fetch light configurations
- Light operations via helper functions (which call Tauri)

### Helper Functions

All light operations delegated to helper functions in:

- `$lib/logic/settings/useLightOperations`
- `$lib/logic/settings/lightColorUtils`

---

## Performance Considerations

### Lazy Loading

- Modal content only rendered when `isOpen` is true
- Reduces initial bundle size impact

### Debouncing

- Name saves only on blur (not on every keystroke)
- Color picker saves immediately but validates first

### Scroll Management

- Auto-scrolls to new light after adding
- Smooth scroll for better UX

---

## Implementation Notes

1. **Priority System:** 0-based, where 0 is highest priority
2. **Color Validation:** Prevents duplicate colors and black
3. **Name Validation:** Empty names revert to previous value
4. **Auto-save:** Name saves on blur and modal close
5. **Error Display:** Single error message area for all errors

---

## Known Issues

None identified. Component follows best practices.

---

## Future Considerations

- Add confirmation dialog for delete operations
- Add undo/redo functionality
- Add bulk operations (enable/disable all)
- Add light templates or presets
- Add import/export configuration
- Add color palette suggestions
- Add keyboard shortcuts for light operations
- Add drag-and-drop for reordering
- Add search/filter for large light lists
