# Performance Profiling & Optimization Analysis
**Date**: 2026-02-12
**Status**: Hotspots identified, recommendations prioritized
**Scope**: Tick loop, SwiftUI recomputation, memory, animations, I/O

---

## Executive Summary

The primary performance concern is a **SwiftUI recomputation storm**: GameEngine has 33 `@Published` properties, and 10-15+ are mutated every tick. Since the entire view hierarchy observes GameEngine via `@EnvironmentObject`, every tick triggers the full DashboardView tree to re-evaluate — including all node cards, connection lines, topology, defense stack, stats, intel panel, and prestige card.

Secondary concerns include double-serialization in the save system (main thread), uncached DefenseStack computed properties (5 separate `.reduce` traversals per tick), and 12-15+ continuous `repeatForever` animations that don't respect `reduceMotion`.

---

## 1. Tick Loop Analysis

### Per-Tick Operation Breakdown

The `processTick()` method (GameEngine.swift) executes every 1 second:

| Phase | Key Operations | Cost |
|-------|---------------|------|
| Defense | Firewall health regen (arithmetic) | Low |
| Threat | 5x DefenseStack `.reduce` traversals, AttackType.allCases filter, RiskCalculation allocation | Medium |
| Events | Random roll with 2% base chance, usually returns nil | Low |
| Batch Upload | Loop over pending reports (when active) | Low |
| Production | CertificateManager multiplier, DataPacket UUID alloc, latencyBuffer filter, EngagementManager calls | Medium |
| Progression | Full milestone scan (16 items), full lore fragment scan | Low-Medium |
| Auto-Save | Double JSON serialization + synchronize() (every 30 ticks) | HIGH |

### @Published Update Storm (Critical)

**33 @Published properties** on GameEngine. Per tick, 10-15+ are mutated:
- `currentTick`, `totalPlayTime`, `lastTickStats` (every tick)
- `resources` (credits/data changes every tick)
- `totalDataGenerated`, `totalDataTransferred`, `totalDataDropped` (every tick)
- `source`, `link`, `sink` (production values)
- `threatState`, `latencyBuffer` (filtered every tick)
- `activeAttack`, `activeRandomEvent`, `defenseStack`, `firewall` (conditional)

Each mutation fires a separate Combine publisher emission → separate SwiftUI view invalidation. A single tick can cause **10-15+ independent view tree re-evaluations** within the same run loop.

---

## 2. SwiftUI Recomputation

### The Core Problem

`DashboardView.swift` line 8:
```swift
@EnvironmentObject var engine: GameEngine
```

Every child view receives the entire GameEngine. When ANY of 33 `@Published` properties changes, **every view reading `engine`** is invalidated and its `body` re-evaluated. This is the single largest performance concern.

### View Tree Scope Per Tick

From DashboardView+iPhone.swift, a single recomputation evaluates:
- 3 NodeCardViews (source, link, sink)
- FirewallCardView
- DefenseApplicationView (defense stack)
- 2 ConnectionLineViews (with particle animations)
- StatsHeaderView
- ThreatIndicatorView
- Intel/Malus panel
- Prestige card
- Engagement banner
- Plus inline computations like `engine.latencyBuffer.reduce(0.0) { $0 + $1.amount }` (line 108)

### Additional @StateObject Singletons

DashboardView also holds 4 more observable objects (lines 11-14):
```swift
@StateObject var tutorialManager = TutorialManager.shared
@StateObject var engagementManager = EngagementManager.shared
@StateObject var achievementManager = AchievementManager.shared
@StateObject var collectionManager = CollectionManager.shared
```

Changes to any of these trigger additional DashboardView body recomputations.

### Missing Equatable Conformance

No view model structs (`TickStats`, `ThreatState`, `PlayerResources`, etc.) conform to `Equatable`. Without it, SwiftUI cannot short-circuit child view body evaluation even when the data hasn't actually changed.

### Positive Pattern: StatsHeaderView

StatsHeaderView receives extracted values rather than the engine — correct pattern. But since DashboardView still reads from `engine` to pass these, the parent always recomputes. The benefit only applies with `Equatable` conformance on inputs.

---

## 3. Memory Hotspots

### DataPacket UUID Allocation
- **File**: Resource.swift
- A new `DataPacket` with `UUID()` is created every tick in the production phase
- UUID involves a system call (`uuid_generate_random`) — unnecessary for a packet consumed in the same tick
- **Fix**: Use monotonic integer ID or remove `Identifiable` if not needed for ForEach

