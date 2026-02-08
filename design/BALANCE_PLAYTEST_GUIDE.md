# Balance Playtesting Guide - Grid Watch Zero

**Date**: 2026-02-06
**Purpose**: Validate that 2x credit multipliers don't trivialize Normal mode
**Status**: CRITICAL TESTING REQUIRED (see MONETIZATION_BRAINSTORM.md)

---

## Overview

This guide provides instructions for manually playtesting Grid Watch Zero with 2x credit multipliers enabled to validate the balance considerations documented in `MONETIZATION_BRAINSTORM.md`.

**Two CRITICAL questions to answer:**
1. Does 2x multiplier trivialize Normal mode?
2. Is Insane mode still challenging with 2x multipliers?

---

## Automated Tests (Already Complete)

✅ **BalanceMultiplierTests.swift** - 25 automated tests created
- Calculates theoretical completion times with multipliers
- Validates all 5 guardrails are in place
- Tests anti-abuse measures
- Confirms Insane mode remains challenging

**Result**: All mathematical projections pass. Now need real playtesting for "feel".

---

## Manual Playtesting Setup

### Step 1: Enable Debug Multiplier

The `GameEngine` now has a debug-only multiplier for testing. To enable:

1. Open **Xcode**
2. Navigate to `GridWatchZero/Views/SettingsView.swift`
3. Add a debug section (only visible in DEBUG builds):

```swift
#if DEBUG
Section(header: Text("🔧 DEBUG: Balance Testing")) {
    VStack(alignment: .leading, spacing: 8) {
        Text("Credit Multiplier: \(String(format: "%.1f", engine.debugCreditMultiplier))×")
            .font(.caption)
            .foregroundColor(.secondary)

        HStack {
            Button("1.0× (Baseline)") {
                engine.debugCreditMultiplier = 1.0
            }
            .buttonStyle(.bordered)

            Button("1.5× (Ad Boost)") {
                engine.debugCreditMultiplier = 1.5
            }
            .buttonStyle(.bordered)

            Button("2.0× (Pro)") {
                engine.debugCreditMultiplier = 2.0
            }
            .buttonStyle(.bordered)
        }

        Text("Testing monetization balance. Remove before production.")
            .font(.caption2)
            .foregroundColor(.orange)
    }
}
#endif
```

### Step 2: Reset Campaign Progress

For accurate testing, start fresh:

1. Settings → **Reset Campaign Progress**
2. Confirm reset

### Step 3: Choose Test Scenario

Pick one of the following test scenarios:

---

## Test Scenario A: Normal Mode Early Game (Levels 1-7)

**Goal**: Can Level 1-7 be completed in <30 minutes total with 2x?

### Test Protocol

1. **Set multiplier to 2.0×** (Grid Watch Pro simulation)
2. Start **Level 1** in Campaign mode
3. Record the following for each level:
   - Start time
   - End time (when victory conditions met)
   - "Feel" rating: Too Easy / Just Right / Too Hard
   - Notes on strategic depth

### Expected Times (with 2x)

| Level | Target Credits | Expected Time | Intel Reports |
|-------|----------------|---------------|---------------|
| 1 | 50K | 8-10 min | 5 |
| 2 | 100K | 10-12 min | 10 |
| 3 | 500K | 12-15 min | 20 |
| 4 | 1M | 15-20 min | 40 |
| 5 | 5M | 20-25 min | 80 |
| 6 | 10M | 25-30 min | 160 |
| 7 | 25M | 30-45 min | 320 |

**Total Expected**: ~2 hours for Levels 1-7

### Key Questions to Answer

- [ ] Does progression feel **too fast** (burnout)?
- [ ] Do you feel **progression satisfaction** or "it's too easy"?
- [ ] Does the multiplier make **defense building feel optional**?
- [ ] Are intel reports still a meaningful time gate?
- [ ] Do you still need to survive attacks strategically?

### Success Criteria

✅ **PASS** if:
- Levels 1-7 complete in 90-150 minutes
- Defense building still feels important
- Intel reports provide meaningful pacing
- Progression feels rewarding, not trivial

❌ **FAIL** if:
- Levels 1-7 complete in <60 minutes (too fast)
- Can ignore defense and just spam upgrades
- Feels like "pay to win"

---

## Test Scenario B: Normal Mode Mid-Game (Level 7)

**Goal**: Is Level 7 (50% campaign checkpoint) engaging with 2x?

### Test Protocol

