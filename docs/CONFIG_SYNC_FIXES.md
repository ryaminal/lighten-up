# Config Sync Bug Fixes - Summary

## Problem Statement

When a user disables or deletes a light definition on one peer, that change needs to propagate to all other peers on the network. Any peer with that light currently active should automatically turn it off, and the UI should update to reflect the changes.

## Root Causes Identified

### 1. Config Service Not Attached to MessageContext ✅ FIXED

**Problem:** The `MessageContext` used by the message handler didn't have `config_service` attached, so `handle_config_sync()` always hit the `None` branch and never processed config syncs.

**Solution:**

- Added `config_service` field to `PeerService`
- Added `attach_config_service()` method
- Updated message loop to attach config service to context on every message
- Files changed: `src-tauri/src/services/peer_service/mod.rs`, `src-tauri/src/setup/initialization.rs`

### 2. Tombstone Check Missing ✅ FIXED

**Problem:** The tombstone check at line 219 of `message_handler.rs` checked `def.enabled && def.color == current_color` but didn't check if `deleted_at` was set. A definition could have `enabled=true` with `deleted_at=Some(...)` (tombstone), and it would incorrectly be considered enabled.

**Solution:** Updated check to include `!def.is_deleted()`:

```rust
let is_enabled = merged
    .definitions
    .iter()
    .any(|def| !def.is_deleted() && def.enabled && def.color == current_color);
```

**File changed:** `src-tauri/src/services/message_handler.rs`

### 3. Config Merge Created Duplicates ✅ FIXED

**Problem:** When two peers have default configs with different UUIDs for the same color (e.g., both have "Red" but with different IDs), the merge would add the remote Red as a NEW definition instead of replacing the local one. This resulted in two Red definitions, and the check would find the non-deleted one.

**Solution:** Updated `merge()` to match by **both ID and color**:

- First try to match by ID
- If no ID match, check if same color exists with different ID
- If found by color, replace it (respecting timestamps)
- Otherwise add as new definition

**File changed:** `src-tauri/src/domain/light_config.rs`

### 4. New Peer Joins Established Network ✅ FIXED

**Problem:** When a new peer with default config (version 1) joined an established network where another peer had customized config (version 5+), the new peer's fresh timestamps would override the established peer's configuration during merge.

**Solution:** Updated merge logic to consider config version:

- If the incoming config has a significantly higher version, it's from an established network
- Established network config takes precedence over default config regardless of timestamps
- For same version, use timestamp comparison as before

**File changed:** `src-tauri/src/domain/light_config.rs`

### 5. Tombstone Pattern Implementation ✅ FIXED

**Problem:** Original code physically removed definitions on delete, so deletions couldn't propagate to offline peers.

**Solution:**

- Added `deleted_at: Option<u64>` field to `LightDefinition`
- Added `is_deleted()` helper method
- Updated `delete_light_definition` command to set tombstone instead of removing
- Updated all query methods to filter out deleted definitions

**Files changed:** `src-tauri/src/domain/light_config.rs`, `src-tauri/src/commands.rs`

## Frontend Verification

The frontend already has proper reactive mechanisms in place:

### Event Flow

1. **Backend receives config sync** → Emits `LightConfigChanged` domain event (message_handler.rs:265-267)
2. **Domain event forwarded** → Tauri emits `light-config-changed` event (setup/mod.rs:76-78)
3. **Frontend listener** → Updates `lightConfig` store (tauri.ts:63-67)
4. **UI Components** → Automatically react to store changes:
   - `LightColorPicker` uses `$derived` to recompute available lights (line 17-28)
   - `LightConfigScreen` uses reactive statements to update display (line 18-23)
   - Both properly filter `deleted_at` and `enabled` flags

### What Should Happen

When Peer A disables or deletes a light:

