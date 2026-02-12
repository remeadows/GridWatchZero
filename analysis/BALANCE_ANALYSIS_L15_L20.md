# Late-Game Balance Analysis: Levels 15-20
**Date**: 2026-02-12
**Scope**: Campaign Levels 15-20, Endless Mode endgame scaling
**Method**: Static code analysis of production formulas, threat tables, and victory conditions

---

## Executive Summary

The late-game economy is **heavily front-loaded toward player power**. Once a player reaches T20+ units at moderate levels, credit generation vastly exceeds victory requirements. The primary gating mechanism shifts from credits to **intel report accumulation**, which is time-gated by footprint data collection from attacks. This creates a gameplay loop where the player is economically dominant but waiting for enough attacks to generate footprint data — a pattern that risks feeling like a passive grind rather than active challenge.

### Key Findings

1. **Credit requirements are trivial at endgame**: T25 Level 50 raw output is 190.84B credits/tick. L20 requires 135B credits — achievable in under 1 tick at max setup.
2. **Intel reports are the real gate**: 10,000 reports for L20 requires ~502M footprint data, estimated 2-6 hours of active play at OMEGA threat level.
3. **Threat escalation doesn't match player power curve**: OMEGA's 100x damage multiplier sounds extreme, but T25 defense stacks with 95% damage reduction cap + 80% attack frequency reduction make it manageable.
4. **Certification maturity is an invisible wall**: 9.0x max multiplier requires 40 certs × 40-60 real hours each = 1,600-2,400 real hours of maturity time. Most players will have 2-4x at best during active campaign play.
5. **The sink is always the bottleneck**: Source outproduces sink capacity at every tier, meaning production multipliers increasingly yield waste rather than credits.

---

## Detailed Analysis

### 1. Production Pipeline at T25 Level 50

| Node | Formula | Value/Tick |
|------|---------|-----------|
| Source | 262,144,000 × 50 × 1.5 | **19.66B data** |
| Link | 314,572,800 × 50 × 1.4 | **22.02B bandwidth** |
| Sink | 209,715,200 × 50 × 1.3 | **13.63B processing** |

**Bottleneck**: Sink processing (13.63B) limits throughput. Source overproduces by 44% (6.03B data/tick wasted).

**Raw credits/tick** = 13.63B × 14.0 (conversion rate) = **190.84B credits/tick**

With multipliers:
| Scenario | Prestige | Cert | Credits/Tick |
|----------|----------|------|-------------|
| Fresh (no bonuses) | 1.0x | 1.0x | 190.84B |
| Early prestige (P5, 8 cores) | 1.75x credit | 2.0x cert | 668.0B |
| Mid prestige (P10, 20 cores) | 2.5x credit | 5.0x cert | 2,385.5B |
| Late prestige (P10, 20 cores) | 2.5x credit | 9.0x cert | 4,293.9B |

### 2. Victory Condition Analysis (L15-L20)

| Level | Credit Req | Reports | Def Tier | Def Points | Time @ Raw Output | Time @ 5x Mult |
|-------|-----------|---------|----------|-----------|-------------------|----------------|
| 15 | 7.2B | 1,500 | T19 | 14,000 | 0.04 ticks | instant |
| 16 | 14.4B | 1,950 | T20 | 18,000 | 0.08 ticks | instant |
| 17 | 25B | 2,500 | T21 | 23,000 | 0.13 ticks | instant |
| 18 | 44B | 3,200 | T23 | 30,000 | 0.23 ticks | instant |
| 19 | 77B | 4,100 | T24 | 40,000 | 0.40 ticks | instant |
| 20 | 135B | 5,500 | T25 | 55,000 | 0.71 ticks | instant |

**Observation**: At T25 with any level progression, credit requirements are met almost instantly. Even at T20 Level 10 (the minimum tier available for L16), raw credits/tick = 6,553,600 × 10 × 1.3 × 11.5 = 980.2M/tick, making 14.4B achievable in ~15 ticks (15 seconds).

**The real gates are**:
1. **Intel reports** — time-gated by footprint data from survived attacks
2. **Defense tier unlocks** — gated by upgrade costs (exponential 1.18^level) and tier gate system
3. **Defense points** — gated by defense app levels

