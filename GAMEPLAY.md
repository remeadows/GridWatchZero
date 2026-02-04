# GAMEPLAY.md - Grid Watch Zero: Balance & Mechanics Reference

> Quick reference for game balance, unit stats, and progression mechanics.

---

## Campaign Level Balance

### Level Progression Overview

| Level | Name | Credits Required | Defense Pts | Reports | Attacks | Start Credits | Attack % | Tiers |
|-------|------|-----------------|-------------|---------|---------|---------------|----------|-------|
| 1 | Home Protection | 100K | 50 | 5 | - | 0 | - | T1 |
| 2 | Small Office | 250K | 150 | 10 | - | 0 | 0.3% | T1-T2 |
| 3 | Office Network | 750K | 350 | 20 | 15 | 0 | 0.5% | T1-T3 |
| 4 | Large Office | 2M | 500 | 40 | 20 | 0 | 1.0% | T1-T4 |
| 5 | Campus Network | 6M | 800 | 80 | 25 | 0 | 1.5% | T1-T5 |
| 6 | Enterprise Network | 10M | 1,000 | 100 | 25 | 1,000 | 1.5% | T1-T6 |
| 7 | City Network | 25M | 1,500 | 200 | 35 | 2,000 | 2.0% | T1-T6 |
| **8** | **Malus Outpost Alpha** | **100M** | **3,000** | **400** | **60** | **5K** | **3.0%** | **T1-T7** |
| 9 | Corporate Extraction | 250M | 4,500 | 500 | 75 | 0 | 4.0% | T1-T8 |
| 10 | Malus Core Siege | 500M | 6,000 | 640 | 90 | 0 | 5.0% | T1-T10 |
| 11 | Ghost Protocol | 1B | 8,000 | 800 | 100 | 0 | 6.0% | T1-T12 |
| 12 | Temporal Incursion | 2.5B | 10,000 | 1,000 | 120 | 0 | 8.0% | T1-T14 |
| 13 | Logic Bomb | 5B | 12,000 | 1,280 | 140 | 0 | 10.0% | T1-T15 |
| 14 | The Black Site | 10B | 15,000 | 1,600 | 160 | 0 | 12.0% | T1-T17 |
| 15 | The Awakening | 25B | 20,000 | 2,000 | 180 | 0 | 15.0% | T1-T19 |
| 16 | Dimensional Breach | 50B | 25,000 | 2,560 | 200 | 0 | 18.0% | T1-T20 |
| 17 | The Convergence | 100B | 30,000 | 3,200 | 220 | 0 | 20.0% | T1-T21 |
| 18 | The Origin | 250B | 40,000 | 4,000 | 250 | 0 | 25.0% | T1-T23 |
| 19 | The Choice | 500B | 50,000 | 5,000 | 280 | 0 | 30.0% | T1-T24 |
| 20 | The New Dawn | 1T | 100,000 | 10,000 | 320 | 0 | 40.0% | T1-T25 |

### Balance Notes

**Level 8 (Critical Transition Point)**
- First level after Helix awakening
- 4x credit jump from Level 7 (25M → 100M)
- Starting credits: 5,000 (provides survival buffer without trivializing early game)
- Requires T7 "Symbiont" technology unlock
- Minimum attack chance: 3.0% per tick

**Progression Multipliers**
| Level Range | Credit Multiplier (vs. Previous) | Report Multiplier |
|-------------|----------------------------------|-------------------|
| 1-7 | ~2-3x | ~2x |
| 8-10 | ~2.5x | ~1.25x |
| 11-15 | ~2x | ~1.25x |
| 16-20 | ~2x | ~1.5x |

---

## Source Units (Data Generation)

