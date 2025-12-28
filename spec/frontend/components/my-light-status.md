# MyLightStatus Component Specification

## Overview

**Purpose**: Displays and manages the user's current light status, including light color selection, custom message/note, and status display with animation.

**Location**: `src/lib/components/MyLightStatus.svelte`

**Dependencies**:

- `$lib/stores` (myPeerName, myLightColor, myNote, lights)
- `$lib/tauri` (setLightColor)
- `LightColorPicker` component
- Svelte lifecycle

**Used By**: Main dashboard view

## Behavior Specification

### Feature: Peer Name Display

#### When peer name is available

- Given myPeerName store has value "Alice"
- Then display "Alice" as large heading (2xl/3xl)
- And use bold font weight

**Acceptance Criteria**:

- ✅ Name displayed prominently
- ✅ Responsive font size (2xl on mobile, 3xl on desktop)
- ✅ Dark mode support

#### When peer name is not available

- Given myPeerName store is empty/null
- Then display "Loading..."
- And use same styling

**Acceptance Criteria**:

- ✅ Loading state visible
- ✅ No crash on null

### Feature: Status Display - Off State

#### When light is off (black)

- Given myLightColor is '#000000'
- Then display "Status: OFF" text
- And show static gray dot (no animation)
- And use muted colors (slate)

**Acceptance Criteria**:

- ✅ "Status: OFF" visible
- ✅ No pulsing animation
- ✅ Gray dot color
- ✅ Uppercase styling

#### When off, don't show light name or note

- Given myLightColor is '#000000'
- Then hide light name section
- And hide note section (even if note exists in store)

**Acceptance Criteria**:

- ✅ Light name not visible
- ✅ Note not visible in status section
- ✅ Clean off state

### Feature: Status Display - Active State

#### When light is active (non-black)

- Given myLightColor is '#ff0000'
- Then show pulsing colored dot animation
- And apply glow effect (box-shadow)
- And hide "Status: OFF" text

**Acceptance Criteria**:

- ✅ Pulsing animation present
- ✅ Dot color matches light
- ✅ Glow effect visible
- ✅ OFF text hidden

#### When light matches enabled light config

- Given myLightColor is '#ff0000'
- And lights config has enabled light with color '#ff0000' named "Urgent"
- Then display "Urgent" as light name
- And show above any note text
- And use small font (xs)

**Acceptance Criteria**:

- ✅ Light name displayed
- ✅ Only if enabled === true
- ✅ Only if color matches exactly
- ✅ Small, muted styling

#### When light doesn't match any config

- Given myLightColor doesn't match any enabled light
- Then don't show light name
- And still show note if present

**Acceptance Criteria**:

- ✅ No light name shown
- ✅ Note still visible

#### When light is disabled in config

- Given myLightColor matches a light with enabled === false
- Then don't show light name

**Acceptance Criteria**:

- ✅ Disabled lights ignored

#### When note/status message exists

- Given myNote store has content "In a meeting"
- And light is active (not off)
- Then display note below light name (or below dot if no light name)
- And use slightly larger font than light name (sm vs xs)
- And truncate if too long

**Acceptance Criteria**:

- ✅ Note visible when present
- ✅ Note hidden when null/empty
- ✅ Trimmed whitespace
- ✅ Not shown in off state

### Feature: Note Input

#### When note input is rendered

- Given component is mounted
- Then display text input field
- And show placeholder "Add a custom message for this light (Optional)..."
- And enforce maxlength of 60 characters
- And sync value with myNote store

**Acceptance Criteria**:

- ✅ Input field visible
- ✅ Placeholder text correct
- ✅ Max length enforced
- ✅ Two-way binding with store

#### When user types in note input

- Given user types "Test note"
- Then update local state immediately
- And debounce save for 500ms
- And enforce max 60 characters
- And slice any excess characters

**Acceptance Criteria**:

- ✅ Input updates immediately
- ✅ No save until 500ms pause
- ✅ Max length enforced client-side

#### When debounce timer expires

- Given user stopped typing for 500ms
- And isSaving is false
- Then trim whitespace from note
- And call setLightColor(color, trimmedNote)
- And set isSaving to true during save
- And catch/log any errors

**Acceptance Criteria**:

- ✅ Auto-save after 500ms
- ✅ Whitespace trimmed
- ✅ Backend called with color + note
- ✅ Prevents concurrent saves

#### When user types rapidly

- Given user types "a", then "b", then "c" quickly
- Then clear previous debounce timers
- And only save once after final 500ms pause