1. **Set multiplier to 2.0×**
2. Start **Level 7** directly (if unlocked)
3. Play through complete level
4. Track:
   - Total time to victory
   - Number of attacks survived
   - Firewall health at completion
   - Highest defense points reached
   - Grade achieved (S/A/B/C)

### Expected Results (with 2x)

- **Time**: 30-45 minutes
- **Credits**: 25M required
- **Intel Reports**: 320 required
- **Attacks**: 15-25 survived
- **Grade**: B or C (faster completion = harder S-rank)

### Key Questions to Answer

- [ ] Does 30-45 minutes feel like a healthy session length?
- [ ] Does threat escalation keep pace with credit acceleration?
- [ ] Is strategic depth maintained (defense apps, intel, timing)?
- [ ] Would you replay for better grade?
- [ ] Does completion feel satisfying or anticlimactic?

### Success Criteria

✅ **PASS** if:
- Level 7 feels challenging but achievable
- 30-45 minute completion time
- Strategic decisions still matter
- Would motivate replay for S-rank

❌ **FAIL** if:
- Level 7 feels trivial or boring
- Can complete in <20 minutes
- Defense building feels pointless

---

## Test Scenario C: Insane Mode Validation

**Goal**: Is Insane mode still challenging with 2x multipliers?

### Test Protocol

1. **Complete Normal Mode Level 7** first (to unlock Insane)
2. **Set multiplier to 2.0×**
3. Start **Insane Mode Level 1**
4. Play for 30-60 minutes
5. Track:
   - Credits earned
   - Attack frequency
   - Firewall damage taken
   - Whether progression feels achievable or frustrating

### Expected Results (with 2x)

- **Credits Required**: 150K (3× Normal)
- **Attack Frequency**: 2× Normal
- **Damage**: Higher than Normal
- **Time**: ~25-30 minutes (vs. 8-10 Normal)

### Key Questions to Answer

- [ ] Does 2x multiplier feel like **quality-of-life** or **pay-to-win**?
- [ ] Is Insane mode still challenging enough?
- [ ] Does it feel like "New Game+" content?
- [ ] Would you consider buying Pro unlock for Insane mode help?

### Success Criteria

✅ **PASS** if:
- Insane mode feels significantly harder than Normal
- 2x multiplier feels helpful but not trivializing
- Positioning as "support future content" resonates
- Insane mode >20% adoption rate likely

❌ **FAIL** if:
- Insane mode feels too easy with 2x
- Multiplier feels like "pay to win"
- No motivation to replay Insane

---

## Test Scenario D: 1.5× Temporary Boost (Rewarded Ads)

**Goal**: Does temporary 1.5× boost feel more active than passive Pro?

### Test Protocol

1. **Set multiplier to 1.5×** (Rewarded Ad simulation)
2. Play Level 3 or 4
3. Every 10 minutes of playtime:
   - Toggle multiplier OFF for 50 minutes (simulating cooldown)
   - Toggle multiplier ON for 10 minutes (simulating ad watch)
4. Track:
   - Overall progression impact
   - Whether 10-minute boost feels meaningful
   - Whether you'd watch ads for this boost

### Expected Results

- **Effective Reduction**: 20-30% time savings
- **Uptime**: ~15% (10 min boost / 60 min cycle)
- **Feel**: More "active" than passive 2x

### Key Questions to Answer

- [ ] Does 10-minute boost duration feel right?
- [ ] Is 1-hour cooldown acceptable?
- [ ] Would you watch 15-30 second ads for this?
- [ ] Does it feel less "pay to win" than permanent 2x?

### Success Criteria

✅ **PASS** if:
- 10-minute boost feels meaningful but not game-breaking
- 1-hour cooldown doesn't feel punishing
- Would watch ads for this reward
- Feels "tasteful" and optional

❌ **FAIL** if:
- 10-minute boost feels too short
- 1-hour cooldown feels too long
- Not worth watching ads for

---

## Data Collection Template

Use this template for each playtest session:

```
=== PLAYTEST SESSION ===
Date: ___________
Scenario: (A/B/C/D)
Multiplier: ___×

--- LEVEL DATA ---
Level: ___
Start Time: ___:___
End Time: ___:___
Total Duration: ___ minutes

Credits Earned: ___________
Intel Reports Sent: ___
Attacks Survived: ___
Grade: (S/A/B/C)

--- FEEL RATINGS (1-5) ---
Progression Speed: ___ (1=Too Slow, 3=Just Right, 5=Too Fast)
Strategic Depth: ___ (1=Trivial, 3=Balanced, 5=Too Complex)
Defense Building: ___ (1=Optional, 3=Important, 5=Critical)
Threat Challenge: ___ (1=Too Easy, 3=Balanced, 5=Too Hard)
Replay Motivation: ___ (1=None, 3=Maybe, 5=Definitely)

--- OBSERVATIONS ---
What worked well:
-
-

What felt off:
-
-

Monetization perception (pay-to-win or quality-of-life?):
-

Would you buy Pro unlock ($3.99) based on this?:
YES / NO / MAYBE

Would you watch ads for temporary boost?:
YES / NO / MAYBE

--- VERDICT ---
PASS / FAIL / NEEDS ADJUSTMENT
```

