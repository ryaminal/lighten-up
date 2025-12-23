# BlueNote Features & Screen Mappings

## Module 1: Alert Manager & Sound Settings
**Route**: `/settings/alerts`

### Features
- Multi-workstation alert configuration
- Visual interruption settings (pop-ups, screen flash, force focus)
- Sound palette selection with preview
- Event-to-sound mapping with volume control
- Quiet hours scheduling
- Per-workstation or global defaults

### UI Components
- Sidebar navigation (Admin menu)
- Two-panel layout (workstation list + settings)
- Tab switcher (Selected Workstation / Global Defaults)
- Search bar for workstation filtering
- Radio button selection list
- Toggle switches for visual settings
- Grid of sound preview buttons
- Table/matrix for event configuration
- Dropdown selectors for sounds
- Range sliders for volume
- Time pickers for quiet hours
- Action buttons (Save, Test Alert)

### Data Models
```dart
- Workstation
- AlertSettings
- VisualSettings
- SoundMapping
- EventType
- QuietHours
```

### API Endpoints
```
GET  /api/workstations
GET  /api/workstations/:id/alert-settings
PUT  /api/workstations/:id/alert-settings
POST /api/alerts/test
GET  /api/sounds
```

---

## Module 2: Daily Activity Review & Analytics
**Route**: `/analytics/daily`

### Features
- KPI dashboard (response times, alert counts, problem areas)
- Visual analytics (bar charts for busy hours, pie charts for alert types)
- Activity log table with filtering
- Date range selection
- Zone/room filtering
- Search functionality
- Export reports (print, download)

### UI Components
- Sidebar navigation
- KPI stat cards with trend indicators
- Bar chart (hourly activity)
- Pie/donut chart (alert type distribution)
- Data table with sorting
- Date picker with navigation
- Dropdown filters
- Search input
- Pagination controls
- Export buttons

### Data Models
```dart
- DailyMetrics
- ActivityLog
- AlertTypeDistribution
- BusyHourData
- KPISummary
```

### API Endpoints
```
GET /api/analytics/daily?date=YYYY-MM-DD
GET /api/analytics/logs?date=YYYY-MM-DD&zone=X&page=N
GET /api/analytics/export?format=pdf|csv
```

---

## Module 3: GoFocus Notification Dock
**Route**: `/dock` (or overlay/sidebar widget)

### Features
- Real-time notification feed
- User status toggle (Available, Busy, Away)
- Priority alert grouping
- Alert timing display
- Color-coded urgency (red=emergency, amber=assist, green=ready, blue=in-session)
- Quick alert acknowledgment
- Profile quick access
- History and logout

### UI Components
- Vertical sidebar/dock panel
- Station header with logo
- Segmented control (status toggle)
- Scrollable alert list
- Alert cards with icons, labels, timers
- Section headers (My Alerts, Room Status)
- Footer with profile and actions

### Data Models
```dart
- Alert
- RoomStatus
- UserStatus
- NotificationItem
```

### API Endpoints
```
GET    /api/dock/alerts (WebSocket preferred)
PATCH  /api/users/status
POST   /api/alerts/:id/acknowledge
```

---

## Module 4: Main Communication Dashboard
**Route**: `/dashboard` (main landing)

