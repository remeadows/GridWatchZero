# COMMIT.md — Grid Watch Zero: Session Power-Down Sequence

> Run this checklist BEFORE ending any session that includes code or doc changes.

---

## Instructions

### 1. Update Project Documentation

- [ ] **GO.md** — Update if documentation index or sprint references changed
- [ ] **project/PROJECT_STATUS.md** — Add session log entry documenting work done
- [ ] **project/ISSUES.md** — Update any issues fixed or progressed
- [ ] **CLAUDE.md** — Update if game systems or project structure changed
- [ ] **SKILLS.md** — Update if new patterns or capabilities were introduced
- [ ] **project/MIGRATION_PLAN.md** — Update sprint status and add version history entries
- [ ] *SESSIONS.md* — Optional: fill in session template if useful for next session

### 2. Stage and Commit

- [ ] `git add` all changed and new files
- [ ] Write a descriptive commit message summarizing the session work
- [ ] `git commit`

### 3. Push to Remote

- [ ] `git push origin <branch-name>`

### 4. Verify

- [ ] Check GitHub Desktop (or `git status`) for any unstaged/uncommitted files
- [ ] If stragglers found: stage, amend or new commit, push again

---

## Notes

- This file itself does not need updating each session.
- SESSIONS.md is a per-session template. COMMIT.md is the exit procedure.
- If no code/doc changes were made, skip this checklist.
