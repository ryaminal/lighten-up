# Product Requirements Document (PRD)

**Product:** Lighten Up (BlueNote-Inspired Intra-Office Communication System)
**Purpose:** Comprehensive specification derived from BlueNote Software's features, content, and customer guidance.
**Document Date:** 2025-12-23

## 1. Executive Summary

BlueNote is a HIPAA-compliant, real-time virtual light system and intra-office communication tool designed primarily for dental, medical, eyecare, veterinary, and general healthcare teams. It provides a glanceable, easy-to-use, and highly effective alternative to traditional intercoms, pagers, or cloud chat tools, supporting fast room/role-based notifications, escalations, task coordination, and secure conversations. Its users include doctors, nurses, technologists, administrative staff, and support personnel who require instant, unobtrusive communication with full privacy. BlueNote emphasizes simplicity, reliability, and regulatory compliance, removing communication silos in busy healthcare environments.

## 2. Product Vision & Goals

- **Vision:**
  - To be the universal backbone of in-clinic, HIPAA-compliant communication—ensuring everyone in the practice or facility knows where they are needed, what needs attention, and who needs help at a glance.
- **Business objectives:**
  - Reduce patient wait times and workflow friction
  - Improve staff coordination and accountability
  - Enable compliant, persistent communication with auditability
  - Replace physical lights/flags and generic chat tools with a purpose-built digital solution
  - Provide a modern, one-time-purchase application: no subscriptions, upgrade protection, and simple licensing

## 3. Target Users & Personas

### A. Front-Desk/Reception Staff

- Monitor patient flow and communicate transitions
- Alert care teams when a patient is ready, checked-in, or checked-out

### B. Medical/Dental Providers (Doctors, Surgeons)

- Receive instant location- or event-based alerts
- Direct care or request assistance without leaving their station

### C. Nursing/Clinical Support Staff

- Receive and send notifications about tasks (sterilization, triage, room prep)
- Update status (e.g., patient ready, room needs cleaning)

### D. Technicians & Specialists (Optometry, Labs, X-ray, etc.)

- Get role-specific alerts & participate in status escalations

### E. Administrators/Managers

- Configure the system, review usage analytics, and track workflow metrics

### F. IT/Support Staff

- Deploy and maintain system, ensure compliance, handle troubleshooting

_Industry verticals: Dental, Medical, Eyecare, Veterinary, General Office_

## 4. Use Cases

- **Quick Room Notification:** Reception sets a room as "Ready"; doctor gets notified visually/audibly in real time
- **Assistance Requests:** Nurse activates a "Need Provider" light; escalates after delay if not acted upon
- **Handoffs:** Technician signals to next care stage (e.g., Optician to Doctor in eyecare, hygienist to dentist)
- **Privacy-Aware Messaging:** One clinician sends a patient status to another confidentially
- **Timed Alerts:** Timer-based alerts for patient waiting, room cooldown, or follow-ups
- **Do-Not-Disturb Mode:** A user "focuses" to avoid non-critical notifications
- **Analytics:** Admin reviews daily activity (room wait times, average fulfillment times)
- **Remote View:** Doctor checks light status remotely during rounds

## 5. Core Features

### 5.1 Light System (Virtual Room Flags / Light Panels)

- Highly customizable light panel; each "light" is a named/timed alert
- Up to 120 programmable lights (locations, tasks, roles, etc.)
- Glanceable grid visible from every workstation
- Color and icon status indicators reflect activity (On/Off/Flashing/Color by duration)
- Lights can include tags, escalations, comments

### 5.2 Conversations & Messaging

- Secure, direct or group conversation threads between users
- Conversation popups for urgent messages
- Timed and persistent message history (with privacy/audit controls)

### 5.3 Alert Manager

- Centralized view for all pending, escalated, and acknowledged alerts
- Manage priority, status, and resolution of alerts

### 5.4 Notifications (Visual, Audible, Push)

- On-screen popups, system tray alerts
- Office-wide or user-specific notifications
- Audible sound library (customizable per alert or user)
- App notifications for phones/watches (integration with Pushover etc)

### 5.5 Light Tags

- Add freeform or templated tags/notes to active lights for context (e.g., "Needs x-ray")

### 5.6 Light Escalation

- Predefined escalation paths if a light is not acknowledged/actioned within a set time
- Automated bump to higher priority or additional users

### 5.7 Priority Escalation

- Mark certain lights or alerts as "high priority" (visually/audibly distinct)
- Immediate override of do-not-disturb/focused mode

### 5.8 Focused Mode (Do Not Disturb)

- User can opt out or mute non-critical lights
- Popups & sounds suppressed except for high-priority events or direct messages

### 5.9 Daily Activity Review & Analytics

- Dashboard of completed, acknowledged, and elapsed events daily/weekly
- Wait time and response time metrics per location or team