| Tier | Unit Name | Base Production | Max Level | Unlock Cost |
|------|-----------|-----------------|-----------|-------------|
| T1 | Public Mesh Sniffer | 8.0/tick | 10 | Free |
| T2 | Corporate Leech | 20.0/tick | 15 | 7,500 |
| T3 | Zero-Day Harvester | 50.0/tick | 20 | 32,000 |
| T4 | Helix Fragment Scanner | 100.0/tick | 25 | 150,000 |
| T5 | Neural Tap Array | 200.0/tick | 30 | 500,000 |
| T6 | Helix Prime Collector | 500.0/tick | 40 | 2,000,000 |
| T7 | Helix Symbiont Array | 1,000/tick | 50 | 20M |
| T8 | Transcendence Probe | 2,000/tick | 50 | 200M |
| T9 | Void Echo Listener | 4,000/tick | 50 | 2B |
| T10 | Dimensional Trawler | 8,000/tick | 50 | 20B |
| T11 | Multiverse Beacon | 16,000/tick | 50 | 200B |
| T12 | Entropy Harvester | 32,000/tick | 50 | 2T |
| T13 | Causality Scanner | 64,000/tick | 50 | 20T |
| T14 | Timeline Extractor | 128,000/tick | 50 | 200T |
| T15 | Akashic Tap | 256,000/tick | 50 | 2Q |
| T16 | Cosmic Web Siphon | 512,000/tick | 50 | 20Q |
| T17 | Dark Matter Collector | 1.024M/tick | 50 | 200Q |
| T18 | Singularity Well | 2.048M/tick | 50 | 2Qi |
| T19 | Omniscient Array | 4.096M/tick | 50 | 20Qi |
| T20 | Reality Core Tap | 8.192M/tick | 50 | 200Qi |
| T21 | Prime Nexus Scanner | 16.384M/tick | 50 | 2Sx |
| T22 | Absolute Zero Harvester | 32.768M/tick | 50 | 20Sx |
| T23 | Genesis Protocol | 65.536M/tick | 50 | 200Sx |
| T24 | Omega Stream | 131.072M/tick | 50 | 2Sp |
| T25 | The All-Seeing Array | 262.144M/tick | 50 | 20Sp |

**Production Formula**: `baseProduction × level × 1.5`

**Upgrade Cost Formula**: `25.0 × 1.18^level`

---

## Link Units (Data Transfer)

| Tier | Unit Name | Base Bandwidth | Latency | Max Level | Unlock Cost |
|------|-----------|---------------|---------|-----------|-------------|
| T1 | Copper VPN Tunnel | 5.0/tick | 3 ticks | 10 | Free |
| T2 | Fiber Darknet Relay | 15.0/tick | 2 ticks | 15 | 6,000 |
| T3 | Quantum Mesh Bridge | 40.0/tick | 1 tick | 20 | 26,000 |
| T4 | Helix Conduit | 100.0/tick | 0 ticks | 25 | 150,000 |
| T5 | Neural Mesh Backbone | 250.0/tick | 0 ticks | 30 | 400,000 |
| T6 | Helix Resonance Channel | 600.0/tick | 0 ticks | 40 | 1,800,000 |
| T7 | Helix Synaptic Bridge | 1,200/tick | 0 ticks | 50 | 18M |
| T8 | Transcendence Gate | 2,400/tick | 0 ticks | 50 | 180M |
| T9 | Void Tunnel | 4,800/tick | 0 ticks | 50 | 1.8B |
| T10 | Dimensional Corridor | 9,600/tick | 0 ticks | 50 | 18B |
| T11 | Multiverse Router | 19,200/tick | 0 ticks | 50 | 180B |
| T12 | Entropy Bypass | 38,400/tick | 0 ticks | 50 | 1.8T |
| T13 | Causality Link | 76,800/tick | 0 ticks | 50 | 18T |
| T14 | Temporal Conduit | 153,600/tick | 0 ticks | 50 | 180T |
| T15 | Akashic Highway | 307,200/tick | 0 ticks | 50 | 1.8Q |
| T16 | Cosmic Strand | 614,400/tick | 0 ticks | 50 | 18Q |
| T17 | Dark Flow Channel | 1.228M/tick | 0 ticks | 50 | 180Q |
| T18 | Singularity Bridge | 2.457M/tick | 0 ticks | 50 | 1.8Qi |
| T19 | Omnipresent Mesh | 4.915M/tick | 0 ticks | 50 | 18Qi |
| T20 | Reality Weave | 9.830M/tick | 0 ticks | 50 | 180Qi |
| T21 | Prime Conduit | 19.66M/tick | 0 ticks | 50 | 1.8Sx |
| T22 | Absolute Channel | 39.32M/tick | 0 ticks | 50 | 18Sx |
| T23 | Genesis Link | 78.64M/tick | 0 ticks | 50 | 180Sx |
| T24 | Omega Bridge | 157.28M/tick | 0 ticks | 50 | 1.8Sp |
| T25 | The Infinite Backbone | 314.57M/tick | 0 ticks | 50 | 18Sp |

**Bandwidth Formula**: `baseBandwidth × level × 1.4`