### Latency Buffer Array Churn
- **File**: GameEngine.swift line 251
- `latencyBuffer = latencyBuffer.filter { ... }` allocates a new array every tick
- Being `@Published`, the assignment triggers a view update even when buffer is empty → empty
- **Fix**: Only assign if elements were actually removed

### DefenseStack Repeated Traversals
- **File**: DefenseApplication.swift lines 1137-1202
- 5 computed properties, each a `.reduce` over the full applications array:
  - `totalRiskReduction`
  - `totalIntelBonus`
  - `totalAutomation`
  - `totalIntelMultiplier`
  - `totalCreditProtection`
- Called from multiple sites per tick — same array traversed 10-15+ times total
- **Fix**: Compute all totals once per tick into a cached `DefenseTotals` struct, invalidated only on deploy/upgrade

### Static Database Linear Scans
- **MilestoneDatabase.checkProgress**: Scans all 16 milestones every tick (MilestoneSystem.swift lines 530-536)
- **LoreDatabase.fragmentsUnlockedByCredits**: Scans all lore fragments every tick (LoreSystem.swift lines 712-717)
- **Fix**: Maintain "next threshold" index, only scan when credits cross it. Or check every 5-10 ticks.

---

## 4. Animation Performance

### Continuous Animations Running Simultaneously

| Component | Animation | Count |
|-----------|-----------|-------|
| SourceCardView | Shadow pulse (.repeatForever) | 1 |
| LinkCardView | Shadow pulse (.repeatForever) | 1 |
| SinkCardView | Shadow pulse (.repeatForever) | 1 |
| ThreatIndicatorView | Main pulse, attack flash, early warning | 2-3 |
| ConnectionLineView | Particle animation (×2 lines) | 4-6 |
| ScanlineOverlay | Canvas (~852 fill ops/frame at 3px spacing) | 1 |
| **Total during gameplay** | | **12-15+** |

Additional during attacks: DDoS overlay effects, critical alarm glitch/pulse.

### ScanlineOverlay Per-Frame Cost
- Canvas renders at 3px spacing across full screen
- iPhone 15 Pro (2556px height) = ~852 fill operations per frame
- Being in a ZStack, it redraws whenever the parent invalidates
- **Fix**: Render once to cached `UIImage` or use `drawingGroup()` to rasterize

### reduceMotion Not Respected
- DashboardView checks `reduceMotion` for screen shake (line 245)
- But all `repeatForever` animations on node cards, connection lines, and threat indicators ignore it
- **Fix**: Gate continuous animations behind `reduceMotion` check

### Animation Restart Risk
- Node card pulse animations use `@State` + `.onAppear` — should survive recomputation
- Risk: if view identity changes (ForEach key mismatch), `@State` recreates and animation restarts
- The @Published storm increases the frequency of view evaluations, amplifying any restart bugs

---

## 5. I/O Performance

### Save System (Highest Periodic Cost)

`GameEngine+Persistence.swift` — executes on **main thread** every 30 ticks:

| Step | Operation | Thread | Cost |
|------|-----------|--------|------|
| 1 | `JSONEncoder().encode(state)` | Main | High — full GameState |
| 2 | `UserDefaults.standard.set(data, forKey:)` | Main | Low — memory write |
| 3 | `UserDefaults.standard.synchronize()` | Main | HIGH — forces disk I/O |
| 4 | `UserDefaults.standard.data(forKey:)` | Main | Low — memory read |
| 5 | `JSONDecoder().decode(GameState.self, from:)` | Main | High — full deserialization |

Steps 3-5 are the problem: forced disk sync (deprecated API) + full verification decode. This is a **double serialization** on the main thread.

Additionally, 9 `print()` statements with `.formatted` (locale-aware number formatting) execute per save.

### Save Data Size Growth

GameState includes: PlayerResources, 3 node types, FirewallNode, DefenseStack (6 categories), MalusIntelligence, ThreatState, UnlockState, LoreState, MilestoneState, PrestigeState. Encoded size grows with player progression. Double serialization amplifies proportionally.

### Audio System

AudioManager uses preloaded PCM buffers, a round-robin player pool, and background-thread music loading. **No significant concerns.**

---

## Recommendations (Priority Order)

### HIGH Impact

