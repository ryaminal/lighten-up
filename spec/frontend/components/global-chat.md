# GlobalChat Component Specification

## Overview

The `GlobalChat` component provides a real-time global chat interface for all connected peers. It displays chat messages with timestamps, supports message editing and deletion, and provides keyboard shortcuts for efficient messaging.

**Component Path:** `src/lib/components/GlobalChat.svelte`

**Key Responsibilities:**

- Display chronological list of chat messages from all peers
- Send new chat messages
- Edit and delete own messages
- Show peer names and timestamps
- Handle real-time message updates via Tauri events
- Provide keyboard shortcuts (Enter, ArrowUp, Escape)
- Auto-scroll to newest messages

---

## Component Structure

### Layout

```
┌─────────────────────────────────────────┐
│  🗨️  Global Chat                        │ ← Header
├─────────────────────────────────────────┤
│                                         │
│  Date: Today                            │ ← Date divider
│                                         │
│  ┌─────────────────────────┐           │
│  │ Alice: Hello everyone!  │  9:30 AM  │ ← Other's message
│  └─────────────────────────┘           │
│                                         │
│           ┌─────────────────────────┐  │
│  9:31 AM  │  Hi Alice! (You)        │  │ ← Own message
│           └─────────────────────────┘  │
│                                         │
├─────────────────────────────────────────┤
│  [                              ] [Send]│ ← Input area
└─────────────────────────────────────────┘
```

### Visual States

- **Loading:** Shows "Loading messages..." centered
- **Empty:** Shows empty state with icon and prompt
- **Messages:** Scrollable message list with date dividers
- **Editing:** Input shows "Editing" indicator and cancel button

---

## Props

This component has no props. All data is fetched via Tauri commands and events.

---

## State Management

### Local State

```typescript
let messages: ChatMessage[] = []; // All chat messages
let messageInput = ''; // Current input text
let isLoading = true; // Loading state
let myPeerId = ''; // Current user's peer ID
let myPeerName = ''; // Current user's name
let unlistenChat: UnlistenFn | null = null; // Event listener cleanup
let unlistenChatDeleted: UnlistenFn | null = null; // Event listener cleanup
let messagesContainer: HTMLDivElement; // Scroll container ref
let editingMessageId: string | null = null; // ID of message being edited
let openMenuId: string | null = null; // ID of message with open menu
```

### Store Dependencies

```typescript
import { peers, myPeerName as myPeerNameStore } from '$lib/stores';
```

### Type Definitions

```typescript
interface ChatMessage {
  id: string;
  peer_id: string;
  peer_name: string;
  content: string;
  timestamp: number;
  edited_at?: number | null;
}
```

---

## Lifecycle Management

### `onMount`

1. Register click outside handler for closing menus
2. Fetch initial data in parallel:
   - Chat messages via `getChatMessages()`
   - My peer ID via `getMyPeerId()`
   - My peer name via `getMyPeerName()`
3. Set up event listeners:
   - `chat-message`: Handle new/updated messages
   - `chat-message-deleted`: Handle message deletions
4. Update loading state
5. Handle errors gracefully

### `onDestroy`

1. Remove click outside handler
2. Cleanup event listeners

### `afterUpdate`

Auto-scroll messages container to bottom after each render.

---

## User Interactions

### Sending Messages

#### Send Button Click

- **Behavior:** Sends message input as new message
- **Validation:** Trims whitespace, ignores empty messages
- **Result:** Clears input after successful send

#### Enter Key

- **Behavior:** Same as send button click (without Shift)
- **Shift+Enter:** Allows multi-line input
- **Validation:** Same as send button

### Editing Messages

#### Arrow Up Key

- **Trigger:** When input is empty
- **Behavior:** Enters edit mode for user's last message
- **Result:** Populates input with message content

#### Edit Menu Option

- **Trigger:** Click edit button in message menu
- **Behavior:** Populates input with message content
- **State:** Shows "Editing" indicator

