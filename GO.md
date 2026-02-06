# GO.md — Grid Watch Zero

## Hard Requirement: Read Order (Enforced)

**STOP. Do not code yet.**

You must read the project docs in this exact order:

1) **SKILLS.md**  ✅ (mandatory first)
2) GO.md
3) CLAUDE.md
4) project/PROJECT_STATUS.md
5) project/ISSUES.md
6) README.md

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
```

## Documentation Index

| Document | Purpose |
|----------|---------|
| [SKILLS.md](./SKILLS.md) | Contributor capability profile - required competencies |
| [CLAUDE.md](./CLAUDE.md) | AI assistant context - project structure, patterns, commands |
| [project/PROJECT_STATUS.md](./project/PROJECT_STATUS.md) | Implementation progress, current version, next tasks |
| [project/ISSUES.md](./project/ISSUES.md) | Bug tracking, enhancement requests |
| [project/ISSUES_ARCHIVE.md](./project/ISSUES_ARCHIVE.md) | Archived/resolved issues and reference docs |
| [project/MIGRATION_PLAN.md](./project/MIGRATION_PLAN.md) | v2.0 balance migration sprint plan (A-F) |
| [design/DESIGN.md](./design/DESIGN.md) | Full game design document with mechanics |
| [design/GAMEPLAY.md](./design/GAMEPLAY.md) | Full gameplay balance and economics |
| [archive/CONTEXT.md](./archive/CONTEXT.md) | Game concept, narrative (legacy — see DESIGN.md) |
| [COMMIT.md](./COMMIT.md) | Session power-down checklist |
| [SESSIONS.md](./SESSIONS.md) | Session prep template (optional) |

---

## Current Work

v2.0 Balance Migration is complete (all sprints A-F merged to `main`). See [project/MIGRATION_PLAN.md](./project/MIGRATION_PLAN.md) for details.

### Remaining Tasks
1. **TestFlight Testing** - Verify v2.0 balance on device
2. **App Store Submission** - Submit for Apple review when testing complete

For current status and next tasks, see [project/PROJECT_STATUS.md](./project/PROJECT_STATUS.md).

---

## Development Workflow

See [CLAUDE.md](./CLAUDE.md) for full details on:
- Adding new files to Xcode
- Architecture overview and color palette
- Save system, key commands, and project structure

### Quick Debug Commands
```swift
engine.addDebugCredits(100000)  // Test higher threat levels
engine.performPrestige()         // Test prestige system
engine.resetGame()               // Reset save data
```

Save data key: `GridWatchZero.GameState.v6`

---

## Session Checklist

Before ending a session:
- [ ] Update project/PROJECT_STATUS.md with progress
- [ ] Log any new issues in project/ISSUES.md
- [ ] Commit changes (if using git)
- [ ] Note next tasks in PROJECT_STATUS.md
