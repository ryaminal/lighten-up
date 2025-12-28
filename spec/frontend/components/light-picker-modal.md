# LightPickerModal Component Specification

## Overview

**Purpose**: A configurable modal dialog for selecting a light color, optionally with a custom message. Supports auto-submit mode for quick selection and manual submit mode with message input.

**Location**: `src/lib/components/LightPickerModal.svelte`

**Dependencies**:

- `$lib/stores` (lights)
- Svelte lifecycle (tick)

**Used By**: Any component that needs a light selection interface (notifications, status changes)

## Behavior Specification

### Feature: Modal Visibility

#### When isOpen is true

- Given isOpen prop is true
- Then render modal overlay with backdrop
- And render dialog content
- And trap focus within modal
- And prevent body scroll

**Acceptance Criteria**:

- ✅ Modal visible when isOpen=true
- ✅ Backdrop covers viewport
- ✅ Dialog centered on screen

#### When isOpen is false

- Given isOpen prop is false
- Then don't render modal
- And allow normal page interaction

**Acceptance Criteria**:

- ✅ No modal elements in DOM
- ✅ No overlay rendered

#### When modal opens with message input

- Given isOpen changes to true
- And showMessageInput is true
- Then focus the message input field
- And cursor ready for typing

**Acceptance Criteria**:

- ✅ Input focused automatically
- ✅ User can type immediately

#### When modal closes

- Given modal closes (isOpen becomes false)
- Then reset message to empty string
- And reset selectedColor to null
- And call onClose callback

**Acceptance Criteria**:

- ✅ State reset on close
- ✅ onClose called
- ✅ Clean slate for next open

### Feature: Modal Header

#### Always display

- Given modal is open
- Then show title (configurable via prop)
- And show subtitle if provided
- And show close button (X)
- And disable close button during submission

**Acceptance Criteria**:

- ✅ Title displayed
- ✅ Subtitle shown if provided
- ✅ Close button visible and functional

### Feature: Light Selection Grid

#### When lights are available

