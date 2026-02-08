# Enable Manual Testing - Quick Start Guide

## Where to Test: MacOS or iPhone?

**Answer: BOTH work, but iPhone Simulator on MacOS is recommended for quick iteration.**

### Option 1: iPhone Simulator (Recommended for Testing)
✅ **Pros:**
- Fast iteration (no cable, instant deployment)
- Easy debugging with Xcode console
- Multiple device sizes available
- Free (no Developer account required)

❌ **Cons:**
- Doesn't test actual iPhone performance
- Haptics won't work (simulated only)

### Option 2: Physical iPhone
✅ **Pros:**
- Real device testing
- Actual haptic feedback
- True performance metrics

❌ **Cons:**
- Requires Apple Developer account ($99/year)
- Slower deployment (USB cable required)
- More setup steps

**For balance testing, use iPhone Simulator. For final validation before release, test on physical device.**

---

## How to Enable Manual Testing (Step-by-Step)

### Step 1: Open Xcode and Select Target
1. Open `GridWatchZero.xcodeproj` in Xcode
2. At the top toolbar, click the device/simulator selector (currently shows "My Mac")
3. Select an iPhone simulator:
   - **iPhone 15 Pro** (recommended - modern device)
   - **iPhone SE (3rd gen)** (for smaller screen testing)
   - **iPad Pro 12.9"** (for iPad testing)

### Step 2: Build and Run
1. Press **Cmd+R** (or click the Play button)
2. Wait for Xcode to build (should take ~10 seconds)
3. The iOS Simulator will launch with Grid Watch Zero running

### Step 3: Enable Debug Multiplier
1. In the running app, tap **Settings** (gear icon)
2. Scroll down to the **🔧 BALANCE TESTING** section (DEBUG builds only)
3. You'll see three multiplier options:
   - **1.0× (Baseline)** - Normal game, no multiplier
   - **1.5× (Ad Boost)** - Simulates watching a rewarded ad
   - **2.0× (Pro)** - Simulates "Grid Watch Pro" permanent unlock

4. Tap the multiplier you want to test
5. Current multiplier shows at the top: "Credit Multiplier: 2.0×"

### Step 4: Start Playtesting
Follow the scenarios in `design/BALANCE_PLAYTEST_GUIDE.md`:

**Test Scenario A: Normal Mode Early Game (Levels 1-7)**
1. Set multiplier to **2.0×** (Pro simulation)
2. Tap "Campaign" from the main dashboard
3. Start Level 1
4. Record:
   - Start time (e.g., 3:45 PM)
   - End time (when victory conditions met)
   - "Feel" rating: Too Easy / Just Right / Too Hard
   - Notes on strategic depth

**Expected Times:**
- Level 1: 8-10 minutes (vs. 15-20 min baseline)
- Level 7: 30-45 minutes (vs. 60-90 min baseline)

### Step 5: Toggle Multipliers During Play
You can change multipliers mid-game:
1. Pause the game
2. Go to Settings → 🔧 BALANCE TESTING
3. Select a different multiplier
4. Resume playing
5. Credits will earn at the new rate immediately

---

## Answering Your Key Questions

### Question: "Does 2x multiplier trivialize Normal mode?"
**How to test:**
1. Set multiplier to 2.0×
2. Play Level 1-7 in Campaign mode
3. Track completion times
4. Ask yourself:
   - Does progression feel **too fast** (burnout)?
   - Do you feel **progression satisfaction** or "it's too easy"?
   - Does the multiplier make **defense building feel optional**?
   - Are intel reports still a meaningful time gate?

**Pass Criteria:**
- Levels 1-7 complete in 90-150 minutes (not <60 minutes)
- Defense building still feels important
- Progression feels rewarding, not trivial

### Question: "Is Insane mode still challenging with multipliers?"
**How to test:**
1. Complete Normal Mode Level 7 first
2. Set multiplier to 2.0×
3. Start Insane Mode Level 1
4. Track:
   - Credits earned
   - Attack frequency (should be 2× Normal)
   - Firewall damage taken
   - Whether progression feels achievable or frustrating

**Pass Criteria:**
- Insane mode feels significantly harder than Normal
- 2x multiplier feels helpful but not trivializing
- Positioning as "support future content" resonates

---

## Pro Tips for Efficient Testing

### Shortcut: Reset Campaign Progress
If you want to start fresh without replaying:
1. Settings → RESET → Reset Campaign Progress
2. Confirm reset
3. Campaign state clears, but credits/units remain

