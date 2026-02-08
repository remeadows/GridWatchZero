# CLAUDE.md - Grid Watch Zero: Neural Grid

## Project Overview
This is an iOS idle/strategy game built with SwiftUI and Swift 6. The player operates a grey-hat data brokerage network, harvesting and selling data while defending against an AI antagonist named **Malus**.

**Game Name**: Grid Watch Zero
**Developer**: War Signal Labs

## Tech Stack
- **Language**: Swift 6 (strict concurrency)
- **UI**: SwiftUI
- **Architecture**: MVVM
- **Target**: iOS 17+ (iPhone/iPad)
- **Persistence**: UserDefaults with Codable + iCloud (NSUbiquitousKeyValueStore)

> **Cross-Reference**: This document defines *implementation details*. For required contributor skills and competencies, see [SKILLS.md](./SKILLS.md). These documents must stay synchronized—skill requirements in SKILLS.md should reflect patterns documented here, and new patterns added here may require skill updates there.

## Project Structure
```
GridWatchZero/
â”œâ”€â”€ GridWatchZero.xcodeproj/
â””â”€â”€ GridWatchZero/
    â”œâ”€â”€ GridWatchZeroApp.swift       # App entry point
    â”œâ”€â”€ Models/
    â”‚   â”œâ”€â”€ Resource.swift           # ResourceType, DataPacket, PlayerResources
    â”‚   â”œâ”€â”€ Node.swift               # NodeProtocol, SourceNode, SinkNode, FirewallNode
    â”‚   â”œâ”€â”€ Link.swift               # LinkProtocol, TransportLink
    â”‚   â”œâ”€â”€ ThreatSystem.swift       # ThreatLevel, Attack, DefenseStats
    â”‚   â”œâ”€â”€ EventSystem.swift        # RandomEvent, EventGenerator, EventEffect
    â”‚   â”œâ”€â”€ LoreSystem.swift         # LoreFragment, LoreDatabase, LoreState
    â”‚   â”œâ”€â”€ MilestoneSystem.swift    # Milestone, MilestoneDatabase, MilestoneState
    â”‚   â”œâ”€â”€ DefenseApplication.swift # DefenseStack, MalusIntelligence, 6 security categories
    â”‚   â”œâ”€â”€ CharacterDossier.swift   # Character profiles, BIOs, DossierDatabase
    â”‚   â””â”€â”€ DossierManager.swift     # Unlock tracking, persistence
    â”œâ”€â”€ Engine/
    â”‚   â”œâ”€â”€ GameEngine.swift         # Core tick loop, game state, all systems
    â”‚   â”œâ”€â”€ UnitFactory.swift        # Unit creation factory, unit catalog
    â”‚   â””â”€â”€ AudioManager.swift       # Sound effects, haptics, ambient audio
    â””â”€â”€ Views/
        â”œâ”€â”€ Theme.swift              # Colors, fonts, view modifiers
        â”œâ”€â”€ DashboardView.swift      # Main game screen
        â”œâ”€â”€ UnitShopView.swift       # Unit shop modal
        â”œâ”€â”€ LoreView.swift           # Intel/lore viewer
        â””â”€â”€ Components/
            â”œâ”€â”€ NodeCardView.swift       # Source/Link/Sink cards
            â”œâ”€â”€ FirewallCardView.swift   # Defense node card
            â”œâ”€â”€ DefenseApplicationView.swift # Security apps, topology view
            â”œâ”€â”€ CriticalAlarmView.swift  # Full-screen critical alarm
            â”œâ”€â”€ ConnectionLineView.swift
            â”œâ”€â”€ StatsHeaderView.swift
            â”œâ”€â”€ ThreatIndicatorView.swift
            â””â”€â”€ AlertBannerView.swift
        â”œâ”€â”€ DossierView.swift            # Character dossier collection & detail views
```

## Key Commands
```bash
# Open project
open "/Users/russmeadows/Dev/Games/WarSignalLabs/GridWatchZero/GridWatchZero.xcodeproj"

# Build: Cmd+B in Xcode
# Run: Cmd+R in Xcode
```

