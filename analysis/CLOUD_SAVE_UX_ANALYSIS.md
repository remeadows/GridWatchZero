# Cloud Save Conflict UX Analysis
**Date**: 2026-02-12
**Status**: Gaps identified, fixes proposed
**Severity**: Critical (data loss bugs found)

---

## Problem Statement

Cloud save sync uses `NSUbiquitousKeyValueStore` with timestamp-based conflict detection. Multiple UX gaps cause silent data loss, ignored errors, and a critical bug where "Use Cloud" resolution never applies cloud data. Players on multiple devices are at high risk of progress loss.

---

## Architecture Overview

| Component | File | Role |
|-----------|------|------|
| `CloudSaveManager` | CloudSaveManager.swift | Core sync engine, conflict detection, iCloud KVS |
| `PlayerProfileView` | PlayerProfileView.swift | Only UI for conflict resolution + manual sync |
| `NavigationCoordinator` | NavigationCoordinator.swift | App launch sync, post-level upload |
| `CampaignState` | CampaignProgress.swift | Auto-uploads on every save (with empty StoryState) |

**Sync Flow**:
1. App launch → `performInitialCloudSync()` (NavigationCoordinator)
2. Level complete → `syncToCloud()` (NavigationCoordinator)
3. Campaign save → `uploadProgress()` (CampaignState.save())
4. Manual → "Sync Now" button (PlayerProfileView)
5. External change → `handleExternalChange()` notification (CloudSaveManager)

---

## Critical Bugs

### BUG 1: "Use Cloud" Button Never Applies Cloud Data (CRITICAL)

**File**: PlayerProfileView.swift, lines 119-135

When the user taps "Use Cloud" in the conflict alert:
1. `cloudManager.resolveConflict(useLocal: false)` is called
2. This sets `pendingConflict = nil` (CloudSaveManager line 232)
3. The next line tries to read `cloudManager.pendingConflict?.cloudProgress`
4. This is **always nil** because step 2 just cleared it
5. Cloud data is **never applied** to `campaignState.progress`

**Impact**: Players who choose "Use Cloud" during a conflict get neither cloud NOR local data applied — they keep whatever local state was already loaded. The conflict appears resolved but cloud data was silently discarded.

**Fix**: Capture `pendingConflict` data BEFORE calling `resolveConflict()`:
```swift
case .useCloud:
    if let cloudProgress = cloudManager.pendingConflict?.cloudProgress {
        cloudManager.resolveConflict(useLocal: false)
        campaignState.progress = cloudProgress
        campaignState.save()
    }
```

### BUG 2: handleCloudDataChange Is a No-Op (HIGH)

**File**: NavigationCoordinator.swift, lines 305-314

`setupCloudSync()` registers for `.cloudDataChanged` notifications but the handler body is empty. External iCloud changes from other devices are detected but completely ignored.

**Impact**: If another device uploads progress while this device is running, the local device never receives the update. This creates a silent divergence that leads to the next sync overwriting the newer data.

**Fix**: Implement the handler to compare and optionally apply incoming changes, or at minimum show a notification to the user.

---

## UX Gaps by Severity

### HIGH Severity

| # | Gap | File:Line | Impact |
|---|-----|-----------|--------|
| 1 | Sync errors silently ignored in manual sync | PlayerProfileView:611-614 | `syncNow()` only handles `.downloaded` case — `.conflict` and `.error` are silently dropped |
| 2 | No error handling in `syncToCloud()` | NavigationCoordinator:322-323 | Post-level upload failures are invisible — player thinks progress was saved to cloud |
| 3 | No sync on foreground return | NavigationCoordinator:537-544 | After backgrounding, cloud changes from other devices are never pulled — stale data persists |
| 4 | App launch conflict silently ignored | NavigationCoordinator:369 | If `performInitialCloudSync()` detects a conflict, it's logged but not surfaced to the user |
| 5 | Alert binding uses `.constant()` | PlayerProfileView:119 | `.constant(cloudManager.pendingConflict != nil)` prevents SwiftUI from properly dismissing the alert |

### MEDIUM Severity

| # | Gap | File:Line | Impact |
|---|-----|-----------|--------|
| 6 | Silent auto-overwrite when timestamps differ >60s | CloudSaveManager:205 | If devices are >60 seconds apart, the newer timestamp wins with NO conflict dialog — silent overwrite |
| 7 | Story state discarded in manual sync | PlayerProfileView:608 | `syncNow()` creates `StoryState()` (empty) instead of using the coordinator's actual story state |
| 8 | No success feedback after sync | PlayerProfileView:187-204 | Spinner shows during sync, then disappears — no confirmation that sync completed |
| 9 | No feedback after conflict resolution | PlayerProfileView:119-135 | After tapping "Use Local" or "Use Cloud", no toast/banner confirms the action |
| 10 | Asymmetrical conflict resolution | PlayerProfileView:121-123 | "Use Local" only calls resolve; "Use Cloud" has extra campaignState update — inconsistent paths |
| 11 | Post-level sync has no timeout | NavigationCoordinator:514 | Async upload with no timeout could leave user hanging on slow networks |
| 12 | External changes detected but no UI feedback | CloudSaveManager:237-261 | Notification posted but no user-visible indicator of incoming cloud data |