### Shortcut: Speed Up Time (Not Recommended)
You could manually advance the tick cycle by setting:
```swift
engine.debugCreditMultiplier = 10.0
```
But this breaks balance testing - stick to 1.0×, 1.5×, or 2.0×.

### Track Your Results
Use the data collection template in `BALANCE_PLAYTEST_GUIDE.md`:
```
=== PLAYTEST SESSION ===
Date: 2026-02-06
Scenario: A (Levels 1-7)
Multiplier: 2.0×

--- LEVEL DATA ---
Level: 1
Start Time: 3:45 PM
End Time: 3:53 PM
Total Duration: 8 minutes

--- FEEL RATINGS (1-5) ---
Progression Speed: 4 (1=Too Slow, 3=Just Right, 5=Too Fast)
Strategic Depth: 3 (1=Trivial, 3=Balanced, 5=Too Complex)
Defense Building: 3 (1=Optional, 3=Important, 5=Critical)
Threat Challenge: 2 (1=Too Easy, 3=Balanced, 5=Too Hard)
Replay Motivation: 4 (1=None, 3=Maybe, 5=Definitely)

--- VERDICT ---
PASS / FAIL / NEEDS ADJUSTMENT
```

---

## Troubleshooting

### "I don't see the 🔧 BALANCE TESTING section"
**Cause:** You're running a RELEASE build, not DEBUG.
**Fix:**
1. In Xcode, select **Product → Scheme → Edit Scheme...**
2. Select **Run** on the left
3. Change **Build Configuration** to **Debug**
4. Click **Close**
5. Build and run again (Cmd+R)

### "The multiplier isn't working"
**Check:**
1. Go to Settings → 🔧 BALANCE TESTING
2. Confirm "Credit Multiplier: 2.0×" shows at the top
3. Watch the credits counter on the main dashboard
4. If baseline is +50₵/tick, with 2.0× it should be +100₵/tick

### "I want to test on my physical iPhone"
**Setup:**
1. Connect iPhone via USB
2. In Xcode, select your iPhone from the device selector
3. If prompted, trust the computer on your iPhone
4. Xcode may require you to sign the app:
   - Select the GridWatchZero project
   - Go to **Signing & Capabilities**
   - Select your Apple ID under **Team**
5. Press Cmd+R to build and deploy

---

## Next Steps After Testing

### If Tests PASS ✅
1. Mark CRITICAL TODOs as complete in `MONETIZATION_BRAINSTORM.md` lines 463-464
2. Document findings in `BALANCE_PLAYTEST_GUIDE.md` → Test Results section
3. Proceed with StoreKit integration (IAP)
4. Integrate AdMob SDK (rewarded ads)
5. **IMPORTANT:** Remove `debugCreditMultiplier` before App Store submission

### If Tests FAIL ❌
1. Document specific issues in `BALANCE_PLAYTEST_GUIDE.md`
2. Adjust multiplier values:
   - Consider 1.75× instead of 2× for Pro
   - Consider 1.25× instead of 1.5× for ads
3. Re-run automated tests with new values (update `BalanceMultiplierTests.swift`)
4. Playtest again with adjusted multipliers

### If Tests INCONCLUSIVE ⚠️
1. Identify specific concerns (e.g., "Level 1 feels fine, but Level 7 too fast")
2. Design focused follow-up tests (e.g., test Level 7 specifically)
3. Consider A/B testing with players (TestFlight beta)
4. Consult `MONETIZATION_BRAINSTORM.md` for alternative monetization models

---

## Quick Reference Commands

### Build and Run
```bash
# From command line (alternative to Xcode UI)
xcodebuild build \
  -project GridWatchZero.xcodeproj \
  -scheme GridWatchZero \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

xcodebuild test \
  -project GridWatchZero.xcodeproj \
  -scheme GridWatchZero \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:GridWatchZeroTests/BalanceMultiplierTests
```

### Reset Simulator
```bash
# If the simulator gets stuck
xcrun simctl shutdown all
xcrun simctl erase all
```

---

**Created:** 2026-02-06
**Purpose:** Quick start guide for manual balance testing
**Related Files:**
- `design/BALANCE_PLAYTEST_GUIDE.md` - Comprehensive testing scenarios
- `design/MONETIZATION_BRAINSTORM.md` - Monetization strategy and TODOs
- `GridWatchZeroTests/BalanceMultiplierTests.swift` - Automated tests (21 tests)
- `GridWatchZero/Engine/GameEngine.swift` - Debug multiplier implementation

**Status:** ✅ Ready for playtesting (build succeeded, UI added to SettingsView)
