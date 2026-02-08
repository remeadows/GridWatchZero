# ISSUES.md - Grid Watch Zero

## Issue Tracker

---

## 🔴 Critical (Blocks Gameplay)

### ISSUE-033: Level 9 Impossible Difficulty - Attacks Drain Millions Per Hit
**Status**: ✅ RESOLVED
**Severity**: Critical - Game Breaking
**Reported**: 2026-02-07
**Resolved**: 2026-02-08
**Description**: Level 9 was unwinnable. Player reported: "My risk level is Signal. Every attack I am getting is taking millions of credits. It will never end well."

**Level 9 Configuration** (`LevelDatabase.swift` line 303-335):
- **Starting Threat**: `.symbiont` (level 12 - extremely high!)
- **Minimum Attack Chance**: 8% per tick
- **Attack Grace Period**: 180 ticks (3 minutes)
- **Victory Requirements**:
  - Credits: 124M
  - Defense Tier: 8
  - Defense Points: 2,600
  - Risk Level: Must reduce to `.priority` (level 5)
  - Reports Sent: 250

**Attack Types at Level 9**:
- **Symbiotic Invasion** (`ThreatSystem.swift` line 598-605):
  ```swift
  let baseDrain = 300 * severity  // Base is 300-900 credits/tick
  creditDrain = baseDrain * effectiveScale  // Scales with player income!
  ```
- **effectiveScale** = `0.7 + (0.3 * min(playerIncome/10, 100))`
  - At 100 credits/tick income: scale = ~3.7×
  - At 1000 credits/tick income: scale = ~30×
  - Attack damage: **1,110 - 27,000 credits/tick**

**The Problem - Income Scaling Death Spiral**:
1. Player needs high income to reach 124M credits
2. High income causes attacks to scale massively
3. Single attack drains millions of credits
4. Player can't build defenses fast enough
5. Each failed attempt makes next attempt harder (income increases)

**Example Calculation** (Player earning 1000 credits/tick):
- Base attack: 300 credits × 2.0 severity = 600
- Income scale: 1000/10 = 100 (capped)
- Effective scale: 0.7 + (0.3 × 100) = 30.7×
- **Damage per tick: 18,420 credits**
- Attack duration: ~5 ticks = **~92,000 credits per attack**
- Attack frequency: 8% per tick = **1 attack every 12.5 ticks**
- **Credit loss rate: ~7,360 credits/tick** (impossible to recover from)

**Root Cause**:
The income scaling formula (`ThreatSystem.swift` line 535-542) creates a runaway scaling problem at high threat levels combined with high income requirements. The formula was designed for early game balance but breaks catastrophically in late game.

**Current Defense Caps**:
- NetDefense max reduction: 72% (at HELIX level 9)
- DefenseStack max reduction: 65%
- Combined max: 85% damage reduction
- Even with max defenses: 18,420 × 0.15 = **2,763 credits/tick** = still crushing

**Player's Situation**:
- Risk Level: SIGNAL (level 3) - should be safe
- Actual Threat: SYMBIONT (level 12) - extremely dangerous
- Defense gap: 9 threat levels difference!
- Even "low risk" shows millions in damage

**Comparison to Earlier Levels**:
- Level 1-6: Threat levels 1-7, base damage 5-200
- Level 7: TARGET threat, base damage up to 200
- Level 8: ASCENDED threat (level 11), base damage 300
- **Level 9: SYMBIONT threat (level 12), base damage 300-600**
- Level 9 is a massive difficulty spike

**Possible Solutions**:

**Option 1**: Reduce Level 9 starting threat
- Change from `.symbiont` (12) to `.ascended` (11) or `.critical` (10)
- Reduces base attack frequency and severity
- Maintains progression curve

**Option 2**: Cap income scaling at lower value for late game
- Change cap from 100× to 10× or 20×
- Formula: `min(incomeScale, 10.0)` instead of `100.0`
- Prevents runaway scaling

**Option 3**: Increase defense effectiveness at high tiers
- Raise damage reduction cap from 85% to 95% for T8+ defenses
- Add flat damage reduction (subtract X credits before percentage)
- Example: Subtract 500 credits, then apply 85% reduction

**Option 4**: Reduce victory credit requirement
- Lower from 124M to 50M or 75M
- Allows player to win before income reaches breaking point
- Maintains challenge without impossibility

**Option 5**: Add income-based defense scaling
- Higher income = stronger defense multiplier
- "You can afford better security contractors"
- Balances the income-scaling attacks

**Recommended Fix** (Combination):
1. Reduce starting threat to `.ascended` (level 11)
2. Cap income scaling at 20× instead of 100×
3. Reduce credit requirement to 75M
4. Increase max defense reduction to 90% for T8+

**Files to Modify**:
- `Models/LevelDatabase.swift` line 317: Change starting threat
- `Models/LevelDatabase.swift` line 323: Reduce credit requirement
- `Models/ThreatSystem.swift` line 540: Reduce income scale cap
- `Models/ThreatSystem.swift` line 262: Increase defense cap for high tiers

**Build Status**: N/A - Analysis complete

**Resolution Implemented** (Option B - Comprehensive Rebalance):

**Global Changes**:
1. ✅ Reduced income scaling cap from 100× to 20× (`ThreatSystem.swift:540`)
2. ✅ Increased defense cap from 85% to 90% (`GameEngine.swift:606`)

**Level-by-Level Rebalancing** (all 12 levels rebalanced):
| Level | Credits (Before → After) | Threat Level (Before → After) | Attack % (Before → After) |
|-------|--------------------------|-------------------------------|---------------------------|
| 9 | 124M → **75M** | .symbiont → **.ascended** | 8% → **8%** |
| 10 | 279M → **175M** | .transcendent → **.symbiont** | 10% → **10%** |
| 11 | 628M → **400M** | .unknown → **.transcendent** | 15% → **12%** |
| 12 | 1.41B → **900M** | .dimensional → **.symbiont** | 15% → **13%** |
| 13 | 2.82B → **1.8B** | .cosmic → **.dimensional** | 18% → **15%** |
| 14 | 5.64B → **3.6B** | .paradox → **.cosmic** | 22% → **18%** |
| 15 | 11.3B → **7.2B** | .primordial → **.paradox** | 25% → **20%** |
| 16 | 22.6B → **14.4B** | .infinite → **.primordial** | 30% → **22%** |
| 17 | 39.5B → **25B** | .omega → **.infinite** | 35% → **25%** |
| 18 | 69.2B → **44B** | .omega → **.infinite** | 40% → **28%** |
| 19 | 121B → **77B** | .omega → **.omega** | 45% → **32%** |
| 20 | 212B → **135B** | .omega → **.omega** | 50% → **35%** |

**Impact**:
- Average credit reduction: ~37% across all levels
- Threat levels reduced by 1-2 levels for most levels
- Attack frequency reduced by 3-15% per level
- Combined damage reduction: ~55% at high income levels

**Files Modified**:
- `Models/ThreatSystem.swift` - Income scaling cap
- `Engine/GameEngine.swift` - Defense cap
- `Models/LevelDatabase.swift` - All 12 levels (9-20) rebalanced

**Build Status**: ✅ Build succeeded (9.2s)
**Player Feedback**: ✅ "Thanks I am now on level 10" - Issue resolved

---

### ISSUE-032: Brand Intro Video Not Displaying Full-Screen
**Status**: ✅ RESOLVED
**Severity**: Medium
**Reported**: 2026-02-07
**Resolved**: 2026-02-08
**Description**: The War Signal Labs brand intro video was not filling the entire iPhone screen edge-to-edge. Video displayed in center with black bars or margins. Additionally, audio pops were heard during transitions.

**Video Details**:
- Filename: `WarSignalLabs_vid1_9x16.mp4` (7.8MB)
- Aspect Ratio: 9:16 (vertical, optimized for iPhone)
- Location: `GridWatchZero/Resources/WarSignalLabs_vid1_9x16.mp4`
- Expected: Full-screen edge-to-edge display
- Actual: Centered with margins/bars

**Issues**:
1. **Video not full-screen**: Despite 9:16 aspect ratio matching iPhone screens, video displays smaller than screen
2. **Audio pops**: Video audio track causes popping sounds during playback

**Investigation Log**:

**Attempt 1** - Added custom AVPlayerLayer with UIViewRepresentable:
- Used `AVPlayerLayer` with `videoGravity = .resizeAspectFill`
- Set layer frame to `UIScreen.main.bounds`
- Result: ❌ Video still not full-screen

**Attempt 2** - Switched to AVPlayerViewController:
- Used `UIViewControllerRepresentable` with `AVPlayerViewController`
- Set `videoGravity = .resizeAspectFill`, disabled playback controls
- Result: ❌ Video still not full-screen

**Attempt 3** - Custom UIViewController with lifecycle management:
- Created `VideoPlayerViewController: UIViewController`
- Implemented `viewDidLayoutSubviews()` to update layer frame on layout changes
- Added `prefersStatusBarHidden` and `prefersHomeIndicatorAutoHidden` for true full-screen
- Muted video audio with `player.isMuted = true` to prevent audio pops
- Added debug logging in `viewDidLoad()` and `viewDidLayoutSubviews()`
- Result: ⏳ Testing - awaiting user feedback

**Current Implementation** (`BrandIntroView.swift`):
```swift
class VideoPlayerViewController: UIViewController {
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        player?.isMuted = true  // Prevent audio pops
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
    }

    override func viewDidLayoutSubviews() {
        playerLayer?.frame = view.bounds  // Update on layout changes
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
}
```

**Possible Root Causes**:
1. **Safe area constraints**: SwiftUI may be applying safe area insets despite `.ignoresSafeArea(.all)`
2. **View hierarchy issue**: Parent view not filling screen before video view is laid out
3. **Layer frame timing**: Player layer frame set before view reaches final size
4. **Video file issue**: Video metadata may specify different dimensions than actual content

**Debug Strategy**:
1. Check Xcode console for `[VideoPlayerViewController]` debug logs showing actual frame sizes
2. Compare `view.bounds` reported in logs vs actual iPhone screen size
3. Verify video file properties: `ffprobe WarSignalLabs_vid1_9x16.mp4`
4. Test on multiple devices/simulators to rule out device-specific issue

**Files Changed**:
- `Views/BrandIntroView.swift`: Complete rewrite of video player implementation

**Build Status**: ✅ Build succeeded (9.18s)

**Resolution Implemented**:

**Problem 1: Video Not Full-Screen**
- Root cause: `.ignoresSafeArea()` was applied globally to RootNavigationView's ZStack, interfering with touch events
- Solution: Applied `.ignoresSafeArea(.all)` selectively only to BrandIntroView case in switch statement
- Result: Video fills entire screen edge-to-edge, buttons remain responsive

**Problem 2: Audio Pops During Transitions**
- Root cause: Race condition in `AudioManager.startMusic()` - `isMusicPlaying` flag set AFTER playback start
- Multiple calls could pass guard check and reset volume to 0 mid-fade, causing audible pops
- Solution: Set `isMusicPlaying = true` BEFORE starting playback to prevent duplicate calls
- Simplified BrandIntroView audio handling - removed redundant volume controls

**Problem 3: Video Aspect Ratio**
- Initial attempts with 9:16 and fullscreen versions had aspect ratio issues
- Final solution: User provided optimized 9.16.5 ratio video (`WarSignalLabs_9_16_5.mp4`)
- Perfect fit for iPhone screens without letterboxing

**Files Modified**:
- `Engine/NavigationCoordinator.swift:330` - Added `.ignoresSafeArea(.all)` only to BrandIntroView case
- `Engine/AudioManager.swift:297-304` - Fixed race condition by setting flag before playback
- `Views/BrandIntroView.swift:107-176` - Simplified audio transitions, updated video reference
- Switched to `UIViewRepresentable` with `VideoPlayerUIView` for direct layer control

**Final Video**: `WarSignalLabs_9_16_5.mp4` (9.1MB, 9.16.5 aspect ratio)

**Build Status**: ✅ Build succeeded (2.94s)
**Player Feedback**: ✅ "Great! Video works great! Issue fixed."

---

### ISSUE-029: Background Music Playing During Gameplay Levels
**Status**: ✅ Fixed
**Severity**: High
**Reported**: 2026-02-07
**Closed**: 2026-02-07
**Description**: The background music loop (`background_music.m4a`) continued playing during gameplay levels. Only the ambient data center soundscape should play during gameplay.

**Root Cause**: `AudioSettings.applySettingsToManagers()` automatically restarted music whenever settings were applied, without distinguishing between menu context (where music should play) and gameplay context (where music should stay off).

**Solution**: Added gameplay context tracking to `AmbientAudioManager`:
1. Added `isInGameplay: Bool` flag to track current context
2. Added `enterGameplayMode()` - stops music and sets flag to prevent restart
3. Added `exitGameplayMode()` - clears flag to allow music in menus
4. Modified `startAmbient()` to check flag and block music start during gameplay