### LOW Severity

| # | Gap | File:Line | Impact |
|---|-----|-----------|--------|
| 13 | Device UUID instead of device name | CloudSaveManager:56 | Conflict dialog shows UUID, not "iPhone" vs "iPad" — user can't identify devices |
| 14 | Generic error messages | CloudSaveManager:162,170 | "Encoding failed" / "Decoding failed" give no actionable guidance |
| 15 | Similar icons for conflict/error states | PlayerProfileView:225-252 | Warning and error icons look similar — users can't distinguish states |
| 16 | No timeout for pending conflicts | CloudSaveManager:86 | `pendingConflict` stays set indefinitely if user never visits PlayerProfileView |
| 17 | Cloud diagnostic view can't resolve conflicts | PlayerProfileView (diagnostics) | Debug info is read-only — can't force-push or force-pull |

---

## Conflict Detection Logic

**Current Flow** (CloudSaveManager, lines 195-213):
```
1. Compare local timestamp vs cloud timestamp
2. If difference < 60 seconds AND different device IDs:
   → Trigger conflict (set pendingConflict, return .conflict)
3. If difference >= 60 seconds:
   → Newer timestamp wins silently (no user input)
4. If same device ID:
   → Always upload local (assumes local is authoritative)
```

**Problems**:
- The 60-second window is too narrow for real multi-device use
- "Newer timestamp wins" can overwrite MORE progress with LESS progress
- Same-device assumption fails if user reinstalls app (new device ID, same device)

---

## Recommended Fixes (Priority Order)

### P0: Fix Critical Bugs (Immediate)

| Fix | Files | Effort |
|-----|-------|--------|
| Capture cloud data before clearing pendingConflict | PlayerProfileView.swift | Low |
| Implement handleCloudDataChange handler | NavigationCoordinator.swift | Medium |
| Fix `.constant()` alert binding | PlayerProfileView.swift | Low |

### P1: Add Error Visibility (High Impact, Low Effort)

| Fix | Files | Effort |
|-----|-------|--------|
| Handle `.error` and `.conflict` cases in `syncNow()` | PlayerProfileView.swift | Low |
| Add error handling to `syncToCloud()` | NavigationCoordinator.swift | Low |
| Surface app launch conflicts to user | NavigationCoordinator.swift | Medium |
| Show success toast after manual sync | PlayerProfileView.swift | Low |

### P2: Improve Conflict Resolution (Medium Effort)

| Fix | Files | Effort |
|-----|-------|--------|
| Compare progress CONTENT not just timestamps | CloudSaveManager.swift | Medium |
| Move conflict dialog to app-level (not just PlayerProfileView) | NavigationCoordinator.swift, RootNavigationView | Medium |
| Add sync on foreground return | NavigationCoordinator.swift | Low |
| Pass actual story state in manual sync | PlayerProfileView.swift | Low |

### P3: Polish (Low Priority)

| Fix | Files | Effort |
|-----|-------|--------|
| Show device name instead of UUID | CloudSaveManager.swift | Low |
| Add conflict timeout/auto-resolve | CloudSaveManager.swift | Medium |
| Better error messages with guidance | CloudSaveManager.swift | Low |
| Cloud diagnostic view with resolve actions | PlayerProfileView.swift | Medium |

---

## Overlap with ISSUE-024

Several gaps here directly cause the progress loss documented in ISSUE-024:

| This Analysis | ISSUE-024 Root Cause | Same Fix? |
|---------------|---------------------|-----------|
| BUG 1: "Use Cloud" never applies | RC3: PlayerProfileView no protection | Yes — both fixed by capturing data before clearing |
| Gap 6: Silent auto-overwrite | RC1: Cloud overwrites local on launch | Yes — both fixed by comparing progress content |
| Gap 7: Empty StoryState in sync | RC2: CampaignState uploads blank story | Yes — same root cause |
| Gap 3: No sync on foreground | RC5: iOS force-quit skips handlers | Related — both leave stale state |

Fixing the P0 and P1 items here addresses the most critical ISSUE-024 root causes simultaneously.

---

## Reproduction Steps for BUG 1

1. Play campaign on Device A, complete Level 3
2. Play campaign on Device B, complete Level 2 only
3. Open app on Device A — conflict detected (both recent, different devices)
4. Tap "Use Cloud" (expecting Device B's data)
5. **Result**: Device A keeps its own Level 3 progress — Device B's data was silently discarded
6. **Expected**: Device A should now show Level 2 progress (matching Device B)

This bug means the conflict resolution dialog is purely cosmetic — "Use Cloud" and "Use Local" produce the same outcome.
