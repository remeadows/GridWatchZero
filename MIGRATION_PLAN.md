# MIGRATION_PLAN.md - Grid Watch Zero: v2.0 Balance Update

> Migration plan for implementing GAMEPLAY_20250204.md, DEFENSE_20250204.md, and UNITS_20250204.md.
>
> **Branch**: `CLAUDE_UPDATE`
> **Created**: 2026-02-05

---

## Key Risks & Observations (Archive Reference)

### 1. Save Migration Required
Changing the defense app bonus structure (adding per-level intel/risk/secondary bonuses to all 6 categories) and adding certification maturity timers will require a save key version bump from `GridWatchZero.GameState.v6` to `v7`. Migration logic must be written to preserve existing player progress.

**Mitigation:** Write `SaveMigrationManager` step for v6→v7. Default new fields (intel bonus, risk reduction, maturity timestamps) to safe values. Existing defense app levels carry forward.

### 2. Balance Testing Critical
The proposed numbers in GAMEPLAY_20250204.md are theoretical. The tiered credit multipliers (2.5×/2.25×/2.0×/1.75×) and rebalanced level requirements need hands-on playtesting.

**Mitigation:** After Sprint A, playtest Levels 1-10 before committing to later sprints. Track actual time-to-complete per level and compare to 30-45 minute targets.

### 3. Scope Creep Potential
Sprints D and E introduce genuinely new mechanics (link latency, batch intel upload, early warning system). These should be validated in isolation before combining with other changes.

**Mitigation:** Implement new mechanics behind feature flags or as clearly separable code paths. Test individually before integration.

### 4. Formula Conflicts
The three update docs use slightly different formulas than what's currently in `GameEngine.swift`:
- Source upgrade cost: doc says `25.0 × 1.18^level`, current code may differ
- Defense app upgrade: doc says `500 × 1.22^level`, current is `250 × tier × 1.25^level`
- Production multipliers: doc specifies `1.5/1.4/1.3` for Source/Link/Sink

**Mitigation:** Audit `GameEngine.swift` production calculations line-by-line during Sprint A. Document all formula changes with before/after values.

### 5. T7-T25 Defense Apps Not Specified
DEFENSE_20250204.md only details T1-T6 bonus rates. T7-T25 defense app intel/risk bonuses are not specified in any of the three documents.

**Mitigation:** Sprint B handles T1-T6 only. Establish a scaling pattern (e.g., per-level bonuses scale with tier) and propose T7+ values for review before implementing.

### 6. Level 20 Credit Target Reduced 79%
GAMEPLAY_20250204.md sets Level 20 at 212B credits (down from 1T in current code). Combined with the certification multiplier system (up to 8.0× when all 40 certs mature), endgame pacing will be dramatically different.

**Mitigation:** Verify this is intentional during Sprint A review. The cert system means theoretical max income scales 8× — the reduced target may assume partial cert maturity. Playtest Levels 16-20 in Sprint validation.

### 7. Insane Mode Difficulty Increase
Insane Mode modifiers change from current (2× threat, 1.5× damage, 0.75× income) to proposed (3.5× credits, +25% absolute attack chance, 2× reports, 2× defense points). This is a substantially different difficulty profile.

**Mitigation:** Insane Mode rebalance can be deferred until Normal Mode is validated. Include in Sprint A numbers but don't prioritize Insane playtesting until Normal Levels 1-20 are confirmed.

### 8. Certification Maturity Is a New Retention Mechanic
The 40-hour per-cert maturity timer is a significant new system that changes the game's economy. Players who speed-run will have lower multipliers than players who play over multiple days.

**Mitigation:** Ensure level requirements are achievable WITHOUT cert bonuses (certs accelerate, not gate). Validate in playtesting that Level 20 is reachable with 0 mature certs, just slower.

### 9. "Send ALL" Intel Feature May Introduce Exploits
Batch intel sending with bandwidth consumption creates a risk of exploit patterns (e.g., hoarding reports then dumping at optimal timing).

**Mitigation:** Implement in Sprint D with rate limiting. The "disabled during attacks" rule is critical — enforce strictly.

### 10. Three Docs May Contain Internal Inconsistencies
GAMEPLAY, DEFENSE, and UNITS were authored separately. Cross-referencing formulas revealed minor differences (e.g., GAMEPLAY's formula section vs. UNITS' formula section for production).

**Mitigation:** When implementing, treat GAMEPLAY as the authoritative source for campaign balance, DEFENSE for defense mechanics, and UNITS for unit stats. If conflicts arise, flag and resolve before coding.

---

## Sprint Plan Summary

| Sprint | Name | Priority | Scope |
|--------|------|----------|-------|
| **A** | Balance Foundation | Highest | Campaign levels, unit costs, defense costs, Insane Mode numbers |
| **B** | Defense System Overhaul | High | All 6 categories gain intel/risk bonuses, new caps, renamed apps |
| **C** | Certification Maturity | Medium | 40-hour maturity timer, partial bonuses, Settings UI |
| **D** | Intel System Enhancements | Medium | Send ALL, batch latency, early warning system |
| **E** | Link Latency & Protection | Medium | Transfer delays, packet loss protection, credit protection |
| **F** | Insane Dossiers & Polish | Lower | 6 new dossiers, story dialog updates, save migration |

---

## Sprint A: Balance Foundation (Detail)

### Objective
Rebalance all 20 campaign levels, unit unlock costs, and defense app costs to match the v2.0 specification documents. Fix ISSUE-018 (Level 8 balance spike).

### Files to Modify

| File | Changes |
|------|---------|
| `Models/LevelDatabase.swift` | All 20 level credit/DP/report/attack requirements |
| `Engine/UnitFactory.swift` | Unit unlock costs for T1-T25 (Sources, Links, Sinks) |
| `Models/DefenseApplication.swift` | Defense app unlock costs (standardized 5K-5M per tier) |
| `Models/DefenseApplication.swift` | Upgrade cost formula → `500 × 1.22^level` |
| `Engine/GameEngine.swift` | Insane Mode modifiers (3.5×/+25%/2×/2×) |
| `Models/CampaignLevel.swift` | InsaneModifiers struct if needed |

### Acceptance Criteria
- [ ] All 20 Normal Mode levels match GAMEPLAY_20250204.md table
- [ ] All 20 Insane Mode levels match GAMEPLAY_20250204.md Insane table
- [ ] Unit unlock costs match UNITS_20250204.md
- [ ] Defense app unlock costs match DEFENSE_20250204.md (5K/25K/100K/400K/1.5M/5M)
- [ ] Defense app upgrade formula is `500 × 1.22^level`
- [ ] Insane Mode modifiers updated
- [ ] Builds cleanly with zero warnings
- [ ] No save migration needed for Sprint A (balance numbers only)

### Validation
- Playtest Levels 1-10 Normal Mode
- Target 30-45 minutes per level
- Report time-to-complete, difficulty feel, chokepoints

---

## Version History

| Date | Change |
|------|--------|
| 2026-02-05 | Initial migration plan created |