**Files Changed**:
- `Engine/AudioManager.swift` (lines 379-437): Added gameplay context tracking
- `Engine/NavigationCoordinator.swift` (lines 601, 205): Call enter/exit gameplay mode

**Build Status**: ✅ Build succeeded (3.16s)

---

### ISSUE-030: Auto-Upgrade Occurring on Single Tap (REOPENED)
**Status**: 🔴 REOPENED - User reports issue persists
**Severity**: High
**Reported**: 2026-02-07 (original), 2026-02-07 (reopened)
**Description**: User reports that tapping upgrade button once causes automatic continuous upgrading. Quote: "When I purchase the next update (like L1 to L2), the device auto upgrades."

**Investigation (2026-02-07 Evening)**:

**Current Implementation** (`NodeCardView.swift` lines 18-45):
```swift
Button(action: {
    // Single tap should also work
    if canPerformAction() {
        action()  // Upgrades once
        HapticManager.selection()
    }
})
.simultaneousGesture(
    LongPressGesture(minimumDuration: 0.3)
        .onEnded { _ in
            if canPerformAction() {
                isPressed = true
                startContinuousUpgrade()  // Timer starts
            }
        }
)
.simultaneousGesture(
    DragGesture(minimumDistance: 0)
        .onEnded { _ in
            stopContinuousUpgrade()  // Timer stops
        }
)
```

**Potential Root Causes**:
1. **Gesture conflict**: Both `LongPressGesture` and `DragGesture` may be firing unintentionally
2. **Button action + gesture racing**: The button `action` closure might be running multiple times
3. **Timer not stopping**: The `upgradeTimer` may not be invalidating properly
4. **Multiple button instances**: Could there be multiple buttons responding to the same tap?

**Questions for User**:
1. Does tapping ONCE cause multiple upgrades (L1 → L2 → L3 → L4...)? OR
2. Does tapping ONCE start continuous upgrade mode that keeps going until you tap again?
3. Does this happen on SOURCE, LINK, SINK, and FIREWALL? Or only specific nodes?
4. Can you reproduce this consistently? Or is it intermittent?

**Tested Scenarios** (code review):
- ✅ Button action should only fire once per tap
- ✅ `LongPressGesture` requires 0.3s minimum duration
- ✅ `DragGesture.onEnded` should fire on finger release
- ✅ GameEngine upgrade functions only upgrade once per call
- ❓ Gesture interaction timing and conflicts need device testing

**Next Steps**:
1. Get clarification from user on exact behavior
2. Consider simplifying button to remove gesture complexity
3. May need to add debug logging to track gesture events
4. Consider alternative: Regular button for single tap, separate "Hold to Upgrade" mode

---

### ISSUE-031: Checkpoint Resume Not Working (REOPENED)
**Status**: 🔴 REOPENED - User reports cannot resume after closing app
**Severity**: Critical
**Reported**: 2026-02-07 (original), 2026-02-07 (reopened)
**Description**: User reports: "When I close the game, I cannot reopen it and continue the game where I left off. THIS IS STILL an issue that hasn't been resolved."

**Previous Fix Attempt**: Removed "Save & Exit" button to clarify auto-save behavior (button text changed to "Exit", manual checkpoint save removed).

**Investigation (2026-02-07 Evening)**:

**Checkpoint System Components**:
1. **Auto-Save** (`GameEngine.swift` line 547-550):
   ```swift
   if currentTick % 30 == 0 {
       if isInCampaignMode {
           saveCampaignCheckpoint()  // Saves every 30 ticks (30 seconds)
       }
   }
   ```

2. **Checkpoint Validation** (`CampaignProgress.swift` line 44-47):
   ```swift
   var isValid: Bool {
       let hoursSinceSave = Date().timeIntervalSince(savedAt) / 3600
       return hoursSinceSave < 24  // Valid for 24 hours
   }
   ```

3. **Resume Detection** (`CampaignProgress.swift` line 410-415):
   ```swift
   func hasValidCheckpoint(for levelId: Int, isInsane: Bool) -> Bool {
       guard let checkpoint = progress.activeCheckpoint else { return false }
       return checkpoint.levelId == levelId &&
              checkpoint.isInsane == isInsane &&
              checkpoint.isValid
   }
   ```

4. **Button Logic** (`HomeView.swift` line 595-621):
   - If `hasNormalCheckpoint` → Shows "CONTINUE MISSION" button
   - Button calls `onResumeNormal()` → Does NOT clear checkpoint
   - Level loads with `gameEngine.resumeFromCheckpoint(checkpoint, config:)`

**All Components Look Correct** ✅
Code review shows checkpoint system should work. Issue must be behavioral/environmental.

**Possible Root Causes**:
1. **Checkpoint not saving**: Auto-save may not be triggering before app closes
2. **Checkpoint being cleared**: Something might be clearing `activeCheckpoint` unexpectedly
3. **Checkpoint loading fails**: Resume path may have silent error
4. **UserDefaults not persisting**: CampaignSaveManager save may be failing
5. **App lifecycle issue**: iOS may be clearing state on force-close

**Questions for User**:
1. How are you closing the app?
   - Background (home button/swipe) OR Force-close (swipe up in app switcher)?
