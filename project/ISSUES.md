# ISSUES.md - Grid Watch Zero

## Issue Tracker

---

## 🔴 Critical (Blocks Gameplay)

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

### ENH-017: Audio System Upgrade Using Apple Dev Tools
**Priority**: High
**Status**: Open
**Description**: Upgrade audio system using better Apple development tools available in Xcode.

---

## Archived Issues & Reference

Historical issues (ISSUE-000 through ISSUE-005), completed enhancements (ENH-009 through ENH-016, ENH-020),
documentation guides (DOC-001, DOC-002), and the ENH-017 audio upgrade details have been moved to
[ISSUES_ARCHIVE.md](./ISSUES_ARCHIVE.md).

---

## Reporting New Issues

When adding issues, include:
1. **Status**: Open / In Progress / Closed
2. **Severity**: Critical / Major / Minor
3. **Description**: What is happening
4. **Impact**: How it affects gameplay/UX
5. **Solution**: Proposed fix (if known)
6. **Files**: Affected source files
