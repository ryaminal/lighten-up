# LightColorPicker Component Specification

## Overview

**Purpose**: Renders a grid of clickable light color buttons that allow users to select their current status light. Handles toggling between active and off states.

**Location**: `src/lib/components/LightColorPicker.svelte`

**Dependencies**:

- `$lib/stores` (myLightColor, lights)
- `$lib/tauri` (setLightColor)

**Used By**: MyLightStatus component

## Behavior Specification

### Feature: Light Button Grid Display

#### When lights config is available

- Given lights store has enabled lights
- Then filter out disabled lights (enabled === false)
- And filter out black lights (color === '#000000')
- And sort by priority (ascending)
- And render as grid of buttons
- And display 2 columns on mobile, 3 on lg, 4 on xl

**Acceptance Criteria**:

- ✅ Only enabled lights shown
- ✅ Black lights excluded
- ✅ Sorted by priority (0 = highest)
- ✅ Responsive grid layout

#### When no enabled lights exist

- Given all lights are disabled or only black exists
- Then render empty grid (no buttons)

**Acceptance Criteria**:

- ✅ No crash on empty array
- ✅ Graceful empty state

### Feature: Light Button Display

#### When light is inactive (not selected)

- Given light color doesn't match myLightColor
- Then show normal state:
  - White/slate background
  - Border: slate-200 (light) / slate-700 (dark)
  - Light name below color dot
  - No pulsing animation
  - No note display
  - 80% opacity on color dot
  - Hover effects active

**Acceptance Criteria**:

- ✅ Correct inactive styling
- ✅ No animation
- ✅ Hover increases opacity to 100%

#### When light is active (currently selected)

- Given light color matches myLightColor
- Then show active state:
  - Larger scale (102%)
  - Colored border matching light
  - Glow effect (box-shadow with color)
  - Pulsing indicator in top-right
  - Light name below color dot
  - Note displayed (if note exists)
  - Higher z-index (10)

**Acceptance Criteria**:

- ✅ Active styling applied
- ✅ Pulsing animation present
- ✅ Border color matches light
- ✅ Glow effect visible
- ✅ Scaled slightly larger

#### When active light has note

- Given light is active
- And note prop is non-empty string
- Then display note below light name
- And wrap in quotes
- And use very small font (10px)
- And truncate with line-clamp-1

**Acceptance Criteria**:

- ✅ Note visible on active light only
- ✅ Quotes around note
- ✅ Trimmed whitespace
- ✅ Truncation with ellipsis

### Feature: Light Selection (Click to Activate)

#### When clicking an inactive light

- Given user clicks light with color '#ff0000'
- And current myLightColor is '#00ff00' (different)
- Then set isChanging to true
- And call setLightColor('#ff0000', note)
- And pass trimmed note (or undefined if empty)
- And disable all buttons during change
- And set isChanging to false when complete

**Acceptance Criteria**:

- ✅ Color changes to clicked light
- ✅ Note preserved during change
- ✅ Backend called with correct params
- ✅ Buttons disabled during change

#### When clicking the active light (toggle off)

- Given user clicks light with color '#ff0000'
- And current myLightColor is '#ff0000' (same)
- Then set isChanging to true
- And call setLightColor('#000000', note)
- And turn light off (black)
- And set isChanging to false when complete

**Acceptance Criteria**:

- ✅ Color changes to '#000000' (off)
- ✅ Note still preserved
- ✅ Toggle behavior works
- ✅ No double-click issues

#### When change is in progress

- Given isChanging is true
- And user clicks another light
- Then ignore the click (early return)
- And prevent race conditions

**Acceptance Criteria**:

- ✅ Concurrent clicks ignored
- ✅ No multiple simultaneous requests
- ✅ Buttons disabled during change

#### When setLightColor fails

- Given backend returns an error
- Then catch error
- And log to console
- And set isChanging to false
- And don't update UI (store will not change)

**Acceptance Criteria**:

- ✅ Error caught and logged
- ✅ No crash on error
- ✅ isChanging reset properly

### Feature: Button Accessibility

#### For each button