#### Save Edits

- **Trigger:** Send while in edit mode
- **Empty Input:** Deletes the message
- **Non-empty:** Updates message content
- **Result:** Clears edit mode and input

#### Cancel Edit

- **Trigger:** Escape key while editing
- **Behavior:** Clears input and exits edit mode

### Deleting Messages

#### Delete Menu Option

- **Trigger:** Click delete button in message menu
- **Behavior:** Sends delete command to backend
- **Result:** Message removed from list

#### Delete via Empty Edit

- **Trigger:** Clear content while editing and send
- **Behavior:** Same as delete menu option

### Message Menus

#### Open Menu

- **Trigger:** Click menu button (three dots)
- **Behavior:** Opens menu for that message
- **Auto-close:** Clicking outside closes menu

---

## Functions

### Message Management

#### `handleSendMessage(): Promise<void>`

Handles sending new messages or saving edits.

**Logic:**

1. Trim input content
2. If editing:
   - Empty content → delete message
   - Non-empty → edit message
3. If new:
   - Empty → ignore
   - Non-empty → send message
4. Clear input and exit edit mode
5. Handle errors by restoring input

#### `handleEditMessage(message: ChatMessage): void`

Enters edit mode for specified message.

- Populates input with message content
- Sets editing message ID
- Closes menus

#### `handleDeleteMessage(id: string): Promise<void>`

Deletes specified message via backend.

- Sends delete command
- Closes menus
- Handles errors

#### `handleEditLastMessage(): void`

Enters edit mode for user's most recent message.

- Filters messages to user's own
- Selects last message
- Populates input

#### `cancelEdit(): void`

Exits edit mode and clears input.

### UI Helpers

#### `toggleMenu(id: string): void`

Opens/closes message menu.

- Toggles menu for specified message
- Only one menu open at a time

#### `handleClickOutside(event: MouseEvent): void`

Closes open menus when clicking outside.

#### `handleKeyDown(e: KeyboardEvent): void`

Handles keyboard shortcuts:

- **Enter (no Shift):** Send message
- **ArrowUp (empty input):** Edit last message
- **Escape (editing):** Cancel edit

---

## Real-time Updates

### Event: `chat-message`

Handles new or updated messages.

**Logic:**

1. Check if message already exists (by ID)
2. If exists: Update existing message
3. If new: Append to messages array
4. Trigger reactive update

### Event: `chat-message-deleted`

Handles message deletions.

**Logic:**

1. Receive deleted message ID
2. Filter message from array
3. Trigger reactive update

---

## Display Features

### Message Rendering

Each message shows:

- Sender name (or "You" for own messages)
- Message content
- Timestamp (formatted as time)
- Edited indicator (if edited)
- Different styling for own vs. others' messages

### Date Dividers

Messages are grouped by date with dividers showing:

- "Today" for current day
- "Yesterday" for previous day
- Date string for older messages

### Peer Name Resolution

Priority order for displaying names:

1. `myPeerName` (from store) for current user
2. Peer name from `peers` store for others
3. Fallback to `peer_name` from message

### Timestamps

- Format: "h:mm A" (e.g., "9:30 AM")
- Shows edited time if message was edited

---

## Child Components

### ChatMessage

Displays individual message with styling and menu.

**Props:**

- `message`: ChatMessage object
- `isOwn`: Boolean for own vs. others
- `peerName`: Resolved peer name
- `onEdit`: Edit callback
- `onDelete`: Delete callback
- `onToggleMenu`: Menu toggle callback
- `isMenuOpen`: Menu open state

### ChatInput

Message input field with send button.

**Props:**

- `value`: Input text
- `isEditing`: Editing mode flag
- `onSend`: Send callback
- `onCancel`: Cancel edit callback
- `onKeyDown`: Keyboard handler

### ChatDateDivider

Shows date separator between message groups.

**Props:**