---

## Summary Metrics to Track

After completing all test scenarios, compile:

### Completion Times

| Level | Baseline (1×) | With 2× | Difference |
|-------|---------------|---------|------------|
| 1 | ___ min | ___ min | ___% |
| 2 | ___ min | ___ min | ___% |
| 3 | ___ min | ___ min | ___% |
| 4 | ___ min | ___ min | ___% |
| 5 | ___ min | ___ min | ___% |
| 6 | ___ min | ___ min | ___% |
| 7 | ___ min | ___ min | ___% |

### Guardrails Validation

- [ ] Intel reports still required (time gate)
- [ ] Defense building still strategic
- [ ] Campaign gates prevent skipping
- [ ] Grade system provides replay value
- [ ] Insane mode justifies multipliers

### Monetization Perception

- [ ] 2× feels like quality-of-life, not pay-to-win
- [ ] 1.5× temporary boost feels active and engaging
- [ ] Pro unlock at $3.99 feels fair
- [ ] Ad frequency limits (3/hour) feel reasonable
- [ ] Multipliers preserve game depth

---

## Next Steps After Testing

### If Tests PASS

1. ✅ Mark CRITICAL TODOs as complete in MONETIZATION_BRAINSTORM.md
2. ✅ Document findings in this file
3. ✅ Proceed with StoreKit integration
4. ✅ Integrate AdMob SDK
5. ✅ Remove `debugCreditMultiplier` before production

### If Tests FAIL

1. ❌ Document specific issues
2. ❌ Adjust multiplier values:
   - Consider 1.75× instead of 2× for Pro
   - Consider 1.25× instead of 1.5× for ads
3. ❌ Re-run automated tests with new values
4. ❌ Playtest again with adjusted multipliers

### If Tests INCONCLUSIVE

1. ⚠️ Identify specific concerns
2. ⚠️ Design focused follow-up tests
3. ⚠️ Consider A/B testing with players
4. ⚠️ Consult MONETIZATION_BRAINSTORM.md for alternatives

---

## Quick Reference: Debug Multiplier Usage

### Enable 2× (Grid Watch Pro simulation)
```swift
engine.debugCreditMultiplier = 2.0
```

### Enable 1.5× (Rewarded Ad simulation)
```swift
engine.debugCreditMultiplier = 1.5
```

### Disable (Baseline)
```swift
engine.debugCreditMultiplier = 1.0
```

### Check Current Multiplier
```swift
print("Current multiplier: \(engine.debugCreditMultiplier)×")
```

---

## Important Notes

⚠️ **DEBUG ONLY**: The `debugCreditMultiplier` is wrapped in `#if DEBUG` and will NOT be included in production builds.

⚠️ **NOT SAVED**: The multiplier is not persisted in save files. It resets to 1.0× when relaunching the app.

⚠️ **REMOVE BEFORE RELEASE**: All debug multiplier code must be removed before App Store submission.

⚠️ **AUTOMATED TESTS**: Run `BalanceMultiplierTests` before manual playtesting to validate mathematical projections.

---

## Contact & Feedback

After completing playtesting, update:
- `design/MONETIZATION_BRAINSTORM.md` (mark TODOs complete or document issues)
- `project/ISSUES.md` (if adjustments needed)
- This file (document findings in "Test Results" section below)

---

## Test Results

### Session 1: [DATE]
- Tester: ___________
- Scenario: ___
- Result: PASS / FAIL / INCONCLUSIVE
- Notes:

### Session 2: [DATE]
- Tester: ___________
- Scenario: ___
- Result: PASS / FAIL / INCONCLUSIVE
- Notes:

### Session 3: [DATE]
- Tester: ___________
- Scenario: ___
- Result: PASS / FAIL / INCONCLUSIVE
- Notes:

---

**Created**: 2026-02-06
**Framework**: Manual + Automated Testing
**Critical TODOs**: See MONETIZATION_BRAINSTORM.md lines 463-464
**Status**: READY FOR PLAYTESTING
