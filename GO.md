# GO.md - Project Plague: Neural Grid

## Quick Start

```bash
# Open the Xcode project
open "/Volumes/DEV/Code/dev/Games/ProjectPlague/ProjectPlague/Project Plague/Project Plague.xcodeproj"
```

Then press **Cmd+R** to build and run.

---

## Documentation Index

| Document | Purpose |
|----------|---------|
| [CLAUDE.md](./CLAUDE.md) | AI assistant context - project structure, patterns, commands |
| [CONTEXT.md](./CONTEXT.md) | Game concept, narrative, design philosophy |
| [PROJECT_STATUS.md](./PROJECT_STATUS.md) | Implementation progress, current version, next tasks |
| [ISSUES.md](./ISSUES.md) | Bug tracking, enhancement requests |
| [DESIGN.md](./DESIGN.md) | Full game design document with mechanics |

---

## Current Sprint: Phase 8 - Platform & Polish

### ✅ Completed: iPhone Layout Fix (2026-01-27)
Added responsive layouts to NodeCardView for iPhone vs iPad:
- SourceCardView, LinkCardView, SinkCardView now detect `horizontalSizeClass`
- iPhone (compact): Vertical stat layout with full-width upgrade buttons
- iPad (regular): Horizontal inline stat layout (preserved)

### ✅ Completed: Helix Awakening Cinematic (2026-01-27)
15-second cinematic sequence after Level 7 completion:
- Dormant Helix (Helixv2) with pulsing aura and eye glow effect
- Crossfade to awakened Helix (Helix_The_Light) looking upward
- Procedural cyberpunk ambient audio (bass drone + harmonics)
- Skip button, reduce motion support, particle effects

### Completed in Phase 8 (2026-01-27)
- ✅ iPad Layout - Side-by-side panels, horizontal card layout
- ✅ Accessibility - Reduce Motion support, VoiceOver labels
- ✅ Game Balance - Level pacing (30-60 min), unit cost reductions
- ✅ Center Panel Visibility - Brighter colors, thicker borders, larger fonts
- ✅ iPhone Layout - Responsive card layouts for narrow screens
- ✅ Helix Awakening - Cinematic sequence for Level 7 completion

### Completed in Phase 7: Security Systems
- Defense Application System (6 categories with progression chains)
- Network Topology visualization
- Critical Alarm full-screen overlay
- Malus Intelligence tracking
- Title changed to "PROJECT PLAGUE"

### Remaining Tasks
1. **App Store Prep** - Screenshots, metadata, TestFlight

### New Files Added
- `Models/DefenseApplication.swift` - Security app model
- `Views/Components/DefenseApplicationView.swift` - Security app cards, topology
- `Views/Components/CriticalAlarmView.swift` - Full-screen alarm
- `Views/HelixAwakeningView.swift` - Level 7 completion cinematic

### Files to Modify
- `Views/DashboardView.swift` - iPad layout with NavigationSplitView
- All Views - Accessibility labels and modifiers
- `Info.plist` - App Store metadata
- `Assets.xcassets` - App icons and screenshots

---

## Development Workflow

### Adding New Files
1. Create file in correct folder via code
2. In Xcode: Right-click folder → "Add Files to 'Project Plague'..."
3. Select file, ensure "Copy items if needed" is **unchecked**
4. Build to verify (Cmd+B)

### Testing Threat System
Add debug credits to quickly reach higher threat levels:
```swift
// In GameEngine, call:
engine.addDebugCredits(100000)
```

### Testing Prestige
To test the prestige (Network Wipe) system:
```swift
// Accumulate enough credits, then:
engine.performPrestige()
```

### Save Data Location
UserDefaults key: `ProjectPlague.GameState.v5`

To reset: Delete app from simulator or call `engine.resetGame()`

---

## Architecture Quick Reference

```
┌─────────────────────────────────────────────────┐
│                  DashboardView                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │  Header  │ │  Threat  │ │   Alert Banner   │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
│  ┌──────────────────────────────────────────┐   │
│  │              Network Map                  │   │
│  │   [Source] → [Link] → [Sink]             │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │              Stats Panel                  │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│                  GameEngine                      │
│  - processTick() runs every 1 second            │
│  - Manages: resources, nodes, threats           │
│  - @Published for SwiftUI reactivity            │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│                    Models                        │
│  - SourceNode, TransportLink, SinkNode          │
│  - FirewallNode, DefenseStack (6 categories)    │
│  - ThreatState, Attack, ThreatLevel             │
│  - EventSystem, LoreSystem, MilestoneSystem     │
│  - PlayerResources, PrestigeState, MalusIntel   │
└─────────────────────────────────────────────────┘
```

---

## Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Terminal Black | #0D0D14 | Background |
| Terminal Dark Gray | #1A1A1F | Card backgrounds |
| Neon Green | #33FF66 | Data, success, source |
| Neon Cyan | #4DE6FF | Links, info |
| Neon Amber | #FFBF33 | Credits, warnings |
| Neon Red | #FF4D4D | Threats, damage |
| Terminal Gray | #333338 | Borders, disabled |

---

## Key Contacts

**Project**: Personal/Solo
**Repository**: Local at `/Volumes/DEV/Code/dev/Games/ProjectPlague`

---

## Session Checklist

Before ending a session:
- [ ] Update PROJECT_STATUS.md with progress
- [ ] Log any new issues in ISSUES.md
- [ ] Commit changes (if using git)
- [ ] Note next tasks in PROJECT_STATUS.md
