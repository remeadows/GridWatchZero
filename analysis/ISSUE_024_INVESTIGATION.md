# ISSUE-024 Investigation: Save System Progress Loss
**Date**: 2026-02-12
**Status**: Root causes identified, fixes proposed
**Severity**: Critical

---

## Problem Statement

Despite prior fixes in ISSUE-021 (adding `synchronize()` and error handling) and ISSUE-006 (cloud sync race condition), progress is still being lost when the app is closed. The game reopens as if starting fresh.

---

## Architecture: Two Independent Save Systems

| System | Key | Managed By |
|--------|-----|-----------|
| Endless Mode | `GridWatchZero.GameState.v6` | GameEngine.saveGame() |
| Campaign | `GridWatchZero.CampaignProgress.v1` | CampaignSaveManager.save() |
| Story | `GridWatchZero.StoryState.v1` | NavigationCoordinator.saveStoryState() |
| Cloud | `GridWatchZero.SyncableProgress.v1` | CloudSaveManager (iCloud KVS) |

---

## Root Causes Identified

### 1. Cloud Sync Overwrites Local Progress on Launch (HIGH)

**File**: `NavigationCoordinator.swift:99-137`, `CloudSaveManager.swift:264-275`

On every app launch, `performInitialCloudSync()` downloads cloud data and compares timestamps. The ISSUE-006 fix only protects against levels completed DURING the async sync. If cloud has a newer timestamp but less/empty progress (e.g., from a different device, simulator reset, or after `handleNewGame()`), the timestamp-wins logic overwrites local data.

**Fix**: Compare progress content (completed level count) not just timestamps. Only download cloud data if it has MORE progress than local.

### 2. CampaignState.save() Uploads Empty StoryState (MEDIUM)

**File**: `CampaignProgress.swift:461`

Every `CampaignState.save()` calls:
```swift
CloudSaveManager.shared.uploadProgress(progress, storyState: StoryState())
```

This uploads a blank story state every time. If another device downloads this, all story progress is wiped.

**Fix**: Pass actual story state, or don't upload story state from CampaignState.save() at all (let NavigationCoordinator handle it).

### 3. PlayerProfileView Manual Sync Has No Protection (HIGH)

**File**: `PlayerProfileView.swift:512-514`

Manual "Sync Now" button downloads and directly overwrites `campaignState.progress` with NO race condition protection (unlike the initial sync):
```swift
case .downloaded(let progress, _):
    campaignState.progress = progress  // Direct overwrite!
    campaignState.save()
```

**Fix**: Apply the same protection as `performInitialCloudSync()` — compare local vs cloud progress before accepting download.

### 4. Campaign Auto-Save Skips GameEngine State (MEDIUM)

**File**: `GameEngine.swift:551-557`

During campaign mode, the 30-tick auto-save only writes a `LevelCheckpoint`, never calling `saveGame()`. If the app crashes or is force-killed between auto-saves and the scenePhase handler doesn't fire, the endless-mode save key contains stale data.

**Fix**: Call `saveGame()` in addition to `saveCampaignCheckpoint()` during campaign auto-save.

### 5. iOS Force-Quit May Skip scenePhase Handlers (MEDIUM)

When a user swipes the app away from the app switcher, iOS may not fire `.background` scenePhase, meaning `pause()` and `campaignState.save()` never execute.

**Fix**: Save on `.inactive` (already done at line 529) AND ensure auto-save interval is short enough to minimize data loss window.

---

## Recommended Fix Priority

| # | Fix | Risk | Effort | Files |
|---|-----|------|--------|-------|
| 1 | Cloud sync: compare progress content, not just timestamps | High value | Medium | CloudSaveManager.swift, NavigationCoordinator.swift |
| 2 | Fix empty StoryState upload | Medium value | Low | CampaignProgress.swift line 461 |
| 3 | Add protection to PlayerProfileView manual sync | High value | Low | PlayerProfileView.swift |
| 4 | Call saveGame() in campaign auto-save | Medium value | Low | GameEngine.swift line 552 |
| 5 | Add save-on-inactive as backup | Low value | Low | Already partially done |

---

## Reproduction Theory

Most likely reproduction path:
1. Player plays campaign, makes progress, app goes to background (saves correctly)
2. On next app launch, `performInitialCloudSync()` fires
3. Cloud has data from a previous session/device with newer timestamp but empty progress
4. Timestamp comparison picks cloud data → overwrites local campaign progress
5. Player sees "fresh start"

Alternative path:
1. Player taps "Sync Now" in PlayerProfileView
2. Cloud has stale/empty data
3. Direct overwrite of campaignState.progress with no protection
4. Player loses all progress