**Acceptance Criteria**:

- ✅ Only one save call
- ✅ Debounce properly cancels previous timers

#### When note exceeds max length

- Given user pastes 70 characters
- Then immediately slice to 60 characters
- And continue with normal debounce flow

**Acceptance Criteria**:

- ✅ Truncation immediate
- ✅ No backend call with invalid length

### Feature: Light Color Picker Integration

#### When component renders

- Given all props passed to LightColorPicker
- Then render LightColorPicker component
- And pass current note value
- And allow user to select lights

**Acceptance Criteria**:

- ✅ LightColorPicker rendered
- ✅ Note prop passed
- ✅ Selection updates myLightColor store

### Feature: Section Header

#### When component renders

- Given component is mounted
- Then display "Light Selection & Message" header
- And use small, bold, uppercase styling
- And place above note input

**Acceptance Criteria**:

- ✅ Header visible
- ✅ Correct text
- ✅ Uppercase and bold

## State Management

### Input (Store Subscriptions)

- `myPeerName`: User's display name (string)
- `myLightColor`: Current light color (hex string)
- `myNote`: Current status note/message (string)
- `lights`: Array of light configurations

### Output (Store Updates)

- Indirectly updates `myNote` via setLightColor backend call

### Internal State

- `note`: Local note value (synced with store)
- `maxNoteLength`: 60 characters (const)
- `isSaving`: Boolean flag to prevent concurrent saves
- `saveTimeout`: Debounce timer ID

### Computed State

- `isOff`: myLightColor === '#000000'
- `statusMessage`: Trimmed myNote or empty string
- `lightName`: Matching light name or empty string

## Edge Cases

### Null/Undefined Handling

- **myPeerName null**: Show "Loading..."
- **myNote null/undefined**: Default to empty string
- **myLightColor null**: Default to '#000000' (off)
- **lights null/undefined**: Skip light name lookup

### Note Edge Cases

- **Empty note**: Send undefined to backend (not empty string)
- **Only whitespace**: Trim to empty, send undefined
- **Exactly 60 chars**: Allow
- **Over 60 chars**: Slice immediately

### Save Edge Cases

- **isSaving true**: Skip concurrent save attempts
- **Component unmounted during save**: Let save complete
- **Save error**: Log to console, set isSaving false

## Integration Points

### Store Dependencies

- Subscribes to 4 stores (reactive)
- Updates myNote indirectly via backend

### Tauri Commands

- `setLightColor(color, note?)`: Save light color and optional note

### Child Components

- `LightColorPicker`: Renders grid of selectable lights

### No Direct Events

- User interactions via input and child component

## Visual Design

### Layout

- Flexbox column, full height
- Header section (name + status)
- Input section (note + color picker)
- Auto margin bottom pushes content to top

### Status Section

- Large name (2xl/3xl)
- Status indicator (dot + text)
- Light name (xs, muted)
- Note message (sm, less muted)

### Input Section

- Section header (xs, bold, uppercase)
- Note input (rounded-xl, bordered, shadowed)
- Color picker grid below

### Colors

- Text: `#0d141b` (light) / `white` (dark)
- Input bg: `slate-50` (light) / `slate-800/50` (dark)
- Input border: `slate-200` (light) / `slate-600` (dark)
- Focus ring: Primary color

### Animation

- Pulsing dot when active (animate-ping)
- Glow effect on dot (box-shadow with alpha)

## Accessibility

- Semantic HTML
- Label for input (implicit via placeholder)
- maxlength attribute
- Keyboard accessible
- Screen reader friendly text

## Testing Strategy

Tests verify:

- ✅ Peer name display (present/loading)
- ✅ Off state (no animation, OFF text)
- ✅ Active state (animation, no OFF text)
- ✅ Light name matching (enabled, disabled, no match)
- ✅ Note display (present, absent)
- ✅ Note input sync with store
- ✅ Note input max length
- ✅ Debounced auto-save
- ✅ Rapid typing (single save)
- ✅ Whitespace trimming
- ✅ Edge cases (null values)

## Performance Considerations

- Debounce prevents excessive backend calls
- No interval timers (unlike PeerList)
- Efficient reactive updates
- Slice operation cheap (60 char limit)

## Future Enhancements

- [ ] Note character counter
- [ ] Note formatting (bold, italic)
- [ ] Note templates/presets
- [ ] Status history
- [ ] Quick status presets
- [ ] Emoji picker for notes
