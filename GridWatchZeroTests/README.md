# GridWatchZero Tests

## Adding the Test Target to Xcode

Since test targets cannot be created via command line tools, follow these steps to add the test target to your Xcode project:

### Step 1: Create Test Target in Xcode

1. Open `GridWatchZero.xcodeproj` in Xcode
2. In the Project Navigator, select the project (top-level "GridWatchZero")
3. At the bottom of the target list, click the "+" button
4. Select "Unit Testing Bundle"
5. Configure the test target:
   - **Product Name**: `GridWatchZeroTests`
   - **Team**: (your development team)
   - **Organization Identifier**: `WarSignal`
   - **Bundle Identifier**: `WarSignal.GridWatchZeroTests`
   - **Project**: GridWatchZero
   - **Target to be Tested**: GridWatchZero
6. Click "Finish"

### Step 2: Delete the Default Test File

Xcode will create a default `GridWatchZeroTests.swift` file. Delete it since we have our own test files.

### Step 3: Add Test Files to Target

1. In Finder, navigate to the `GridWatchZeroTests/` folder
2. Drag the following test files into the GridWatchZeroTests group in Xcode:
   - `GameEngineTests.swift`
   - `ResourceCalculationTests.swift`
   - `DefenseSystemTests.swift`
3. In the dialog that appears:
   - ✅ **Copy items if needed** (uncheck - files are already in place)
   - ✅ **Create groups**
   - ✅ **Add to targets**: GridWatchZeroTests
4. Click "Add"

### Step 4: Configure Test Target Settings

1. Select the **GridWatchZeroTests** target in the project settings
2. Go to **Build Settings**
3. Verify these settings:
   - **Test Host**: GridWatchZero
   - **Bundle Loader**: `$(TEST_HOST)`
   - **Testing Framework**: Swift Testing (default in Xcode 16+)

### Step 5: Enable App Target for Testing

1. Select the **GridWatchZero** (app) target
2. Go to **Build Settings**
3. Search for "Enable Testing"
4. Set **Enable Testing Search Paths** to **Yes**

### Step 6: Run Tests

#### In Xcode UI:
- Press `Cmd+U` to run all tests
- Or click the diamond icon next to any `@Test` function to run individual tests
- Or use **Product → Test** from the menu

#### From Command Line:
```bash
xcodebuild test \
  -project GridWatchZero.xcodeproj \
  -scheme GridWatchZero \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Test Files Overview

### 1. GameEngineTests.swift (18 tests)
Tests core game engine functionality:
- ✅ Initialization
- ✅ Unit purchasing (success/failure/locked)
- ✅ Unit upgrading (success/max level)
- ✅ Tick cycle execution
- ✅ Resource production (source/sink)
- ✅ Threat level progression
- ✅ Save/load persistence
- ✅ Prestige system
- ✅ Offline progress
- ✅ Firewall defense

### 2. ResourceCalculationTests.swift (22 tests)
Tests resource production and conversion:
- ✅ Source production scaling
- ✅ Prestige multipliers
- ✅ Link bandwidth limits
- ✅ Packet loss calculations
- ✅ Sink conversion rates
- ✅ Certificate maturity bonuses
- ✅ Resource formatting (K/M/B/T)
- ✅ Efficiency calculations
- ✅ Combined multipliers

### 3. DefenseSystemTests.swift (20 tests)
Tests defense system mechanics:
- ✅ Defense stack deployment
- ✅ Damage reduction (with tier caps)
- ✅ Risk reduction (attack frequency)
- ✅ Category-specific bonuses (SIEM, Endpoint, IDS, Network, Encryption)
- ✅ Defense points scaling (tier/level)
- ✅ Intel collection
- ✅ Malus intelligence tracking

## Test Coverage Summary

**Total Tests**: 60 tests across 3 files

**Coverage by Priority**:
- ✅ CRITICAL: GameEngine core (18 tests)
- ✅ HIGH: Resource calculations (22 tests)
- ✅ HIGH: Defense system (20 tests)

**Remaining Gaps** (see project/ISSUES.md TODO-002):
- ⚠️ Campaign progression tests
- ⚠️ Save migration tests
- ⚠️ Unit factory tests
- ⚠️ Certificate system tests
- ⚠️ UI component tests

## Running Specific Test Suites

### Run only GameEngine tests:
```swift
// In Xcode: Navigate to GameEngineTests.swift and click the diamond next to the @Suite
```

### Run only a specific test:
```swift
// Click the diamond next to any @Test function
```

### Test from command line with filter:
```bash
xcodebuild test \
  -project GridWatchZero.xcodeproj \
  -scheme GridWatchZero \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:GridWatchZeroTests/GameEngineTests
```

## Understanding Test Results

### ✅ Success Indicators:
- All `#expect` assertions pass
- No `Issue.record()` failures
- Green diamonds in Xcode gutter

### ❌ Failure Indicators:
- `#expect` assertion fails → test shows exact line and expected vs actual values
- `Issue.record()` called → custom failure message displayed
- Red X in Xcode gutter

### Test Output:
- Xcode shows test results in the **Test Navigator** (Cmd+6)
- Console shows detailed test execution log
- Failed tests show diff between expected and actual values

## Best Practices

1. **Run tests before committing**: Ensure all tests pass with `Cmd+U`
2. **Write tests for bugs**: Before fixing a bug, write a failing test that reproduces it
3. **Test edge cases**: Include tests for boundary conditions, invalid inputs, and error states
4. **Keep tests fast**: Unit tests should run in milliseconds
5. **Use descriptive test names**: Function names should clearly state what is being tested

## Next Steps

After adding these tests, consider:

1. **Add Campaign Progression Tests** (PRIORITY: MEDIUM)
   - Level unlock/completion logic
   - Victory/failure conditions
   - Checkpoint save/restore

2. **Add Save System Tests** (PRIORITY: HIGH)
   - Save migration (v5 → v6)
   - iCloud sync
   - Data corruption handling

3. **Add UI Tests** (PRIORITY: LOW)
   - Create `GridWatchZeroUITests` target
   - Test critical user flows
   - Test accessibility

4. **Increase Coverage**
   - Current: ~60 tests covering core systems
   - Target: 100+ tests covering all business logic

## Troubleshooting

### "No such module 'GridWatchZero'"
- Ensure the app target builds successfully first
- Check that `@testable import GridWatchZero` is present
- Verify test target's **Build Settings → Testing → Enable Testing Search Paths** is set to **Yes**

### Tests crash or hang
- Check that GameEngine's `@MainActor` isolation is respected
- Ensure async tests use proper `await` syntax
- Verify no infinite loops in test code

### Tests pass locally but fail in CI
- Check Xcode version consistency
- Verify simulator/device configuration
- Ensure all test files are added to the test target

---

**Created**: 2026-02-06
**Framework**: Swift Testing (Xcode 16+)
**Test Count**: 60 tests (18 + 22 + 20)
**Coverage**: GameEngine, Resources, Defense (CRITICAL + HIGH priority systems)