### 5.10 Delayed Lights

- Schedule a light/event to activate after a preset delay (e.g., bring patient in 10 min)

### 5.11 Elapsed Timers

- Visual timer on each light showing time since activation (color shift as indicator)

### 5.12 Sound Library

- Multiple tone options and volume controls per alert/light
- Assign unique sounds to different events

### 5.13 BlueNote Actions

- Predefined or ad-hoc action buttons for quick workflow steps (e.g. "Call patient", "Send message")

### 5.14 Privacy Lock

- Hide light content and conversations behind a PIN or quick toggle
- Obscures on-screen alerts in shared/workstation environments

### 5.15 Remote View

- Web, mobile, or in-network view-only panels for checking light status externally

### 5.16 Integration/Other

- Pushover integration (notifications on mobile/watches)
- Diagnostic/onboarding tooling for easy setup across all user computers
- Version/license management centrally administered
- Fully local-network or optional cloud mode (no forced external messaging)

## 6. Technical Requirements

- **Platforms:**
  - Windows (primary), support for tablets (Surface, touch devices)
  - Web/Remote view (browser-based for tablets, mobile, read-only or interactive)
- **Deployment:**
  - Local network-based (peer-to-peer or client/server)
  - Quick onboarding for new computers
  - Automatic license/registration propagation
- **Architecture:**
  - Central service managing license, configuration, global state
  - Each client: runs the light panel, receives/sends events/alerts
  - Support for cloud push notifications (optional)
- **Security:**
  - Full HIPAA compliance: all data encrypted in transit and (if stored) at rest
  - No protected health information sent externally (unless cleared through integration, e.g., Pushover)
  - Activity and access audit trails for conversations and light activity
- **Reliability:**
  - System must function if one workstation is offline
  - Fault-tolerant event sync and time-synchronization

## 7. User Interface Requirements

- **Light Panel** as center of workflow: grid-based, customizable, touch- and mouse-friendly
- **Conversation Popups:** Context-aware, can be moved/resized by user
- **Customizable Sounds:** Local mute/volume, Snap-to-popup
- **Notification Popups:** Appear in configurable corners, with text and optional sound
- **Elapsed Timers:** Color and/or shape changes as duration passes (green → yellow → red)
- **Light/Tag Dialogs:** Add comments, tags, actions, or escalation paths per light
- **Remote View:** Simple, real-time read-only grid accessible via browser/mobile
- **Privacy:** Obscure or hide content with single click (for walkby privacy)
- **Analytics/Review:** Dashboard for managers, showing usage, bottlenecks, unfulfilled events

## 8. Non-Functional Requirements

- **Performance:**
  - Instant event delivery (<300ms typical)
  - Low system resource usage (<2% CPU per client)
- **Security:**
  - Encryption TLS 1.2+ in transit
  - Option for strict local-only operation/no outbound ports
  - Audit trails/logging
- **Scalability:**
  - Support for 5–100+ workstations per location
  - Light panel must perform with 100+ simultaneous events/lights
- **Usability:**
  - <=10 min onboarding (training & setup)
- **Maintainability:**
  - Centralized, one-time system management
  - Update mechanism with free maintenance releases, upgrade protection
- **Reliability:**
  - Notification delivery must be robust, even if one device is offline (retries, failover)

## 9. Industry-Specific Requirements

- **Healthcare (Medical, Dental, Eyecare, Veterinary):**
  - HIPAA-compliant for PHI
  - “Good Interruption” workflows: role- or location-specific alerts
  - Visual and audible cues consistent with clinical priorities
  - Handoff/transition workflow support (handover/comment chains)
  - Privacy features for shared/common workstations
- **General Office:**
  - Customizable for non-healthcare process queues, broadcast/individual tasks
- **Compliance:**
  - Option to disable any “cloud” features and ensure internal-only network operation

## 10. Differentiators (BlueNote's Unique Selling Points)

- **No Subscriptions:** One-time license, perpetual use
- **Upgrade Protection:** Free upgrade path for major versions, discounted upgrades for legacy users
- **No Per-User/Per-Device Fees:** Unlimited workstations per license
- **True Local Option:** Fully functional on internal network without cloud reliance
- **HIPAA/Privacy First:** Purpose-built, not a generic chat app; no business associate risk
- **Rapid Onboarding:** System auto-discovers new clients, nearly zero IT overhead
- **Purpose-Built:** NOT a generic messaging tool—light metaphor and workflow integration

---

**Note:** This PRD was authored by analyzing BlueNote Software’s public documentation, support articles, and product marketing across over 30 pages as of December 2025. Requirements above are directly derived from stated features, customer testimonials, implementation how-tos, and industry-specific documentation surfaced from BlueNote’s website.
