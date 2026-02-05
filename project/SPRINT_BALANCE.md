# Sprint: Campaign Balance Overhaul

**Date**: 2026-01-24
**Goal**: Increase game intensity, make levels last longer, create meaningful upgrade decisions

---

## Current State Analysis

### Problem 1: Defense Reduces Attacks Too Effectively

**Current Mechanics:**
- `NetDefenseLevel` reduces raw threat to `effectiveRisk`
- Formula: `effectiveRisk = max(1, threat - defense.threatReduction)`
- FORTIFIED defense (level 5) reduces threat by 5 levels
- Example: TARGETED(4) - FORTIFIED(5) = GHOST(1) → almost no attacks

**Result:** Players fortify quickly → attacks stop → "attacks survived" objective becomes tedious waiting game.

### Problem 2: Upgrade Costs Are Too Cheap

**Current Costs (per level):**
| Unit | Cost Formula | Level 30 Cost |
|------|--------------|---------------|
| Source | `level × 25` | ₵750 |
| Link | `level × 30` | ₵900 |
| Sink | `level × 40` | ₵1,200 |
| Firewall | `level × 50` | ₵1,500 |

**Problem:** Linear scaling means upgrades are trivially affordable. At Level 30, total spent is only ~₵15K for each unit type.

### Problem 3: No Reason to Upgrade Beyond Level 30

**Current Scaling:**
- Source: `baseProduction × level × 1.5`
- Link: `baseBandwidth × level × 1.4`
- Sink: `baseProcessingRate × level × 1.3`

**At Level 30:**
| Tier | Source Output | Link BW | Sink Processing |
|------|---------------|---------|-----------------|
| T1 (base 8) | 360/tick | 210 | 195 |
| T2 (base 20) | 900/tick | 630 | 585 |
| T3 (base 50) | 2,250/tick | 1,680 | 1,755 |

**Problem:** Upgrading T1 to level 30 often exceeds T2 at level 1. No natural "ceiling" forcing tier upgrades.

### Problem 4: Unit Upgrades Persist Across Campaign Levels

**Current Behavior:** When starting a new campaign level, units reset to level 1 (correct), but unlocked units persist (also correct per recent fix). However, the balance assumes players start fresh each level.

**Verified:** `startCampaignLevel()` creates fresh T1 units at level 1.

---

## Proposed Changes

### Change 1: Reduce Defense Impact on Attack Frequency

**Option A - Cap Threat Reduction:**
```
Max threat reduction = 3 levels (not raw defense value)
FORTIFIED(5) → reduces by 3 (not 5)
TARGETED(4) - 3 = BLIP(2) instead of GHOST
```

**Option B - Minimum Attack Chance Floor:**
```
attackChancePerTick = max(minimumFloor, baseChance × (1 - reduction))
minimumFloor varies by starting threat:
- GHOST start: 0.2% floor
- SIGNAL start: 0.5% floor
- TARGET start: 1.0% floor
- HAMMERED start: 2.0% floor
```

**Option C - Defense Reduces Severity, Not Frequency:**
```
Defense reduces DAMAGE taken, not attack frequency
High defense = still getting attacked, but attacks hurt less
```

**DECISION: Option C** - Defense reduces damage, not frequency. Players still experience attacks (engagement), but defense makes them survivable.

**Implementation:**
- Remove `threatReduction` from `NetDefenseLevel` affecting attack chance
- Instead, apply defense as damage reduction multiplier
- `damageMultiplier = 1.0 - (defenseLevel × 0.08)` (max 60% reduction at level 8)
- Attack frequency stays tied to raw threat level, not effective risk

---

### Change 2: Exponential Upgrade Costs (CONFIRMED - 1.18x)

**Formula:**
```
upgradeCost = baseCost × (1.18 ^ level)
```

**New Costs (1.18x curve):**
| Level | Source (base 25) | Link (base 30) | Sink (base 40) | Firewall (base 50) |
|-------|------------------|----------------|----------------|-------------------|
| 1 | 30 | 35 | 47 | 59 |
| 5 | 55 | 66 | 88 | 110 |
| 10 | 130 | 156 | 208 | 260 |
| 15 | 305 | 366 | 488 | 610 |
| 20 | 715 | 858 | 1,144 | 1,430 |
| 25 | 1,677 | 2,012 | 2,683 | 3,354 |
| 30 | 3,932 | 4,718 | 6,291 | 7,864 |

**Total to reach Level 10 (T1 max):** ~₵850 per unit type
**Total to reach Level 15 (T2 max):** ~₵2,500 per unit type (cumulative ~₵3,350)
**Total to reach Level 20 (T3 max):** ~₵5,800 per unit type (cumulative ~₵9,150)

This makes progression meaningful but not impossible.

