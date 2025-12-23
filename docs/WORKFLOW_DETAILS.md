# BlueNote Workflow and UX Manual

## 1. Patient Journey Workflows (Arrival to Departure)

This covers every step and exact user interaction from patient arrival through treatment, readiness, and departure using the BlueNote Lights system.

### a. Patient Arrival (Receptionist Flow)
#### Steps & Interactions:
1. **Patient enters the office.**
2. **Receptionist logs into their computer:**
   - Sees the "Light Panel"—a grid of alert timers, each representing actions, tasks, rooms, or code words.
3. **To indicate a patient has arrived:**
   - Receptionist clicks or presses the Light corresponding to e.g. "Patient Here" or a specific Room (lights can have custom names).
   - If the Light is programmed for quick notes (colon at end of name), Receptionist can add specific information:
     - Clicking the Light opens the **Action Window**.
     - Receptionist chooses a pre-defined BlueNote (dropdown) or types a comment/note in the text field. E.g. “Waiting for Dr. Smith.”
     - Clicks "Turn On Light".
   - The Light changes from "Off" (gray/dark) to "On" (colored, typically green at first).
4. **All logged-in users see the change instantly:**
   - Their Light Panels update, showing the active Light now "On."
   - Optional: Light may **flash** to attract attention.
   - A **sound tone** is played (configurable, e.g. chime).
   - **Popup notification** appears on every user’s screen (unless disabled via Alert Manager). Panel does not need to be frontmost—popups will appear regardless.
   - Duration: Popups remain visible for a set time (default, e.g. several seconds) unless dismissed or acted upon.
   - If the Light is configured with aging, it begins as green and turns yellow, then red as time passes (set by admin per Light in config—e.g., green: <5min, yellow: 5-10min, red: >10min).

### b. Patient Ready/Hand-off (Tech/Nurse)
#### Steps:
5. **Nurse or Tech Preps Room:**
   - Nurse logs into any workstation, sees the Light Panel.
   - When patient is ready, Nurse clicks/presses the relevant Light (e.g. "Ready in Room 3").
   - Adds a comment as needed in the Action Window. (e.g., “Procedure X set up”).
   - Clicks "Turn On Light" or updates an existing one.
6. **Doctor receives notification:**
   - Doctor sees colored/flashing Light on their Light Panel.
   - Receives tone/popup notification.
   - Doctor (or anyone) can click the Light, view Action Window, see comments/history.

### c. Treatment/Interaction (Doctor/Nurse)
#### Steps:
7. **Doctor enters room.**
   - (Optionally, Doctor clicks Light and adds comment: “In with patient.”)
8. **Ongoing updates:**
   - Any relevant Light (e.g., “X-Ray Ready,” "Checkout Needed") can be turned on by clicking the panel, adding an appropriate comment or selecting a BlueNote, and confirming.
   - Everyone receives notification as above.

### d. Patient Departure
#### Steps:
9. **Checkout:**
   - Receptionist or Clinic Manager clicks relevant Light (e.g., “Ready for Checkout”).
   - Tech adds a note if necessary (“Needs follow-up in 6mo”).
10. **All tasks done:**
   - Once the patient has left and all steps are complete, any team member can “turn off” the relevant Light:
      - Click the Light (in the panel or popup)
      - In the Action Window, select "Turn Off Light" (green/off button)
      - Optionally, add resolution notes as a comment
   - Light returns to its "Off" (gray) state; no active notification.
   - Panel only shows active Lights in Focused Mode (if enabled). Light instantly disappears from Focused panel upon turn-off.

### e. Edge Cases & Error Paths
- **Late Arrivals:** Receptionist adds comment (“Patient 15min late”) in Light Action Window.
- **Missed Notifications:** If a user has Alert Manager set to opt-out, they won’t get tone/popup but will still see highlights on their Panel.
- **Multiple Alerts:** Many Lights can be active at once; each is tracked/timed separately (aging color changes).
- **No one turns Off Light:** Light continues to age into “overdue” (red); may trigger escalation (see below).

---

## 2. Role-Specific Workflows

### a. Receptionist
- Turns on Arrival Lights, manages Ready/Checkout alerts.
- Edits comments via Action Window.
- Monitors all active tasks in Focused Mode/GoFocus dock.
- Uses Alert Manager to mute unneeded popups/tones (e.g. for Lights irrelevant to their station).

