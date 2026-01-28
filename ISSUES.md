# ISSUES.md - Project Plague: Neural Grid

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

### ISSUE-007: Cloud Save Does Not Work
**Status**: 🔴 Open
**Severity**: Critical
**Description**: Cloud save functionality is not working. Player progress is not syncing across devices or to the cloud.
**Impact**: Players cannot recover progress if they switch devices or reinstall the app. Critical for user retention.
**Solution**: TBD - Investigate iCloud/CloudKit implementation
**Files**: TBD

---

## 🟠 Major (Significant Impact)

### ISSUE-008: Sound Plays When Phone Volume Is Off
**Status**: 🟠 Open
**Severity**: Major
**Description**: Game sounds are still audible when the phone's volume is turned all the way down. Sounds should respect the device's ringer/media volume settings.
**Impact**: Disruptive to users in quiet environments; unexpected audio in meetings, etc.
**Solution**: Ensure AudioManager uses the correct audio session category (e.g., `.ambient` or `.playback`) and respects system volume. Check if sounds are bypassing the silent switch.
**Files**: `Engine/AudioManager.swift`

### ISSUE-009: Starting Credits Should Be Zero Per Level
**Status**: 🟠 Open
**Severity**: Major
**Description**: Each campaign level should start with zero credits. Currently, players can beat levels too quickly due to starting credit balance.
**Impact**: Game balance issue - levels are too easy and don't provide intended challenge/progression.
**Solution**: Reset credits to 0 at the start of each campaign level.
**Files**: `Engine/GameEngine.swift`, `Models/CampaignProgress.swift`

### ISSUE-010: Offline Progress Lost When Switching Apps
**Status**: 🟠 Open
**Severity**: Major
**Description**: When user switches to a different app (swipes away) or turns screen off without manually saving, all progress since last save is lost. The game closes without auto-saving.
**Impact**: Frustrating user experience - players lose progress unexpectedly.
**Solution**: Implement auto-save on app backgrounding using `scenePhase` changes or `UIApplication.willResignActiveNotification`. Save state when entering background.
**Files**: `Engine/GameEngine.swift`, `Project_PlagueApp.swift`

### ISSUE-011: App Defenses Don't Affect Game Success
**Status**: 🟠 Open
**Severity**: Major
**Description**: Defense applications are too cheap and upgrade too quickly. They don't meaningfully impact game success. The intended mechanic is: better app defenses = more intel collected to send to team. Currently intel collection should NOT start until proper defenses are deployed.
**Impact**: Removes strategic depth from defense system; intel reports too easy to obtain.
**Solution**:
1. Increase defense app costs and upgrade time
2. Gate intel collection behind defense deployment
3. Scale intel collection rate with defense quality
**Files**: `Models/DefenseApplication.swift`, `Engine/GameEngine.swift`

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
**Status**: 🟡 Open
**Severity**: Minor
**Description**: Dialog text shows incorrect goal requirements. Example: Level 1 dialog says it takes 2,000 credits to complete, but actual requirement differs per CLAUDE.md (Level 1 = 50K credits).
**Impact**: Confusing for players; undermines trust in game instructions.
**Solution**: Audit all level dialogs and correct goal text to match actual requirements in code.
**Files**: `Views/` (dialog-related views), Lore/Story text files

### ISSUE-013: Achievement Rewards - Are They Instant?
**Status**: 🟡 Open
**Severity**: Minor
**Description**: Unclear whether achievement rewards are granted instantly upon completion or require manual claim.
**Impact**: UX confusion; need to verify and document expected behavior.
**Solution**: Investigate current implementation and decide on intended behavior.
**Files**: `Models/MilestoneSystem.swift`, `Engine/GameEngine.swift`

### ISSUE-014: Total Playtime Not Displaying
**Status**: 🟡 Open
**Severity**: Minor
**Description**: Total playtime statistic is not showing in the stats/lifetime stats view.
**Impact**: Players cannot see how long they've played the game.
**Solution**: Ensure playtime is being tracked and displayed correctly in stats UI.
**Files**: `Engine/GameEngine.swift`, `Views/` (stats views)