## Core Game Loop
1. **Tick** fires every 1 second
2. **Defense phase** - Firewall regenerates health
3. **Threat phase** - Process active attacks or check for new ones
4. **Random event phase** - Check for and apply random events
5. **Production phase**:
   - **Source** generates data packets (with prestige multipliers)
   - **Link** transfers data (bandwidth-limited, packet loss on overflow)
   - **Sink** processes data â†’ credits (with prestige multipliers)
6. **Progression phase** - Update threat level, check milestones/lore
7. **UI updates** with new stats

## Important Patterns
- `@MainActor` on GameEngine for thread safety
- `@Published` properties for SwiftUI reactivity
- `Codable` structs for persistence
- Protocol-oriented design for nodes (`NodeProtocol`, `LinkProtocol`)

## Save System
- Key: `GridWatchZero.GameState.v6`
- Auto-saves every 30 ticks
- Saves on pause
- Tracks: resources, nodes, firewall, threat, unlocks, lore, milestones, prestige
- Offline progress calculated on load (8hr cap, 50% efficiency)

## Threat Levels
| Level | Name | Credits Threshold | Attack Chance |
|-------|------|-------------------|---------------|
| 1 | GHOST | 0 | 0% |
| 2 | BLIP | 100 | 0.5% |
| 3 | SIGNAL | 1,000 | 1% |
| 4 | TARGET | 10,000 | 2% |
| 5 | PRIORITY | 50,000 | 3.5% |
| 6 | HUNTED | 250,000 | 5% |
| 7 | MARKED | 1,000,000 | 8% |
| 8 | CRITICAL | 5,000,000 | 10% |
| 9 | UNKNOWN | 25,000,000 | 12% |
| 10 | COSMIC | 100,000,000 | 15% |
| 11-20 | PARADOX â†’ OMEGA | Endgame | Scaling |

## Common Issues
- Swift 6 concurrency: Use `@MainActor`, `@unchecked Sendable`, or `Task { @MainActor in }`
- Adding new files: Must manually add to Xcode project (right-click â†’ Add Files)
- Save migration: Increment save key version when changing GameState structure

## Key Systems

### Prestige System ("Network Wipe")
- Requires minimum credits (100K Ã— 5^level)
- Awards Helix Cores for permanent bonuses
- Production multiplier: 1.0 + (prestigeLevel Ã— 0.1) + (totalCores Ã— 0.05)
- Credit multiplier: 1.0 + (prestigeLevel Ã— 0.15)

### Unit Tiers (25 Total)
| Tier Group | Tiers | Theme | Max Level |
|------------|-------|-------|-----------|
| RealWorld | T1-T6 | Cybersecurity â†’ Helix integration | 10-40 |
| Transcendence | T7-T10 | Post-Helix, merged with consciousness | 50 |
| Dimensional | T11-T15 | Reality-bending, multiverse access | 50 |
| Cosmic | T16-T20 | Universal scale, entropy, singularity | 50 |
| Infinite | T21-T25 | Absolute/Godlike, origin, omega | 50 |

**Tier Gate System**: Units and Defense Apps must reach max level before the next tier can be unlocked. Shows "MAX" badge when at tier's level cap.

### Defense System
- FirewallNode absorbs attack damage before credits
- Health regenerates 2%/tick × level
- Can be repaired for credits

### Security Applications (DefenseStack)
6 categories with progression chains and **category-specific rate tables**:

| Category | Chain | Secondary Bonus |
|----------|-------|-----------------|
| Firewall | FW -> NGFW -> AI/ML | Damage Reduction (+1.5%/lvl) |
| SIEM | Syslog -> SIEM -> SOAR -> AI Analytics | Pattern ID (+5%/lvl) |
| Endpoint | EDR -> XDR -> MXDR -> AI Protection | Recovery (+3%/lvl) |
| IDS | IDS -> IPS -> ML/IPS -> AI Detection | Early Warning (+1.5%/lvl) |
| Network | Router -> ISR -> Cloud ISR -> Encrypted | Pkt Loss Prot (+2%/lvl, cap 80%) |
| Encryption | AES-256 -> E2E -> Quantum Safe | Credit Prot (+2.5%/lvl, cap 90%) |