**Packet Loss**: Excess data subject to 80-100% loss (improves slightly with level)

**Upgrade Cost Formula**: `30.0 × 1.18^level`

---

## Sink Units (Credit Processing)

| Tier | Unit Name | Base Processing | Conversion Rate | Max Level | Unlock Cost |
|------|-----------|-----------------|-----------------|-----------|-------------|
| T1 | Data Broker | 5.0/tick | 1.5x | 10 | Free |
| T2 | Shadow Market | 15.0/tick | 2.0x | 15 | 9,000 |
| T3 | Corp Backdoor | 45.0/tick | 2.5x | 20 | 38,000 |
| T4 | Helix Decoder | 80.0/tick | 3.0x | 25 | 150,000 |
| T5 | Neural Exchange | 180.0/tick | 3.5x | 30 | 600,000 |
| T6 | Helix Integration Core | 400.0/tick | 4.5x | 40 | 2,500,000 |
| T7 | Helix Synapse Core | 800/tick | 5.0x | 50 | 22M |
| T8 | Transcendence Engine | 1,600/tick | 5.5x | 50 | 220M |
| T9 | Void Processor | 3,200/tick | 6.0x | 50 | 2.2B |
| T10 | Dimensional Nexus | 6,400/tick | 6.5x | 50 | 22B |
| T11 | Multiverse Exchange | 12,800/tick | 7.0x | 50 | 220B |
| T12 | Entropy Converter | 25,600/tick | 7.5x | 50 | 2.2T |
| T13 | Causality Broker | 51,200/tick | 8.0x | 50 | 22T |
| T14 | Temporal Marketplace | 102,400/tick | 8.5x | 50 | 220T |
| T15 | Akashic Decoder | 204,800/tick | 9.0x | 50 | 2.2Q |
| T16 | Cosmic Monetizer | 409,600/tick | 9.5x | 50 | 22Q |
| T17 | Dark Matter Exchange | 819,200/tick | 10.0x | 50 | 220Q |
| T18 | Singularity Forge | 1.638M/tick | 10.5x | 50 | 2.2Qi |
| T19 | Omniscient Broker | 3.276M/tick | 11.0x | 50 | 22Qi |
| T20 | Reality Synthesizer | 6.553M/tick | 11.5x | 50 | 220Qi |
| T21 | Prime Processor | 13.1M/tick | 12.0x | 50 | 2.2Sx |
| T22 | Absolute Converter | 26.2M/tick | 12.5x | 50 | 22Sx |
| T23 | Genesis Core | 52.4M/tick | 13.0x | 50 | 220Sx |
| T24 | Omega Processor | 104.8M/tick | 13.5x | 50 | 2.2Sp |
| T25 | The Infinite Core | 209.7M/tick | 14.0x | 50 | 22Sp |

**Processing Formula**: `baseProcessingRate × level × 1.3`

**Credits per Tick** = `min(bufferData, processingPerTick) × conversionRate`

**Upgrade Cost Formula**: `40.0 × 1.18^level`

---

## Defense Applications (Intel Gathering)

Defense Apps provide damage reduction AND intel collection bonuses. SIEM and IDS categories are specialists for intel gathering.

### Defense Categories & Intel Bonuses

| Category | Intel Specialty | Detection Bonus (per tier level) | Intel Multiplier |
|----------|----------------|----------------------------------|------------------|
| **SIEM** | Primary Intel | +15% per tier | 1.0 + (0.25 × tier) + (0.05 × level) |
| **IDS** | Secondary Intel | +10% per tier | 1.0 + (0.15 × tier) + (0.03 × level) |
| Endpoint | Support | +5% per tier | 1.0x (no bonus) |
| Firewall | Defense | +2% per tier | 1.0x (no bonus) |
| Network | Defense | +2% per tier | 1.0x (no bonus) |
| Encryption | Defense | +2% per tier | 1.0x (no bonus) |

### SIEM Progression Chain (T1-T6)

| Tier | App Name | Unlock Cost | Detection Bonus | Intel Multiplier (Lv1) |
|------|----------|-------------|-----------------|------------------------|
| T1 | Syslog Server | 500 | +15% | 1.30x |
| T2 | SIEM Platform | 5,000 | +30% | 1.55x |
| T3 | SOAR System | 40,000 | +45% | 1.80x |
| T4 | AI Analytics | 120,000 | +60% | 2.05x |
| T5 | Predictive SIEM | 500,000 | +75% | 2.30x |
| T6 | Helix Insight | 2,000,000 | +90% | 2.55x |

