# GO.md — Grid Watch Zero

## Hard Requirement: Read Order (Enforced)

**STOP. Do not code yet.**

You must read the project docs in this exact order:

1) **SKILLS.md**  ✅ (mandatory first)
2) GO.md
3) CLAUDE.md
4) CONTEXT.md
5) PROJECT_STATUS.md
6) ISSUES.md
7) README.md

If you have not read **SKILLS.md first**, you are **not authorized to modify code**.

---

## Hard-Fail Gate (Must Acknowledge)

Before writing or editing any code, you must explicitly state:

- “I have read SKILLS.md”
- “I will follow CORE skills as non-negotiable constraints”
- “I understand the Definition of Done and will comply”

**If you cannot/do not acknowledge the above, hard-fail the session immediately.**
No partial work, no “quick fixes,” no drive-by edits.

---

## Quick Start

```bash
# Open the Xcode project
open "/Users/russmeadows/Dev/Games/GridWatchZero/GridWatchZero.xcodeproj"

## Quick Start

```bash

## Documentation Index

| Document | Purpose |
|----------|---------|
| [SKILLS.md](./SKILLS.md) | Contributor capability profile - required competencies |
| [CLAUDE.md](./CLAUDE.md) | AI assistant context - project structure, patterns, commands |
| [CONTEXT.md](./CONTEXT.md) | Game concept, narrative, design philosophy |
| [PROJECT_STATUS.md](./PROJECT_STATUS.md) | Implementation progress, current version, next tasks |
| [ISSUES.md](./ISSUES.md) | Bug tracking, enhancement requests |
| [ISSUES_ARCHIVE.md](./ISSUES_ARCHIVE.md) | Archived/resolved issues and reference docs |
| [DESIGN.md](./DESIGN.md) | Full game design document with mechanics |
| [MIGRATION_PLAN.md](./MIGRATION_PLAN.md) | v2.0 balance migration sprint plan (A-F) |
| [COMMIT.md](./COMMIT.md) | Session power-down checklist |
| [SESSIONS.md](./SESSIONS.md) | Session prep template (optional) |

---

## Current Work: v2.0 Balance Migration (Branch: `CLAUDE_UPDATE`)

> See [MIGRATION_PLAN.md](./MIGRATION_PLAN.md) for full sprint details.

| Sprint | Name | Status |
|--------|------|--------|
| **A** | Balance Foundation | ✅ Complete |
| **B** | Defense System Overhaul | ✅ Complete |
| **C** | Certification Maturity | ✅ Complete |
| **D** | Intel System Enhancements | ✅ Complete |
| **E** | Link Latency & Protection | 🔜 Next |
| **F** | Insane Dossiers & Polish | ⏳ Planned |

### Remaining Tasks
1. **Sprint E** - Link latency, packet loss protection, credit protection
2. **Sprint F** - 6 new Insane Mode dossiers, story dialog, save migration
4. **TestFlight Testing** - Verify v2.0 balance on device
5. **App Store Submission** - Submit for Apple review when testing complete

---

## Development Workflow

### Adding New Files
1. Create file in correct folder via code
2. In Xcode: Right-click folder → "Add Files to 'GridWatchZero'..."
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
UserDefaults key: `GridWatchZero.GameState.v6`

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
**Repository**: Local at `/Users/russmeadows/Dev/Games/GridWatchZero`

---

## Session Checklist

Before ending a session:
- [ ] Update PROJECT_STATUS.md with progress
- [ ] Log any new issues in ISSUES.md
- [ ] Commit changes (if using git)
- [ ] Note next tasks in PROJECT_STATUS.md
