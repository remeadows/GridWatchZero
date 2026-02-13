# GridWatchZero — Performance Audit Report
**Date:** 2026-02-13
**Auditor:** Claude (God-Tier SwiftUI Technical Director)
**Target:** Simulator performance degradation on iPhone 17 Pro Max
**Scope:** Read-only codebase analysis — no changes made

---

## Executive Summary

The game loop architecture is fundamentally sound. The tick engine is well-structured with cached defense totals, throttled milestone checks, and a clean production pipeline. However, **the primary performance issue is on the SwiftUI rendering side, not the engine side**. The `@Observable` macro on `GameEngine` combined with the density of property reads in the view hierarchy creates a **full-tree invalidation storm every 1-second tick**. This is your #1 bottleneck.

Secondary issues include permanently-running animations, `NoiseTextureView` Canvas rendering, and excessive overlay stacking on the dashboard.

---

## 🚨 CRITICAL: Full-Tree View Invalidation (PERFORMANCE RISK)

**File:** `GameEngine.swift` + all Dashboard views
**Severity:** HIGH — This is the root cause of simulator sluggishness

### The Problem

`GameEngine` is decorated with `@Observable` and contains **~40+ mutable properties** that change every tick:

```
resources.credits, lastTickStats, currentTick, totalDataGenerated,
totalDataTransferred, totalDataDropped, latencyBuffer, cachedDefenseTotals,
activeAttack, threatState, bandwidthDebuff, processingDebuff,
source.currentLoad, sink.inputBuffer, link.lastTickTransferred...
```

Every tick mutates a cascade of these properties. With `@Observable`, **any read from any view creates a dependency**. The iPhone layout alone reads:

- `engine.resources.credits` (header + every card)
- `engine.lastTickStats` (header + connection lines + topology)
- `engine.source` / `engine.link` / `engine.sink` (cards)
- `engine.isRunning` (header + connection lines)
- `engine.currentTick` (header)
- `engine.threatState` (threat bar + stats)
- `engine.activeAttack` (threat bar + link overlay)
- `engine.defenseStack` (defense stack view + topology)
- `engine.malusIntel` (intel panel)
- `engine.totalDataGenerated/Transferred/Dropped` (stats view)
- `engine.firewall` (firewall card)
- `engine.activeEarlyWarning` (threat bar)
- `engine.batchUploadState` (intel panel)
- `engine.totalBufferedData` (link card — computed property re-traverses latencyBuffer)

**Result:** Every single tick triggers a diff of the **entire DashboardView tree** — header, threat bar, all node cards, connection lines, topology view, defense stack, stats view, intel panel, and prestige card. On iPad, this includes 3-panel layout with duplicate reads.

### Why It's Worse in Simulator

The iOS Simulator runs SwiftUI layout on the CPU (no GPU acceleration for view diffing). Real devices will be faster, but the invalidation scope is still too broad for a 1Hz game loop.

### Recommended Fix

Split `GameEngine` into purpose-specific observable objects:

1. **TickDisplayState** — `lastTickStats`, `currentTick`, `isRunning` (read by header/lines)
2. **NodeState** — source, link, sink, firewall (read by cards)
3. **ThreatDisplayState** — `threatState`, `activeAttack`, `earlyWarning` (read by threat bar)
4. **DefenseDisplayState** — `defenseStack`, `cachedDefenseTotals` (read by defense views)
5. **IntelDisplayState** — `malusIntel`, `batchUploadState` (read by intel panel)

Each view then only subscribes to the slice it needs. Tick processing updates all slices, but SwiftUI only invalidates views whose specific slice changed.

**Alternative (less invasive):** Keep single engine but use `withObservationTracking` or manual `willSet`/`didSet` to batch mutations, and extract computed display values into a separate `@Observable` that only updates when display-relevant values change.

---

## 🚨 PERFORMANCE RISK: NoiseTextureView Canvas Rendering

**File:** `Theme.swift` (lines 211-235)
**Severity:** MEDIUM-HIGH

```swift
struct NoiseTextureView: View {
    var body: some View {
        Canvas { context, size in
            var rng = StableRNG(seed: 42)
            let step: CGFloat = 3
            for x in stride(from: 0, to: size.width, by: step) {
                for y in stride(from: 0, to: size.height, by: step) {
                    // ... fill rect per pixel
                }
            }
        }
    }
}
```

This generates a full-screen noise texture by iterating every 3px cell and filling rectangles. On iPhone 17 Pro Max (2796×1290 logical), that's approximately **~160,000 fill operations** per Canvas redraw.

**The `GlassDashboardBackground` containing this is placed directly in the DashboardView ZStack**, meaning it can potentially be invalidated by any parent state change.