### b. Doctor
- Sees Light Panel: watches for "Ready"/"Assist"/"Stat" Lights corresponding to rooms or patients.
- Optionally uses Focused Mode (shows just active tasks in chronological order).
- Clicks a Light to acknowledge, add comment (e.g. “With Patient 2”), or turn Light off after completion.
- Can initiate conversations with nurse/tech for clarification (see Conversation Flow).

### c. Nurse/Technician
- Responds to doctor or receptionist requests by activating/forming Lights ("Bring X-Ray").
- Adds detailed comments or chooses pre-set BlueNotes for specific scenarios.
- Uses GoFocus dock to see only time-sensitive alerts without popups cluttering the screen.

### d. Admin / IT
- Installs BlueNote on new computers via download, auto-registration (per support docs).
- Configures which Lights, escalation timing, pre-set BlueNotes, and permissions show up for each station.
- Troubleshoots missed connections.
- Sets licensing and version checks via Menu > Help.

---

## 3. Feature Interaction Flows

### a. Light Activation/Deactivation (Exact Button, Action Window, Interactions)

- **Turning ON a Light:**
   - Click or press any Light button in the main "Light Panel" grid.
   - Action Window may appear:
      - Type an optional note; or
      - Choose from pre-defined BlueNotes popdown.
      - Click "On" or "Activate Light".
   - Light turns from gray to colored (usually green).
   - Sends office-wide update:
      - All Panels update live, color change is instant (network synch)
      - Optional: Light flashes
      - Tone/sound plays (configurable, per-user/Light in Alert Manager)
      - Popup appears on every computer (unless Alert Manager disables it)
      - Aging: Starts timer for Light (set in admin)
- **Turning OFF a Light:**
   - Any user: click active Light (on Panel or on Popup)
   - In Action Window, click "Off" or "Turn Off Light"
   - Light turns gray/off
   - Popup closes; Focused Panel removes entry
   - May prompt for comment

### b. Escalation Mechanics & Aging
- Each Light can have escalation/aging rules set by admin (e.g. 5min/10min/15min cutoffs)
- Color coding:
   - Green: just activated
   - Yellow: aging (over threshold)
   - Red: overdue/critical
- Some Lights can be programmed to escalate (e.g. after 10min, sound changes, popup pulses, different color/tone, extra popup message)
- Step-by-step escalation:
   1. Light is triggered (green, start timer)
   2. At first aging threshold (e.g. 5min), color changes (yellow), optional new sound
   3. At second threshold (e.g. 10min), color red, urgent tone, possible extra popup/badge/notification sent (per Alert Manager or admin setting)

### c. Alert Manager (Popup/Tone Preferences)
- Accessible via: Menu > Notifications > Open Alert Manager
- Lets each user individually opt-in or out of sounds/popups for every Light
- Green = On, Red = Off
- Disabling popups/tones only affects the notifications, not the state or color of the Light on the grid
- All settings are immediate; user preview possible

### d. Notification Behavior (When, What, Who)
- **When:** Any Light is turned on, updated, or commented upon
- **Who:** By default, all logged-in clients see all notifications; can be narrowed via Alert Manager
- **What:**
   - Panel update: visual
   - Popup (choosable size/location): appears over all windows in user’s chosen position; customizable via dragging/saving and via Menu > Preferences > Popups
   - Tone: office-wide or per-user (library of sounds; can be turned off)
   - Popup persists until dismissed or Light switched off
- **Sound/Visuals:**
   - Tone can play repeatedly for active Light (e.g. every X seconds)
   - Taskbar icon flashes green for Conversation messages
- **Edge Cases:**
   - Too many popups: User disables in Alert Manager
   - Missed popups: Light always visible as colored on Panel, Focused view, and GoFocus dock

### e. Conversation Flow
- Peer-to-peer messaging (specific vs. office-wide):
   - Click "Conversations" button
   - Select recipient(s) from Users list
   - Type message, hit "Send"
- Recipients see popup (stays up to one hour), can reply directly
   - Reply also through Conversation Inbox or "Messages" tab
- Taskbar flashes green when new Conversation arrives
- Each computer/user can set their Conversation name (Menu > Preferences > change User Name)
- Threads organized by participant and subject
- Inbox holds all pending and recent Conversation messages

