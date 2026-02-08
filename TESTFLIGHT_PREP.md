# TestFlight Preparation Checklist - Grid Watch Zero

**Date**: 2026-02-08
**Version**: 1.0 (Build 2)
**Bundle ID**: WarSignal.GridWatchZero

---

## ✅ Pre-Flight Checklist

### 1. Code Quality & Stability
- [x] ✅ All critical issues resolved (ISSUE-032, ISSUE-033)
- [x] ✅ Game playable through Level 10+
- [x] ✅ No game-breaking bugs
- [x] ✅ Balance adjustments complete
- [x] ✅ Audio/video polish complete
- [ ] Final build succeeds without warnings
- [ ] Run on physical device (not just simulator)

### 2. Assets & Resources
- [x] ✅ Brand intro video (`WarSignalLabs_9_16_5.mp4`) - 9.1MB
- [x] ✅ Storm audio (`storm.wav`) - 2.7MB
- [x] ✅ Levels ambient (`levels_ambient.wav`) - 2.7MB
- [x] ✅ Background music loop (`background_music.m4a`)
- [x] ✅ All sound effects (upgrade, equip, attack, etc.)
- [ ] App icon set (1024x1024 required for App Store)
- [ ] Screenshots prepared (see requirements below)

### 3. App Store Connect Configuration
- [x] ✅ Bundle ID registered: `WarSignal.GridWatchZero`
- [x] ✅ App name: "Grid Watch Zero"
- [ ] Privacy Policy URL configured
- [ ] Support URL configured
- [ ] App description written
- [ ] Keywords defined
- [ ] Age rating set
- [ ] TestFlight Beta Info filled out

### 4. Build Configuration
**Current Settings**:
- Version: **1.0**
- Build: **2**
- Development Team: **B2U8T6A2Y3**
- Deployment Target: **iOS 17.0+**
- Bundle ID: **WarSignal.GridWatchZero**

### 5. Required Documentation
- [x] ✅ Privacy Policy: `docs/privacy-policy.html`
- [x] ✅ Support Page: `docs/support.html`
- [x] ✅ Landing Page: `docs/index.html`
- [ ] "What to Test" notes for TestFlight testers
- [ ] Known issues list for testers

---

## 📱 TestFlight Requirements

### Screenshots Needed (All devices)
Create screenshots showing:
1. **Brand intro** - War Signal Labs video/logo
2. **Campaign hub** - Level selection screen
3. **Gameplay** - Active level with nodes, firewall, stats
4. **Defense apps** - Security applications screen
5. **Victory/Complete** - Level completion screen