The `ScanlineOverlay` uses `.drawingGroup()` which rasterizes to Metal — good. But `NoiseTextureView` does NOT have `.drawingGroup()`.

### Recommended Fix

1. Add `.drawingGroup()` to `NoiseTextureView`
2. Better: Pre-render the noise texture to a `UIImage` once at app launch and use `Image(uiImage:)` instead
3. Even better: Use an asset catalog PNG — a 100x100 tiling noise texture is ~2KB and eliminates all runtime computation

---

## PERFORMANCE RISK: Perpetual Animations on Node Cards

**File:** `NodeCardView.swift`
**Severity:** MEDIUM

Every `SourceCardView`, `LinkCardView`, and `SinkCardView` runs a perpetual pulsing animation:

```swift
.onAppear {
    guard !reduceMotion else { return }
    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
        isPulsing = true
    }
}
```

This applies a continuously animating `.shadow()` modifier:

```swift
.shadow(color: .neonGreen.opacity(isPulsing ? 0.3 : 0.1), radius: isPulsing ? 8 : 3)
```

Three perpetually animating shadows (source, link, sink) force continuous **compositing layer updates** on every animation frame (~60fps). Combined with the 1Hz tick invalidation, the GPU is compositing animated shadows while the CPU is diffing the full tree.

### Recommended Fix

- Gate pulsing animations behind a user preference or limit to "idle" state
- Use `TimelineView(.animation)` with explicit frame control instead of `repeatForever`
- Consider removing the pulsing shadow entirely — it adds visual noise with minimal UX value
- At minimum, use `.compositingGroup()` before `.shadow()` to flatten the compositing

---

## PERFORMANCE RISK: ConnectionLineView Particle System

**File:** `ConnectionLineView.swift`
**Severity:** MEDIUM

Each `ConnectionLineView` runs `repeatForever` animation on `animationPhase`:

```swift
withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
    animationPhase = 1.0
}
```

With 2 connection lines visible (source→link, link→sink), each containing up to 3 animated particles with `.glow()` modifiers (which add `.shadow()`), that's 6 continuously animated shadow layers.

The `DataPacketParticle` struct is defined but appears unused — dead code.

### Recommended Fix

- Replace particle animation with a simple repeating offset animation (no shadow/glow on particles)
- Remove `DataPacketParticle` dead code
- Consider `Canvas`-based particle rendering for the connection lines instead of multiple SwiftUI views

---

## PERFORMANCE RISK: `.terminalCard()` Modifier Overdraw

**File:** `Theme.swift` (TerminalCardModifier)
**Severity:** MEDIUM

Every `.terminalCard()` applies:

```swift
// Base: 2 stacked color layers
ZStack {
    Color.terminalDarkGray.opacity(0.55)
    Color.terminalBlack.opacity(0.15)
}
// Material blur
.background(.ultraThinMaterial.opacity(0.4))
// Inner shadow (blur + mask)
.overlay(RoundedRectangle.stroke.blur.offset.mask)
// Neon rim glow (stroke + shadow)
.overlay(RoundedRectangle.stroke.shadow)
// Outer depth shadow
.shadow(...)
```

That's **6 compositing operations per card**. The iPhone dashboard has approximately 8-10 cards visible simultaneously (source, link, sink, firewall, defense stack items, stats, intel, prestige). That's **~60 compositing layers** just for card chrome, all recomposited when any parent state triggers invalidation.

### Recommended Fix

- Add `.compositingGroup()` at the end of `TerminalCardModifier` to flatten each card into a single compositing layer
- Consider pre-rendering the card background as a 9-slice image asset
- Remove the inner shadow blur/mask — it's a significant per-card cost for a subtle visual effect

---

## ARCHITECTURAL OBSERVATION: Timer on Main RunLoop

**File:** `GameEngine.swift` (line 310)

```swift
tickTimer = Timer.publish(every: tickInterval, on: .main, in: .common)
    .autoconnect()
    .sink { [weak self] _ in
        self?.processTick()
    }
```

The tick fires on `.main` RunLoop in `.common` mode. This is correct for a 1Hz tick — it properly coalesces with scrolling. However, `processTick()` executes synchronously on the main thread. The method itself is lightweight (~O(n) over defense apps, n≤6), but it directly mutates all the `@Observable` properties that trigger the view invalidation storm above.

### Observation

Not a direct perf bug, but if `processTick()` ever grows heavier (more defense apps, more complex campaign checks), it will directly block UI responsiveness. Consider profiling the tick duration with Instruments.

---

## STABILITY NOTE: DispatchQueue.main.asyncAfter for Event Banners