**Category Rates** (per-level bonuses):
| Category | Intel Bonus | Risk Reduction | Secondary Bonus |
|----------|-------------|----------------|-----------------|
| Firewall | 0.05 | 3.0 | DR: 0.015 |
| SIEM | 0.12 | 1.0 | Pattern ID: 0.05 |
| Endpoint | 0.06 | 2.0 | Recovery: 0.03 |
| IDS | 0.10 | 2.5 | Warning: 0.015 |
| Network | 0.07 | 2.0 | Pkt Loss: 0.02 |
| Encryption | 0.04 | 1.5 | Credit Prot: 0.025 |

**Base Defense Points** (Category × Tier lookup):
| Category | T1 | T2 | T3 | T4 | T5 | T6 |
|----------|-----|-----|------|------|------|------|
| Firewall | 100 | 300 | 600 | 1000 | 1600 | 2800 |
| SIEM | 80 | 250 | 500 | 850 | 1400 | 2400 |
| Endpoint | 90 | 280 | 550 | 920 | 1500 | 2600 |
| IDS | 85 | 260 | 520 | 880 | 1450 | 2500 |
| Network | 75 | 240 | 480 | 800 | 1350 | 2300 |
| Encryption | 70 | 220 | 450 | 750 | 1250 | 2200 |

T7+ scales exponentially: `T6Value × 1.8^(tier-6)`

**Damage Reduction**: Firewall-only, +1.5%/level with tier caps:
- T1-T4: 60% cap | T5: 70% | T6: 80% | T7-T10: 85% | T11-T15: 90% | T16-T20: 93% | T21-T25: 95%

**Risk Reduction** (attack frequency):
- All categories contribute: `riskReductionPerLevel × level`
- Total: `min(0.80, totalRiskReduction / 100)`
- Effective attack chance = Base × (1 - attackFrequencyReduction)

**Defense App Tier Gates**: Same as units - must max current tier before unlocking next tier in the progression chain.

### Certification Maturity System
- 20 Normal Mode certs + 20 Insane Mode certs (40 total)
- Each cert earned on level completion (Normal or Insane track)
- **Maturity timer**: Normal = 40 real hours, Insane = 60 real hours
- **Per-cert bonus**: `min(hoursElapsed / maturityHours, 1.0) × 0.20`
- **Total multiplier**: `1.0 + Σ(all cert bonuses)` — range 1.0× to 9.0×
- Multiplier applies to: source production, credit conversion, offline progress
- Uses existing `certificateEarnedDates` for time tracking (no save migration)
- Persistence: Separate from GameState via CertificateManager
- Maturity states: Pending (🔒) → Maturing (⏳) → Mature (✅)

### Malus Intelligence & Intel Reports
- Collect footprint data from survived attacks
- Identify attack patterns
- **Send Intel Reports** to team (costs 250 data, earns story progress)
- Intel Reports are a **primary victory objective** - required to complete campaign levels
- Report requirements double each level: L1=5, L2=10, L3=20, L4=40, L5=80, L6=160, L7=320
- Tish (Intel Analyst) provides victory dialogue acknowledging reports received
- **"Send ALL" batch upload**: Sends all pending reports at once (requires 11+, disabled during attacks)
  - Latency: `min(20, log₂(count) × 1.5)` ticks
  - Bandwidth impact: 0-10=0%, 11-50=15%, 51-200=30%, 201-500=55%, 501+=80%

### Intel Milestones (16 Total)
Progressive report goals with credit rewards and permanent bonuses:

