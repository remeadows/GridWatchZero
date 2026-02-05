# SESSIONS.md — Grid Watch Zero

> **Update this file BEFORE every Claude Code session**

---

## Build Status

- [ ] ✅ Compiles successfully
- [ ] ✅ Runs in Simulator
- [ ] ❌ Broken

**Last successful build:** YYYY-MM-DD
**Simulator target:** iPhone 16 Pro Max / iPad Pro 13"
**Xcode version:** 16.x
**Swift version:** 6

---

## Current Game State (Plain English)

What happens when you launch and play:

### App Launch & Navigation
- App launches to Home/Campaign Hub: ⬜
- Can select campaign level: ⬜
- Dashboard loads correctly: ⬜
- Can return to Campaign Hub: ⬜

### Core Game Loop
- Tick fires every 1 second: ⬜
- Source generates data: ⬜
- Link transfers data (bandwidth limited): ⬜
- Sink processes data → credits: ⬜
- Packet loss on overflow: ⬜

### Unit System
- Can open Unit Shop: ⬜
- Units display correctly: ⬜
- Can purchase/upgrade units: ⬜
- Tier gates working (MAX badge): ⬜
- All 25 tiers accessible at appropriate levels: ⬜

### Threat & Defense
- Threat level escalates with credits: ⬜
- Attacks trigger at appropriate frequency: ⬜
- Firewall absorbs damage: ⬜
- Defense Apps reduce damage: ⬜
- Critical Alarm overlay triggers: ⬜

### Progression Systems
- Intel Reports can be sent: ⬜
- Milestones unlock correctly: ⬜
- Lore fragments appear: ⬜
- Level completion triggers: ⬜
- Prestige (Network Wipe) works: ⬜

### Save/Load
- Auto-save every 30 ticks: ⬜
- Manual save on pause: ⬜
- Offline progress calculated: ⬜
- iCloud sync working: ⬜

### UI/UX
- iPad layout (NavigationSplitView): ⬜
- iPhone layout (responsive): ⬜
- Alert banner doesn't push layout: ⬜
- VoiceOver labels present: ⬜
- Reduce Motion respected: ⬜

---

## What Was Already Tried (IMPORTANT)

| Session Date | What Was Tried | Result |
|--------------|----------------|--------|
| | | |
| | | |
| | | |

---

## This Session's SINGLE Goal

> **[Write ONE specific, testable goal here]**

**Why this matters:** [Explain the player impact or technical debt being addressed]

---

## Acceptance Criteria (Checkboxes)

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
- [ ] Builds without warnings
- [ ] Tested in Simulator (iPhone + iPad)

---

## Reference Material

### Architecture Docs
- `CLAUDE.md` — Project structure, patterns, commands
- `archive/CONTEXT.md` — Narrative, design philosophy (legacy — see design/DESIGN.md)
- `SKILLS.md` — Required skill set, Definition of Done
- `design/GAMEPLAY.md` — Balance, unit stats, formulas

### Key Files (Read First)
- `Engine/GameEngine.swift` — Core tick loop, all systems
- `Models/Resource.swift` — PlayerResources, DataPacket
- `Views/DashboardView.swift` — Main game screen
- `Views/Theme.swift` — Colors, fonts, modifiers

---

## Files Likely To Change

```
[List specific files this session will modify]
```

Example:
- `Engine/GameEngine.swift` — [reason]
- `Views/Components/XxxView.swift` — [reason]
- `Models/Xxx.swift` — [reason]

---

## DO NOT Touch These Files (Unless Explicitly Required)

- `GridWatchZeroApp.swift` — Entry point, stable
- `Engine/AudioManager.swift` — Working, complex state
- `Views/Theme.swift` — Shared across all views
- Any file in `archive/AppPhoto/` — Art assets, not code

---

## Session Notes

```
[Claude fills this in during the session]

Changes made:
- 

Issues encountered:
- 

Left incomplete:
- 

Next session should:
- 
```

---

## Quick Commands

```bash
# Open project
open "/Users/russmeadows/Dev/Games/GridWatchZero/GridWatchZero.xcodeproj"

# Build: Cmd+B in Xcode
# Run: Cmd+R in Xcode
# Clean Build: Cmd+Shift+K

# Reset save data (in code)
engine.resetGame()

# Add debug credits (in code)
engine.addDebugCredits(100000)
```

---

## Save Data Reference

- **Key:** `GridWatchZero.GameState.v6`
- **Location:** UserDefaults + iCloud (NSUbiquitousKeyValueStore)
- **Migration:** Increment version when changing GameState structure

---

## Threat Level Quick Reference

| Level | Name | Credits Threshold | Attack Chance |
|-------|------|-------------------|---------------|
| 1 | GHOST | 0 | 0% |
| 2 | BLIP | 100 | 0.5% |
| 3 | SIGNAL | 1,000 | 1% |
| 4 | TARGET | 10,000 | 2% |
| 5 | PRIORITY | 50,000 | 3.5% |
| 6 | HUNTED | 250,000 | 5% |

---

## Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| Swift 6 concurrency error | Use `@MainActor`, `@unchecked Sendable`, or `Task { @MainActor in }` |
| File not in build | Right-click folder → Add Files to 'GridWatchZero' |
| Save not loading | Check key version matches `GameState.v6` |
| Large number precision warning | Use scientific notation in UnitFactory |
| View not updating | Ensure property is `@Published` in GameEngine |

---

## Session Discipline Reminders

1. ✅ Read SKILLS.md first (hard requirement)
2. ✅ State acknowledgment before coding
3. ✅ Update this file BEFORE starting
4. ✅ ONE goal per session
5. ✅ Update project/PROJECT_STATUS.md when done
6. ✅ Log issues in project/ISSUES.md
7. ✅ Leave codebase cleaner than you found it