### ISSUE-015: Tier Requirements Display Incorrect
**Status**: 🟡 Open
**Severity**: Minor
**Description**: The requirements shown for purchasing next tier of Source, Link, and Sink nodes incorrectly mentions "Target level". Threat level has nothing to do with tier unlocks.
**Impact**: Misleading UI text; players don't understand actual unlock requirements.
**Solution**: Update tier requirement text to show correct unlock conditions (max level of current tier).
**Files**: `Views/UnitShopView.swift`

### ISSUE-016: Analyze Lifetime Stats
**Status**: 🟡 Open
**Severity**: Minor
**Description**: Review and analyze lifetime stats implementation. Ensure all relevant stats are being tracked and displayed accurately.
**Impact**: Analytics and player engagement features.
**Solution**: Audit lifetime stats tracking and display.
**Files**: `Engine/GameEngine.swift`, Stats views

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
**Status**: Open
**Description**: Award Cyber Defense certificates after completing each campaign level. These certifications should be displayed on the player's account/profile.
**Notes**: Could tie into real-world security cert names (CompTIA Security+, CISSP-lite, etc.) or create fictional equivalents matching game lore.

### ENH-009: Endless Mode Slower Gameplay
**Priority**: Medium
**Status**: Open
**Description**: Make Endless Mode gameplay slower, similar to the balance changes needed in ISSUE-009. Progression should feel more deliberate.
**Notes**: Adjust tick rates, costs, and/or production rates for Endless Mode specifically.

### ENH-010: Insane Mode - Slow, Expensive, Frequent Attacks
**Priority**: Medium
**Status**: Open
**Description**: Create an "Insane Mode" difficulty with:
- Slower progression
- Much higher costs for upgrades
- Frequent attack events from Malus
**Notes**: Could be unlocked after completing campaign or reaching certain prestige level.

### ENH-011: Expand Tiers to 25 with New Names
**Priority**: High
**Status**: Open
**Description**: Unit shop and app defense need expansion to Tier 25. Brainstorm new product names for:
- Source nodes (data harvesting)
- Link nodes (transport)
- Sink nodes (processing)
- Defense applications (all 6 categories)
**Notes**: Current tiers go to Tier 6 (Quantum). Need Tiers 7-25 with thematic naming.

### ENH-012: New Campaign Levels Beyond 7
**Priority**: Medium
**Status**: Open
**Description**: Brainstorm and design new campaign levels beyond the current 7. Consider:
- New story beats with Malus/Helix
- Escalating mechanics
- New environments or scenarios
**Notes**: Current max is Level 7 (25M credits, 320 reports).

### ENH-013: Level 1 Rusty Tutorial Walkthrough
**Priority**: High
**Status**: Open
**Description**: In Level 1, Rusty should perform a guided walkthrough explaining:
- How to play the game
- Core mechanics (Source → Link → Sink)
- Goals and victory conditions
- Threat system basics
**Notes**: Consider step-by-step tutorial with highlighting and forced actions.

### ENH-014: Game Engagement Improvements
**Priority**: High
**Status**: Open
**Description**: Brainstorm features to make the game more engaging and keep users interested longer:
- Daily rewards/login bonuses
- Streak systems
- Limited-time events
- Social features
- Achievement hunting
- Collection mechanics
**Notes**: Focus on retention without becoming predatory.

### ENH-015: Ad/Purchase Multipliers
**Priority**: Medium
**Status**: Open
**Description**: Brainstorm multiplier systems:
- **Watch Ads**: Temporary multipliers (2x production for 30 min, etc.)
- **Lifetime Purchase**: Permanent multipliers if game is purchased (remove ads + bonus)
**Notes**: Balance between F2P accessibility and rewarding paying users.

### ENH-016: Weekend Tournaments for Endless Mode
**Priority**: Medium
**Status**: Open
**Description**: Brainstorm weekend tournament system for Endless Mode:
- Timed challenges (highest score in X hours)
- Leaderboards
- Exclusive rewards (cosmetics, unique upgrades)
- Special tournament modifiers
**Notes**: Could require server infrastructure for leaderboards.