---

### Change 3: Hard Level Cap with Tier Unlock Gates (CONFIRMED)

**Hard caps with unlock requirement:**
| Tier | Max Level | Unlock Requirement |
|------|-----------|-------------------|
| T1 | 10 | Free (starting tier) |
| T2 | 15 | Must have T1 at level 10 |
| T3 | 20 | Must have T2 at level 15 |
| T4 | 25 | Must have T3 at level 20 |
| T5 | 30 | Must have T4 at level 25 |
| T6 | 40 | Must have T5 at level 30 |

**Mechanics:**
- Player CANNOT purchase next tier until current tier hits max level
- This forces meaningful investment in each tier
- Creates clear progression milestones
- "Upgrade" button disabled at max level, shows "MAX" or "Unlock T2"

**Example Flow:**
1. Start with T1 Source at level 1
2. Upgrade T1 Source to level 10 (max)
3. T2 Source unlock becomes available for purchase
4. Buy T2 Source, starts at level 1
5. Can upgrade T2 to level 15 (max)
6. T3 unlocks... and so on

---

### Change 4: Increase Base Attack Frequencies

**Current Values:**
| Threat Level | Attack Chance/Tick |
|--------------|-------------------|
| GHOST | 0.2% |
| BLIP | 0.5% |
| SIGNAL | 1.0% |
| TARGET | 2.0% |
| PRIORITY | 3.5% |
| HUNTED | 5.0% |
| MARKED | 8.0% |
| TARGETED | 12.0% |
| HAMMERED | 18.0% |

**Proposed (1.5x increase):**
| Threat Level | Attack Chance/Tick |
|--------------|-------------------|
| GHOST | 0.3% |
| BLIP | 0.8% |
| SIGNAL | 1.5% |
| TARGET | 3.0% |
| PRIORITY | 5.0% |
| HUNTED | 7.5% |
| MARKED | 12.0% |
| TARGETED | 18.0% |
| HAMMERED | 25.0% |

---

### Change 5: Level-Specific Tuning

**Level 1 (Tutorial):**
- No changes needed - already easy

**Level 2-3 (Early Game):**
- Increase attack frequency multiplier to 1.3x
- Reduce defense tier scaling on threat

**Level 4-5 (Mid Game):**
- Minimum attack floor: 1%/tick regardless of defense
- Increase starting threat or reduce starting credits

**Level 6-7 (Endgame):**
- Minimum attack floor: 2%/tick
- Attacks should be constant pressure
- Defense = survival, not immunity

---

## Implementation Checklist

### Phase 1: Attack System Rebalance ✅ COMPLETE
- [x] **Change defense to reduce DAMAGE, not frequency**
  - File: `ThreatSystem.swift` - `RiskCalculation`
  - Added `damageReductionMultiplier` to `NetDefenseLevel` (8% per level, max 72%)
  - `RiskCalculation.attackChancePerTick` now uses RAW threat level
  - `RiskCalculation.damageReduction` property added
  - `GameEngine.swift` applies defense damage reduction in attack processing
- [x] **Implement minimum attack chance floor per level**
  - File: `CampaignLevel.swift` - Added `minimumAttackChance` property
  - File: `LevelDatabase.swift` - Set floors per level (nil, 0.3%, 0.5%, 1.0%, 1.5%, 2.0%, 2.5%)
  - File: `GameEngine.swift` - Attack generation uses `minimumChance` parameter
  - File: `ThreatSystem.swift` - `AttackGenerator.tryGenerateAttack` accepts `minimumChance`
- [x] **Increase base attack chances by 1.5x**
  - File: `ThreatSystem.swift` - `attackChancePerTick` values all increased 1.5x
  - GHOST: 0.2% → 0.3%, BLIP: 0.5% → 0.8%, etc.

### Phase 2: Economy Rebalance ✅ COMPLETE
- [x] **Change upgrade costs to exponential (1.18^level)**
  - File: `Node.swift` - `SourceNode.upgradeCost` = `25.0 * pow(1.18, level)`
  - File: `Node.swift` - `SinkNode.upgradeCost` = `40.0 * pow(1.18, level)`
  - File: `Link.swift` - `TransportLink.upgradeCost` = `30.0 * pow(1.18, level)`
  - File: `Node.swift` - `FirewallNode.upgradeCost` = `50.0 * pow(1.18, level)`
- [x] **Implement tier-based hard level caps**
  - File: `Node.swift` - Added `NodeTier.maxLevel` (T1=10, T2=15, T3=20, T4=25, T5=30, T6=40)
  - Added `maxLevel`, `canUpgrade`, `isAtMaxLevel` to SourceNode, SinkNode, FirewallNode
  - File: `Link.swift` - Added tier extension with `maxLevel`, `canUpgrade`, `isAtMaxLevel`
  - File: `GameEngine.swift` - All upgrade functions check `canUpgrade` before allowing upgrade
