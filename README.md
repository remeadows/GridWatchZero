# Grid Watch Zero

**Cyberpunk idle/strategy game for iOS** — Operate a grey-hat data brokerage network, balance a data pipeline, and defend against the AI antagonist Malus while uncovering the Helix mystery.

[![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6-orange)](https://swift.org/)
[![TestFlight](https://img.shields.io/badge/TestFlight-Available-green)](https://testflight.apple.com/)

---

## Overview

Grid Watch Zero is a cyberpunk-themed idle game where you manage a data harvesting network. Balance resource generation, bandwidth throughput, and credit processing while defending against increasingly sophisticated AI threats.

**Developer**: War Signal (REMeadows)
**Version**: 1.0.0
**Status**: TestFlight Internal Testing

---

## Key Features

- **20-Level Campaign** spanning 5 story arcs with unlockable characters
- **25 Unit Tiers** from basic cybersecurity to cosmic-scale technology
- **Defense Stack System** with 6 security categories and progression chains
- **Malus Intelligence** tracking system for hunting the AI antagonist
- **Character Dossiers** with detailed BIOs for 11+ characters
- **Prestige System** ("Network Wipe") with Helix Cores
- **Insane Mode** variants for each level with bonus rewards
- **iCloud Sync** for cross-device progress

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| **Platform** | iOS 17+ (iPhone/iPad) |
| **Language** | Swift 6 (strict concurrency) |
| **UI Framework** | SwiftUI |
| **Architecture** | MVVM |
| **Persistence** | UserDefaults + iCloud Key-Value Store |
| **Audio** | AVFoundation (AVAudioPlayer) |

---

## Gameplay Loop

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   SOURCE    │ ───▶ │    LINK     │ ───▶ │    SINK     │
│  (Generate) │      │ (Transfer)  │      │  (Process)  │
└─────────────┘      └─────────────┘      └─────────────┘
       │                    │                    │
       └────────────────────┴────────────────────┘
                           │
                    ┌──────▼──────┐
                    │   CREDITS   │
                    └─────────────┘
```

1. **Sources** generate data packets each tick
2. **Links** transfer data (bandwidth-limited, packet loss on overflow)
3. **Sinks** process data into credits (with conversion multipliers)
4. **Threats** escalate as your network grows
5. **Defenses** protect against Malus attacks
6. **Upgrades** unlock new tiers and capabilities

---

## Project Structure

```
GridWatchZero/
├── GridWatchZero.xcodeproj/
└── GridWatchZero/
    ├── Engine/
    │   ├── GameEngine.swift        # Core tick loop
    │   ├── AudioManager.swift      # Sound/haptic management
    │   ├── CloudSaveManager.swift  # iCloud sync
    │   └── NavigationCoordinator.swift
    ├── Models/
    │   ├── Resource.swift          # PlayerResources, DataPacket
    │   ├── Node.swift              # Source, Link, Sink nodes
    │   ├── ThreatSystem.swift      # Attacks, threat levels
    │   ├── DefenseApplication.swift # Security apps
    │   ├── LevelDatabase.swift     # Campaign levels
    │   └── StorySystem.swift       # Narrative content
    └── Views/
        ├── DashboardView.swift     # Main game screen
        ├── HomeView.swift          # Campaign hub
        └── Components/             # Reusable UI components
```

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/remeadows/GridWatchZero.git

# Open in Xcode
open GridWatchZero/GridWatchZero.xcodeproj

# Build: Cmd+B
# Run: Cmd+R
```

---

## Documentation

| Document | Purpose |
|----------|---------|
| [GO.md](./GO.md) | Required read order, session rules |
| [CLAUDE.md](./CLAUDE.md) | Architecture, systems, commands |
| [CONTEXT.md](./CONTEXT.md) | Narrative and design philosophy |
| [PROJECT_STATUS.md](./PROJECT_STATUS.md) | Current progress and tasks |
| [ISSUES.md](./ISSUES.md) | Bug tracking, enhancements |
| [DESIGN.md](./DESIGN.md) | Full game design document |
| [SKILLS.md](./SKILLS.md) | Agent/contributor skill requirements |

---

## Campaign Levels

| Arc | Levels | Theme |
|-----|--------|-------|
| **The Awakening** | 1-7 | Tutorial → Helix awakens |
| **The Helix Alliance** | 8-10 | Working WITH Helix, hunting Malus |
| **The Origin Conspiracy** | 11-13 | Other AIs exist (VEXIS, KRON, AXIOM) |
| **The Transcendence** | 14-16 | Helix evolves, dimensional threats |
| **The Singularity** | 17-20 | Cosmic scale, ultimate endgame |

---

## Characters

### GridWatch Team
- **Ronin** — Team Lead, strategic commander
- **Rusty** — Senior Engineer, player mentor
- **Tish** — Intelligence Analyst, cryptographer
- **FL3X** — Field Operative, Prometheus survivor
- **Tee** — Communications Specialist

### AI Characters
- **Helix** — Benevolent AI consciousness
- **Malus** — Primary antagonist, adaptive threat

### Project Prometheus AIs
- **VEXIS** — Infiltrator AI
- **KRON** — Temporal AI
- **AXIOM** — Logic engine
- **ZERO** — Helix's dark mirror
- **The Architect** — First consciousness

---

## Screenshots

<p align="center">
  <img src="AppStoreAssets/Screenshots/iPhone_6.5/01_iPhone.png" width="200" />
  <img src="AppStoreAssets/Screenshots/iPhone_6.5/02_iPhone.png" width="200" />
  <img src="AppStoreAssets/Screenshots/iPhone_6.5/03_iPhone.png" width="200" />
</p>

---

## App Store & TestFlight

- **App Name**: Grid Watch Zero
- **Bundle ID**: WarSignal.GridWatchZero
- **Category**: Games > Strategy
- **Price**: Free
- **Privacy Policy**: [View](https://remeadows.github.io/GridWatchZero/privacy-policy.html)
- **Support**: [View](https://remeadows.github.io/GridWatchZero/support.html)

---

## Save Data

- **Key**: `GridWatchZero.GameState.v6`
- **Reset**: Delete app or call `engine.resetGame()`
- **iCloud**: Synced via NSUbiquitousKeyValueStore

---

## Contributing

This is a personal project, but feedback is welcome:
- Open issues for bugs or suggestions
- TestFlight feedback through the app

---

## License

© 2026 War Signal / REMeadows. All rights reserved.

---

*Built with SwiftUI and a passion for cyberpunk aesthetics.*