### IDS Progression Chain (T1-T6)

| Tier | App Name | Unlock Cost | Detection Bonus | Intel Multiplier (Lv1) |
|------|----------|-------------|-----------------|------------------------|
| T1 | IDS Sensor | 500 | +10% | 1.18x |
| T2 | IPS Active | 5,000 | +20% | 1.33x |
| T3 | ML/IPS | 40,000 | +30% | 1.48x |
| T4 | AI Detection | 120,000 | +40% | 1.63x |
| T5 | Quantum IDS | 500,000 | +50% | 1.78x |
| T6 | Helix Watcher | 2,000,000 | +60% | 1.93x |

### Intel Report System

| Action | Base Cost | Reward | Notes |
|--------|-----------|--------|-------|
| Send Report | 200 data (+5% per report) | 100 + (patterns × 10) credits | Multiplied by SIEM intel multiplier |
| Attack Survived | - | +50-200 footprint data | Multiplied by detection bonus |

### Intel Milestones

| Reports | Milestone | Credit Reward | Permanent Bonus |
|---------|-----------|---------------|-----------------|
| 1 | First Contact | 1,000 | +10% intel collection |
| 3 | Pattern Analyst | 5,000 | +25% pattern ID speed |
| 5 | Signature Expert | 15,000 | +15% intel collection |
| 10 | Threat Hunter | 50,000 | 20% attack early warning |
| 15 | Malus Tracker | 100,000 | +5% damage reduction |
| 20 | Origin Discovery | 250,000 | +25% intel collection |
| 25 | Counter-Intelligence | 500,000 | 10% fewer attacks |

---

## Monetization Ideas (Future)

### Credit Boost Button (Proposed: ENH-020)

**Concept**: Paid feature allowing players to temporarily multiply credit income.

| Boost Level | Duration | Credit Multiplier | Suggested Price |
|-------------|----------|-------------------|-----------------|
| Standard | 5 minutes | 2x credits | $0.99 |
| Premium | 5 minutes | 3x credits | $1.99 |
| Bundle | 30 minutes | 2x credits | $4.99 |

**Implementation Considerations**:
- Timer displayed in UI (countdown)
- Visual indicator (golden glow on credit counter)
- Stacks with prestige multipliers
- Does NOT affect threat level progression
- Available from Level 3+ (after tutorial completion)

**Revenue Model**: Single-use consumable (not subscription)

---

## Audio System Notes

### Current State

- Single background track (`GridWatchZero_Ambient.m4a`)
- 9 sound effect files (.m4a format)
- AVAudioPlayer for music, preset haptics

### Concerns

- **Repetitive**: Single track becomes monotonous during extended play sessions
- **No variation**: No dynamic music system (intensity doesn't scale with threat)
- **Player feedback**: "Pretty wild to listen to non-stop"

### Proposed Improvements (See ENH-017)

1. **Multiple tracks** - At least 3-5 ambient tracks with smooth crossfading
2. **Threat-reactive audio** - Music intensity scales with threat level
3. **Audio variety** - Low-threat calm ambience vs. high-threat intense music
4. **User controls** - Volume sliders, music toggle, track skip

---

## Quick Reference Formulas

### Production Pipeline

```
Data Generated = sourceBase × sourceLevel × 1.5 × prestigeMultiplier
Data Transferred = min(bandwidth × linkLevel × 1.4, dataGenerated)
Data Processed = min(sinkBase × sinkLevel × 1.3, transferredData)
Credits Earned = processedData × conversionRate × prestigeMultiplier
```

### Defense Calculations

```
Total Damage Reduction = min(cap, sum(appDamageReduction))
  - T1-T4 cap: 60%
  - T5 cap: 70%
  - T6 cap: 80%
  - T7-T10 cap: 85%
  - T11+ cap: 90-95%

Attack Frequency = baseThreatChance × (1 - defensePointReduction) × (1 - intelReduction)
```

### Prestige Multipliers

```
Production Multiplier = 1.0 + (prestigeLevel × 0.1) + (totalCores × 0.05)
Credit Multiplier = 1.0 + (prestigeLevel × 0.15)
```

---

## Version History

| Date | Changes |
|------|---------|
| 2026-02-04 | Initial creation with all 20 levels, unit tables, defense apps, monetization ideas |