**File:** `DashboardView.swift` (handleEvent, triggerScreenShake)

Multiple `DispatchQueue.main.asyncAfter` calls are used for event banner timing and screen shake sequencing. These are not cancellable and can stack if events fire rapidly. During intense attack sequences, you could get overlapping shake animations and banner state conflicts.

### Recommended Fix

Replace with `Task { try await Task.sleep(...) }` with proper cancellation, or use a single `TimelineView` for shake sequencing.

---

## MINOR: `totalBufferedData` Computed Property

**File:** `GameEngine.swift`

```swift
var totalBufferedData: Double {
    latencyBuffer.reduce(0.0) { $0 + $1.amount }
}
```

This is a computed property on `@Observable`, meaning any view reading it creates an observation dependency. Since `latencyBuffer` is mutated every tick (decrement loop + append), this computed property triggers re-evaluation every tick for any view that reads it. `LinkCardView` reads it.

### Recommended Fix

Cache the total as a stored property, update it when latencyBuffer changes.

---

## FIX TRACKER

| Priority | Issue | Status | Commit | Notes |
|----------|-------|--------|--------|-------|
| P0 | Observable scope — TickDisplayState isolation | ✅ DONE | `856f2a6` | iPhone + iPad dashboard migrated. All mutation paths sync. |
| P0 | TitleScreenView scanline ForEach → Canvas | ✅ DONE | `df8efd7` | ~240 Rectangle views replaced with single Canvas + drawingGroup |
| P0 | TitleScreenView glow compositingGroup | ✅ DONE | `df8efd7` | Flattens glow+glitch into single rasterized composite |
| P1 | NoiseTextureView — add drawingGroup | ✅ DONE | `856f2a6` | Added .drawingGroup() to Theme.swift NoiseTextureView |
| P1 | `.terminalCard()` — add `.compositingGroup()` | ✅ DONE | (prior) | Flattens ~60 compositing layers per dashboard |
| P1 | Global `.animation()` on RootNavigationView | ✅ DONE | pending | Was double-animating all transitions + rendering both screens |
| P1 | MainMenuView gridBackground drawingGroup | ✅ DONE | pending | Static Path rasterized to Metal |
| P2 | Perpetual shadow animations on node cards | ✅ DONE | (prior) | .compositingGroup() on all 3 cards |
| P2 | ConnectionLineView particle shadows | ✅ DONE | (prior) | .glow() removed from particles |
| P3 | DispatchQueue.main.asyncAfter → Task.sleep | 🔴 TODO | — | Event banners can stack during rapid attacks |
| P3 | Cache totalBufferedData | 🔴 TODO | — | Computed property re-traverses latencyBuffer every tick |
| P3 | GameplayContainerView victoryProgress observation | 🟡 MINOR | — | Reads ~6 engine props per tick; body is thin so low impact |

### User-Reported Issues (2026-02-13)

- Title screen → campaign menu transition: SLOW (pre-fix recording captured)
- Level goals screen: SLOW (user report, longer video forthcoming)
- Dashboard gameplay: NOT YET VERIFIED (recording never reached dashboard)

### Root Cause Analysis (Session 2)

Global `.animation(.easeInOut, value: coordinator.currentScreen)` on RootNavigationView's ZStack was the likely primary cause of transition sluggishness. Every navigation already used explicit `withAnimation`, so the global modifier caused **double-animation** where SwiftUI rendered BOTH the departing and arriving screens simultaneously (each with GlassDashboardBackground = ~320K Canvas fill ops). Removed in this session.

### Xcode Cloud Baseline

If regression testing needed, restore from last successful Xcode Cloud build on `main` branch (pre-CLAUDE_UPDATE).

---

## What's Actually Good

The codebase has several smart performance decisions already in place:

- **`cachedDefenseTotals = defenseStack.computeTotals()`** — Single-pass aggregation per tick instead of N individual property traversals. Well done.
- **Milestone/lore checks throttled to every 5 ticks** — Prevents O(n) scans from running every second.
- **Auto-save every 30 ticks** — Not hammering UserDefaults every tick.
- **`ScanlineOverlay` uses `.drawingGroup()`** — Correctly rasterized to Metal.
- **`StableRNG` for noise** — Avoids random() per-frame. Deterministic is good.
- **`@Environment(\.accessibilityReduceMotion)` checks** — Animations disabled for accessibility. Professional.
- **Campaign checkpoint saves separated from endless saves** — Prevents cross-contamination.
- **`ContinuousUpgradeButton` uses structured concurrency** — Proper Task cancellation on finger lift.

The engine architecture is clean. The performance wall is in the rendering layer, not the game logic.

---

*No code changes were made during this audit.*