- `date`: Date to display

---

## Styling

### Layout

- Full height flex container
- Header: 64px fixed height with shadow
- Messages: Flex-1 scrollable area
- Input: Fixed at bottom

### Messages Container

- Scrollable with custom scrollbar
- Light gray background (dark: #0f1521)
- Padding: 16-24px
- Auto-scrolls to bottom

### Message Styles

- **Own Messages:** Right-aligned, blue background
- **Others' Messages:** Left-aligned, white/gray background
- **Edited Indicator:** Gray italic text
- **Timestamps:** Small gray text

### States

- **Loading:** Centered gray text
- **Empty:** Centered icon and prompt
- **Editing:** Yellow background on input

---

## Accessibility

### Semantic HTML

- `<main>` for content area
- `<header>` for title bar
- Proper heading levels

### Keyboard Navigation

- All interactive elements keyboard accessible
- Keyboard shortcuts documented
- Focus management during edit mode

### Screen Readers

- Meaningful aria-labels on buttons
- Status messages for loading/empty states
- Message structure conveyed properly

---

## Error Handling

### Load Errors

- Catches errors during initial load
- Displays error in console
- Sets loading to false to show UI

### Send/Edit/Delete Errors

- Catches operation errors
- Logs to console
- Restores message input on send error
- Prevents data loss

---

## Test Coverage Requirements

### Initial State Tests

1. Shows loading state initially
2. Displays messages after loading
3. Shows empty state when no messages
4. Displays header with title

### Message Display Tests

5. Displays peer names correctly
6. Formats timestamps correctly
7. Applies different styling to own messages
8. Shows edited indicator when message edited

### Sending Messages Tests

9. Sends message when send button clicked
10. Sends message on Enter key press
11. Does not send empty messages
12. Trims whitespace from messages
13. Clears input after sending message

### Editing Messages Tests

14. Enters edit mode when ArrowUp pressed on empty input
15. Edits message when in edit mode and sends
16. Deletes message when editing and content cleared
17. Cancels edit mode with Escape key
18. Clears edit mode after successful edit

### Peer Name Resolution Tests

19. Displays updated peer name from store
20. Uses peer name from peers store for other users
21. Falls back to message peer name when peer not in store

### Error Handling Tests

22. Handles load error gracefully
23. Restores message input on send error

---

## Integration Points

### Tauri Commands

- `getChatMessages()`: Fetch message history
- `sendChatMessage(content)`: Send new message
- `editChatMessage(id, content)`: Update message
- `deleteChatMessage(id)`: Remove message
- `getMyPeerId()`: Get current user ID
- `getMyPeerName()`: Get current user name

### Tauri Events

- `chat-message`: New/updated message event
- `chat-message-deleted`: Message deletion event

### Store Integration

- Reads `peers` for peer name resolution
- Reads `myPeerName` for current user name
- Does not write to stores

---

## Performance Considerations

### Auto-scroll

- Uses `afterUpdate` to scroll after each render
- Direct DOM manipulation for performance
- Only scrolls to bottom (no smooth scroll)

### Event Listeners

- Properly cleaned up in `onDestroy`
- Minimal re-renders via reactive arrays

### Message Updates

- Efficient array operations
- Replaces specific messages rather than full reload
- Preserves array identity for Svelte reactivity

---

## Implementation Notes

1. **Auto-scroll Behavior:** Always scrolls to bottom on update
2. **Edit Mode:** Only one message editable at a time
3. **Menu Behavior:** Click outside to close (global handler)
4. **Keyboard Shortcuts:** Standard chat application patterns
5. **Name Resolution:** Multi-source with fallbacks

---

## Future Considerations

- Add scroll-to-bottom button (when not at bottom)
- Add message search functionality
- Add file attachment support
- Add emoji picker
- Add typing indicators
- Add message reactions
- Add infinite scroll / pagination
- Add message threading
- Add read receipts
- Improve error notifications to users