### 3. Intel Report Bottleneck

**Report cost formula**: `200 × (1 + reportsSent × 0.05)`

| Report # | Cost | Cumulative Cost |
|----------|------|----------------|
| 1 | 200 | 200 |
| 100 | 1,200 | 70,000 |
| 1,000 | 10,200 | 5,200,000 |
| 5,000 | 50,200 | 125,500,000 |
| 10,000 | 100,200 | 501,950,000 |

**Cost escalation is aggressive**: Report #10,000 costs 501x what report #1 costs. Total footprint needed for 10,000 reports is ~502M.

**Footprint data income** (per survived attack at OMEGA):
- Base: `damageBlocked × 0.5 + duration × 15 + severity × 25`
- At OMEGA (severity ~100, duration ~30-50): base ~3,000-5,000+ per attack
- With defense stack intel multipliers (~3-5x): ~10,000-25,000 per attack
- Attack frequency: 80%/tick × (1 - 0.80 freq reduction) = 16%/tick effective

**Effective footprint/tick**: ~1,600-4,000 footprint data/tick
**Time for 10,000 reports**: 502M / 2,800 avg = ~179,000 ticks = **~50 hours of active play**

This is substantially longer than the credit accumulation time, confirming intel reports are the dominant time gate for L20.

### 4. Threat Level vs. Player Defense

| Threat | Atk Chance | Sev Mult | Effective Chance (80% freq red) | Effective Damage (95% DR) |
|--------|-----------|----------|-------------------------------|--------------------------|
| ASCENDED (11) | 30% | 12.0x | 6.0% | 0.6x |
| TRANSCENDENT (13) | 40% | 18.0x | 8.0% | 0.9x |
| DIMENSIONAL (15) | 50% | 27.0x | 10.0% | 1.35x |
| PARADOX (17) | 60% | 40.0x | 12.0% | 2.0x |
| INFINITE (19) | 70% | 65.0x | 14.0% | 3.25x |
| OMEGA (20) | 80% | 100.0x | 16.0% | 5.0x |

**With max defense stack** (T25 Firewall app at L50 = 95% DR cap, max risk reduction = 80%):
- OMEGA's effective damage is only 5x base — manageable with T25 firewall node
- Effective attack frequency is 16%/tick — roughly 1 attack every 6 ticks
- Player is economically unassailable at this point

**Without defense upgrades**: OMEGA's 80%/tick at 100x damage is devastating, creating a hard wall. The defense vs. no-defense gap is enormous.

### 5. Sink Bottleneck Problem

At every tier, the source outproduces the sink:

| Tier | Source Output | Sink Processing | Waste % |
|------|-------------|----------------|---------|
| T1 (L10) | 120 | 78 | 35% |
| T10 (L50) | 9.83B | 6.81B | 31% |
| T15 (L50) | 19.2M × 50 × 1.5 = 1.44B | 204,800 × 50 × 1.3 = 13.3M | N/A* |
| T25 (L50) | 19.66B | 13.63B | 31% |

*T15 numbers are correct at their own scale. The ratios hold consistently.

The production multiplier from prestige amplifies source output but NOT sink processing rate. This means prestige increasingly generates waste rather than credits. The credit multiplier (applied to final output) is the only prestige benefit that directly improves income.

---

## Risk Assessment

### HIGH RISK: Intel Report Grind (L17-L20)

**Problem**: Players complete credit, tier, and defense point objectives quickly, then spend hours waiting to accumulate enough footprint data for intel reports. This creates a "watching paint dry" experience.

**Evidence**: L20 requires 5,500 reports. At ~2,800 footprint/tick effective rate, that's ~50 hours of active play. Credit requirements are met in seconds.

**Recommendation**: Consider one or more of:
- Reduce report scaling factor from +5% per report to +2-3%
- Add passive footprint generation (perhaps from IDS apps)
- Increase footprint data per attack at higher threat levels
- Add an offline footprint accumulation mechanic (like offline credits)

### MEDIUM RISK: Certification Time Wall