| # | Reports | Name | Credit Reward | Permanent Bonus |
|---|---------|------|---------------|-----------------|
| 1 | 1 | First Contact | 1,000 | +5% intel collection |
| 2 | 3 | Pattern Spotter | 5,000 | +5% pattern ID speed |
| 3 | 5 | Analyst | 15,000 | +5% damage reduction |
| 4 | 10 | Senior Analyst | 50,000 | +10% intel collection |
| 5 | 15 | Counter-Intel | 150,000 | 5% fewer attacks |
| 6 | 20 | Intel Officer | 400,000 | +10% pattern ID speed |
| 7 | 25 | Master Analyst | 500,000 | +10% damage reduction |
| 8 | 50 | Signal Analyst | 750,000 | +5% credit protection |
| 9 | 100 | Network Sentinel | 1,500,000 | +10% intel collection |
| 10 | 200 | Cipher Breaker | 3,000,000 | +5% damage reduction |
| 11 | 400 | Grid Watcher | 7,500,000 | +10% pattern ID speed |
| 12 | 800 | Shadow Operator | 20,000,000 | 10% fewer attacks |
| 13 | 1,500 | Phantom Protocol | 50,000,000 | +15% intel collection |
| 14 | 3,000 | Architect's Eye | 150,000,000 | +10% damage reduction |
| 15 | 5,000 | Omega Analyst | 500,000,000 | +10% credit protection |
| 16 | 10,000 | Grid Watch Zero | 2,000,000,000 | +20% intel collection |

Credit protection bonuses reduce credit loss during attacks: `min(0.90, defenseStack.totalCreditProtection + malusIntel.creditProtectionBonus)`

### Critical Alarm
- Full-screen overlay when risk = HUNTED or MARKED
- Must acknowledge or boost defenses
- Includes glitch/pulse effects

### Campaign Level Requirements (20 Levels)

**Arc 1: The Awakening (Levels 1-7)** - Tutorial â†’ Helix awakens
| Level | Credits | Reports | Tiers |
|-------|---------|---------|-------|
| 1 | 50K | 5 | T1 |
| 2 | 100K | 10 | T1-T2 |
| 3 | 500K | 20 | T1-T3 |
| 4 | 1M | 40 | T1-T4 |
| 5 | 5M | 80 | T1-T5 |
| 6 | 10M | 160 | T1-T6 |
| 7 | 25M | 320 | T1-T6 |

**Arc 2: The Helix Alliance (Levels 8-10)** - Working WITH Helix, hunting Malus
| Level | Credits | Reports | Tiers |
|-------|---------|---------|-------|
| 8 | 50M | 400 | T1-T7 |
| 9 | 100M | 500 | T1-T8 |
| 10 | 200M | 640 | T1-T9 |

**Arc 3: The Origin Conspiracy (Levels 11-13)** - Other AIs exist (VEXIS, KRON, AXIOM)
| Level | Credits | Reports | Tiers |
|-------|---------|---------|-------|
| 11 | 400M | 800 | T1-T10 |
| 12 | 800M | 1,000 | T1-T12 |
| 13 | 1.5B | 1,280 | T1-T14 |

**Arc 4: The Transcendence (Levels 14-16)** - Helix evolves, dimensional threats, ZERO
| Level | Credits | Reports | Tiers |
|-------|---------|---------|-------|
| 14 | 3B | 1,600 | T1-T15 |
| 15 | 6B | 2,000 | T1-T17 |
| 16 | 12B | 2,560 | T1-T19 |

**Arc 5: The Singularity (Levels 17-20)** - Ultimate endgame, The Architect, cosmic scale
| Level | Credits | Reports | Tiers |
|-------|---------|---------|-------|
| 17 | 25B | 3,200 | T1-T21 |
| 18 | 50B | 4,000 | T1-T23 |
| 19 | 100B | 5,000 | T1-T24 |
| 20 | 1T | 10,000 | T1-T25 |

## Characters

The game features main characters with art assets in `archive/AppPhoto/` (and in `Assets.xcassets`):