| # | Fix | Problem | Files | Effort |
|---|-----|---------|-------|--------|
| H1 | Migrate to `@Observable` or split view models | All views observe all 33 properties | GameEngine.swift, DashboardView.swift | High |
| H2 | Move save off main thread, remove verify pass | Double serialization + synchronize() blocks main thread | GameEngine+Persistence.swift | Medium |
| H3 | Cache DefenseStack totals per tick | 5 uncached `.reduce` traversals, called 10-15x/tick | DefenseApplication.swift | Medium |
| H4 | Batch @Published with manual `objectWillChange.send()` | 10-15+ separate view invalidations per tick | GameEngine.swift | Medium |

### MEDIUM Impact

| # | Fix | Problem | Files | Effort |
|---|-----|---------|-------|--------|
| M1 | Throttle milestone/lore scans | Full linear scan every tick | GameEngine+Progression.swift | Low |
| M2 | Add `Equatable` to model structs | SwiftUI can't short-circuit child body evaluation | Resource.swift, ThreatSystem.swift, etc. | Low |
| M3 | Respect `reduceMotion` for continuous animations | 12-15+ animations ignore accessibility setting | NodeCardView, ConnectionLineView, ThreatIndicatorView | Low |
| M4 | Cache ScanlineOverlay rendering | ~852 Canvas fills per frame | ScanlineOverlay.swift | Low |
| M5 | Conditional latencyBuffer assignment | Triggers @Published even when empty→empty | GameEngine.swift | Low |

### LOW Impact

| # | Fix | Problem | Files | Effort |
|---|-----|---------|-------|--------|
| L1 | Remove DataPacket UUID | Unnecessary system call per tick | Resource.swift | Low |
| L2 | Guard print statements with `#if DEBUG` | String interpolation + .formatted in save path | GameEngine+Persistence.swift | Low |
| L3 | Move inline reduce out of view body | `latencyBuffer.reduce()` recomputed 10-15x/tick | DashboardView+iPhone.swift line 108 | Low |
| L4 | Pre-index milestone/lore databases | Linear scan when binary search or index would suffice | MilestoneSystem.swift, LoreSystem.swift | Low |

---

## Implementation Strategy

### Quick Wins (Can Ship Immediately)

1. **H2**: Remove `synchronize()` call and verification decode from save — instant main-thread relief
2. **L2**: Wrap print statements in `#if DEBUG`
3. **M5**: Add guard `if latencyBuffer.isEmpty { return }` before filter
4. **M1**: Change milestone/lore checks to run every 5 ticks instead of every tick
5. **M3**: Add `reduceMotion` checks to continuous animations

### Planned Refactors (Next Sprint)

1. **H1**: Migrate GameEngine to `@Observable` (iOS 17+ — already the deployment target)
   - This is the single highest-impact change, eliminating the recomputation storm
   - `@Observable` provides automatic per-property tracking — only views reading a specific property recompute when it changes
   - Alternative: Split into focused `@ObservableObject` view models

2. **H3**: Create `DefenseTotals` struct computed once per tick at the start of processTick()

3. **H4**: If not migrating to `@Observable`, suppress automatic `@Published` and use manual `objectWillChange.send()` once per tick

4. **M2**: Add `Equatable` conformance to `TickStats`, `ThreatState`, `PlayerResources`, `RiskCalculation`

### Measurement Plan

Before implementing, baseline these metrics using Instruments:
- **Time Profiler**: Measure `processTick()` duration, `saveGame()` duration
- **SwiftUI Instruments**: Count view body evaluations per tick
- **Allocations**: Track per-tick allocations (DataPacket, latencyBuffer, RiskCalculation)
- **Core Animation**: Measure GPU frame time with all animations running
- **Energy Log**: Battery impact during idle gameplay (screen on, no interaction)

After each optimization, re-measure to confirm improvement and check for regressions.

---

## Risk Assessment

| Optimization | Risk | Mitigation |
|-------------|------|------------|
| @Observable migration | Medium — API differences from @ObservableObject | Test all views, especially EnvironmentObject injection |
| Remove save verification | Low — verification was belt-and-suspenders | Keep verification in debug builds only |
| Cache DefenseStack | Low — pure optimization, same values | Unit test cached vs computed values match |
| Manual objectWillChange | Medium — easy to forget to send | Use a wrapper function for all state mutations |
| Throttle scans | Low — milestones/lore thresholds change slowly | Test threshold crossing still detected |