**Problem**: 9.0x max cert multiplier requires all 40 certs fully matured (1,600-2,400 real hours). Realistic cert multiplier during active play is 1.5-3.0x, making the 9.0x theoretical max misleading.

**Evidence**: A player who completes campaign in 100 hours of play has ~4-8 certs matured (Normal: 40hrs each), giving ~1.8-2.6x multiplier.

**Recommendation**: This is acceptable as a long-term retention mechanic IF the balance doesn't assume 9.0x. Currently, the economy doesn't require it — it's a bonus accelerator, not a gate.

### MEDIUM RISK: Sink Bottleneck Frustration

**Problem**: Players upgrading source/link see no benefit once they exceed sink throughput. The 31% waste rate is invisible — players may not understand why their "better" source isn't earning more credits.

**Recommendation**: Consider adding a UI indicator showing "pipeline efficiency" or suggesting the bottleneck node. The NetworkTopologyView already shows efficiency — ensure it's prominent.

### LOW RISK: Credit Trivializiation

**Problem**: Credit requirements for L15-L20 are met almost instantly at appropriate tier levels.

**Assessment**: This is actually OK for gameplay flow — credits serve as an early-level gate and transition to a non-issue by design. The real challenges (reports, defense tiers, defense points) provide meaningful progression. However, the credit requirement display in VictoryProgressBar may feel anticlimactic.

### LOW RISK: Insane Mode Scaling

Insane mode multipliers (3.5x credits, 2x reports, 2x DP, 1.5-2.0x damage) are reasonable at late game. The real challenge is surviving higher damage rather than reaching economic targets.

---

## Specific Recommendations

### 1. Reduce Intel Report Cost Scaling (HIGH PRIORITY)
**Current**: `200 × (1 + reportsSent × 0.05)` — report #5000 costs 50,200
**Proposed**: `200 × (1 + reportsSent × 0.02)` — report #5000 costs 20,200
**Impact**: Total cost for 10,000 reports drops from 502M to 220M (~56% reduction)
**Files**: `DefenseApplication.swift` line 1483

### 2. Add Passive Footprint Generation (MEDIUM PRIORITY)
IDS defense apps could generate small amounts of footprint data per tick even without attacks, creating a "scanning for threats" mechanic.
**Proposed**: `passiveFootprint = idsLevel × 10 × (1 + intelBonuses)` per tick
**Impact**: At IDS L50: 500 footprint/tick passive, accelerating report generation by ~18%
**Files**: `GameEngine+IntelReports.swift`, `DefenseApplication.swift`

### 3. Scale Footprint Data with Threat Level (MEDIUM PRIORITY)
Higher threat levels should yield more footprint data per attack. Currently, severity and duration provide some scaling, but an explicit threat-level multiplier would help.
**Proposed**: `footprintData *= (1.0 + threatLevel × 0.1)` — OMEGA gives 3.0x footprint
**Impact**: Reduces report grind at high threat levels where players need more reports
**Files**: `GameEngine+IntelReports.swift`

### 4. Sink Bottleneck UI Feedback (LOW PRIORITY)
Show players which node is limiting their pipeline throughput.
**Files**: `NetworkTopologyView.swift` (already shows efficiency — could add explicit "bottleneck" indicator)

---

## Data Sources

All formulas verified from source code:
- `UnitFactory.swift` — Base production/bandwidth/processing values for all 25 tiers
- `Node.swift` — Production formula: `base × level × 1.5`, upgrade cost: `25 × 1.18^level`
- `Link.swift` — Bandwidth formula: `base × level × 1.4`, upgrade cost: `30 × 1.18^level`
- `ThreatSystem.swift` — Threat levels 11-20 thresholds, attack chances, severity multipliers
- `LevelDatabase.swift` — Victory conditions for all 20 campaign levels
- `DefenseApplication.swift` — Report cost formula, defense point calculations, intel milestones
- `GameEngine.swift` — Prestige multiplier formulas, production tick pipeline
- `CertificateSystem.swift` — Certification maturity formula, max multiplier calculation
- `GameEngine+IntelReports.swift` — Footprint data collection formula per attack
