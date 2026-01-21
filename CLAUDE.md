# CLAUDE.md - Project Plague: Neural Grid

## Project Overview
This is an iOS idle/strategy game built with SwiftUI and Swift 6. The player operates a grey-hat data brokerage network, harvesting and selling data while defending against an AI antagonist named **Malus**.

## Tech Stack
- **Language**: Swift 6 (strict concurrency)
- **UI**: SwiftUI
- **Architecture**: MVVM
- **Target**: iOS 17+ (iPhone/iPad)
- **Persistence**: UserDefaults with Codable

## Project Structure
```
ProjectPlague/
├── ProjectPlague.xcodeproj/
└── ProjectPlague/Project Plague/Project Plague/
    ├── Project_PlagueApp.swift      # App entry point
    ├── Models/
    │   ├── Resource.swift           # ResourceType, DataPacket, PlayerResources
    │   ├── Node.swift               # NodeProtocol, SourceNode, SinkNode, FirewallNode
    │   ├── Link.swift               # LinkProtocol, TransportLink
    │   ├── ThreatSystem.swift       # ThreatLevel, Attack, DefenseStats
    │   ├── EventSystem.swift        # RandomEvent, EventGenerator, EventEffect
    │   ├── LoreSystem.swift         # LoreFragment, LoreDatabase, LoreState
    │   ├── MilestoneSystem.swift    # Milestone, MilestoneDatabase, MilestoneState
    │   └── DefenseApplication.swift # DefenseStack, MalusIntelligence, 6 security categories
    ├── Engine/
    │   ├── GameEngine.swift         # Core tick loop, game state, all systems
    │   ├── UnitFactory.swift        # Unit creation factory, unit catalog
    │   └── AudioManager.swift       # Sound effects, haptics, ambient audio
    └── Views/
        ├── Theme.swift              # Colors, fonts, view modifiers
        ├── DashboardView.swift      # Main game screen
        ├── UnitShopView.swift       # Unit shop modal
        ├── LoreView.swift           # Intel/lore viewer
        └── Components/
            ├── NodeCardView.swift       # Source/Link/Sink cards
            ├── FirewallCardView.swift   # Defense node card
            ├── DefenseApplicationView.swift # Security apps, topology view
            ├── CriticalAlarmView.swift  # Full-screen critical alarm
            ├── ConnectionLineView.swift
            ├── StatsHeaderView.swift
            ├── ThreatIndicatorView.swift
            └── AlertBannerView.swift
```

## Key Commands
```bash
# Open project
open "/Volumes/DEV/Code/dev/Games/ProjectPlague/ProjectPlague/Project Plague/Project Plague.xcodeproj"

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
   - **Sink** processes data → credits (with prestige multipliers)
6. **Progression phase** - Update threat level, check milestones/lore
7. **UI updates** with new stats

## Important Patterns
- `@MainActor` on GameEngine for thread safety
- `@Published` properties for SwiftUI reactivity
- `Codable` structs for persistence
- Protocol-oriented design for nodes (`NodeProtocol`, `LinkProtocol`)

## Save System
- Key: `ProjectPlague.GameState.v5`
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

## Common Issues
- Swift 6 concurrency: Use `@MainActor`, `@unchecked Sendable`, or `Task { @MainActor in }`
- Adding new files: Must manually add to Xcode project (right-click → Add Files)
- Save migration: Increment save key version when changing GameState structure

## Key Systems

### Prestige System ("Network Wipe")
- Requires minimum credits (100K × 5^level)
- Awards Helix Cores for permanent bonuses
- Production multiplier: 1.0 + (prestigeLevel × 0.1) + (totalCores × 0.05)
- Credit multiplier: 1.0 + (prestigeLevel × 0.15)

### Unit Tiers
| Tier | Name | Unlock Requirement |
|------|------|-------------------|
| 1 | Basic | Free (starting) |
| 2 | Advanced | SIGNAL threat + credits |
| 3 | Elite | PRIORITY threat + credits |
| 4 | Helix | Story unlock + 500K credits |

### Defense System
- FirewallNode absorbs attack damage before credits
- Damage reduction scales with level (20% base + 5%/level, max 60%)
- Health regenerates 2%/tick × level
- Can be repaired for credits

### Security Applications (DefenseStack)
6 categories with progression chains:
| Category | Chain |
|----------|-------|
| Firewall | FW -> NGFW -> AI/ML |
| SIEM | Syslog -> SIEM -> SOAR -> AI Analytics |
| Endpoint | EDR -> XDR -> MXDR -> AI Protection |
| IDS | IDS -> IPS -> ML/IPS -> AI Detection |
| Network | Router -> ISR -> Cloud ISR -> Encrypted |
| Encryption | AES-256 -> E2E -> Quantum Safe |

Each deployed app adds:
- Defense Points (tier × level × 10)
- Damage Reduction (stacks with firewall, cap 60%)
- Detection Bonus (SIEM/IDS categories)
- Automation Level (SOAR/AI tiers)

### Malus Intelligence
- Collect footprint data from survived attacks
- Identify attack patterns
- Send reports to team (costs 250 data, earns story progress)
- Goal: Learn Malus behavior, report to team

### Critical Alarm
- Full-screen overlay when risk = HUNTED or MARKED
- Must acknowledge or boost defenses
- Includes glitch/pulse effects

## Characters

The game features 5 main characters with art assets in `AppPhoto/`:

| Character | Role | Image File |
|-----------|------|------------|
| **Malus** | Antagonist AI - adaptive threat hunting the player | `Malus.png` |
| **Helix** | Benevolent AI - mythical consciousness, player's goal | `Helix_Portrait.png` |
| **Rusty** | Team Lead - player's handler, human coordinator | `Rusty.jpg` |
| **Tish** | Hacker/Intel - technical analyst, decodes Helix | `TishRaw.webp` |
| **Fl3x** | Field Operative - tactical support, ground intel | `FL3X_3000x3000.jpg` |

See `DESIGN.md` for detailed character profiles and visual descriptions.