### ENH-002: iPad Layout
**Priority**: High
**Status**: ✅ Closed
**Description**: Optimize layout for iPad with side-by-side panels or wider cards.
**Notes**: Implemented HStack layout with 380px sidebar for defense/stats and main area for network map. Uses horizontalSizeClass environment variable.
**Closed**: 2026-01-20

### ENH-003: Accessibility
**Priority**: High
**Status**: ✅ Closed
**Description**: Add VoiceOver labels, dynamic type support, reduce motion option.
**Notes**: Added accessibility labels to all interactive components, converted fonts to use Dynamic Type scaling, added reduceMotion support for screen shake.
**Closed**: 2026-01-20

### ENH-005: iCloud Sync
**Priority**: Low
**Description**: Sync save data across devices via iCloud.
**Notes**: Would require migrating from UserDefaults to CloudKit or NSUbiquitousKeyValueStore.

### ENH-006: App Store Preparation
**Priority**: High
**Description**: Prepare all assets and metadata for App Store submission.
**Notes**: Need app icon (1024×1024), screenshots for all devices, privacy policy, description.

### ENH-007: Game Balance Tuning
**Priority**: Medium
**Description**: Tune game balance based on playtesting feedback.
**Notes**: Track time-to-unlock for each tier, credit/threat curves, prestige timing.

---

## Recently Added Features (v0.7.0)

### FEAT-001: Defense Application System
**Status**: Implemented
**Description**: 6 defense application categories with progression chains:
1. **Firewall**: Basic FW -> NGFW -> AI/ML Firewall
2. **SIEM**: Syslog -> SIEM -> SOAR -> AI Analytics
3. **Endpoint**: EDR -> XDR -> MXDR -> AI Protection
4. **IDS**: IDS -> IPS -> ML/IPS -> AI Detection
5. **Network**: Router -> ISR -> Cloud ISR -> Encrypted Mesh
6. **Encryption**: AES-256 -> E2E Crypto -> Quantum Safe
**Files**: `Models/DefenseApplication.swift`, `Views/Components/DefenseApplicationView.swift`

### FEAT-002: Network Topology View
**Status**: Implemented
**Description**: Visual network topology diagram showing Source -> Link -> Sink with defense stack indicator and data flow animation.
**Files**: `Views/Components/DefenseApplicationView.swift` (NetworkTopologyView)

### FEAT-003: Critical Alarm System
**Status**: Implemented
**Description**: Full-screen alarm overlay when risk level becomes HUNTED or MARKED. Includes glitch effects, pulsing warning, and action buttons.
**Files**: `Views/Components/CriticalAlarmView.swift`

### FEAT-004: Malus Intelligence System
**Status**: Implemented
**Description**: Track Malus footprint data from survived attacks. Collect patterns, analyze behavior, and send reports to the team.
**Files**: `Models/DefenseApplication.swift` (MalusIntelligence), `Views/Components/CriticalAlarmView.swift` (MalusIntelPanel)

### FEAT-005: Title Update
**Status**: Implemented
**Description**: Changed header from "PLAGUE" to "PROJECT PLAGUE" for better branding.
**Files**: `Views/Components/StatsHeaderView.swift`

---

## Closed Issues

### ISSUE-000: AudioManager Swift 6 Concurrency Errors
**Status**: ✅ Closed
**Resolution**: Removed ObservableObject, used `@unchecked Sendable`, wrapped haptics in `Task { @MainActor in }`
**Closed**: 2026-01-19

### ENH-001: Offline Progress
**Status**: ✅ Closed
**Resolution**: Implemented offline progress calculation with 8-hour cap and 50% efficiency. Shows modal on app return with ticks simulated and credits earned.
**Closed**: 2026-01-19

### ENH-004: Custom Sound Pack
**Status**: ✅ Closed
**Resolution**: Changed system sounds to cyberpunk-themed electronic tones. Added procedural ambient synth drone generator using AVAudioEngine.
**Closed**: 2026-01-19

---

## 📘 Documentation & Questions

### DOC-001: App Store Deployment Process
**Status**: ✅ Completed
**Type**: Documentation

