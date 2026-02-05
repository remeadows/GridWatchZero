# Game Balance Analysis - Project Plague: Neural Grid

## Current Production Formulas

### Source Node
- Production per tick: `baseProduction × level × 1.5`
- Upgrade cost: `level × 25`

### Link Node
- Bandwidth per tick: `baseBandwidth × level × 1.4`
- Upgrade cost: `level × 30`

### Sink Node
- Processing per tick: `baseProcessingRate × level × 1.3`
- Credits earned: `processedData × conversionRate`
- Upgrade cost: `level × 40`

---

## Tier 1 Starting Configuration (Level 1)

| Component | Stat | Value |
|-----------|------|-------|
| Public Mesh Sniffer | Production | 8 × 1 × 1.5 = **12/tick** |
| Copper VPN Tunnel | Bandwidth | 5 × 1 × 1.4 = **7/tick** |
| Data Broker | Processing | 5 × 1 × 1.3 = **6.5/tick** |
| Data Broker | Conversion | **1.5x** |

**Bottleneck Analysis (Level 1):**
- Source outputs: 12/tick
- Link can transfer: 7/tick
- Sink can process: 6.5/tick (BOTTLENECK)
- **Effective throughput**: 6.5/tick
- **Credits/tick**: 6.5 × 1.5 = **9.75 ¢/tick**
- **Packet loss**: 5.5/tick (46% loss)

---

## Time-to-Unlock Calculations (Tier 1 only, no upgrades)

| Unlock | Cost | Time @ 9.75¢/tick | Real Time |
|--------|------|-------------------|-----------|
| BLIP (100¢) | n/a | ~10 ticks | 10 seconds |
| Basic Firewall | 500¢ | ~51 ticks | 51 seconds |
| SIGNAL (1,000¢) | n/a | ~103 ticks | 1.7 minutes |
| Fiber Relay (T2 Link) | 6,000¢ | ~615 ticks | 10.3 minutes |
| Corp Leech (T2 Source) | 7,500¢ | ~769 ticks | 12.8 minutes |
| Shadow Market (T2 Sink) | 9,000¢ | ~923 ticks | 15.4 minutes |
| Adaptive IDS (T2 Defense) | 12,000¢ | ~1,231 ticks | 20.5 minutes |
| TARGET (10,000¢) | n/a | ~1,026 ticks | 17.1 minutes |

---

## Tier 2 Configuration Analysis

After purchasing full T2 set (~22,500¢ total, ~40 min from start):

| Component | Stat | Value |
|-----------|------|-------|
| Corporate Leech | Production | 20 × 1 × 1.5 = **30/tick** |
| Fiber Darknet Relay | Bandwidth | 15 × 1 × 1.4 = **21/tick** |
| Shadow Market | Processing | 15 × 1 × 1.3 = **19.5/tick** |
| Shadow Market | Conversion | **2.0x** |

**Bottleneck Analysis (T2 Level 1):**
- Source outputs: 30/tick
- Link can transfer: 21/tick
- Sink can process: 19.5/tick (BOTTLENECK)
- **Effective throughput**: 19.5/tick
- **Credits/tick**: 19.5 × 2.0 = **39 ¢/tick** (4x improvement)
- **Packet loss**: 10.5/tick (35% loss)

---

## Time-to-Unlock (T2 → T3)

Starting from T2 at 39¢/tick:

| Unlock | Cost | Time @ 39¢/tick | Real Time |
|--------|------|-----------------|-----------|
| PRIORITY (50,000¢) | n/a | ~1,282 ticks | 21.4 minutes |
| Quantum Bridge (T3 Link) | 40,000¢ | ~1,026 ticks | 17.1 minutes |
| Zero-Day Harvester (T3 Source) | 50,000¢ | ~1,282 ticks | 21.4 minutes |
| Corp Backdoor (T3 Sink) | 60,000¢ | ~1,538 ticks | 25.6 minutes |
| Neural Counter (T3 Defense) | 75,000¢ | ~1,923 ticks | 32.1 minutes |

**Cumulative time to T3 (from start):** ~60-75 minutes

---

## Tier 3 Configuration Analysis

| Component | Stat | Value |
|-----------|------|-------|
| Zero-Day Harvester | Production | 50 × 1 × 1.5 = **75/tick** |
| Quantum Mesh Bridge | Bandwidth | 40 × 1 × 1.4 = **56/tick** |
| Corp Backdoor | Processing | 45 × 1 × 1.3 = **58.5/tick** |
| Corp Backdoor | Conversion | **2.5x** |

**Bottleneck Analysis (T3 Level 1):**
- Source outputs: 75/tick
- Link can transfer: 56/tick (BOTTLENECK)
- Sink can process: 58.5/tick
- **Effective throughput**: 56/tick
- **Credits/tick**: 56 × 2.5 = **140 ¢/tick** (3.3x improvement)

---

## Time-to-Unlock (T3 → T4)

Starting from T3 at 140¢/tick:

| Unlock | Cost | Time @ 140¢/tick | Real Time |
|--------|------|------------------|-----------|
| HUNTED (250,000¢) | n/a | ~1,786 ticks | 29.8 minutes |
| Helix units (500,000¢ each) | 500,000¢ | ~3,571 ticks | 59.5 minutes |
| MARKED (1,000,000¢) | n/a | ~7,143 ticks | 119 minutes |