1. Backend broadcasts `LightConfigSync` message
2. Peer B receives message and merges config
3. If Peer B has that light active, it turns it off and broadcasts `PeerAnnouncement`
4. Backend emits `light-config-changed` event to Peer B's frontend
5. Peer B's UI updates:
   - Light disappears from color picker (or shows as disabled)
   - If light was active, UI shows "Off" status
   - Config screen shows updated state

## Test Coverage

Added comprehensive integration tests in `src-tauri/src/services/config_sync_tests.rs`:

1. ✅ `test_config_sync_disables_active_light_on_remote_peer` - Tests that when Peer A deletes a light, Peer B (who has it active) turns it off
2. ✅ `test_config_sync_with_no_active_light` - Tests config sync when peer doesn't have the deleted light active
3. ✅ `test_offline_peer_catches_up` - Tests that offline peers correctly sync deletions when they rejoin
4. ✅ `test_new_peer_joins_existing_network_with_custom_config` - Tests new peer adopting existing network config

**All 64 tests passing** ✅

## Manual Testing Guide

### Test 1: Real-time Config Sync

1. Start two instances: `pnpm tauri dev`
2. On Peer A: Go to config screen and disable "Yellow" light
3. **Expected:** Peer B's UI should immediately update:
   - Yellow disappears from light picker (or shows disabled in config screen)
   - If Peer B had Yellow active, it should turn Off

### Test 2: Active Light Deletion

1. Start two instances
2. On Peer B: Set light to "Red"
3. On Peer A: Delete "Red" light definition
4. **Expected:**
   - Peer B's light should immediately turn Off
   - Peer B's UI should update to show light is Off
   - Red should disappear from Peer B's light picker

### Test 3: Offline Peer Catch-up

1. Start Peer A
2. Start Peer B (they discover each other)
3. Stop Peer B
4. On Peer A: Delete "Green" light
5. Restart Peer B
6. **Expected:**
   - Peer B should receive config sync on startup
   - Green light should be gone from Peer B's UI
   - If Peer B had Green active before stopping, it should be Off after restart

### Test 4: New Peer Joins Established Network

1. Start Peer A, customize config (rename lights, disable some)
2. Let it run for a bit (version number increases)
3. Start Peer B (brand new, default config)
4. **Expected:**
   - Peer B should adopt Peer A's customized config
   - Peer A's config should NOT be overwritten by Peer B's default
   - Both peers should have identical configs

## Files Modified

### Backend (Rust)

- `src-tauri/src/domain/light_config.rs` - Tombstone pattern, version-based merge
- `src-tauri/src/services/message_handler.rs` - Fixed tombstone check, removed debug logs
- `src-tauri/src/services/peer_service/mod.rs` - Config service attachment
- `src-tauri/src/setup/initialization.rs` - Config service initialization
- `src-tauri/src/commands.rs` - Delete command using tombstones
- `src-tauri/src/services/config_sync_tests.rs` - NEW FILE with integration tests

### Frontend (TypeScript/Svelte)

- No changes needed - frontend was already correctly implemented with:
  - Event listeners for `light-config-changed`
  - Reactive stores
  - Proper filtering of deleted/disabled lights

## Architecture Decisions

1. **Tombstone Pattern:** Deletions are marked with `deleted_at` timestamp, not physically removed, allowing offline peers to sync deletions
2. **Version-Based Merge:** Higher version numbers take precedence over newer timestamps to prevent new peers from overwriting established configs
3. **Color-Based Secondary Matching:** When IDs don't match, merge by color to handle different peer configs
4. **Config Service Attachment:** Config service is injected into PeerService after creation to handle circular dependencies

## Next Steps

1. ✅ Run all tests: `cd src-tauri && cargo test --lib`
2. ⏳ Manual testing with two instances (see guide above)
3. ⏳ Consider version increment strategy:
   - Should version increment on every config change?
   - Should version be per-definition instead of global?
4. ⏳ Monitor logs during manual testing: `RUST_LOG=debug pnpm tauri dev`
5. ⏳ Test edge cases:
   - Multiple rapid config changes
   - Network partition and rejoin
   - Three or more peers with different configs