- Given lights store has enabled lights
- Then filter out disabled lights
- And filter out black lights (#000000)
- And sort by priority (ascending)
- And render in 4-column grid
- And show for each light:
  - Color dot (20px circle)
  - Light name (truncated)
  - Priority badge (Critical/Urgent/High/Medium/Low)

**Acceptance Criteria**:

- ✅ Grid shows enabled lights only
- ✅ Sorted by priority
- ✅ 4 columns layout
- ✅ All visual elements present

#### When light is selected

- Given user clicks a light button
- Then set selectedColor to that color
- And show selected styling:
  - Colored border
  - Glow effect (box-shadow)
  - Pulsing indicator (if not current)
- And enable submit button (if not autoSubmit)

**Acceptance Criteria**:

- ✅ Selection updates immediately
- ✅ Visual feedback clear
- ✅ Only one light selected at a time

#### When light is current user's light

- Given currentColor prop matches light color
- Then show green checkmark indicator
- And mark as "current"

**Acceptance Criteria**:

- ✅ Current light visually distinguished
- ✅ Checkmark visible

#### When allowToggleOff is enabled

- Given allowToggleOff prop is true
- And user clicks their current light
- Then set selectedColor to '#000000' (off)
- And show hint text below grid
- And submit will turn light off

**Acceptance Criteria**:

- ✅ Toggle-off works
- ✅ Hint text displayed
- ✅ Off state (#000000) selected

#### When autoSubmitOnSelect is enabled

- Given autoSubmitOnSelect prop is true
- And user clicks a light
- Then immediately call onSelect(color, message)
- And close modal without submit button
- And don't wait for state updates

**Acceptance Criteria**:

- ✅ Auto-submit on click
- ✅ No submit button shown
- ✅ Modal closes immediately
- ✅ Message passed (if any)

### Feature: Message Input (Optional)

#### When showMessageInput is false

- Given showMessageInput prop is false
- Then don't render message input field
- And don't render character counter
- And submit immediately possible after selection

**Acceptance Criteria**:

- ✅ No input shown
- ✅ Streamlined selection

#### When showMessageInput is true

- Given showMessageInput prop is true
- Then render message input field
- And show label (configurable via messageLabel prop)
- And show "(Optional)" or nothing based on messageRequired
- And show placeholder (configurable)
- And show character counter (remaining chars)
- And enforce maxlength (default 60)

**Acceptance Criteria**:

- ✅ Input field visible
- ✅ Label correct
- ✅ Placeholder shown
- ✅ Counter updates as user types

#### When message is required

- Given messageRequired prop is true
- And user hasn't entered message
- Then disable submit button
- And prevent submission

**Acceptance Criteria**:

- ✅ Submit disabled without message
- ✅ Submit enabled with message

#### When message is optional

- Given messageRequired prop is false
- Then allow empty message
- And submit button enabled with just color selection

**Acceptance Criteria**:

- ✅ Can submit without message
- ✅ Message optional

#### When message reaches limit

- Given user types and reaches messageMaxLength
- Then prevent additional characters
- And show remaining chars in orange (< 10 chars left)
- And show remaining chars in gray (>= 10 chars left)

**Acceptance Criteria**:

- ✅ Max length enforced
- ✅ Counter color changes near limit
- ✅ Visual warning for low chars

#### When user presses Enter in message input

- Given canSubmit is true
- And message input has focus
- Then trigger handleSubmit
- And submit selection

**Acceptance Criteria**:

- ✅ Enter key submits
- ✅ Only if valid

### Feature: Priority Badges

#### For priority 0 (Critical)

- Given light has priority 0
- Then show "Critical" badge
- And use red theme (bg-red-100, text-red-700)

#### For priority 1 (Urgent)

- Given light has priority 1
- Then show "Urgent" badge
- And use orange theme

#### For priority 2 (High)

- Given light has priority 2
- Then show "High" badge
- And use yellow theme

#### For priority 3 (Medium)

- Given light has priority 3
- Then show "Medium" badge
- And use blue theme

#### For priority >= 4 (Low)

- Given light has priority >= 4
- Then show "Low" badge
- And use gray theme

**Acceptance Criteria**:

- ✅ All priorities mapped correctly
- ✅ Colors match theme
- ✅ Dark mode support

### Feature: Submit Button (Manual Mode)

#### When autoSubmitOnSelect is false

- Given autoSubmitOnSelect prop is false
- Then show footer with Cancel and Submit buttons
- And enable Submit when:
  - selectedColor is not null
  - messageRequired=false OR message has content
  - isSubmitting is false
- And disable Submit otherwise

**Acceptance Criteria**:

- ✅ Footer visible
- ✅ Both buttons present
- ✅ Submit enable/disable logic correct

#### When Submit is clicked

- Given canSubmit is true
- Then set isSubmitting to true
- And trim message (or set to null if empty)
- And call onSelect(selectedColor, message)
- And close modal on success
- And catch/log errors
- And set isSubmitting to false finally

**Acceptance Criteria**:

- ✅ Loading state during submit
- ✅ onSelect called with correct params
- ✅ Modal closes on success
- ✅ Error handling present

#### When Cancel is clicked

- Given user clicks Cancel
- Then call onClose callback
- And don't call onSelect
- And reset state

**Acceptance Criteria**:

- ✅ onClose called
- ✅ onSelect not called
- ✅ Modal closes

### Feature: Keyboard Navigation

#### When Escape is pressed

- Given modal is open
- And isSubmitting is false
- Then close modal
- And call onClose

**Acceptance Criteria**:

- ✅ Escape closes modal
- ✅ Escape blocked during submit

#### When Enter is pressed (no message input)

- Given showMessageInput is false
- And canSubmit is true
- Then trigger handleSubmit

**Acceptance Criteria**:

- ✅ Enter submits
- ✅ Only in no-input mode

### Feature: Backdrop Click

#### When backdrop is clicked

- Given user clicks outside dialog
- And isSubmitting is false
- Then close modal
- And call onClose

**Acceptance Criteria**:

- ✅ Click outside closes
- ✅ Click on dialog doesn't close
- ✅ Blocked during submit

### Feature: Loading State

#### During submission

- Given isSubmitting is true
- Then show spinner on submit button
- And change text to "Submitting..."
- And disable all buttons
- And disable color selection buttons
- And disable message input
- And prevent closing

**Acceptance Criteria**:

- ✅ Loading indicator visible
- ✅ All interactions disabled
- ✅ Can't close during submit

## State Management

### Input (Props)

- `isOpen`: Boolean - Modal visibility
- `onClose`: Function - Close callback
- `onSelect`: Function(color, message) - Selection callback
- `currentColor`: String|null - User's current light color
- `title`: String - Modal title (default "Select Light")
- `subtitle`: String|null - Optional subtitle
- `showMessageInput`: Boolean - Show message field
- `messageLabel`: String - Message field label
- `messagePlaceholder`: String - Message placeholder
- `messageRequired`: Boolean - Message required for submit
- `messageMaxLength`: Number - Max message length (default 60)
- `submitLabel`: String - Submit button text
- `submitIcon`: String - Submit button icon
- `allowToggleOff`: Boolean - Allow turning off current light
- `autoSubmitOnSelect`: Boolean - Auto-submit on color click

### Input (Store Subscriptions)

- `lights`: Array of light configurations

### Internal State

- `message`: String - Current message input value
- `selectedColor`: String|null - Currently selected color
- `isSubmitting`: Boolean - Submission in progress
- `inputElement`: HTMLInputElement - Reference for focus

### Computed

- `remainingChars`: messageMaxLength - message.length
- `canSubmit`: Complex validation (color selected, message if required, not submitting)
- `lightButtons`: Filtered and sorted lights

## Edge Cases

### Null/Undefined Handling

- **lights null/undefined**: Show empty grid
- **currentColor null**: No current indicator
- **subtitle null**: Don't show subtitle
- **message empty**: Pass null to onSelect

### Priority Edge Cases

- **Negative priority**: Shows "Low" (falls through)
- **Very high priority (>10)**: Shows "Low"
- **Same priority**: Maintains order (stable sort)

### Message Edge Cases

- **Message with only whitespace**: Trimmed to empty, sent as null
- **Message at exactly maxLength**: Allowed
- **Rapid typing**: Handled by input maxlength

### Toggle-Off Edge Cases

- **allowToggleOff false, clicking current**: Selects same color (no toggle)
- **allowToggleOff true, clicking current**: Selects #000000 (off)

### Auto-Submit Edge Cases

- **autoSubmitOnSelect true**: No footer, submits immediately
- **autoSubmitOnSelect false**: Shows footer, manual submit

## Integration Points

### Store Dependencies

- Subscribes to lights (reactive)

### Callbacks

- `onClose()`: Called when modal closes
- `onSelect(color, message)`: Called when selection made

### No Direct Tauri Commands

- Parent component handles backend calls via onSelect

## Visual Design

### Modal Overlay

- Full viewport coverage
- Black overlay with 50% opacity
- Backdrop blur effect
- z-index 50

### Dialog

- Max width 448px (max-w-md)
- White/gray-900 background
- Rounded-xl corners
- Shadow-2xl
- Border

### Grid Layout

- 4 columns (grid-cols-4)
- 8px gap (gap-2)
- Buttons: 3px padding, rounded-lg

### Colors

- Selected border: Light color
- Selected glow: Light color at 15% opacity
- Priority badges: Theme-specific
- Message counter: Gray (>= 10 chars), Orange (< 10 chars)

### Typography

- Title: lg, bold
- Subtitle: sm, gray
- Label: sm, semibold
- Light name: 10px, semibold
- Priority badge: 8px, bold, uppercase

## Accessibility

- role="dialog" and aria-modal="true"
- aria-labelledby points to title
- aria-label on close button
- aria-label on color buttons (Select/Deselect)
- Disabled states clear
- Keyboard navigation (Escape, Enter)
- Focus management (input auto-focus)

## Testing Strategy

Tests should verify:

- [ ] Modal visibility (open/close)
- [ ] Light grid display (filtering, sorting)
- [ ] Light selection (single selection)
- [ ] Current light indicator
- [ ] Toggle-off behavior
- [ ] Auto-submit mode
- [ ] Manual submit mode
- [ ] Message input (optional, required)
- [ ] Character counter
- [ ] Submit button enable/disable logic
- [ ] Cancel button
- [ ] Escape key closes
- [ ] Enter key submits
- [ ] Backdrop click closes
- [ ] Loading state during submit
- [ ] Error handling
- [ ] State reset on close
- [ ] Priority badge display

## Performance Considerations

- Focus management uses tick() for timing
- State reset on close prevents stale data
- Auto-submit bypasses state updates for speed
- Disabled states prevent double-submission

## Future Enhancements

- [ ] Search/filter lights by name
- [ ] Recently used lights section
- [ ] Light preview before submit
- [ ] Keyboard shortcuts (1-9 for lights)
- [ ] Custom color picker
- [ ] Light description/tooltip
- [ ] Animation on open/close