**Cumulative time to T4 (from start):** ~2.5-3 hours

---

## Prestige Analysis

| Prestige Level | Credits Required | Time to Reach (T3 rate) |
|----------------|------------------|-------------------------|
| 1st Prestige | 150,000¢ | ~18 minutes (from T3) |
| 2nd Prestige | 750,000¢ | ~89 minutes (from T3) |
| 3rd Prestige | 3,750,000¢ | ~7.5 hours (from T3) |

**Prestige Bonuses:**
- Production Multiplier: `1.0 + (prestigeLevel × 0.1) + (helixCores × 0.05)`
- Credit Multiplier: `1.0 + (prestigeLevel × 0.15)`

At Prestige 1: 1.1x production, 1.15x credits → ~26% overall boost

---

## Balance Assessment (Post-Tuning)

### Issues Resolved

1. **✅ Bottleneck Variety Added**
   - Sink is now the bottleneck at T1 and T2 (was always link)
   - Players must choose between upgrading sink or link
   - Creates meaningful strategic decisions

2. **✅ Tier 2 Progression Slowed**
   - Full T2 set now takes ~40 minutes (was ~10 minutes)
   - More time to learn threat/defense dynamics

3. **✅ T3 Defense Pricing Fixed**
   - Neural Countermeasure reduced to 75K (from 100K)
   - Affordable before HUNTED threat level

4. **✅ Prestige Timing Improved**
   - First prestige requires 150K (was 100K)
   - Must reach mid-T3 before first prestige

5. **✅ Attack Scaling Implemented**
   - Attacks scale with player income (30% factor)
   - Attacks remain meaningful throughout progression

---

## Applied Balance Changes (v0.7.1)

All recommended adjustments have been implemented:

### 1. T2 Unlock Costs Increased 50%
| Unit | Old Cost | New Cost |
|------|----------|----------|
| Corporate Leech | 5,000¢ | 7,500¢ |
| Fiber Darknet Relay | 4,000¢ | 6,000¢ |
| Shadow Market | 6,000¢ | 9,000¢ |
| Adaptive IDS | 8,000¢ | 12,000¢ |

### 2. T3 Defense Cost Reduced
- Neural Countermeasure: 100,000¢ → **75,000¢**

### 3. Prestige Threshold Increased
- First prestige: 100,000¢ → **150,000¢**
- Scaling remains 5x per level (150K, 750K, 3.75M, 18.75M...)

### 4. Attack Damage Scales with Income
- Attacks now scale based on player's credits/tick
- Formula: `baseDamage × (0.7 + 0.3 × min(income/10, 20))`
- Keeps attacks threatening at all progression stages
- DDoS bandwidth reduction unchanged (already percentage-based)

### 5. Bottleneck Variety Added
- T1 Sink processing: 6/tick → **5/tick** (creates sink bottleneck early)
- T2 Sink processing: 18/tick → **15/tick** (balanced with link)
- Players now have meaningful choices about which node to upgrade

---

## Upgrade Economy

### Current Upgrade Costs (per level)
| Node | Cost/Level | Stats Gained |
|------|------------|--------------|
| Source | 25¢ | +1.5 base production |
| Link | 30¢ | +1.4 base bandwidth |
| Sink | 40¢ | +1.3 base processing |
| Firewall | 50¢ | +1.5 base health, +5% DR |

### Upgrade ROI Analysis
At T1 starting rates (10.5¢/tick):

- Source Lv1→2: 25¢ cost, +1.5 production/tick, but link-bottlenecked (no gain)
- Link Lv1→2: 30¢ cost, +1.4 bandwidth/tick, ROI in ~21 ticks (21 seconds)
- Sink Lv1→2: 40¢ cost, but link-bottlenecked (no gain until link upgraded)

**Optimal upgrade path:** Link first, always.

---

## Threat vs Defense Balance

| Threat Level | Attack Chance | Severity | With Basic FW | With Adaptive IDS |
|--------------|---------------|----------|---------------|-------------------|
| GHOST | 0% | 0x | n/a | n/a |
| BLIP | 0.5% | 0.5x | GHOST (0%) | GHOST (0%) |
| SIGNAL | 1% | 1x | BLIP (0.5%) | GHOST (0%) |
| TARGET | 2% | 1.5x | SIGNAL (1%) | BLIP (0.5%) |
| PRIORITY | 3.5% | 2x | TARGET (2%) | SIGNAL (1%) |
| HUNTED | 5% | 3x | PRIORITY (3.5%) | TARGET (2%) |
| MARKED | 8% | 5x | HUNTED (5%) | PRIORITY (3.5%) |

Defense effectively reduces threat by 1-2 levels, which is significant.

---

## Summary

The game is **playable but could benefit from tuning**:

1. **Early game** (0-15 min): Well-paced, introduces mechanics gradually
2. **Mid game** (15-60 min): Slightly too fast, T2→T3 transition quick
3. **Late game** (60+ min): Prestige comes before T4 is fully explored
4. **Attack balance**: Defense is very effective, attacks feel less threatening at higher tiers

**Recommended Priority Changes:**
1. Increase T2 unlock costs OR decrease starting production
2. Scale attack damage with player total credits
3. Adjust prestige thresholds to encourage T3+ exploration

---

*Analysis Date: 2026-01-20*
*Version: 0.7.0-alpha*
