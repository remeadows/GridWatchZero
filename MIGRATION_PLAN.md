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

| Sprint | Name | Priority | Status | Scope |
|--------|------|----------|--------|-------|
| **A** | Balance Foundation | Highest | ✅ Complete | Campaign levels, unit costs, defense costs, Insane Mode numbers |
| **B** | Defense System Overhaul | High | ✅ Complete | All 6 categories gain intel/risk bonuses, new caps, renamed apps |
| **C** | Certification Maturity | Medium | ✅ Complete | 40h/60h maturity timers, partial bonuses, Settings UI |
| **D** | Intel System Enhancements | Medium | ✅ Complete | Send ALL, batch latency, early warning system |
| **E** | Link Latency & Protection | Medium | 🔜 Next | Transfer delays, packet loss protection, credit protection |
| **F** | Insane Dossiers & Polish | Lower | ⏳ Planned | 6 new dossiers, story dialog updates, save migration |

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

## Sprint B: Defense System Overhaul (Detail)

### Objective
Add per-category intel/risk/secondary bonuses to all 6 defense categories per DEFENSE_20250204.md. Replace generic defense point formula with category-specific rate tables.

### Files Modified

| File | Changes |
|------|---------|
| `Models/DefenseApplication.swift` | Added `CategoryRates` struct, per-category rate tables, base DP lookup table, Firewall-only DR with tier caps, risk reduction formula |
| `Engine/GameEngine.swift` | Updated defense calculations to use category-specific rates |
| `Views/Components/DefenseApplicationView.swift` | Updated UI to show category-specific bonuses |

### Acceptance Criteria (All Met)
- [x] Each of 6 categories has unique intel/risk/secondary bonus per level
- [x] Base defense points use Category × Tier lookup table (6×6)
- [x] T7+ scales exponentially: `T6Value × 1.8^(tier-6)`
- [x] Damage reduction is Firewall-only (+1.5%/lvl, tier caps)
- [x] Risk reduction formula: `min(0.80, totalRisk/100)`
- [x] Builds cleanly with zero warnings

---

## Sprint C: Certification Maturity (Detail)

### Objective
Implement certification maturity system with real-time timers. Normal certs mature in 40 hours, Insane certs in 60 hours. Partial bonuses accumulate linearly.

### Files Modified

| File | Changes |
|------|---------|
| `Models/CertificateSystem.swift` | NEW — `CertificateManager` with maturity tracking, per-cert bonus calculation, persistence via UserDefaults |
| `Models/CampaignLevel.swift` | Added Insane Mode certification support (20 Insane certs) |
| `Engine/GameEngine.swift` | Integrated cert multiplier into production pipeline (source, credit, offline) |
| `Views/CertificateView.swift` | NEW — Maturity state UI (Pending 🔒 / Maturing ⏳ / Mature ✅), progress bars |
| `Views/DashboardView.swift` | Added certificate section link |

### Acceptance Criteria (All Met)
- [x] 20 Normal certs (40h maturity) + 20 Insane certs (60h maturity)
- [x] Per-cert bonus: `min(hoursElapsed / maturityHours, 1.0) × 0.20`
- [x] Total multiplier range: 1.0× to 9.0×
- [x] Multiplier applies to source production, credit conversion, offline progress
- [x] Maturity states display correctly in UI
- [x] No save migration needed (uses separate persistence key)
- [x] Builds cleanly with zero warnings

---

## Sprint D: Intel System Enhancements (Detail)

### Objective
Implement "Send ALL" batch intel upload with latency/bandwidth tradeoffs, and IDS-based early warning system that predicts attacks before they land.

### Files Modified

| File | Changes |
|------|---------|
| `Models/ThreatSystem.swift` | Added `EarlyWarning` struct (prediction countdown with IDS-level-based params), `BatchUploadState` struct (latency/bandwidth formulas) |
| `Models/DefenseApplication.swift` | Added `pendingReportCount` to MalusIntelligence, `totalIdsLevel` to DefenseStack |
| `Engine/GameEngine.swift` | New GameEvent cases (earlyWarning, batchUploadStarted/Complete), @Published state, processThreats() rewrite for IDS prediction, batch upload tick processing, sendAllMalusReports(), cancelBatchUpload() |
| `Views/Components/CriticalAlarmView.swift` | MalusIntelPanel gains onSendAll callback, batch upload progress bar, early warning display, "Send ALL" button |
| `Views/Components/ThreatIndicatorView.swift` | Added EarlyWarningIndicator component, earlyWarning parameter propagation |
| `Views/Components/AlertBannerView.swift` | Added EarlyWarningBanner, banner cases for batch upload events |
| `Views/DashboardView.swift` | Wired onSendAll/canSendAll/batchUpload/earlyWarning to MalusIntelPanel (3 sites), earlyWarning to ThreatBarView (2 sites) |

### Acceptance Criteria (All Met)
- [x] IDS Early Warning: IDS level 10-20 → 2 ticks/60%, 21-40 → 3 ticks/70%, 41-60 → 4 ticks/80%, 61+ → 5 ticks/90%
- [x] Early warning replaces simple block-chance for IDS ≥ 10; legacy preserved for IDS < 10
- [x] False positives possible (accuracy < 100%)
- [x] Batch upload requires 11+ pending reports, no active attack
- [x] Latency formula: `min(20, log₂(count) × 1.5)` ticks
- [x] Bandwidth impact: 0-10=0%, 11-50=15%, 51-200=30%, 201-500=55%, 501+=80%
- [x] Batch upload auto-cancels when attack starts
- [x] Early warning banner + threat bar indicator with countdown
- [x] Batch upload progress bar with bandwidth cost warning
- [x] Builds cleanly with zero warnings

---

## Version History

| Date | Change |
|------|--------|
| 2026-02-05 | Initial migration plan created |
| 2026-02-05 | Sprint A completed — all 20 levels rebalanced, unit/defense costs updated, Insane Mode modifiers |
| 2026-02-05 | Sprint B completed — defense system overhaul with per-category rate tables |
| 2026-02-05 | Sprint C completed — certification maturity system (40h/60h timers) |
| 2026-02-05 | ISSUES.md archived (2003 → 636 lines), COMMIT.md + SESSIONS.md created |
| 2026-02-05 | Sprint D completed — early warning system (IDS prediction) + batch intel upload |