#### 1. Apple Developer Program Enrollment
- **Cost**: $99/year (individual or organization)
- **URL**: https://developer.apple.com/programs/enroll/
- **Requirements**:
  - Apple ID with two-factor authentication enabled
  - Valid payment method
  - For organizations: D-U-N-S number (free from Dun & Bradstreet)
- **Timeline**: Individual accounts typically approved within 48 hours; organizations may take 1-2 weeks

#### 2. Certificates & Provisioning Profiles
- **In Xcode** (recommended automatic management):
  1. Open project → Signing & Capabilities tab
  2. Check "Automatically manage signing"
  3. Select your Team from the dropdown
  4. Xcode creates Development and Distribution certificates automatically
- **Manual Setup** (if needed):
  1. Go to https://developer.apple.com/account/resources/certificates
  2. Create "Apple Distribution" certificate using Keychain Access CSR
  3. Create App ID matching your bundle identifier
  4. Create "App Store" provisioning profile linking certificate + App ID

#### 3. App Store Connect Setup
- **URL**: https://appstoreconnect.apple.com
- **Create New App**:
  1. My Apps → "+" → New App
  2. Select platform (iOS)
  3. Enter app name, primary language, bundle ID, SKU
- **Required Metadata**:
  | Field | Requirement |
  |-------|-------------|
  | App Name | 30 characters max |
  | Subtitle | 30 characters max |
  | Description | 4000 characters max |
  | Keywords | 100 characters total, comma-separated |
  | Support URL | Required, must be active |
  | Privacy Policy URL | Required for all apps |
  | Category | Primary + optional secondary |
  | Age Rating | Complete questionnaire |

#### 4. Required Assets
| Asset | Specification |
|-------|---------------|
| App Icon | 1024×1024 PNG, no alpha |
| iPhone Screenshots | 6.7" (1290×2796) and 5.5" (1242×2208) |
| iPad Screenshots | 12.9" (2048×2732) - required if iPad supported |
| App Preview Video | Optional, 15-30 seconds, up to 3 per locale |

#### 5. Build & Upload
```bash
# Archive in Xcode
Product → Archive

# Or via command line
xcodebuild -scheme "Project Plague" -archivePath build/App.xcarchive archive
xcodebuild -exportArchive -archivePath build/App.xcarchive -exportPath build/ -exportOptionsPlist ExportOptions.plist
```
- After archive: Window → Organizer → Distribute App → App Store Connect
- Alternatively use `xcrun altool` or Transporter app

#### 6. TestFlight Beta Testing
1. Upload build to App Store Connect
2. Build processes (5-30 minutes for automated review)
3. **Internal Testing**: Up to 100 testers, no review needed
4. **External Testing**: Up to 10,000 testers, requires Beta App Review
5. Testers install via TestFlight app using invite link or email

#### 7. App Review Submission
- Click "Add for Review" after completing all metadata
- **Review Timeline**: Typically 24-48 hours (90% within 24 hours)
- **Expedited Review**: Request at https://developer.apple.com/contact/app-store (emergency only)

#### 8. Common Rejection Reasons
| Reason | Solution |
|--------|----------|
| **Guideline 2.1 - Crashes/Bugs** | Test thoroughly on all supported devices |
| **Guideline 2.3 - Incomplete Info** | Provide demo account if login required |
| **Guideline 3.1.1 - In-App Purchase** | Use Apple IAP for digital goods, not Stripe/PayPal |
| **Guideline 4.2 - Minimum Functionality** | App must provide value beyond a website |
| **Guideline 5.1.1 - Data Collection** | Disclose all data collection in privacy policy |
| **Guideline 5.1.2 - Data Use** | Only collect data necessary for core functionality |
| **Metadata Rejected** | Screenshots must show actual app, no iPhone frames |

#### 9. Post-Launch Checklist
- [ ] Monitor App Store Connect for crash reports
- [ ] Respond to user reviews (increases engagement)
- [ ] Set up App Analytics for download/usage metrics
- [ ] Plan update cadence (fix bugs, add features)
- [ ] Consider App Store Optimization (ASO) for keywords

---

### DOC-002: Claude Cowork Xcode/Simulator Permissions
**Status**: ✅ Completed
**Type**: Documentation