- Given button is rendered
- Then include aria-label:
  - Inactive: "Set light to {name}"
  - Active: "Turn off {name}"
- And include title attribute with hint
- And ensure keyboard accessible (type="button")

**Acceptance Criteria**:

- ✅ Aria-labels descriptive
- ✅ Title shows toggle hint
- ✅ Keyboard navigable

## State Management

### Input (Props)

- `note`: Optional string (current user's note)

### Input (Store Subscriptions)

- `myLightColor`: Current light color (hex string)
- `lights`: Array of light configurations

### Output

- Indirectly updates myLightColor via backend

### Internal State

- `lightButtons`: Derived filtered and sorted lights
- `isChanging`: Boolean flag to prevent concurrent changes

### Computed

- `isActive(color)`: Returns true if color matches myLightColor

## Edge Cases

### Null/Undefined Handling

- **lights null/undefined**: lightButtons becomes empty array
- **note undefined**: Treat as empty string
- **note null**: Treat as empty string
- **myLightColor null**: No lights active

### Note Handling

- **Empty note**: Pass undefined to backend (not empty string)
- **Whitespace-only note**: Trim to empty, pass undefined
- **Note with leading/trailing spaces**: Trim before sending

### Priority Handling

- **Same priority**: Maintain original order (stable sort)
- **Negative priority**: Allowed (sorts before 0)
- **Missing priority**: Treated as undefined (end of list)

### Color Edge Cases

- **Black color in config**: Filtered out (never shown)
- **Invalid hex color**: Still rendered (browser will handle)
- **Uppercase vs lowercase hex**: Comparison case-sensitive

## Integration Points

### Store Dependencies

- Subscribes to myLightColor (reactive)
- Subscribes to lights (reactive, used in derived)

### Tauri Commands

- `setLightColor(color, note?)`: Change user's light status

### Parent Component

- Receives note prop from parent
- Parent typically MyLightStatus

## Visual Design

### Grid Layout

- 2 columns on mobile (< 1024px)
- 3 columns on large (>= 1024px)
- 4 columns on xl (>= 1280px)
- Gap: 16px (gap-4)

### Button Styling

- Height: 7rem (112px) mobile, 8rem (128px) desktop
- Rounded: xl (12px)
- Padding: 12px horizontal, 16px vertical
- Flexbox column, centered

### Colors

- Inactive: White/slate-800 background
- Active: slate-50/slate-800 with colored border
- Color dot: 24px circle (h-6 w-6)
- Text: slate-700/slate-200

### Animation

- Pulsing dot: animate-ping (top-right corner)
- Scale on active: 102%
- Scale on click: 98% (active:scale-[0.98])
- Opacity: 80% → 100% on hover (inactive)
- Shadow: Increases on hover

### Typography

- Light name: xs, semibold, line-clamp-1
- Note: 10px, medium, line-clamp-1, quoted

## Accessibility

- Button elements (not divs)
- aria-label describes action
- title provides additional context
- Keyboard accessible (tab, enter, space)
- Disabled state during loading
- Color not sole indicator (text labels)

## Testing Strategy

Tests should verify:

- [ ] Enabled lights displayed in grid
- [ ] Disabled lights filtered out
- [ ] Black lights filtered out
- [ ] Lights sorted by priority
- [ ] Active light styling correct
- [ ] Inactive light styling correct
- [ ] Click activates light (backend called)
- [ ] Click on active light toggles off
- [ ] Note displayed on active light only
- [ ] Note trimmed before sending
- [ ] Concurrent clicks prevented (isChanging)
- [ ] Error handling (backend failure)
- [ ] Empty lights array handled
- [ ] Responsive grid layout

## Performance Considerations

- Derived state efficiently filters/sorts
- Single backend call per click
- No unnecessary re-renders
- Stable sort maintains order

## Future Enhancements

- [ ] Drag-to-reorder lights
- [ ] Custom colors (color picker)
- [ ] Light presets/favorites
- [ ] Keyboard shortcuts (1-9 for lights)
- [ ] Long-press for more options
- [ ] Confirmation before turning off
