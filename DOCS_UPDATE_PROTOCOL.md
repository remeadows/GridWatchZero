# Documentation Update Protocol

> **Audience**: AI agents (Claude Code, Codex, Gemini, Copilot, etc.) working on this codebase.
> **Owner**: Russ Meadows. Only the project owner modifies `CLAUDE.md`.

## Rule #1: Do NOT modify CLAUDE.md or MEMORY.md

`CLAUDE.md` is the project owner's authoritative architecture document. `MEMORY.md` (in `.claude/projects/.../memory/`) is the owner's persistent Claude Code context. **No agent may edit either file.** If your changes require updates to these, document what changed in `HANDOFF.md` and `SESSIONS.md` so the owner can update them.

---

## When to Update Documentation

After any work session that changes code, update the documents listed below. Do this **before** your final commit or as a separate documentation commit.

---

## Documents You MUST Update

### 1. `HANDOFF.md` (repo root)
**Purpose**: Executive status summary — what was done, what's next, current project health.

**When**: After every session that produces commits.

**What to update**:
- Add your commit(s) under "Work Completed" with SHA, title, and bullet-point summary of changes
- Update "Overall Project Health" if your work materially changed it
- Update "Architecture Status" table if you added/removed/renamed files or changed line counts significantly
- Update "Technical Debt Resolved" table if you fixed known issues
- Update "Immediate Actions" / "Execution Priorities" if priorities shifted

**Format**: Follow the existing section structure. Don't reorganize.

### 2. `SESSIONS.md` (repo root)
**Purpose**: Chronological session log — who did what and when.

**When**: After every session.

**What to append** (always append, never overwrite prior entries):
```markdown
## Session: YYYY-MM-DD — [Agent Name/Type]
**Commits**: `sha1`, `sha2`, ...
**Summary**: 1-3 sentence description of what was accomplished.
**Files Changed**: List of files modified/added/deleted.
**Key Decisions**: Any architectural or design decisions made.
**Known Issues**: Anything broken, deferred, or needing follow-up.
```

---

## Documents You MAY Update (if relevant)

| Document | When to update | What to update |
|----------|----------------|----------------|
| `project/ISSUES.md` | Fixed a bug or found a new one | Mark issue resolved or add new issue |
| `project/PROJECT_STATUS.md` | Release readiness changed | Update status, blockers, next steps |
| `design/GAMEPLAY.md` | Changed game balance numbers | Update affected tables/formulas |
| `design/BALANCE.md` | Changed economy or scaling | Update affected sections |
| `SKILLS.md` | Added patterns requiring new skills | Add/update relevant skill requirements |
| `RELEASE.md` | Preparing a release | Update release checklist |

---

## Documents You Must NOT Modify

| Document | Reason |
|----------|--------|
| `CLAUDE.md` | Owner-managed. Log your changes in HANDOFF.md instead. |
| `MEMORY.md` (`.claude/projects/.../memory/`) | Owner's Claude Code context — owner only |
| `design/DESIGN.md` | Creative/narrative content — owner only |
| `project/APP_STORE_METADATA.md` | App Store copy — owner only |
| Anything in `archive/` | Historical record — never modify |

---

## How to Reference This Protocol

When handing off to another agent or starting a new session, include:

> "Read `DOCS_UPDATE_PROTOCOL.md` for documentation update requirements before finishing your session."

---

## Document Hierarchy (Read-Only Reference)

These are the authoritative sources — read them to understand the project, but follow the rules above about which ones you can modify:

| Document | Source of truth for |
|----------|---------------------|
| `CLAUDE.md` | Architecture, patterns, file structure (DO NOT EDIT) |
| `MEMORY.md` | Claude Code persistent context (DO NOT EDIT) |
| `SKILLS.md` | Contributor competencies |
| `design/GAMEPLAY.md` | Game balance numbers and formulas |
| `HANDOFF.md` | Current project status and priorities |
| `SESSIONS.md` | Session history log |