#### Overview
Claude Code (and similar AI assistants) runs commands in a terminal environment. To build and run iOS projects, the following must be configured on macOS.

#### 1. Install Xcode Command Line Tools
```bash
# Install command line tools
xcode-select --install

# Verify installation
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer

# If pointing to wrong location, reset:
sudo xcode-select --reset
```

#### 2. Accept Xcode License
```bash
# Accept license (required before first use)
sudo xcodebuild -license accept
```

#### 3. Build Project via Command Line
```bash
# List available schemes
xcodebuild -list -project "Project Plague.xcodeproj"

# Build for simulator
xcodebuild -project "Project Plague.xcodeproj" \
  -scheme "Project Plague" \
  -destination "platform=iOS Simulator,name=iPhone 15" \
  build

# Build and run tests
xcodebuild test -project "Project Plague.xcodeproj" \
  -scheme "Project Plague" \
  -destination "platform=iOS Simulator,name=iPhone 15"
```

#### 4. Launch iOS Simulator
```bash
# List available simulators
xcrun simctl list devices

# Boot a specific simulator
xcrun simctl boot "iPhone 15"

# Open Simulator app (shows booted device)
open -a Simulator

# Install app on simulator
xcrun simctl install booted /path/to/App.app

# Launch app on simulator
xcrun simctl launch booted com.yourcompany.ProjectPlague
```

#### 5. macOS Security Permissions
For full automation, grant these permissions in System Settings → Privacy & Security:

| Permission | Required For |
|------------|--------------|
| **Full Disk Access** | Accessing project files in protected directories |
| **Developer Tools** | Terminal/iTerm needs this for debugging |
| **Automation** | Controlling Xcode and Simulator programmatically |

To add Terminal to Developer Tools:
1. System Settings → Privacy & Security → Developer Tools
2. Click "+" and add Terminal.app (or iTerm)

#### 6. Automation with `xcodebuild`
```bash
# Full build + run workflow
PROJECT_DIR="/Volumes/DEV/Code/dev/Games/ProjectPlague/ProjectPlague/Project Plague"
SCHEME="Project Plague"
SIMULATOR="iPhone 15"

# Build
xcodebuild -project "$PROJECT_DIR/Project Plague.xcodeproj" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$SIMULATOR" \
  -derivedDataPath build/ \
  build

# Find the built app
APP_PATH=$(find build/ -name "*.app" -type d | head -1)

# Boot simulator and install
xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
xcrun simctl install booted "$APP_PATH"
xcrun simctl launch booted com.yourcompany.ProjectPlague
```

#### 7. Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| `xcodebuild: error: unable to find utility` | Run `xcode-select --install` |
| `Signing requires a development team` | Add `-allowProvisioningUpdates` or set team in project |
| `Simulator not found` | Run `xcrun simctl list` to find exact device name |
| `Permission denied` | Add Terminal to Full Disk Access |
| `Build fails with provisioning error` | Use `-destination generic/platform=iOS Simulator` |

#### 8. Headless CI/CD Considerations
For automated pipelines (GitHub Actions, etc.):
```bash
# Create and boot simulator headlessly
xcrun simctl create "CI_iPhone" "iPhone 15"
xcrun simctl boot "CI_iPhone"

# Build with no code signing (simulator only)
xcodebuild -project "Project.xcodeproj" \
  -scheme "Scheme" \
  -destination "platform=iOS Simulator,name=CI_iPhone" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  build
```

#### 9. For Claude Code Specifically
Claude Code operates within a sandboxed terminal environment. To enable Xcode operations:
1. Ensure the working directory contains the `.xcodeproj`
2. Use absolute paths when referencing project files
3. Commands execute in the user's shell environment
4. Xcode must already be installed and configured on the host Mac
5. Claude Code cannot click GUI buttons - all operations must be CLI-based

---

## Reporting New Issues

When adding issues, include:
1. **Status**: Open / In Progress / Closed
2. **Severity**: Critical / Major / Minor
3. **Description**: What's happening
4. **Impact**: How it affects gameplay/UX
5. **Solution**: Proposed fix (if known)
6. **Files**: Affected source files