### f. Focused Mode & GoFocus Dock
- **Focused Mode** button shows ONLY active Lights, ordered by time since activation
- Clearing a Light removes it instantly from Focused view; helps users prioritize tasks
- **GoFocus Dock**: Always-on slim sidebar lists all active Lights, color/priority order
   - Popups appear briefly, then dock in the GoFocus tray
   - Turn off Lights from dock, refresh, or open full Panel
- GoFocus settings: Menu > Preferences > BlueNote Go > Enable GoFocus Notifications
- Dock position and popup display time are customizable

### g. Remote View and Mobile Integration
- **BlueNote Remote:**
   - Accessible via browser (no app required), see all live Light statuses for remote workflow
   - Designed for users who want to review activity outside the local office network
- **Pushover (Push Notifications to phone/watch):**
   - Install Pushover app, set up account and BlueNote Lights as a new application
   - Enter User Key and API Token in BlueNote’s Mobile Notifications tab of Alert Manager
   - Verify with a 6-digit code sent by Pushover
   - Enable Push for individual Lights (Alert Manager > Push toggle per Light)
   - When enabled, each Light activation sends push to configured devices
   - Pushover can be personalized for banners, lock screen, vibration, etc.; does NOT support replies

### h. Daily Activity
- Panel and GoFocus views show timer history per Light/event
- Users can review aged Lights, completed tasks, who turned on/off, comments, and elapsed times in the Light’s Action Window
- Advanced implementations track stats on wait times and average response, visually available for staff review
- IT/Admin can audit all activity logs for compliance or process improvement

---

## 4. Edge Cases, Error States, and Visual/Sound/Timing Details

### a. Edge Cases
- **Popups stack:** Each new event stacks above previous; most recent always on top
- **Disconnected Client:** If a new install does not receive data, see network/troubleshooting docs (Menu > Help; "Client with No Connections")
- **Expired Trial/License:** BlueNote client warns with visible banner and countdown; fixable by running as Admin or updating registration

### b. Visual/Screen Details
- Light Panel: full grid, up to 120 customizable Lights
- Lights: Off (gray/empty), On (green/yellow/red), Flashing (optional)
- Action Window: modal, displays comments, BlueNotes, all activity history for that Light
- Popups: user-customizable size (small/medium/large) and position, always-on-top
- GoFocus dock: narrow, positionable on screen edge; Lights listed in color/priority order
- Focused mode: only live Lights shown, sorted by age (first in, topmost)
- Conversations: Inbox window with thread list, each thread clickable to open full conversation

### c. Sound Patterns
- Library of tones selectable per Light; global, per-user, and per-Light control
- Sound duration and volume controlled individually (user-level)
- Red Lights (critical/escalated) may use louder or recurring sound
- Can be disabled entirely for workstations in "quiet" areas (via Alert Manager)

### d. Timing/Duration
- Popups: Stay until dismissed or set time expires (default: urgent/active popups stay, others auto-dismiss after e.g. 5 seconds, customizable)
- Lights: Color changes (green to yellow to red) based on admin-specified thresholds per Light
- Conversations: Popup stays for up to 1 hour unless replied/dismissed
- GoFocus dock: Always visible; popups briefly appear, then dock

---

## 5. Quick-Reference: Exact User Interactions
- **Activate Light:** Click or tap any Light on main Panel; fill Action Window note if prompted; click Confirm/On
- **Deactivate/Resolve Light:** Click colored Light (Panel, Popup, Focused, or GoFocus); choose "Turn Off Light"
- **Respond to alert:** Click popup, Action Window opens, view/add comment, "Turn Off Light" or "Update"
- **Opt-out of popups/sounds:** Menu > Notifications > Open Alert Manager; switch off for unwanted Lights
- **Send direct message:** Click "Conversations," select user(s), type + send. Reply via popup or Inbox.
- **Move popup to new location:** When popup is visible, drag top bar; click black arrow, "Save Popup Location"
- **Change popup size:** Menu > Preferences > Popups; select size
- **Enable Focused mode or GoFocus dock:** Menu > Preferences > BlueNote Go; toggle features as needed
- **Enable/verify mobile push:** Set up Pushover, enter codes in BlueNote, Alert Manager > Mobile Notifications, toggle Push per Light

---

For further workflows (install, network, advanced scenarios, etc.) refer to the BlueNote online support library or your practice’s admin policies.

_Last compiled: 2025-12-23, based on BlueNote Lights v9 documentation and support articles._