- [x] **Implement tier unlock gates**
  - File: `GameEngine.swift` - Added `isTierGateSatisfied(for:)` function
  - `canUnlock()` now checks tier gate: must have previous tier at max level
  - Added `tierGateReason(for:)` for UI display
  - Logic: Can't buy T2 Source unless T1 Source is at level 10

### Phase 3: Level Tuning ✅ COMPLETE (attack floors set)
- [x] **Level 1:** Tutorial, no attack floor (nil)
- [x] **Level 2:** Attack floor 0.3%
- [x] **Level 3:** Attack floor 0.5%
- [x] **Level 4:** Attack floor 1.0%
- [x] **Level 5:** Attack floor 1.5%
- [x] **Level 6:** Attack floor 2.0%
- [x] **Level 7:** Attack floor 2.5%
- [ ] Starting credits adjustments (if needed after playtesting)

### Phase 4: Victory Condition Tuning
- [x] **Risk level requirements** work with new system (defense reduces damage, risk stays higher)
- [ ] **Adjust "attacks survived" requirements** based on new attack rates (playtest needed)
- [ ] **Test each level** to ensure beatable with new balance

### Phase 5: UI Updates
- [ ] Show "MAX LEVEL" when tier cap reached
- [ ] Show "Unlock T2" requirement in shop (using `tierGateReason`)
- [ ] Update upgrade button to show tier gate progress
- [ ] Display damage reduction from defense (not threat reduction)

---

## Design Decisions (CONFIRMED)

1. **Defense Philosophy:** Defense reduces DAMAGE, not frequency
   - Attacks keep coming regardless of defense level
   - High defense = attacks hurt less, not fewer attacks
   - More engaging gameplay, constant action

2. **Level Caps:** HARD CAPS with tier unlock gates
   - T1 max level 10 → Must reach level 10 to unlock T2 purchase
   - T2 max level 15 → Must reach level 15 to unlock T3 purchase
   - T3 max level 20 → Must reach level 20 to unlock T4 purchase
   - T4 max level 25 → Must reach level 25 to unlock T5 purchase
   - T5 max level 30 → Must reach level 30 to unlock T6 purchase
   - T6 max level 40

3. **Attack Floor:** YES - Guaranteed minimum attack rate per level
   - Ensures constant pressure regardless of defense

4. **Upgrade Cost Curve:** 1.18x exponential (middle ground)
   - 1.18x = ~6x more expensive to reach max level
   - Challenging but not impossible

---

## Appendix: Current Unit Stats

### Sources
| Tier | Name | Base Production | Unlock Cost |
|------|------|-----------------|-------------|
| T1 | Public Mesh Sniffer | 8/tick | Free |
| T2 | Corporate Leech | 20/tick | ₵7,500 |
| T3 | Zero-Day Harvester | 50/tick | ₵32,000 |
| T4 | Helix Fragment Scanner | 100/tick | ₵300,000 |
| T5 | Neural Tap Array | 200/tick | ₵750,000 |
| T6 | Helix Prime Collector | 500/tick | ₵3,500,000 |

### Links
| Tier | Name | Base Bandwidth | Unlock Cost |
|------|------|----------------|-------------|
| T1 | Copper VPN Tunnel | 5/tick | Free |
| T2 | Fiber Darknet Relay | 15/tick | ₵6,000 |
| T3 | Quantum Mesh Bridge | 40/tick | ₵26,000 |
| T4 | Helix Conduit | 100/tick | ₵300,000 |
| T5 | Neural Mesh Backbone | 250/tick | ₵600,000 |
| T6 | Helix Resonance Channel | 600/tick | ₵3,000,000 |

### Sinks
| Tier | Name | Base Processing | Conversion | Unlock Cost |
|------|------|-----------------|------------|-------------|
| T1 | Data Broker | 5/tick | 1.5x | Free |
| T2 | Shadow Market | 15/tick | 2.0x | ₵9,000 |
| T3 | Corp Backdoor | 45/tick | 2.5x | ₵38,000 |
| T4 | Helix Decoder | 80/tick | 3.0x | ₵300,000 |
| T5 | Neural Exchange | 180/tick | 3.5x | ₵900,000 |
| T6 | Helix Integration Core | 400/tick | 4.5x | ₵4,000,000 |

### Scaling Formulas
- Source Production: `base × level × 1.5`
- Link Bandwidth: `base × level × 1.4`
- Sink Processing: `base × level × 1.3`
- Upgrade Cost: `level × baseCost` (CURRENT - linear)
- Upgrade Cost: `baseCost × 1.15^level` (PROPOSED - exponential)