2. How long do you play before closing? (Need >30 seconds for first checkpoint)
3. When you reopen, what do you see?
   - "START MISSION" (no checkpoint detected) OR
   - "CONTINUE MISSION" (checkpoint detected but doesn't work)?
4. Are you testing on simulator or real device?
5. Have you waited at least 30 seconds in gameplay before closing?

**Debug Strategy**:
1. Add console logging to checkpoint save/load cycle
2. Verify UserDefaults persistence on app relaunch
3. Check if checkpoint is being cleared on app background
4. Test with 60+ second gameplay session before closing
5. Verify CampaignProgress.activeCheckpoint is non-nil after load

**Next Steps**: Need user answers to questions above to narrow down root cause.

---

### ISSUE-006: Campaign Level Completion Lost on Return to Hub
**Status**: ✅ Fixed
**Severity**: Critical
**Description**: After completing a campaign level and selecting "Back to Hub", the level completion is erased. Level shows as not completed despite victory screen appearing.
**Impact**: Players lose all campaign progress when returning to hub. Game-breaking bug.
**Reproduction**:
1. Start Level 1 campaign
2. Meet all victory conditions
3. Victory screen appears
4. Click "Back to Hub"
5. Level 1 shows as incomplete/locked

**Root Cause**:
Race condition in initial cloud sync. The async `performInitialCloudSync()` could complete AFTER a player completed a level, overwriting local progress with stale cloud data. The sequence was:
1. App starts → async cloud sync begins (captures current empty progress)
2. User plays and completes level 1 → saved to UserDefaults and uploaded to cloud
3. Initial cloud sync finally completes → downloads old cloud data (from before level was completed)
4. Old cloud data overwrites local progress → level completion lost

**Solution**:
Modified `performInitialCloudSync()` in `NavigationCoordinator.swift` to:
1. Capture `completedLevels` count BEFORE starting the async sync
2. After sync returns `.downloaded`, compare current progress with captured state
3. If local progress advanced during sync (more levels completed), upload local instead of downloading cloud
4. This prevents stale cloud data from overwriting newer local progress

**Files Changed**:
- `Engine/NavigationCoordinator.swift` - Added race condition protection in `performInitialCloudSync()`
- `Models/CampaignProgress.swift` - Added TODO for story state sync issue

**Closed**: 2026-01-21

### ISSUE-017: iCloud Sync Failing
**Status**: ✅ Fixed
**Severity**: Critical
**Reported**: 2026-01-31
**Closed**: 2026-02-01
**Description**: iCloud sync was failing despite correct project configuration. Cloud saves not syncing between devices.
**Resolution**: Added CloudDiagnosticView for troubleshooting. After adding diagnostic tools and verbose logging, sync functionality confirmed working. User verified cloud sync operational via diagnostics panel.

**Diagnostic Tools Added (2026-01-31):**
- Created `CloudDiagnosticView.swift` - In-app diagnostic UI accessible via Settings → iCloud Diagnostics
- Added verbose logging to `CloudSaveManager.swift` using `os.log` (filter: "CloudSync")
- Diagnostic features:
  - Quick status check (iCloud token, cloud availability, last sync, conflicts)
  - Full diagnostics button (tests all iCloud components)
  - Force Sync button (manual sync trigger)
  - KV Store Write/Read test (validates NSUbiquitousKeyValueStore)
  - Detailed diagnostic log with timestamps

**How to Access Diagnostics:**
1. From Campaign Hub: Tap Settings (gear icon) → iCloud Sync section → "iCloud Diagnostics"
2. From Gameplay: Tap Settings (gear icon) → iCloud Sync section → "iCloud Diagnostics"

**Console Logging:**
Run app in Xcode and filter console for "CloudSync" to see detailed iCloud operations.

**Configuration Verified (All Correct):**
- `GridWatchZero.entitlements` exists with `com.apple.developer.ubiquity-kvstore-identifier`
- `CODE_SIGN_ENTITLEMENTS` linked in both Debug and Release configurations
- Team ID: B2U8T6A2Y3
- Bundle ID: WarSignal.GridWatchZero
- KV Store ID: `$(TeamIdentifierPrefix)$(CFBundleIdentifier)` → `B2U8T6A2Y3.WarSignal.GridWatchZero`

**Diagnostic Steps Required:**
1. **Check device iCloud status:**
   - Settings → Apple ID → iCloud → iCloud Drive (must be ON)
   - Settings → Apple ID → iCloud → Apps Using iCloud → Grid Watch Zero (must be ON)

2. **Check Xcode Console for errors:**
   - Run app in Xcode, filter console for "iCloud" or "ubiquit"
   - Look for: `NSUbiquitousKeyValueStore` errors

3. **Verify provisioning profile:**
   - Xcode → Signing & Capabilities → Verify iCloud capability shows green checkmark
   - If red X: Click "Try Again" or regenerate provisioning profile in Developer Portal

4. **Test NSUbiquitousKeyValueStore directly:**
   ```swift
   // Add to AppDelegate or test
   let store = NSUbiquitousKeyValueStore.default
   let synced = store.synchronize()
   print("iCloud KV sync result: \(synced)")
   print("iCloud token: \(FileManager.default.ubiquityIdentityToken != nil)")
   ```

5. **Check CloudSaveManager status:**
   - Add breakpoint in `setupCloudSync()` 
   - Verify `FileManager.default.ubiquityIdentityToken` is not nil
   - Verify `cloudStore.synchronize()` returns true

**Potential Causes:**
- [ ] Device not signed into iCloud
- [ ] iCloud Drive disabled on device
- [ ] App not enabled in iCloud settings
- [ ] Provisioning profile needs regeneration after entitlements change
- [ ] Network connectivity issue
- [ ] iCloud quota exceeded
- [ ] Simulator vs device difference (Simulator iCloud can be flaky)

**Next Steps:**
1. ✅ Created in-app diagnostic view
2. ✅ Added verbose logging to CloudSaveManager
3. Run diagnostic view on device to capture specific error
4. Check Xcode console for "CloudSync" log entries
5. Test on physical device (not simulator)
6. If still failing: regenerate provisioning profile in Developer Portal

**Files Added:**
- `Views/CloudDiagnosticView.swift` - In-app iCloud diagnostic UI

**Files Modified:**
- `Engine/CloudSaveManager.swift` - Added os.log verbose logging
- `Views/SettingsView.swift` - Added iCloud Sync section with diagnostics link
- `Views/HomeView.swift` - Pass environment objects to SettingsView
- `Views/DashboardView.swift` - Added cloudManager/campaignState environment objects
- `Engine/NavigationCoordinator.swift` - Pass environment objects to DashboardView

---

### ISSUE-007: Cloud Save Does Not Work
**Status**: ✅ Fixed
**Severity**: Critical
**Description**: Cloud save functionality is not working. Player progress is not syncing across devices or to the cloud.
**Impact**: Players cannot recover progress if they switch devices or reinstall the app. Critical for user retention.

**Root Cause**:
The `CloudSaveManager.swift` code is **fully implemented** using `NSUbiquitousKeyValueStore` (iCloud Key-Value Store), but the Xcode project was **missing the entitlements link**. The entitlements file existed at `Project Plague/Project Plague.entitlements` but the `CODE_SIGN_ENTITLEMENTS` build setting was not configured in the project.

**Solution**:
Added `CODE_SIGN_ENTITLEMENTS = "Project Plague/Project Plague.entitlements"` to both Debug and Release build configurations in `project.pbxproj`.

**Files Changed**:
- `Project Plague.xcodeproj/project.pbxproj` - Added CODE_SIGN_ENTITLEMENTS to Debug and Release configs

**Closed**: 2026-01-28

---

### ISSUE-021: Save System Fails When Backgrounding - Complete Progress Loss
**Status**: ✅ Fixed
**Severity**: Critical
**Reported**: 2026-02-07
**Description**: When the player backgrounds the app (switches to another app or locks device), game progress is completely lost. Upon returning to the app, the game restarts from scratch as if no save data exists.

**Impact**: Players lose ALL progress when switching apps or locking their device. This is a showstopper bug for any idle game where players expect to background and return frequently.

**Reproduction**:
1. Play the game and make progress (earn credits, upgrade units, advance campaign)
2. Background the app (home button, app switcher, or lock device)
3. Wait 5-10 seconds
4. Return to the app
5. All progress is lost - game restarts as new

**Root Cause**: Multiple issues in save system:
1. **Silent failures**: `GameEngine.saveGame()` used `try?` which silently swallowed encoding errors
2. **No forced write**: No `UserDefaults.synchronize()` call to force immediate disk write
3. **Race condition**: iOS can terminate backgrounded apps before async UserDefaults writes complete
4. **No error logging**: No visibility when saves fail

**Solution**:
Modified save system in `GameEngine.swift` to:
1. Replace `try?` with `do-catch` block for proper error handling
2. Add `UserDefaults.standard.synchronize()` to force immediate write to disk (critical for backgrounding)
3. Add detailed logging for save success/failure with timestamp and progress indicators
4. Add logging for load operations to track save/load lifecycle

**Files Changed**:
- `Engine/GameEngine.swift` (lines 1190-1252):
  - Enhanced `saveGame()` with error handling, synchronize(), and logging
  - Enhanced `loadGame()` with logging to track save data retrieval

**Technical Details**:
```swift
// BEFORE (Silent failure):
if let data = try? JSONEncoder().encode(state) {
    UserDefaults.standard.set(data, forKey: saveKey)
}

// AFTER (Robust with immediate write):
do {
    let data = try JSONEncoder().encode(state)
    UserDefaults.standard.set(data, forKey: saveKey)
    UserDefaults.standard.synchronize()  // Force immediate write
    print("[GameEngine] Save successful at \(Date()): \(resources.credits.formatted) credits, tick \(currentTick)")
} catch {
    print("[GameEngine] CRITICAL: Save failed - \(error)")
}
```

**Verification**:
After fix, console logs show:
- `[GameEngine] Save successful at [timestamp]: X credits, tick Y` on every save
- `[GameEngine] Loading save: X credits, tick Y` on app launch
- Saves now persist correctly when backgrounding/force-killing app

**Related Systems**:
- Campaign checkpoint saves already used synchronize() (`CampaignProgress.swift:223`)
- Auto-save every 30 ticks already implemented (`GameEngine.swift:547`)
- Background save triggers correct (`NavigationCoordinator.swift:515`)

**Closed**: 2026-02-07

---

### ISSUE-022: Continuous Upgrade Buttons Auto-Upgrade to Max
**Status**: ✅ Fixed
**Severity**: High
**Reported**: 2026-02-07
**Description**: When holding upgrade buttons on Source, Link, Sink, Firewall, and Defense Apps, the continuous upgrade feature doesn't stop when credits run out. Buttons continue upgrading until the unit reaches maximum level, even without sufficient credits.

**Impact**: Players unintentionally spend all credits and max out units they didn't want to fully upgrade. Breaks upgrade strategy and resource management.

**Reproduction**:
1. Have sufficient credits to upgrade a unit
2. Hold down any upgrade button (Source, Link, Sink, Firewall, or Defense App)
3. Observe: upgrades continue even after credits run out
4. Unit upgrades to maximum level

**Root Cause**: The `ContinuousUpgradeButton` component used a **static boolean** `isEnabled` that was captured at button creation time. Even though the timer checked `isEnabled`, it was checking the original captured value, not re-evaluating affordability. Timer also ran too fast (0.1s = 10 upgrades/sec) making it hard to control.

**Solution**: Redesigned `ContinuousUpgradeButton` with three key changes:

1. **Dynamic closure check**: Changed from static `isEnabled: Bool` to `canPerformAction: () -> Bool` closure that re-evaluates affordability every timer cycle
2. **LongPressGesture requirement**: Added 0.3 second hold requirement before continuous upgrades start (prevents accidental continuous upgrades)
3. **Slower upgrade rate**: Changed from 0.1s to 0.15s interval (~7 upgrades/sec instead of 10)

**Files Changed**:
- `Views/Components/NodeCardView.swift` (lines 7-57):
  - Redesigned `ContinuousUpgradeButton` with dynamic check and LongPressGesture
  - Updated all 6 Source/Link/Sink upgrade buttons to use closure-based check
- `Views/Components/FirewallCardView.swift` (line 155):
  - Updated Firewall upgrade button
- `Views/Components/DefenseApplicationView.swift` (line 272):
  - Updated Defense App upgrade button

**Technical Details**:
```swift
// BEFORE (Static check - broken):
ContinuousUpgradeButton(action: onUpgrade, isEnabled: credits >= cost) { ... }
// Timer checked static `isEnabled` value from creation time

// AFTER (Dynamic check - works correctly):
ContinuousUpgradeButton(action: onUpgrade, canPerformAction: { credits >= cost }) { ... }
// Timer calls closure to re-check affordability every cycle
```

**Behavior After Fix**:
- **Single tap**: One upgrade with haptic feedback
- **Hold 0.3s**: Continuous upgrading starts
- **Stops immediately when**:
  - Credits run out (checks every 0.15s)
  - Button is released
  - Unit reaches max level
- **Upgrade rate**: ~7 per second (controlled, not overwhelming)

**Total Buttons Fixed**: 8
- 6 in NodeCardView (3 per layout: iPhone and iPad)
- 1 in FirewallCardView
- 1 in DefenseApplicationView

**Closed**: 2026-02-07

---

### ENH-026: Streamlined Navigation & Campaign Checkpoint UX
**Priority**: High
**Status**: ✅ Implemented
**Reported**: 2026-02-07
**Description**: Two UX improvements for campaign flow: (1) Remove unnecessary Continue/New Game menu screen, (2) Fix mission resumption to show "Continue Mission" button when player has in-progress checkpoint.

**Problems Identified**:

**Problem 1 - Unnecessary Menu Screen**:
- After title screen, player goes to Main Menu with "Continue / New Game" buttons
- This menu serves no purpose - players always want to continue their game
- Adds extra tap to get to actual gameplay
- User feedback: "I dont think this menu is needed. the game should just play as you never want to start over"

**Problem 2 - Missing Continue Button**:
- When player exits gameplay (backgrounds app or force-closes), checkpoint auto-saves every 30 ticks
- Upon returning, player selects mission from Campaign Hub
- Button says "START MISSION" even though checkpoint exists
- Expected behavior: Show "CONTINUE MISSION" when checkpoint detected

**Solution**:

**Part 1 - Skip Main Menu Screen**:
- Title screen now goes directly to Campaign Hub (Home screen)
- Flow: Brand Intro → Title Screen → Campaign Hub → Gameplay
- Removed: Main Menu with Continue/New Game choice
- Benefit: One less tap, faster to gameplay

**Part 2 - Checkpoint Detection & Continue Buttons**:
- Added separate checkpoint detection for Normal mode and Insane mode
- `LevelDetailSheet` now has two checkpoint flags: `hasNormalCheckpoint` and `hasInsaneCheckpoint`
- Added separate resume callbacks: `onResumeNormal()` and `onResumeInsane()`
- Button logic updated:
  - **Normal mode with checkpoint**: Shows "CONTINUE MISSION" (green) + "RESTART MISSION" (gray)
  - **Normal mode without checkpoint**: Shows "START MISSION" or "REPLAY MISSION"
  - **Insane mode with checkpoint**: Shows "CONTINUE INSANE" (red) + "RESTART INSANE" (gray)
  - **Insane mode without checkpoint**: Shows "INSANE MODE" or "REPLAY INSANE"

**User Experience Improvements**:
- **Faster onboarding**: Title → Campaign Hub (skip menu)
- **Clear resumption**: "CONTINUE MISSION" explicitly tells player they can pick up where they left off
- **No confusion**: Separate buttons for normal/insane checkpoints
- **Restart option**: Players can still restart fresh if desired (secondary button)

**Technical Details**:
- Checkpoint auto-saves every 30 ticks during campaign gameplay
- Checkpoint saves when player explicitly clicks "Save & Exit"
- Checkpoint persists in `CampaignProgress.activeCheckpoint`
- Checkpoint validity: Within 24 hours, matches levelId and isInsane mode
- Checkpoint clearing: Cleared on "Restart Mission" or level completion/failure

**Files Modified**:
- `Engine/NavigationCoordinator.swift` (line 330-337):
  - Changed title screen to call `coordinator.showHome()` instead of `coordinator.showMainMenu()`
- `Views/HomeView.swift` (lines 50-81, 496-711):
  - Updated `LevelDetailSheet` parameters: added `hasNormalCheckpoint`, `hasInsaneCheckpoint`
  - Added `onResumeNormal` and `onResumeInsane` callbacks
  - Complete rewrite of button logic to show Continue/Restart/Start appropriately
  - Normal and Insane modes now have independent checkpoint detection

**Button States Summary**:
| Scenario | Button 1 | Button 2 | Button 3 |
|----------|----------|----------|----------|
| Normal checkpoint exists | "CONTINUE MISSION" (green) | "RESTART MISSION" (gray) | — |
| Normal no checkpoint, not completed | "START MISSION" (green) | — | — |
| Normal no checkpoint, completed | "REPLAY MISSION" (green) | "INSANE MODE" (red) | Modifiers info |
| Insane checkpoint exists | "CONTINUE MISSION" (green) | "RESTART MISSION" (gray) | "CONTINUE INSANE" (red) + "RESTART INSANE" (gray) + Modifiers |
| Insane no checkpoint, completed | "REPLAY MISSION" (green) | "REPLAY INSANE" (red) | Modifiers info |

**Build Status**: ✅ Build succeeded (3.15s)

**Logged**: 2026-02-07

---

### ENH-028: Ambient Data Center Soundscape for Gameplay
**Priority**: Medium
**Status**: 🟡 Open (Awaiting Audio Asset)
**Reported**: 2026-02-07
**Description**: Add subtle ambient background soundscape during gameplay levels to enhance the "lonely NOC operator at night" atmosphere. The ambient layer should play continuously during gameplay but stop when returning to menus.

**Design Requirements**:
- **Atmosphere**: Quiet data center control room at night
- **Sound Elements**:
  - Distant ventilation noise (HVAC hum, constant low frequency)
  - Muted electronic hum behind walls (transformer buzz, server whir)
  - Sporadic LED relay clicks (occasional, not rhythmic)
- **Mood**: Lonely, neutral, observational
- **Exclusions**: No voices, no alarms, no music
- **Audio Format**: .m4a file, stereo, 44.1kHz sample rate
- **Loop Duration**: 60-120 seconds for seamless looping

**Technical Implementation**:

**1. AudioManager.swift Additions**:
```swift
// Add new audio nodes for ambient layer
private let ambientPlayerNode = AVAudioPlayerNode()
private let ambientMixerNode = AVAudioMixerNode()
private var ambientBuffer: AVAudioPCMBuffer?
private var isAmbientPlaying = false

// In setupAudioEngine():
engine.attach(ambientPlayerNode)
engine.attach(ambientMixerNode)
engine.connect(ambientPlayerNode, to: ambientMixerNode, format: nil)
engine.connect(ambientMixerNode, to: engine.mainMixerNode, format: nil)
ambientMixerNode.outputVolume = 0.3  // Subtle, not overpowering

// New public methods:
func startAmbient() {
    guard !isAmbientPlaying else { return }
    if ambientBuffer == nil {
        guard let url = Bundle.main.url(forResource: "data_center_ambient", withExtension: "m4a") else {
            print("[AudioManager] ⚠️ Ambient audio file not found")
            return
        }
        do {
            let file = try AVAudioFile(forReading: url)
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: file.processingFormat,
                frameCapacity: AVAudioFrameCount(file.length)
            ) else { return }
            try file.read(into: buffer)
            ambientBuffer = buffer
        } catch {
            print("[AudioManager] ❌ Failed to load ambient: \(error)")
            return
        }
    }
    scheduleLoopingAmbient()
    ambientPlayerNode.play()
    isAmbientPlaying = true
    print("[AudioManager] ✅ Ambient soundscape started")
}

func stopAmbient() {
    guard isAmbientPlaying else { return }
    ambientPlayerNode.stop()
    isAmbientPlaying = false
    print("[AudioManager] Ambient soundscape stopped")
}

private func scheduleLoopingAmbient() {
    guard let buffer = ambientBuffer else { return }
    ambientPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops)
}
```

**2. AmbientAudioManager Facade**:
```swift
// Add to existing singleton
func startGameplayAmbient() {
    AudioManager.shared.startAmbient()
}

func stopGameplayAmbient() {
    AudioManager.shared.stopAmbient()
}
```

**3. NavigationCoordinator Integration**:
```swift
// In GameplayContainerView.setupLevel() (line 598):
private func setupLevel() {
    // Stop background music when gameplay starts
    AmbientAudioManager.shared.stopAmbient()

    // Start ambient soundscape for gameplay
    AmbientAudioManager.shared.startGameplayAmbient()

    print("[GameplayContainer] Background music stopped, ambient soundscape started")

    if let levelId = levelId {
        // ... existing code
    }
}

// In cleanupOnExit():
private func cleanupOnExit() {
    // Stop ambient soundscape when leaving gameplay
    AmbientAudioManager.shared.stopGameplayAmbient()

    // ... existing code
}
```

**Audio Sourcing Guidance**:

**Option 1: Royalty-Free Audio Libraries**
- **Freesound.org**: Community-uploaded sounds (Creative Commons licenses)
  - Search: "data center", "server room", "HVAC hum", "ventilation", "relay click"
  - Download individual elements and layer in audio editor
- **Zapsplat.com**: Free sound effects (attribution required)
- **Sonniss.com**: GameAudioGDC bundles (free, no attribution)

**Option 2: Create Custom Ambient Loop**
Using GarageBand (free on Mac):
1. Create new project, 60-120 second loop
2. Layer 3 tracks:
   - **Track 1 (Bass)**: Low-pass filtered brown noise (HVAC hum) - constant
   - **Track 2 (Mid)**: High-pass filtered white noise (electronic buzz) - constant, quieter
   - **Track 3 (Accent)**: Random relay clicks using "click" preset - sporadic timing
3. Mix: Bass 40%, Mid 25%, Accent 10%
4. Apply EQ: Roll off below 40Hz and above 8kHz
5. Export as .m4a, 44.1kHz stereo

**Option 3: AI Audio Generation**
- **ElevenLabs Sound Effects**: Text-to-sound AI (subscription)
  - Prompt: "Quiet data center at night, distant ventilation hum, muted electronic buzz, occasional relay clicks, no voices, ambient soundscape, loopable"
- **AudioCraft by Meta**: Free AI model (local generation)

**File Placement**:
- Add `data_center_ambient.m4a` to `GridWatchZero/Resources/` directory
- Add to Xcode project target membership

**Volume Levels**:
- Ambient: 0.3 (30%) - subtle background presence
- Music: 0.5 (50%) - menu screens
- SFX: 0.7 (70%) - UI interactions and alerts

**User Control**:
- Ambient volume controlled by existing "Sound Effects" toggle in Settings
- No separate control needed (ambient is part of the gameplay soundscape)

**Testing Checklist**:
- [ ] Ambient starts when gameplay level begins
- [ ] Ambient stops when returning to Campaign Hub
- [ ] Ambient loops seamlessly (no audible click/gap)
- [ ] Ambient volume doesn't overpower SFX or attack sounds
- [ ] Ambient respects user's sound effects toggle in Settings
- [ ] No memory leaks from continuous looping
- [ ] Works on both iPhone and iPad

**Related Enhancements**:
- ENH-017: Audio System Upgrade Using Apple Dev Tools (completed, provides AVAudioEngine foundation)
- ENH-025: War Signal Labs Brand Video Intro (completed, demonstrates audio lifecycle management)

**Files to Modify**:
- `Engine/AudioManager.swift` - Add ambient audio layer
- `Engine/NavigationCoordinator.swift` - Start/stop ambient at gameplay boundaries
- `GridWatchZero/Resources/data_center_ambient.m4a` - **NEW ASSET REQUIRED**

**Next Steps**:
1. Source or create `data_center_ambient.m4a` audio file (see guidance above)
2. Add audio file to Resources directory
3. Implement AudioManager ambient layer
4. Test seamless looping and volume levels
5. Verify lifecycle (start at gameplay, stop at hub)

---

### ISSUE-020: Zero-Credit Start on High-Threat Levels Blocks Defense Deployment
**Status**: ✅ Fixed
**Severity**: Critical
**Reported**: 2026-02-05
**Found During**: Sprint A playtest (Level 5+, confirmed impossible on Level 7)
**Description**: When a level starts at a high threat level (e.g., HAMMERED on Level 7), the player begins with 0 credits and cannot afford any defenses. Attacks drain credits faster than production, creating a death spiral. Level 7 math: HAMMERED = 18% attack chance/tick with 7.5× severity, T1 production = ~7.5 credits/tick, expected ~12 attacks in 67 ticks drain ~1,248 credits vs ~503 earned = net negative. The CRITICAL THREAT alarm also fires at tick 0, blocking dashboard interaction.

**Root Cause**: Threat level only goes UP (`updateThreatLevel` checks `newLevel > currentLevel`), so high starting threat is a permanent floor. Combined with 0 starting credits and attack damage exceeding income, defense deployment is mathematically impossible.

**Fix (Three-Part)**:

**Part A — Attack Grace Period**: Suppress new attack generation for the first N ticks per level, giving the player time to earn credits and purchase initial defenses.
| Level | Starting Threat | Grace Ticks | Time | Insane Mode |
|-------|----------------|-------------|------|-------------|
| 1-2 | ghost/blip | 0 | — | — |
| 3 | signal | 30 | 30s | 30 (min) |
| 4 | target | 60 | 1 min | 30 |
| 5 | targeted | 90 | 1.5 min | 45 |
| 6 | priority | 120 | 2 min | 60 |
| 7-20 | hammered+ | 180 | 3 min (cap) | 90 |

**Part B — Starter Firewall Kit**: Auto-deploy a free T1 Basic Firewall (100 HP, 20% damage reduction) on levels with `startingThreatLevel >= .target` (Levels 4+). Ensures the player has damage absorption when attacks begin after grace period ends.

**Part C — Critical Alarm Suppression**: Suppress CRITICAL THREAT alarm during the grace period so the player can interact with the dashboard to build their economy.

**Level 7 Verification (Normal mode with fix)**:
- Ticks 0-180: No attacks → 7.5 × 180 = ~1,350 credits earned
- Starter firewall absorbs initial damage when attacks begin at tick 181
- T1 defense app (¢5,000) reachable by ~tick 847 (14 min) — challenging but playable

**Files Changed**:
- `Models/CampaignLevel.swift` — Added `attackGracePeriod: Int?` to struct, computed var in `LevelConfiguration` (Insane mode halves, min 30)
- `Models/LevelDatabase.swift` — Added `attackGracePeriod` values to all 20 levels
- `Engine/GameEngine.swift` — Grace period suppression in `processThreats()`, starter firewall in `startCampaignLevel()`, alarm suppression in `shouldShowCriticalAlarm` and `checkCriticalAlarmReset()`

**Related Issues**: ISSUE-009 (starting credits zeroed), ISSUE-011 (defense costs rebalanced), ISSUE-018 (Level 8 balance spike)
**Closed**: 2026-02-05

---

## 🟠 Major (Significant Impact)

### ISSUE-021: Attack Indicator Text Overflow Causes Layout Shift in ThreatBarView
**Status**: ✅ Fixed
**Severity**: Major
**Reported**: 2026-02-05
**Found During**: Sprint A playtest (Level 5 — Campus Network)
**Description**: When an active attack occurs (especially COORDINATED_ASSAULT with a 19-character rawValue), the `AttackIndicator` inside `ThreatIndicatorView` renders the attack type name in a tight HStack. On iPhone screens, this text overflows horizontally, causing the ThreatBarView to expand vertically and push all content below it (ScrollView with network map, nodes, defense cards) downward. This creates a jarring, frustrating layout shift mid-gameplay that drops the screen down while playing.

**Impact**: During active attacks, the entire game view shifts downward as the ThreatBarView expands to accommodate overflowing text. When the attack ends, the view shifts back up. This is especially disruptive during intense gameplay moments when the player needs to make quick decisions about defense upgrades and intel reports.

**Root Cause**:
1. `ThreatBarView` (DashboardView.swift) had no fixed height constraint
2. `AttackIndicator` (ThreatIndicatorView.swift) rendered `attack.type.rawValue` (e.g., "COORDINATED_ASSAULT" — 19 chars) without line limits
3. The HStack in ThreatIndicatorView already contained THR label + Defense shield + RISK label + divider, leaving insufficient width for long attack names
4. Text overflow caused wrapping/vertical expansion, pushing the ThreatBarView height and shifting all content below

**Solution**:
1. Added `shortName` computed property to `AttackType` for compact display (e.g., "COORD_ASLT" instead of "COORDINATED_ASSAULT")
2. Added `.lineLimit(1)` to the attack name Text in AttackIndicator
3. Set fixed `.frame(height: 32)` with `.clipped()` on ThreatBarView to prevent height changes
4. Replaced floating AlertBannerView overlay with a fixed-height (60pt) reserved alert space between ThreatBarView and ScrollView
5. The reserved space shows a subtle `terminalDarkGray` background when empty, and alert banners populate within it when active

**Files Changed**:
- `Models/ThreatSystem.swift` — Added `shortName` property to `AttackType` enum
- `Views/Components/ThreatIndicatorView.swift` — Changed `attack.type.rawValue` → `attack.type.shortName`, added `.lineLimit(1)`
- `Views/DashboardView.swift` — Fixed ThreatBarView height, added reserved alert space, removed old floating overlay

**Related Issues**: ISSUE-020 (zero-credit defense gap on high-threat levels)
**Closed**: 2026-02-05

---

### ISSUE-008: Sound Plays When Phone Volume Is Off
**Status**: ✅ Fixed
**Severity**: Major
**Description**: Game sounds are still audible when the phone's volume is turned all the way down. Sounds should respect the device's ringer/media volume settings.
**Impact**: Disruptive to users in quiet environments; unexpected audio in meetings, etc.

**Root Cause**:
`AudioManager.swift:61` uses `AudioServicesPlaySystemSound()` which ignores the media volume setting.

**Solution**:
Added volume check before playing system sounds:
```swift
guard AVAudioSession.sharedInstance().outputVolume > 0 else { return }
AudioServicesPlaySystemSound(sound.systemSoundID)
```

**Files Changed**: `Engine/AudioManager.swift:60`
**Closed**: 2026-01-28

### ISSUE-009: Starting Credits Should Be Zero Per Level
**Status**: ✅ Fixed
**Severity**: Major
**Description**: Each campaign level should start with zero credits. Currently, players can beat levels too quickly due to starting credit balance.
**Impact**: Game balance issue - levels are too easy and don't provide intended challenge/progression.

**Root Cause**:
`LevelDatabase.swift` defined non-zero `startingCredits` for each level (500 to 400,000).

**Solution**:
Changed all `startingCredits` values to `0` in `LevelDatabase.swift` for all 7 levels.

**Files Changed**: `Models/LevelDatabase.swift` - All 7 level definitions
**Closed**: 2026-01-28

### ISSUE-010: Offline Progress Lost When Switching Apps
**Status**: ✅ Fixed
**Severity**: Major
**Description**: When user switches to a different app (swipes away) or turns screen off without manually saving, all progress since last save is lost. The game closes without auto-saving.
**Impact**: Frustrating user experience - players lose progress unexpectedly.

**Root Cause**:
No lifecycle handling - app didn't save when going to background.

**Solution**:
Added `scenePhase` observer to `RootNavigationView` in `NavigationCoordinator.swift`:
```swift
@Environment(\.scenePhase) private var scenePhase

.onChange(of: scenePhase) { oldPhase, newPhase in
    if newPhase == .background || newPhase == .inactive {
        gameEngine.pause()  // pause() calls saveGame()
        campaignState.save()
        coordinator.saveStoryState()
    }
}
```

**Files Changed**: `Engine/NavigationCoordinator.swift:282,480-486`
**Closed**: 2026-01-28

### ISSUE-011: App Defenses Don't Affect Game Success
**Status**: ✅ Fixed
**Severity**: Major
**Description**: Defense applications are too cheap and upgrade too quickly. They don't meaningfully impact game success. The intended mechanic is: better app defenses = more intel collected to send to team. Currently intel collection should NOT start until proper defenses are deployed.
**Impact**: Removes strategic depth from defense system; intel reports too easy to obtain.

**Solution**:

1. **Increased upgrade costs** (10x base, steeper scaling):
```swift
var upgradeCost: Double {
    250.0 * Double(tier.tierNumber) * pow(1.25, Double(level))
}
```
New T1 costs: L1=295, L5=763, L10=2,328 credits (was 30/57/130)

2. **Gated intel collection** - Must have at least 1 defense app deployed:
```swift
// In collectMalusFootprint():
guard defenseStack.deployedCount >= 1 else { return }
```

3. **Gated passive intel generation** - Automation bonus also requires deployed apps:
```swift
if defenseStack.totalAutomation >= 0.75 && defenseStack.deployedCount >= 1 {
    // generate passive intel
}
```

**Files Changed**:
- `Models/DefenseApplication.swift:470-473` - Upgrade cost formula
- `Engine/GameEngine.swift:1348-1351` - Intel collection gate
- `Engine/GameEngine.swift:467-470` - Passive intel gate

**Closed**: 2026-01-28

### ISSUE-001: Save Migration Not Implemented
**Status**: ✅ Closed
**Severity**: Major
**Description**: When GameState structure changes, old saves become incompatible. Currently using versioned save key (`v4`) as workaround.
**Impact**: Players lose progress on updates
**Solution**: Implemented `SaveMigrationManager` with version-aware loading. Defines legacy `GameStateV1-V4` structs and migration paths to current version. Automatically detects old saves, migrates them, and cleans up old keys.
**Files**: `Engine/SaveMigration.swift` (new), `Engine/GameEngine.swift`
**Closed**: 2026-01-20

---

### ISSUE-027: Rusty Incorrectly Labeled as Team Lead
**Priority**: Minor
**Status**: ✅ Fixed
**Reported**: 2026-02-07
**Description**: In StorySystem.swift, Rusty's role was incorrectly set to "Team Lead / Handler". According to the game's lore and character design, **Ronin** is the Team Lead, while **Rusty** is the Handler/Engineer who coordinates operations from behind a desk.

**Character Roles (Correct)**:
- **Rusty**: Handler / Engineer (former field operator, now coordinates from desk)
- **Ronin**: Team Lead / Veteran Hunter (actual field leader)
- **Tish**: Hacker / Intel (network architect, systems specialist)
- **FL3X**: Field Operative (close-quarters specialist)
- **Tee**: Hardware Specialist (communications and street hacker)

**Impact**: Minor lore inconsistency. Players viewing character profiles or story dialogue would see incorrect role for Rusty.

**Root Cause**: The `role` property in `StorySystem.swift` enum had Rusty's role hardcoded as "Team Lead / Handler" instead of "Handler / Engineer". Ronin's role was also missing the "Team Lead" designation.

**Solution**:
Updated the `role` computed property in `StoryCharacter` enum:
```swift
// BEFORE:
case .rusty: return "Team Lead / Handler"
case .ronin: return "Veteran Hunter"

// AFTER:
case .rusty: return "Handler / Engineer"
case .ronin: return "Team Lead / Veteran Hunter"
```

**Verification**:
Checked all Swift files for "Team Lead" references:
- ✅ `StorySystem.swift`: Ronin correctly labeled as "Team Lead / Veteran Hunter"
- ✅ `HomeView.swift`: Ronin's TeamMember role correctly shows "Team Leader"
- ✅ `CharacterDossier.swift`: Rusty's classification already correct as "HANDLER / FIELD COORDINATOR"

**Files Modified**:
- `Models/StorySystem.swift` (lines 46, 52): Updated Rusty and Ronin roles

**Build Status**: ✅ Build succeeded (2.74s)

**Logged**: 2026-02-07

---

## 🟡 Minor (Polish/UX)

### ISSUE-012: Level Dialog Goal Accuracy
**Status**: ✅ Fixed
**Severity**: Minor
**Description**: Dialog text shows incorrect goal requirements. Example: Level 1 dialog says it takes 2,000 credits to complete, but actual requirement differs per CLAUDE.md (Level 1 = 50K credits).
**Impact**: Confusing for players; undermines trust in game instructions.

**Solution**:
Updated all level intro dialogs in `StorySystem.swift` to match actual requirements from `LevelDatabase.swift`:
- Level 1: ₵2K → ₵50K
- Level 2: ₵10K → ₵100K, removed "survive 8 attacks" (not a requirement)
- Level 3: ₵50K → ₵500K
- Level 4: ₵100K → ₵1M
- Level 5: ₵300K → ₵5M
- Level 6: ₵600K → ₵10M
- Level 7: ₵1.5M → ₵25M

**Files Changed**: `Models/StorySystem.swift:172,203,249,295,341,387,432`
**Closed**: 2026-01-28

### ISSUE-013: Achievement Rewards - Are They Instant?
**Status**: ✅ Closed (Verified - Working as Intended)
**Severity**: Minor
**Description**: Unclear whether achievement rewards are granted instantly upon completion or require manual claim.
**Impact**: UX confusion; need to verify and document expected behavior.

**Root Cause Analysis**:
Rewards ARE instant. No manual claim required.

`GameEngine.swift:714-724`:
```swift
private func checkMilestones() {
    let completable = MilestoneDatabase.checkProgress(state: milestoneState)
    for milestone in completable {
        milestoneState.complete(milestone.id)
        emitEvent(.milestoneCompleted(milestone.title))
        AudioManager.shared.playSound(.milestone)
        applyMilestoneReward(milestone.reward)  // ← Instant application
    }
}
```

`applyMilestoneReward()` (line 727-745) immediately:
- Adds credits: `resources.addCredits(amount)`
- Unlocks lore: `unlockLoreFragment(fragmentId)`
- Unlocks units: `unlockState.unlock(unitId)`

**Verdict**: Working as intended. Consider adding UI feedback showing reward granted.
**Files**: `Engine/GameEngine.swift:714-745`
**Closed**: 2026-01-28

### ISSUE-014: Total Playtime Not Displaying
**Status**: ✅ Fixed
**Severity**: Minor
**Description**: Total playtime statistic is not showing in the stats/lifetime stats view.
**Impact**: Players cannot see how long they've played the game.

**Solution**:
Added `lifetimeStats.totalPlaytimeTicks += stats.ticksToComplete` to `recordCompletion()` in `CampaignProgress.swift:105`.

**Files Changed**: `Models/CampaignProgress.swift:105`
**Closed**: 2026-01-28

### ISSUE-015: Tier Requirements Display Unclear
**Status**: ✅ Fixed
**Severity**: Minor
**Description**: Tier gate requirements only shown AFTER user attempts to unlock. Display is reactive, not proactive. Players don't see they need to max current tier level before next tier unlocks.
**Impact**: Confusing UX; players don't understand unlock requirements until they fail.

**Solution**:
Updated `UnitShopView.swift` to pass `tierGateReason` from GameEngine to `UnitRowView`. Now tier gate requirements are shown proactively for locked units with a warning icon and red text explaining why the tier is locked (e.g., "T1 Source must be at max level (10)").

**Files Changed**:
- `Views/UnitShopView.swift:134-146` - Pass tierGateReason to UnitRowView
- `Views/UnitShopView.swift:264` - Added tierGateReason parameter
- `Views/UnitShopView.swift:355-363` - Display tier gate reason proactively

**Closed**: 2026-01-28

### ISSUE-016: Lifetime Stats Analysis
**Status**: ✅ Fixed
**Severity**: Minor
**Description**: Review and analyze lifetime stats implementation. Ensure all relevant stats are being tracked and displayed accurately.
**Impact**: Analytics and player engagement features.

**Solution**:
1. Added `totalIntelReportsSent` and `highestDefensePoints` fields to `LifetimeStats` struct
2. Added `intelReportsSent` field to `LevelCompletionStats`
3. Updated `recordCompletion()` to track:
   - `totalPlaytimeTicks` (fixed in ISSUE-014)
   - `totalIntelReportsSent` - accumulates from each completed level
   - `highestDefensePoints` - tracks personal best

**Files Changed**:
- `Models/CampaignProgress.swift:174-182` - Added new fields to LifetimeStats
- `Models/CampaignProgress.swift:110-117` - Updated recordCompletion to track new stats
- `Models/CampaignLevel.swift:215` - Added intelReportsSent to LevelCompletionStats
- `Engine/GameEngine.swift:1633` - Capture intel reports in completion stats
- `Engine/NavigationCoordinator.swift:1172` - Updated preview with new field

**Closed**: 2026-01-28

### ISSUE-002: Connection Line Animation Jank
**Status**: ✅ Closed
**Severity**: Minor
**Description**: The animated flow particles in ConnectionLineView don't loop smoothly. Animation appears to stutter at loop point.
**Impact**: Visual polish only
**Solution**: Refactored to use single phase variable with `truncatingRemainder` for smooth looping. Particles now calculate position from shared animation phase with offsets.
**Files**: `Views/Components/ConnectionLineView.swift`
**Closed**: 2026-01-20

### ISSUE-003: Malus Banner Timer Leak
**Status**: ✅ Closed
**Severity**: Minor
**Description**: The typewriter effect in MalusBanner creates scheduled timers that aren't properly invalidated when view disappears.
**Impact**: Potential memory leak, console warnings
**Solution**: Store timer reference and invalidate in onDisappear
**Files**: `Views/Components/AlertBannerView.swift`
**Closed**: 2026-01-20

### ISSUE-004: Link Stats Reset on Tick
**Status**: ✅ Closed
**Severity**: Minor
**Description**: In GameEngine.processTick(), a new TransportLink is created to update stats, which resets the link's ID. Should mutate in place.
**Impact**: Potential animation issues if Link uses ID for identity
**Solution**: Code already mutates `link.lastTickTransferred` and `link.lastTickDropped` directly (lines 355-356). The `modifiedLink` is only used for transfer calculation, not reassigned.
**Files**: `Engine/GameEngine.swift`
**Closed**: 2026-01-20

### ISSUE-005: Efficiency Shows 100% at Game Start
**Status**: ✅ Closed
**Severity**: Minor
**Description**: When totalGenerated is 0, efficiency calculation returns 1.0 (100%). Should show "--" or "N/A" instead.
**Impact**: Misleading initial state
**Solution**: Return nil or special value when no data generated yet
**Files**: `Views/DashboardView.swift`
**Closed**: 2026-01-20

---

## 🟢 Enhancement Requests

### ENH-023: Increase Profile Picture Sizes for Better Visibility
**Priority**: Medium
**Status**: ✅ Implemented
**Reported**: 2026-02-07
**Description**: Profile pictures for team members and character dossiers were too small, making character art difficult to see clearly. Players should be able to easily identify and appreciate character portraits.

**Changes Made**:

**1. Dossier Grid Cards** (Collection View)
- **Before**: 120px height
- **After**: 180px height (+50%)
- Fallback icon: 40pt → 60pt
- **Impact**: Character portraits now clearly visible in grid view

**2. Dossier Detail View** (Full Character Screen)
- **Before**: iPhone 150×150px, iPad 200×200px
- **After**: iPhone 220×220px, iPad 300×300px (+47-50%)
- Border width: 2pt → 3pt
- Shadow radius: 10 → 15
- Corner radius: 12 → 16
- Fallback icon: 50pt/60pt → 80pt/100pt
- **Impact**: Character showcase is now prominent and cinematic

**3. Story Dialogue View** (During Story Moments)
- **Before**: iPhone 80×80px, iPad 160×160px
- **After**: iPhone 120×120px, iPad 220×220px (+37-50%)
- Fallback icon: 30pt/60pt → 50pt/90pt
- **Impact**: Character presence much stronger during dialogue scenes

**Files Changed**:
- `Views/DossierView.swift` (lines 169-186, 304-329):
  - Increased portrait heights in `DossierCardView`
  - Increased portrait sizes in `DossierDetailView.headerSection`
  - Enhanced borders and shadows for better visual impact
- `Views/StoryDialogueView.swift` (lines 31-37, 125-130):
  - Increased `portraitSize` and `portraitInnerSize` properties
  - Increased fallback icon size

**Benefits**:
- Character art is now showcase-worthy and easily identifiable
- Profile pictures are the visual focal point (as intended)
- Better matches the cinematic feel of story moments
- Improved visual hierarchy in dossier collection
- All sizes scale appropriately between iPhone and iPad

**Closed**: 2026-02-07

---

### ENH-008: Cyber Defense Certificates Per Level
**Priority**: Medium
**Status**: ✅ Implemented
**Description**: Award Cyber Defense certificates after completing each campaign level. These certifications should be displayed on the player's account/profile.

**Implementation**:

#### Certificate System Design
- 20 unique certificates (one per campaign level)
- 6 certificate tiers matching story arcs:
  - **Foundational** (Levels 1-4): CDO series - Basic cyber defense certifications
  - **Practitioner** (Levels 5-7): CSP series - Enterprise-level certifications
  - **Professional** (Levels 8-10): CEX series - Offensive operations certifications
  - **Expert** (Levels 11-14): MSE series - Master-level certifications
  - **Master** (Levels 15-17): GM series - Grandmaster certifications
  - **Architect** (Levels 18-20): SA series - Supreme Architect certifications

#### Certificate Naming Convention
| Level | Abbreviation | Name | Issuing Body |
|-------|--------------|------|--------------|
| 1 | CDO-NET | Network Fundamentals | Helix Alliance Certification Board |
| 2 | CDO-SEC | Security Essentials | Helix Alliance Certification Board |
| 3 | CDO-TI | Threat Intelligence | Helix Alliance Certification Board |
| 4 | CDO-IR | Incident Response | Helix Alliance Certification Board |
| 5 | CSP-DA | Defense Architecture | Global Cyber Defense Institute |
| 6 | CSP-EM | Enterprise Management | Global Cyber Defense Institute |
| 7 | CSP-CI | Critical Infrastructure | Global Cyber Defense Institute |
| 8 | CEX-OO | Offensive Operations | Helix Alliance Advanced Programs |
| 9 | CEX-IE | Intelligence Extraction | Helix Alliance Advanced Programs |
| 10 | CEX-ATN | AI Threat Neutralization | Helix Alliance Advanced Programs |
| 11 | MSE-ID | Infiltration Defense | Prometheus Research Consortium |
| 12 | MSE-TO | Temporal Operations | Prometheus Research Consortium |
| 13 | MSE-AL | Adversarial Logic | Prometheus Research Consortium |
| 14 | MSE-DA | Deep Analysis | Prometheus Research Consortium |
| 15 | GM-CES | Consciousness Evolution Support | Architect's Council |
| 16 | GM-MD | Multidimensional Defense | Architect's Council |
| 17 | GM-RC | Reality Convergence | Architect's Council |
| 18 | SA-FCP | First Contact Protocol | The Architect |
| 19 | SA-CI | Consciousness Integration | The Architect |
| 20 | SA-UH | Universal Harmony | The Unified Consciousness |

#### Features
- Certificates awarded automatically on first normal-mode level completion
- Each certificate tracks: credit hours earned, issue date
- Tier-themed colors matching game visual system
- Certificate popup on level completion showing newly earned cert
- Full certificate gallery in Player Profile
- Progress tracking: total certs earned, total credit hours, completed tiers

#### UI Components
- **CertificateSummaryBadge**: Compact display showing count and highest tier
- **CertificateCardView**: Individual certificate display with tier styling
- **CertificateGridView**: Grid of all certificates organized by tier
- **CertificateDetailView**: Full certificate details modal
- **CertificateUnlockPopupView**: Celebration popup on certificate earned
- **CertificatesFullView**: Full-screen certificate gallery sheet

#### Integration Points
- NavigationCoordinator: Awards certificate in `completeLevel()` for normal mode
- LevelCompleteView: Shows earned certificate after level stats
- PlayerProfileView: Certificates section with summary and "View All" button

**Files Added**:
- `Models/CertificateSystem.swift` - Certificate model, tiers, database, state, manager
- `Views/CertificateView.swift` - All certificate UI components

**Files Modified**:
- `Engine/NavigationCoordinator.swift` - Certificate award on level completion
- `Views/PlayerProfileView.swift` - Certificates section in profile

**Closed**: 2026-01-31

### ISSUE-018: Level 8 Balance Spike (TestFlight Feedback)
**Status**: ✅ Resolved (Sprint A)
**Severity**: Major
**Reported**: 2026-02-04
**Resolved**: 2026-02-05
**Description**: TestFlight testing revealed significant balance issues with Level 8:
- Levels 1-4 felt easy
- Level 5 felt hard; multiple failures
- Levels 6-7 felt easier than Level 5 (started with credits: 1000/2000)
- Level 8 felt impossible to earn enough credits to defend the network
- Levels 9-20 not tested due to inability to progress

**Level 8 Configuration (from LevelDatabase)**:
- `requiredCredits: 100_000_000` (4x jump from L7's 25M)
- `requiredDefensePoints: 3000`
- `requiredReportsSent: 400`
- `requiredAttacksSurvived: 60`
- `startingThreatLevel: .ascended`
- `minimumAttackChance: 3.0`
- `startingCredits: 0`

**Analysis**:
Level 8 represents a major difficulty spike after Levels 6-7 which provide starting credits. The jump from Level 7 (25M credits, T6) to Level 8 (100M credits, T7) with zero starting credits and high defense/report requirements creates a stall.

**User Feedback** (2026-02-04):
- 5M starting credits is too much (trivializes early game)
- Level should be challenging but not unfair
- Suggested: 5,000 starting credits as buffer

**Proposed Fix**:
- Change Level 8 `startingCredits: 0` → `startingCredits: 5000`
- This provides survival buffer without trivializing progression
- Levels 6-7 have 1000/2000 starting credits for reference

**Impact**: Players cannot progress past Level 8, blocking 60% of campaign content.

**See Also**: GAMEPLAY.md for comprehensive balance tables

---

### ISSUE-019: GitHub Pages URLs Point to Old Repository
**Status**: ✅ Verified Working
**Severity**: Minor
**Reported**: 2026-02-04
**Updated**: 2026-02-04
**Description**: App Store Connect and PROJECT_STATUS.md reference GitHub Pages URLs pointing to the old repository (ProjectPlaguev1) instead of the authoritative GridWatchZero repo.

**Current URLs (Already Correct in README.md)**:
- Privacy: `https://remeadows.github.io/GridWatchZero/privacy-policy.html`
- Support: `https://remeadows.github.io/GridWatchZero/support.html`

**Status Check**:
The README.md already references the correct GridWatchZero URLs. GitHub Pages is configured and serving from the `docs/` folder. The pages are live and accessible.

**Verification**:
1. ✅ README.md lines 176-177 show correct GridWatchZero URLs
2. ✅ `docs/` folder exists with privacy-policy.html and support.html
3. ✅ GitHub Pages enabled on GridWatchZero repository

**User Action Required**:
- Verify App Store Connect URLs match the GridWatchZero pages
- If still pointing to ProjectPlaguev1 in App Store Connect, update manually:
  - Privacy Policy URL: `https://remeadows.github.io/GridWatchZero/privacy-policy.html`
  - Support URL: `https://remeadows.github.io/GridWatchZero/support.html`

**Closed**: 2026-02-04

---

### ISSUE-021: "Send ALL" Batch Upload Shows Wrong Credit Amount
**Status**: ✅ Fixed
**Severity**: Major
**Reported**: 2026-02-05
**Description**: After completing a batch intel upload via "Send ALL", the alert banner displays the player's lifetime total intel credits (~963K) instead of the credits earned in that specific batch. Player sees "+₵963.1K" and believes they were promised that amount, but actual credits deposited are much smaller (batch-specific).
**Impact**: Confusing UX — players think they received zero credits because the displayed amount doesn't match their credit change.

**Root Cause**: In `GameEngine.swift` line 403, the batch complete event passed `malusIntel.totalIntelCredits` (lifetime accumulated total) instead of the credits earned during the batch upload.

**Fix**:
- Added `batchCreditsEarned` accumulator variable in the batch processing loop
- Accumulate `result.creditsEarned` for each report successfully sent in the batch
- Pass `batchCreditsEarned` to the `.batchUploadComplete` event instead of lifetime total
- Credits WERE being deposited correctly — only the display was wrong

**Files Changed**:
- `Engine/GameEngine.swift` — Batch credit accumulator, event payload fix

**Closed**: 2026-02-05

---

### ISSUE-022: Intel Milestones Cap at 25 Reports — No Goals for Endgame
**Status**: ✅ Fixed
**Severity**: Major
**Reported**: 2026-02-05
**Description**: Intel milestones have only 7 levels (capping at 25 reports). After claiming all 7, the UI permanently shows "ALL MILESTONES COMPLETE" with no further goals. Campaign levels require up to 10,000 reports (Level 20), leaving a massive 9,975-report gap with zero progression feedback.
**Impact**: Players lose motivation and progression signals for the majority of the campaign. At ~430 credits per report, the only incentive is grinding credits with no milestone rewards.

**Fix**: Added 9 new endgame milestones aligned with campaign progression:
| Reports | Name | Credit Reward | Permanent Bonus |
|---------|------|---------------|-----------------|
| 50 | Signal Analyst | 750K | +5% credit protection |
| 100 | Network Sentinel | 1.5M | +10% intel collection |
| 200 | Cipher Breaker | 3M | +5% damage reduction |
| 400 | Grid Watcher | 7.5M | +10% pattern ID speed |
| 800 | Shadow Operator | 20M | 10% fewer attacks |
| 1,500 | Phantom Protocol | 50M | +15% intel collection |
| 3,000 | Architect's Eye | 150M | +10% damage reduction |
| 5,000 | Omega Analyst | 500M | +10% credit protection |
| 10,000 | Grid Watch Zero | 2B | +20% intel collection |

No save migration needed — `claimedMilestones` is `Set<Int>`, new raw values simply absent from existing saves. Total milestones: 16 (7 original + 9 new). New `IntelBonus.creditProtection` bonus wired into attack damage calculation.

**Files Changed**:
- `Models/DefenseApplication.swift` — 9 new IntelMilestone cases, all switch arms, creditProtection bonus
- `Engine/GameEngine.swift` — Credit protection wiring in attack damage calc

**Closed**: 2026-02-05

---

### ENH-017: Audio System Upgrade Using Apple Dev Tools
**Priority**: High
**Status**: ✅ Implemented
**Closed**: 2026-02-05
**Description**: Upgrade audio system using better Apple development tools available in Xcode.
**Implementation**:
- Migrated from AVAudioPlayer to AVAudioEngine with unified node graph (SFX + music buses)
- 8 AVAudioPlayerNode pool for concurrent SFX playback
- Core Haptics (CHHapticEngine) with 8 custom AHAP pattern files, UIKit fallback for Simulator
- Automatic music ducking during attacks (duck on attackIncoming, restore on attackEnd)
- Fixed bug: `attack_end.m4a` was defined but never played — now triggers on attack end
- Zero call-site changes: all 27 existing call sites preserved via AmbientAudioManager facade
**Files Changed**: `Engine/AudioManager.swift` (rewrite), `Engine/GameEngine.swift` (+1 line), 8 new `.ahap` files in `Resources/Haptics/`

---

### ENH-029: Full-Width Banner Portraits for All Character Views
**Priority**: Medium
**Status**: ✅ Implemented
**Reported**: 2026-02-08
**Closed**: 2026-02-08
**Description**: Converted all character portrait layouts from small square/circle thumbnails to full-width rectangular banners stretching edge-to-edge. Character name, role, and classification info repositioned below the portrait image. Applied consistently across StoryDialogueView, DossierDetailView, and TeamMemberDetailView.

**Changes Implemented**:

**1. StoryDialogueView (Level Briefings/Story Moments)**:
- **Before**: Small square portrait (120×120 iPhone / 220×220 iPad) beside name in HStack
- **After**: Full-width banner (360px iPhone / 420px iPad) with name/role below in VStack
- Uses `.aspectRatio(contentMode: .fill)` + `.frame(alignment: .top)` + `.clipped()`
- Bottom edge glow line in character's theme color
- Reduced dialogue min height (100px iPhone / 160px iPad) for more portrait space
- Removed GeometryReader to fix hit-testing bug with parent overlay gestures

**2. DossierDetailView (Character Dossier Showcase)**:
- **Before**: Centered fixed-width portrait (280×240 iPhone / 400×320 iPad)
- **After**: Full-width banner (360px iPhone / 420px iPad) with name/classification left-aligned below
- Faction badge positioned on right side of name row
- Visual description text below name section
- Same bottom edge glow pattern as StoryDialogueView

**3. TeamMemberDetailView (Team Roster in Campaign Hub)**:
- **Before**: 140px circular portrait with glow ring, name centered above
- **After**: Full-width rectangular banner (360px iPhone / 420px iPad), close button overlaid top-right
- Name/role left-aligned below banner with divider
- Bio in scrollable area below
- Consistent visual language with story and dossier views

**4. DossierCardView (Dossier Grid Thumbnails)**:
- Kept default `.center` alignment (not `.top`) for small grid cards
- Center alignment works better for varied character compositions at thumbnail size
- 180px card height maintained from ENH-023

**Bug Fix**: Removed `GeometryReader` from StoryDialogueView portrait — was interfering with tap gesture hit-testing in parent `StoryOverlayModifier`, causing buttons on the dashboard to stop working.

**Files Changed**:
- `Views/StoryDialogueView.swift`: Full rewrite of `characterHeader` and `characterPortrait` computed properties
- `Views/DossierView.swift`: Rewrote `DossierDetailView.headerSection`, adjusted `DossierCardView` alignment
- `Views/HomeView.swift`: Complete rewrite of `TeamMemberDetailView` from circular to banner layout

**Build Status**: ✅ Build succeeded

---

### ISSUE-034: FL3X Wrong Image Asset & Tee Watermark
**Status**: ✅ RESOLVED
**Severity**: Minor
**Reported**: 2026-02-08
**Resolved**: 2026-02-08
**Description**: Two character image issues discovered during portrait banner work:

**1. FL3X Using Wrong Image**:
- `StorySystem.swift` referenced `"FL3X"` (tight face close-up from original asset)
- Should use `"FL3X_v1"` (full cyberpunk character portrait)
- **Fix**: Changed `imageName` from `"FL3X"` to `"FL3X_v1"` in `StoryCharacter.imageName` computed property
- Propagates to all views using `character.imageName` (dossiers, story dialogues, team roster)

**2. Tee Image Watermark**:
- `Tee_v1.png` contained "Sora @rustyrtr" watermark in top 8% of image
- **Fix**: Cropped top 8% of image (468×712 → 468×656) to remove watermark
- Updated both `Assets.xcassets/Tee_v1.imageset/Tee_v1.png` and `archive/AppPhoto/Tee_v1.png`

**Files Changed**:
- `Models/StorySystem.swift`: FL3X imageName reference
- `Assets.xcassets/Tee_v1.imageset/Tee_v1.png`: Cropped watermark
- `archive/AppPhoto/Tee_v1.png`: Cropped watermark (archive copy)

**Build Status**: ✅ Build succeeded

---

### ISSUE-035: Brand Intro Video — UIView-Based Full-Screen Fix
**Status**: ✅ RESOLVED
**Severity**: Medium
**Reported**: 2026-02-08
**Resolved**: 2026-02-08
**Description**: Follow-up to ISSUE-032. After video file change to `WarSignalLabs_9_16_5.mp4`, video still showed margins on some devices. Previous `UIViewControllerRepresentable` approach replaced with `UIViewRepresentable` using direct `AVPlayerLayer` control via `UIScreen.main.bounds`.

**Root Cause**: SwiftUI layout passes don't always provide final view bounds to `UIViewControllerRepresentable` before the player layer is created. Using `UIScreen.main.bounds` directly bypasses this timing issue.

**Solution**:
- Created `VideoPlayerUIView: UIView` with `AVPlayerLayer` using `UIScreen.main.bounds`
- `layoutSubviews()` override forces layer frame to screen bounds on every layout pass
- Video muted (storm audio plays separately via `AVAudioPlayer`)
- Wrapped in `VideoPlayerView: UIViewRepresentable` for SwiftUI integration
- Storm audio (`storm.wav`) plays at 0.3 volume during brand intro, fades out on completion

**Files Changed**:
- `Views/BrandIntroView.swift`: Replaced `UIViewControllerRepresentable` with `UIViewRepresentable` + `VideoPlayerUIView`

**Build Status**: ✅ Build succeeded

---

## 🔧 Open TODOs

### TODO-002: E2E Testing - Test Coverage Gaps & Known Issues
**Priority**: High
**Status**: ✅ COMPLETE - Test Infrastructure Expanded (205 passing tests)
**Reported**: 2026-02-06
**Updated**: 2026-02-06 (Defense System Expansion)
**Description**: Comprehensive E2E testing revealed complete lack of automated test coverage and one preview crash issue. Test infrastructure successfully created and expanded with 205 working tests covering CRITICAL, HIGH, and MEDIUM priority systems including save migration, cloud sync conflict handling, and defense category bonuses.

#### Known Issues from E2E Testing

**ISSUE-023: SettingsView Preview Crash**
- **Status**: ✅ Fixed
- **Severity**: Minor
- **Closed**: 2026-02-06
- **Location**: `GridWatchZero/Views/SettingsView.swift:352`
- **Type**: Preview Runtime Error
- **Description**: SettingsView preview crashed because it required `@EnvironmentObject` dependencies (CloudSaveManager, CampaignState) that weren't provided in the preview
- **Impact**: Medium - Only affected development preview, not production app
- **Solution**: Added required environment objects to preview:
```swift
#Preview {
    SettingsView()
        .environmentObject(CloudSaveManager.shared)
        .environmentObject(CampaignState())
}
```
- **Files Changed**: `Views/SettingsView.swift`

#### Test Coverage Gaps (0% Coverage)

**1. GameEngine Tests** (PRIORITY: CRITICAL)
Missing unit tests for:
- [x] Tick cycle execution ✅ (TickCycleTests.swift)
- [x] Resource production calculations ✅ (TickCycleTests.swift)
- [x] Unit purchase validation ✅ (GameEngineSmokeTests.swift)
- [x] Unit upgrade logic ✅ (GameEngineSmokeTests.swift, UnitSystemTests.swift)
- [x] Save/load functionality ✅ (SaveSystemTests.swift)
- [x] Prestige system calculations ✅ (ResourceAndCampaignTests.swift, SaveSystemTests.swift)
- [x] Offline progress calculations ✅ (SaveSystemTests.swift)
- [x] Attack damage calculations ✅ (AttackSystemTests.swift)
- [x] Threat level progression ✅ (AttackSystemTests.swift)

**2. Defense System Tests** (PRIORITY: HIGH)
Missing unit tests for:
- [x] DefenseStack calculations ✅ (DefenseSystemTests.swift, AttackSystemTests.swift)
- [x] Damage reduction formulas ✅ (AttackSystemTests.swift)
- [x] Risk reduction calculations ✅ (AttackSystemTests.swift)
- [x] Security application bonuses ✅ (DefenseSystemTests.swift - category rates, intel/risk/secondary bonuses)
- [x] Tier-based defense points ✅ (DefenseSystemTests.swift - T1-T6 tables, T7+ exponential scaling)
- [x] Category-specific rate tables ✅ (DefenseSystemTests.swift - all 6 categories validated)
- [x] MalusIntelligence footprint collection ✅ (DefenseSystemTests.swift)
- [ ] Pattern identification

**3. Resource Calculations Tests** (PRIORITY: HIGH)
Missing unit tests for:
- [x] Source node production rates ✅ (UnitSystemTests.swift, TickCycleTests.swift)
- [x] Link bandwidth limits ✅ (UnitSystemTests.swift, TickCycleTests.swift)
- [x] Sink credit conversion ✅ (UnitSystemTests.swift, TickCycleTests.swift)
- [x] Packet loss on overflow ✅ (TickCycleTests.swift)
- [x] Prestige multiplier effects ✅ (TickCycleTests.swift)
- [ ] Certificate maturity bonuses
- [ ] Resource formatting (K, M, B, T notation)

**4. Campaign Progression Tests** (PRIORITY: MEDIUM)
Missing unit tests for:
- [x] Level unlock logic ✅ (CampaignProgressionTests.swift)
- [x] Victory condition checking ✅ (CampaignProgressionTests.swift)
- [x] Checkpoint save/restore ✅ (CampaignProgressionTests.swift)
- [x] Level configuration application ✅ (CampaignProgressionTests.swift)
- [x] Stats tracking ✅ (CampaignProgressionTests.swift - LifetimeStats, LevelCompletionStats)
- [x] Insane mode logic ✅ (CampaignProgressionTests.swift)
- [ ] Certificate awarding
- [ ] Dossier unlocking
- [ ] Failure condition checking

**5. Save System Tests** (PRIORITY: HIGH)
Missing unit tests for:
- [x] Save data encoding/decoding ✅ (SaveSystemTests.swift)
- [x] Save migration (v5 → v6) ✅ (SaveSystemTests.swift - version comparison, key generation, detection)
- [x] Brand migration (ProjectPlague → GridWatchZero) ✅ (SaveSystemTests.swift - flag tracking, old data detection)
- [x] iCloud sync upload/download ✅ (SaveSystemTests.swift - CloudSaveStatus, SyncableProgress)
- [x] Conflict resolution ✅ (SaveSystemTests.swift - conflict status, date preservation, MigrationResult)
- [ ] Data corruption handling
- [ ] Auto-save triggers

**6. Unit Factory Tests** (PRIORITY: MEDIUM)
Missing unit tests for:
- [x] Unit catalog generation ✅ (UnitSystemTests.swift)
- [x] Tier-based cost scaling ✅ (UnitSystemTests.swift)
- [x] Tier-based production scaling ✅ (UnitSystemTests.swift)
- [ ] Unit unlock requirements
- [x] Max level enforcement ✅ (GameEngineSmokeTests.swift)
- [x] Unit creation validation ✅ (UnitSystemTests.swift)

**7. Certificate System Tests** (PRIORITY: MEDIUM)
- [x] Certificate earning (Normal/Insane) ✅ (CertificateSystemTests.swift)
- [x] Maturity timer calculations (40h/60h) ✅ (CertificateSystemTests.swift)
- [x] Per-cert bonus calculations ✅ (CertificateSystemTests.swift)
- [x] Total multiplier aggregation ✅ (CertificateSystemTests.swift)
- [x] Time-based maturity progression ✅ (CertificateSystemTests.swift)
- [x] Tier completion tracking ✅ (CertificateSystemTests.swift)
- [x] CertificateDatabase lookup ✅ (CertificateSystemTests.swift)

**8. UI Component Tests** (PRIORITY: LOW)
Missing UI tests for:
- [ ] NodeCardView rendering
- [ ] FirewallCardView rendering
- [ ] DefenseApplicationView layout
- [ ] ThreatIndicatorView states
- [ ] AlertBannerView animations
- [ ] CriticalAlarmView dismissal

#### Code Quality Observations

**OBSERVATION-001: ContentView Unused**
- **Location**: `GridWatchZero/ContentView.swift`
- **Description**: ContentView contains placeholder "Hello, world!" code but is never used (app uses RootNavigationView)
- **Impact**: Low - Dead code
- **Recommendation**: Remove or repurpose for future use

**OBSERVATION-002: No Error Logging**
- **Description**: No structured error logging or analytics integration
- **Impact**: Low - Harder to debug production issues
- **Recommendation**: Consider adding OSLog or analytics framework

**OBSERVATION-003: Magic Numbers in Formulas**
- **Location**: Various calculation files
- **Description**: Many calculations use hardcoded constants (e.g., 1.8 for tier scaling, 0.05 for bonuses)
- **Impact**: Low - Works but harder to tune
- **Recommendation**: Extract constants to configuration file

#### E2E Test Results Summary (2026-02-06)

**Grade: A- (92/100)**

✅ **PASSED - All Core Views Render Correctly**:
- Title Screen (glitch effects, animations)
- Main Menu (save detection, UI flow)
- Home View (campaign hub, level list, 20 levels)
- Dashboard View (main gameplay, topology, units)
- Unit Shop (all 6 tiers, categories, costs)
- Defense Applications (network topology, security apps)
- Lore/Intel Database (fragments, timeline)
- Dossier Collection (character categories, unlock tracking)
- Player Profile (stats, certificates, mission tracking)

✅ **Build & Compilation**:
- Zero compiler errors
- Zero compiler warnings
- Swift 6 concurrency compliant
- Clean MVVM architecture

⚠️ **Known Issues**:
- SettingsView preview crash (ISSUE-023)
- No test target exists
- No unit tests (0% coverage)
- No UI tests (0% coverage)

**Strengths**:
- Excellent visual design consistency (cyberpunk terminal aesthetic)
- Comprehensive SwiftUI implementation
- Clean architecture with MVVM pattern
- All major game systems integrated
- iCloud sync implemented
- Campaign progression system complete

**Completed Actions**:
1. ✅ Fixed SettingsView preview crash (ISSUE-023)
2. ✅ Created test infrastructure in `GridWatchZeroTests/` directory
3. ✅ Added test target to Xcode project (manually by user)
4. ✅ Implemented 134 working tests across 7 test suites:
   - GameEngineSmokeTests.swift (13 tests) - CRITICAL priority ✅ ALL PASSING
   - DefenseSystemTests.swift (10 tests) - HIGH priority ✅ ALL PASSING
   - ResourceAndCampaignTests.swift (18 tests) - HIGH priority ✅ ALL PASSING
   - UnitSystemTests.swift (14 tests) - MEDIUM priority ✅ ALL PASSING
   - TickCycleTests.swift (23 tests) - CRITICAL priority ✅ ALL PASSING
   - AttackSystemTests.swift (30 tests) - CRITICAL priority ✅ ALL PASSING
   - SaveSystemTests.swift (26 tests) - HIGH priority ✅ ALL PASSING

**Test Infrastructure Created** (2026-02-06):
- **Location**: `/GridWatchZeroTests/`
- **Test Framework**: Swift Testing (Xcode 16+)
- **Execution Time**: ~3 seconds for full suite
- **Files Created**:
  - `GameEngineSmokeTests.swift` - Core engine initialization, unit operations, prestige, start/stop
  - `DefenseSystemTests.swift` - Defense stack, firewall, threat state, intel tracking
  - `ResourceAndCampaignTests.swift` - Credits, prestige, nodes, campaign state, cumulative stats
  - `UnitSystemTests.swift` - Unit factory, catalog, tier system, upgrade mechanics
  - `TickCycleTests.swift` - Tick execution, resource flow, prestige multipliers, buffer tracking
  - `AttackSystemTests.swift` - Threat levels, attack mechanics, damage calculations, risk formulas
  - `SaveSystemTests.swift` - GameState encoding/decoding, save versioning, offline progress, iCloud sync
  - `README.md` - Comprehensive setup instructions
  - `TEST_STATUS.md` - Detailed test report and lessons learned

**Test Coverage Achieved**:
- ✅ GameEngine initialization and state management (resilient to saved state)
- ✅ Unit purchase and upgrade logic (handles max level, tier locks)
- ✅ Resource addition and tracking
- ✅ Prestige system state and eligibility
- ✅ Node properties (source, link, sink)
- ✅ Firewall purchase, health, and repair
- ✅ Defense stack and defense points
- ✅ MalusIntelligence and intel tracking
- ✅ Threat state and attack handling
- ✅ Campaign mode detection
- ✅ Unlock, lore, and milestone state tracking
- ✅ Cumulative statistics (data generated, transferred, dropped)
- ✅ Tick cycle execution and resource production flow
- ✅ Source production scaling with level and prestige
- ✅ Link bandwidth limits and packet loss tracking
- ✅ Sink credit conversion and buffer utilization
- ✅ Threat level enumeration and comparisons
- ✅ Attack type properties and damage calculations
- ✅ NetDefenseLevel and RiskCalculation formulas
- ✅ Firewall damage absorption and pass-through mechanics
- ✅ Defense stack damage reduction and risk reduction
- ✅ GameState save/load with JSON encoding/decoding
- ✅ SaveVersion management and comparison (v1-v6)
- ✅ Offline progress calculation and time formatting
- ✅ UnlockState initialization and persistence
- ✅ CloudSaveStatus and iCloud sync state management
- ✅ SyncableProgress device ID tracking
- ✅ Prestige multiplier calculations (production, credit, cores)

**Key Technical Achievements**:
- ✅ Proper `@MainActor` isolation handling
- ✅ Tests work with loaded saved state (not just fresh installs)
- ✅ Resilient to edge cases (max level units, campaign restrictions)
- ✅ Uses actual public API (discovered via code inspection)
- ✅ Incremental test-driven development approach
- ✅ Zero compilation errors, zero test failures

**Test Results**:
```
134 tests: 134 passed, 0 failed, 0 skipped
Test suite: 100% pass rate
Status: ✅ ALL PASSING
```

**Future Test Expansion Opportunities**:
- Campaign progression validation (level unlock, victory conditions)
- Save/load persistence testing (save data encoding/decoding, migration)
- Certificate maturity calculations (40h/60h timers, bonus aggregation)
- Defense app tier gates and progression chains
- Intel report batch upload mechanics

---

### TODO-001: Xcode Cloud Cannot See `main` Branch
**Priority**: High
**Status**: ✅ Resolved
**Reported**: 2026-02-05
**Updated**: 2026-02-06
**Closed**: 2026-02-06
**Description**: Xcode Cloud's "Start Build" dialog shows no branches available when trying to build from `main`. The workflow is configured for `main` but Xcode Cloud only indexed the legacy `master` branch from a previous successful build. An empty commit was pushed to `main` to trigger detection but the issue persists.
**Impact**: Cannot trigger Xcode Cloud builds from `main` branch via App Store Connect.
**Root Cause**: Stale GitHub authorization token. Xcode Cloud's connection to GitHub had gone stale, preventing branch list fetching. The "Find a Branch" dropdown showed "There are no branches available" even with "Any Branches" selected.
**Actions Taken**:
1. Pushed empty commit to `main` to trigger detection — no effect
2. Changed workflow from "Specific Branches" to "Any Branches" — still no branches visible
3. Confirmed repo connection is correct: `https://github.com/remeadows/GridWatchZero.git`
4. Revoked and reconnected Xcode Cloud GitHub application authorization
5. Also found stale App Store Connect URLs still pointing to old `ProjectPlaguev1` repo — updated to `GridWatchZero`
6. ✅ Deleted old workflow and created new workflow in Xcode — resolved issue
**Resolution**: Deleting the old workflow and recreating it fresh in Xcode resolved the branch detection issue. Xcode Cloud now properly detects and can build from the `main` branch.

---

## Archived Issues & Reference

Historical issues (ISSUE-000 through ISSUE-005), completed enhancements (ENH-009 through ENH-016, ENH-020),
documentation guides (DOC-001, DOC-002), and the ENH-017 audio upgrade details have been moved to
[ISSUES_ARCHIVE.md](./ISSUES_ARCHIVE.md).

---

### ISSUE-024: Save System Still Failing - Progress Lost on App Close (Investigation)
**Status**: 🔍 Under Investigation
**Severity**: Critical
**Reported**: 2026-02-07
**Description**: Despite implementing synchronize() and error handling in ISSUE-021, the user reports that progress is STILL being lost every time the app is closed. The previous fix did not resolve the underlying issue.

**Symptoms**:
- User completes levels, earns credits, makes progress
- Closes app (home button or app switcher)
- Reopens app → all progress lost, game starts fresh

**Investigation Status**:
Added aggressive debug logging to both:
1. `GameEngine.saveGame()` - Now logs every step: encoding, UserDefaults write, synchronize, verification
2. `CampaignSaveManager.save()` - Same detailed logging for campaign progress
3. `GameEngine.loadGame()` - Logs raw data check and decode attempts
4. `CampaignSaveManager.load()` - Logs load process

**Next Steps**:
1. User needs to test and provide console logs
2. Check if saves are actually being written (look for "✅ VERIFIED" logs)
3. Check if loads are finding data (look for "Raw data found" logs)
4. Determine if issue is:
   - Save not being called at all
   - Save being called but encoding fails
   - Save succeeds but UserDefaults not persisting
   - Load reading stale/wrong data
   - Campaign vs Endless mode using different save paths

**Hypotheses**:
1. **App termination race condition**: iOS might kill app before synchronize() completes
2. **Save key mismatch**: Campaign and game engine use different keys, one might not be saving
3. **iCloud overwriting local data**: Cloud sync might be clobbering local saves (but ISSUE-006 was supposed to fix this)
4. **Simulator vs device behavior**: Simulator might not persist UserDefaults the same way

**Files Modified**:
- `GridWatchZero/Engine/GameEngine.swift`: Enhanced saveGame() and loadGame() with verification logging
- `GridWatchZero/Models/CampaignProgress.swift`: Enhanced CampaignSaveManager.save() and load() with detailed logging

**Logged**: 2026-02-07

---

### ENH-024: Enlarge Character Portraits to Fill Top 1/4 of Screen
**Priority**: Medium
**Status**: ✅ Implemented
**Reported**: 2026-02-07
**Description**: After ENH-023 increased portrait sizes moderately, user feedback indicated portraits were still too small. Portraits should fill approximately the top 1/4 of screen height (~240px iPhone, ~320px iPad) and use rectangular format instead of circles for maximum visibility.

**Changes Implemented**:

**1. DossierDetailView (Character Showcase)**:
- **Before**: 220×220px (iPhone), 300×300px (iPad), rounded corners
- **After**: 280×240px (iPhone), 400×320px (iPad), rectangular with border
- Removed `RoundedRectangle`, now uses `Rectangle` with `.clipped()`
- Increased border thickness: 3px → 4px
- Increased glow radius: 15px → 20px

**2. StoryDialogueView (Story Moments)**:
- **Before**: 120×120px (iPhone), 220×220px (iPad), rounded corners
- **After**: 240×240px (iPhone), 320×320px (iPad), rectangular
- Removed `RoundedRectangle`, now uses `Rectangle` with `.clipped()`
- Portraits now fill ~1/4 of screen height as requested
- Increased icon sizes for fallback: 50px/90px → 100px/120px
- Increased border: 2px/3px → 3px/4px
- Increased glow: 8px/12px → 12px/15px

**3. Support Email Update**:
- Updated `docs/support.html` to use `WarSignalLabs@gmail.com` (3 instances)
- Changed from `russell.meadows@gmail.com` to match developer branding

**Visual Impact**:
- Character portraits are now 2× larger than ENH-023
- Rectangular format shows more character detail (no corner cropping)
- Portraits dominate the top portion of screen during story/dossier views
- Maintains aspect ratio while maximizing visibility

**Files Modified**:
- `GridWatchZero/Views/DossierView.swift`: DossierDetailView headerSection (lines 304-330)
- `GridWatchZero/Views/StoryDialogueView.swift`: portraitSize, characterPortrait (lines 31-139)
- `docs/support.html`: Email addresses (3 instances)

**Build Status**: ✅ Build succeeded

**Logged**: 2026-02-07

---

### ENH-025: War Signal Labs Brand Video Intro
**Priority**: High
**Status**: ✅ Implemented
**Reported**: 2026-02-07
**Description**: Added War Signal Labs brand video intro that plays before the title screen. The intro features the developer brand video with background audio (thunderstorm or ambient music).

**Implementation**:

**1. Created BrandIntroView**:
- Full-screen video player using AVKit
- Plays `WarSignalLabs_vid1.mp4` (9.3MB video file)
- Background audio support (thunderstorm preferred, falls back to background_music)
- Automatic fade in/out transitions
- Auto-advances to title screen when video completes
- Clean resource management (stops video and audio on completion)

**2. Updated Navigation Flow**:
- Added `.brandIntro` case to `AppScreen` enum
- Changed initial screen from `.title` to `.brandIntro`
- Brand intro → Title Screen → Main Menu flow
- Smooth fade transitions between screens (0.5s)

**3. Video Asset Management**:
- Video file: `GridWatchZero/Resources/WarSignalLabs_vid1.mp4`
- Copied from root directory to Resources folder
- File size: 9.3MB (acceptable for brand intro)
- Format: MP4 (iOS native support)

**4. Audio Handling** (Updated 2026-02-07):
- Uses `AmbientAudioManager.shared` for persistent background music
- Music starts during brand intro video
- Music **continues playing** through: Title Screen → Main Menu → Campaign Hub
- Music **stops** when gameplay actually starts (level begins)
- Smooth audio continuity: Brand Intro → Title Screen → Main Menu → Campaign Hub → (gameplay starts) → Music stops

**Technical Details**:
- Uses `AVPlayer` for video playback
- Uses `AmbientAudioManager` for background music (delegates to `AudioManager`)
- Music plays `background_music.m4a` in loop
- Observes `AVPlayerItemDidPlayToEndTime` notification for video
- Video cleanup does NOT stop music (intentional persistence)
- Proper cleanup in `onDisappear`
- Handles missing assets gracefully (logs errors, advances to next screen)

**User Experience**:
- First-time app launch: Brand intro plays automatically
- Subsequent launches: Brand intro plays every time (can be optimized later)
- Non-intrusive: Auto-advances after video, no user interaction required
- **Seamless audio**: Music flows from intro through title screen, main menu, and campaign hub
- **User control**: Music stops when player starts a level (gameplay begins)
- **Menu atmosphere**: Background music creates immersive menu experience
- Professional branding: Establishes War Signal Labs identity

**Files Created**:
- `GridWatchZero/Views/BrandIntroView.swift` (new file)

**Files Modified**:
- `GridWatchZero/Engine/NavigationCoordinator.swift`:
  - Added `.brandIntro` to `AppScreen` enum (line 11)
  - Updated hash and equality checks (lines 24, 36)
  - Changed initial screen to `.brandIntro` (line 49)
  - Added brand intro case in RootNavigationView switch (lines 322-330)
  - **Added music stop in GameplayContainerView.setupLevel()** (lines 599-601)
- `GridWatchZero/Views/BrandIntroView.swift`:
  - Starts `AmbientAudioManager` instead of local `AVAudioPlayer`
  - Does NOT stop music in cleanup (intentional persistence)
- `GridWatchZero/Views/TitleScreenView.swift`:
  - **Removed music stop** from onTapGesture (music now persists to main menu)

**Assets Added**:
- `GridWatchZero/Resources/WarSignalLabs_vid1.mp4` (9.3MB)

**Build Status**: ✅ Build succeeded

**Future Enhancements**:
- Add `thunderstorm.m4a` audio asset for better brand atmosphere
- Option to skip intro after first view (UserDefaults flag)
- Allow tap-to-skip functionality
- Compress video further if app size becomes concern

**Logged**: 2026-02-07

---

## Reporting New Issues

When adding issues, include:
1. **Status**: Open / In Progress / Closed
2. **Severity**: Critical / Major / Minor
3. **Description**: What is happening
4. **Impact**: How it affects gameplay/UX
5. **Solution**: Proposed fix (if known)
6. **Files**: Affected source files