### Features
- Overview of all rooms/locations
- Real-time light status indicators
- Zone filtering (All, Doctor's Wing, Hygiene Wing, etc.)
- Room occupancy status
- Active alerts per room with timers
- Quick action triggers (activate lights)
- Broadcast system integration

### UI Components
- Sidebar navigation with recent broadcasts
- Top bar with clock, privacy toggle, user status
- Filter chips for zones
- Grid layout of room cards
- Room status badges (Occupied, Available, Active)
- Light buttons with color states and timers
- Floating action button (mobile)

### Data Models
```dart
- Room
- LightStatus
- Zone
- Broadcast
- RoomCard
```

### API Endpoints
```
GET    /api/rooms
GET    /api/rooms/:id/status
POST   /api/rooms/:id/lights/:type/activate
GET    /api/broadcasts/recent
POST   /api/broadcasts
```

---

## Module 5: Privacy Lock Screen
**Route**: `/lock`

### Features
- Station lock/unlock with PIN
- Current station display
- Secure environment indicator
- Custom numpad for PIN entry
- Emergency logout option
- Visual feedback (animations, validation)

### UI Components
- Centered card layout
- Lock icon and status
- Station name display
- Secure badge/chip
- Password input field (masked)
- Custom 3x4 numpad grid
- Clear/backspace buttons
- Primary unlock button
- Secondary emergency logout button
- Animated feedback

### Data Models
```dart
- LockSession
- Station
- SecurityStatus
```

### API Endpoints
```
POST /api/auth/unlock
POST /api/auth/emergency-logout
GET  /api/stations/current
```

---

## Module 6: Private Chat Conversations
**Route**: `/chat` or `/chat/:conversationId`

### Features
- Three-panel layout (nav, conversation list, active chat)
- Search conversations
- Filter tabs (All, Urgent, Archived)
- Real-time messaging
- Message read receipts
- Typing indicators
- Quick action templates
- File attachments
- Emoji picker
- HIPAA-compliant encryption indicator
- Privacy blur toggle

### UI Components
- Three-column responsive layout
- Sidebar navigation
- Conversation list with search
- Filter tabs
- Conversation preview cards (avatar, name, snippet, timestamp, unread badge)
- Chat header (contact info, status, encryption badge)
- Message stream (date separators, incoming/outgoing bubbles)
- System messages
- Message input with toolbar
- Quick action chips
- Send button
- Keyboard shortcuts hint

### Data Models
```dart
- Conversation
- Message
- User
- MessageStatus
- QuickAction
- Attachment
```

### API Endpoints
```
GET    /api/conversations
GET    /api/conversations/:id/messages
POST   /api/conversations/:id/messages
PATCH  /api/messages/:id/read
WS     /api/ws/chat (WebSocket for real-time)
POST   /api/conversations/:id/attachments
```

---

## Common Features Across All Modules

### Navigation
- Persistent sidebar (desktop)
- Drawer (mobile/tablet)
- Bottom navigation (mobile alternative)
- Breadcrumbs (desktop)

### User Context
- Current user profile
- Active station/location
- Online status
- Role/permissions

### Notifications
- Toast/snackbar for feedback
- Badge counts on nav items
- System alerts overlay

### Theming
- Dark mode (primary)
- Light mode support
- High contrast option
- Custom color palette (blue primary, status colors)

### Responsive Breakpoints
- Mobile: < 600px (single pane, drawer nav)
- Tablet: 600-1024px (two-pane with nav rail)
- Desktop: > 1024px (three-pane with sidebar)

---

## Screen Navigation Flow

```
/ (Root/Splash)
├── /auth/login
├── /auth/lock → /lock
└── /app
    ├── /dashboard (Main Communication Dashboard)
    ├── /dock (GoFocus Notification Dock - overlay/sidebar)
    ├── /analytics
    │   └── /daily (Daily Activity Review)
    ├── /chat
    │   ├── / (Conversation List)
    │   └── /:id (Active Chat)
    ├── /settings
    │   ├── /alerts (Alert Manager)
    │   ├── /profile
    │   └── /system
    └── /admin (Admin-only routes)
```

---

## Permission & Role Matrix

| Feature                    | Admin | Doctor | Nurse | Front Desk |
|----------------------------|-------|--------|-------|------------|
| Alert Manager (Global)     | ✓     | ✗      | ✗     | ✗          |
| Alert Manager (Local)      | ✓     | ✓      | ✓     | ✓          |
| Analytics Dashboard        | ✓     | ✓      | ✗     | ✗          |
| Communication Dashboard    | ✓     | ✓      | ✓     | ✓          |
| Notification Dock          | ✓     | ✓      | ✓     | ✓          |
| Private Chat               | ✓     | ✓      | ✓     | ✓          |
| Broadcasts (Send)          | ✓     | ✓      | ✗     | ✓          |
| Broadcasts (Receive)       | ✓     | ✓      | ✓     | ✓          |
| Lock Screen                | ✓     | ✓      | ✓     | ✓          |

---

## Real-Time Features

### WebSocket Events
```dart
// Room status updates
onRoomStatusChanged(roomId, status)

// New alerts
onAlertReceived(alert)

// Chat messages
onMessageReceived(conversationId, message)

// User status changes
onUserStatusChanged(userId, status)

// Broadcast notifications
onBroadcastSent(broadcast)
```

### Polling Fallback
For environments without WebSocket support, implement polling:
- Room statuses: every 10 seconds
- Alerts: every 5 seconds
- Chat messages: every 3 seconds when chat is active

---

## Offline Support

### Cached Data
- Last known room statuses
- Recent chat conversations
- User profiles
- Alert settings

### Offline Actions
- Queue chat messages for send when reconnected
- Local alert acknowledgment with sync
- View cached analytics data

### Sync Strategy
- On reconnect: sync queued actions
- Conflict resolution: server wins for status, merge for queued actions
- Local-first for chat compose, sync on send