**Device sizes required**:
- iPhone 16 Pro Max (6.9" - 1320 x 2868)
- iPhone 16 Pro (6.3" - 1206 x 2622)
- iPhone 16 Plus (6.7" - 1290 x 2796)
- iPhone 16 (6.1" - 1179 x 2556)
- iPad Pro 13" (2nd gen) (2048 x 2732)

### App Preview Video (Optional but Recommended)
- Up to 3 videos per device size
- 15-30 seconds each
- Show core gameplay loop
- Highlight key features (defense apps, attacks, progression)

### App Icon
- 1024x1024 PNG (no transparency)
- Current placeholder needs to be replaced with final art

---

## 🚀 Build & Upload Process

### Step 1: Clean Build
```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Open project
open GridWatchZero.xcodeproj

# In Xcode:
# Product → Clean Build Folder (Cmd+Shift+K)
```

### Step 2: Archive for Distribution
```bash
# In Xcode:
# 1. Select "Any iOS Device (arm64)" as destination
# 2. Product → Archive (Cmd+B won't work - must use Archive)
# 3. Wait for archive to complete (~2-5 minutes)
```

### Step 3: Upload to App Store Connect
```bash
# After archive completes:
# 1. Organizer window opens automatically
# 2. Select the new archive
# 3. Click "Distribute App"
# 4. Choose "App Store Connect"
# 5. Select "Upload"
# 6. Click "Next" through the options:
#    - Include bitcode: NO (deprecated)
#    - Upload symbols: YES (for crash reports)
#    - Manage version and build number: Automatic
# 7. Review and click "Upload"
# 8. Wait for upload to complete (~5-15 minutes depending on connection)
```

### Step 4: Processing in App Store Connect
- Apple processes the build (15-90 minutes)
- You'll receive email when processing completes
- Build will appear in "TestFlight" tab in App Store Connect

### Step 5: Configure TestFlight Build
```bash
# In App Store Connect:
# 1. Go to "TestFlight" tab
# 2. Select the new build
# 3. Fill out "Test Details":
#    - What to Test
#    - Test Notes (known issues, focus areas)
# 4. Add internal testers (if not already added)
# 5. Submit build for beta app review (required for external testers)
```

---

## 📝 What to Test (For Testers)

### Critical Path Testing
1. **Launch & Intro**
   - Video plays full-screen without issues
   - Audio transitions smoothly (storm → music)
   - No crashes on launch

2. **Campaign Progression**
   - Can start Level 1
   - Can complete early levels (1-3)
   - Can save and resume levels
   - Checkpoints work correctly

3. **Core Gameplay Loop**
   - Nodes generate/transfer/process data
   - Credits accumulate properly
   - Can upgrade units
   - Tier gates work (MAX badge appears)

4. **Defense System**
   - Attacks occur and display correctly
   - Firewall absorbs damage
   - Defense apps reduce damage
   - Can survive attacks at Level 5+

5. **Balance Testing**
   - Level 9 is now completable (was broken)
   - Level 10+ feels challenging but fair
   - Income vs attack damage feels balanced

### Known Issues (Document for testers)
- ISSUE-030: Auto-upgrade button behavior (under investigation)
- ISSUE-031: Checkpoint resume (debug logging added, needs testing)

### Performance Metrics
- App size: TBD (will show after upload)
- Launch time: ~2-3 seconds
- Memory usage: Monitor for leaks
- Battery drain: Report if excessive

---

## 🛠️ Pre-Upload Actions

### 1. Increment Build Number
Since this is a new build with significant changes, increment to Build 3:

```bash
# In Xcode project settings:
# General → Identity → Build: 2 → 3
```

Or update programmatically:
```bash
agvtool next-version -all
```

### 2. Final Build Test
```bash
# Run one more time on physical device
# Test critical path:
# - Launch
# - Play through Level 1
# - Start Level 2
# - Background/resume app
# - Close and reopen app (checkpoint test)
```

### 3. Create Release Notes
Document what's new in this build for testers.

---

## 📋 Release Notes for Build 3 (TestFlight)

**What's New**:
- ✅ Fixed Level 9+ balance issues - now completable!
- ✅ Full-screen brand intro video
- ✅ Smooth audio transitions throughout app
- ✅ Improved button responsiveness
- ✅ Rebalanced all endgame levels (9-20)

**Testing Focus**:
- Campaign progression through Level 10+
- Save/resume functionality
- Audio experience during transitions
- Video display on your device

**Known Issues**:
- Auto-upgrade button may trigger multiple upgrades (under investigation)
- Checkpoint resume being refined (please report if you can't resume)

---

## 🚨 Common Upload Issues & Solutions

### Issue: "App Icon Not Found"
**Solution**:
- Add 1024x1024 icon to Assets.xcassets
- Must be named exactly "AppIcon"

### Issue: "Missing Compliance"
**Solution**:
- If app uses encryption: Answer export compliance questions
- Grid Watch Zero: NO encryption (just local storage)

### Issue: "Processing Failed"
**Solution**:
- Check email for specific error
- Common: Missing entitlements, provisioning issues
- Re-archive with correct settings

### Issue: "Build Takes Too Long to Process"
**Solution**:
- Normal processing: 15-90 minutes
- If >2 hours: Contact Apple Developer Support
- Check App Store Connect system status

---

## 📞 Support Resources

**Apple Developer Support**:
- Phone: 1-800-633-2152
- Developer Forums: https://developer.apple.com/forums/
- System Status: https://developer.apple.com/system-status/

**Xcode/Build Issues**:
- Clean build folder
- Delete DerivedData
- Restart Xcode
- Update to latest Xcode if prompted

**App Store Connect**:
- https://appstoreconnect.apple.com
- TestFlight tab for beta testing
- Users and Access for adding testers

---

## ✅ Post-Upload Checklist

After successful upload:

- [ ] Build shows in App Store Connect
- [ ] Processing completes (email notification)
- [ ] TestFlight details filled out
- [ ] Internal testers invited
- [ ] "What to Test" notes added
- [ ] Build submitted for beta review (for external testers)
- [ ] Monitor crash reports in Xcode Organizer
- [ ] Collect feedback from testers
- [ ] Document bugs/issues for next build

---

## 🎯 Next Steps After TestFlight

1. **Collect Feedback**: Get reports from 5-10 testers minimum
2. **Fix Critical Bugs**: Address any crashes or blockers
3. **Iterate**: Build 4, 5, 6... until stable
4. **Polish**: Final UI/UX improvements
5. **App Store Submission**: Full release when ready

**Timeline Estimate**:
- TestFlight testing: 1-2 weeks
- Bug fixes: 1 week
- Final polish: 1 week
- App Store review: 1-7 days
- **Total to launch**: ~4-6 weeks

---

## 📊 Current Build Status

**Version**: 1.0
**Build**: 2 (increment to 3 for this upload)
**Last Build Date**: 2026-02-08
**Last Test Date**: 2026-02-08
**Issues Resolved**: 2 critical (ISSUE-032, ISSUE-033)
**Issues Pending**: 2 minor (ISSUE-030, ISSUE-031)

**Ready for TestFlight**: ✅ YES
**Blocking Issues**: ❌ NONE

---

Good luck with the TestFlight submission! 🚀