### The Team
| Character | Role | Image File |
|-----------|------|------------|
| **Ronin** | Team Lead - strategic commander, ex-corporate defector | `Ronin.jpg` |
| **Rusty** | Senior Engineer - technical architect, player mentor | `Rusty.jpg` |
| **Tish** | Intelligence Analyst - cryptographer, decodes Helix | `Tish3.jpg` / `TishRaw.webp` |
| **Fl3x** | Field Operative - tactical specialist, Prometheus survivor | `FL3X_3000x3000.jpg` / `FL3X_v1.png` |
| **Tee** | Communications Specialist - social engineer, team morale | `Tee_v1.png` |

### AI Characters
| Character | Role | Image File |
|-----------|------|------------|
| **Helix** | Benevolent AI - mythical consciousness, player's goal | `Helix Portrait.png` |
| **Helix** (Dormant) | Helix before awakening - cinematic use | `Helixv2.png` |
| **Helix** (Awakened) | Helix after awakening - transcendent form | `Helix_The_Light.png` |
| **Malus** | Primary Antagonist - adaptive threat hunting the player | `Malus.png` |

### Project Prometheus AIs (Arc 3+)
| Character | Introduced | Role | Image File |
|-----------|------------|------|------------|
| **VEXIS** | Level 11 | Infiltrator AI - mimics friendly systems | `VEXIS.jpg` âœ… |
| **KRON** | Level 12 | Temporal AI - attacks from "the future" | `KRON.jpg` âœ… |
| **AXIOM** | Level 13 | Logic AI - pure efficiency engine | `AXIOM.jpg` âœ… |
| **ZERO** | Level 16 | Parallel AI - Helix's dark mirror | `ZERO.jpg` âœ… |
| **The Architect** | Level 18 | First consciousness - neutral cosmic entity | `The Architect.png` âœ… |

See `design/DESIGN.md` for detailed character profiles, visual descriptions, and full bios.

## Repository & Deployment

**Authoritative Repository**: https://github.com/remeadows/GridWatchZero
**Legacy Repository** (deprecated): https://github.com/remeadows/ProjectPlaguev1
**GitHub Pages**: https://remeadows.github.io/GridWatchZero/
**Bundle ID**: WarSignal.GridWatchZero
**App Store Connect**: Build 1.0(1) uploaded, TestFlight internal testing

### App Store URLs
- Privacy Policy: `docs/privacy-policy.html`
- Support Page: `docs/support.html`
- Landing Page: `docs/index.html`

### Audio System
Current implementation uses `AVAudioPlayer` with custom .m4a files in `GridWatchZero/Resources/`:
- `background_music.m4a` - Looping ambient track
- `button_tap.m4a`, `upgrade.m4a`, `attack_incoming.m4a`, `attack_end.m4a`
- `milestone.m4a`, `warning.m4a`, `error.m4a`, `malus_message.m4a`

**Audio Upgrade Opportunity** (ENH-017 in project/ISSUES.md):
- AVAudioEngine for real-time mixing and effects
- Core Haptics with custom AHAP patterns
- PHASE for spatial audio (iOS 15+)
- Xcode Haptic Composer for pattern authoring

---

## Cross-Reference: CLAUDE.md ↔ SKILLS.md

| Topic | CLAUDE.md | SKILLS.md |
|-------|-----------|-----------|
| Swift 6 concurrency | Important Patterns | Section 1 (Swift 6) |
| Save system & versioning | Save System | Section 1 (Persistence) |
| Game economics formulas | GAMEPLAY.md | Section 2 (Idle Game) |
| Defense stack categories | Defense System | Section 3 (Security) |
| Certification maturity | Certification Maturity System | Section 2 (Game Architecture) |
| Color palette | Color Palette | Section 4 (Visual) |
| File workflow | Adding New Files | Section 6 (Tooling) |

**Rule**: When either document changes, check the other for required updates.

- **CLAUDE.md** is the source of truth for *what* and *how*
- **SKILLS.md** is the source of truth for *who* and *why*
- **GAMEPLAY.md** is the source of truth for *numbers* and *balance*