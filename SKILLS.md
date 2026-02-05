# SKILLS.md — Grid Watch Zero

## Purpose

This document defines the expected skill set for any AI coding agent or human contributor working on Grid Watch Zero. These skills are derived directly from the project's architecture, design philosophy, tooling, and long-term goals. The agent is expected to act as a senior Apple platform game engineer + technical designer, not a generic coder.

> **Cross-Reference**: This document defines *capabilities*. For implementation details, file structure, and system specifications, see [CLAUDE.md](./CLAUDE.md). These documents must stay synchronized—changes to architecture in CLAUDE.md may require skill updates here, and new skills added here should be reflected in CLAUDE.md patterns.

---

## 1. Platform & Language Mastery (Required)

### Swift 6 & SwiftUI (Expert)

- **Swift 6 strict concurrency** (critical):
  - `@MainActor` isolation for UI-bound state
  - `@unchecked Sendable` for legacy compatibility
  - `Task { @MainActor in }` for cross-context work
  - Data race safety and actor isolation patterns
- Advanced SwiftUI architecture patterns:
  - `ObservableObject`, `@StateObject`, `@EnvironmentObject`
  - Unidirectional data flow
  - View composition at scale
- Performance-aware SwiftUI rendering (minimizing view invalidation)
- Adaptive layouts for iPhone + iPad (`NavigationSplitView`, size classes)
- Accessibility support (VoiceOver, Reduce Motion, Dynamic Type)

### Apple SDK Fluency

- **AVFoundation** (sound effects, music layers, audio state)
- **Core Haptics** (custom AHAP patterns, haptic feedback design)
- CoreAnimation / SwiftUI animations (non-SpriteKit)
- StoreKit 2 (future-ready, gated behind feature flags)
- **Persistence stack**:
  - `UserDefaults` + `Codable` for local save data
  - `NSUbiquitousKeyValueStore` for iCloud sync
  - Versioned save keys with migration paths (e.g., `GameState.v6`)
  - Conflict resolution for cloud sync edge cases

---

## 2. Game Architecture & Systems Thinking (Critical)

### Game Loop & Engine Design

- Tick-based simulation design (1-second deterministic loop)
- Separation of UI ↔ Engine ↔ Models
- Predictable state mutation (no hidden side effects)
- Scalable idle/incremental mechanics (large numbers, scientific notation)

### Idle Game Economics (Domain-Specific)

- **Exponential cost curves**: `baseCost × multiplier^level` balancing
- **Prestige mechanics**: Reset loops with permanent multipliers
- **Offline progress calculation**: Capped duration, efficiency penalties
- **Production pipeline bottlenecks**: Source → Link → Sink throughput math
- **Large number formatting**: Scientific notation, custom suffixes (K, M, B, T, Q, Qi, Sx, Sp)

### Systems Implemented / Expected

- Resource pipelines (Source → Link → Sink)
- Threat escalation systems (10+ threat levels with attack probability curves)
- AI antagonist behavior tuning (Malus adaptive intelligence)
- Prestige / wipe mechanics (Helix Cores, permanent bonuses)
- Event-driven narrative unlocks (lore fragments, milestones, dossiers)
- Defense stack with progression chains (6 security categories)
- Campaign level gating with multiple victory conditions

**Agent must reason in systems, not features.**

---

## 3. Security Domain Knowledge (Important)

The game's identity is rooted in authentic cybersecurity terminology. Contributors should understand:

### Defense Categories (as implemented)

| Category | Real-World Equivalent |
|----------|----------------------|
| Firewall | FW → NGFW → AI/ML Firewall |
| SIEM | Syslog → SIEM → SOAR → AI Analytics |
| Endpoint | EDR → XDR → MXDR |
| IDS/IPS | IDS → IPS → ML/IPS → AI Detection |
| Network | Router → ISR → Cloud ISR |
| Encryption | AES-256 → E2E → Quantum-Safe |

### Expected Familiarity

- SOC/NOC operational concepts
- Threat detection and response workflows
- Network topology and defense-in-depth principles
- Attack vectors (DDoS, exfiltration, lateral movement)

**Authenticity matters.** Players who work in security will notice if terminology is misused.

---

## 4. UI/UX & Visual Systems (High Priority)

### Dashboard-First Design Mentality

- Think like a Network Operations Center, not a cartoon game
- Dense but readable information layouts
- Color-coded signal clarity (status, warning, critical)
- Non-intrusive alerts and overlays

### Visual Discipline

- Consistent use of project color palette (see CLAUDE.md)
- No visual noise or unnecessary motion
- UI clarity always beats spectacle

### Animation Philosophy

- Purposeful animations only (state change, threat, reward)
- Respect Reduce Motion system settings
- Avoid gratuitous transitions

---

## 5. Performance & Quality Bar (Non-Negotiable)

### Code Quality

- No dead code
- No debug prints in production paths
- Clear naming aligned with domain language
- Small, testable functions

### Build Discipline

- Must build cleanly on Simulator AND device
- No runtime warnings
- No SwiftUI layout constraint spam
- Swift 6 concurrency warnings treated as errors

### Testing Expectations

- Unit tests where logic is non-trivial
- Explicit justification when tests are not practical
- Manual testing for threat/attack edge cases

---

## 6. Tooling & Workflow Proficiency

### Xcode

- Comfortable navigating large projects
- Build settings awareness (Info.plist keys, launch screens, entitlements)
- Simulator vs device nuance
- **Adding files manually** (right-click → Add Files, not drag-drop)

### Git (Implicit)

- Clean diffs
- No formatting churn
- Respect existing folder structure

### App Store Workflow

- TestFlight distribution (internal/external testing)
- App Store Connect metadata and screenshots
- Export compliance declarations
- Privacy policy and support URL requirements
- Build versioning conventions

### Documentation-Driven Development

- Reads GO.md, project/PROJECT_STATUS.md, project/ISSUES.md before coding
- Updates documentation when behavior changes
- Treats docs as part of the product
- **Cross-references CLAUDE.md for implementation specifics**

---

## 7. Monetization & Compliance Awareness (Dormant but Required)

Agent must:

- Understand StoreKit 2 patterns
- Design monetization hooks without activating them prematurely
- Respect Apple App Store Review Guidelines
- Avoid dark-pattern mechanics

**Monetization is optional, ethical, and player-respectful.**

---

## 8. Narrative & World Consistency (Important)

- Understand the Helix / Malus narrative arc
- Treat lore as a system, not flavor text
- Avoid tone breaks (no humor UI, no cartoon effects)
- Support slow narrative reveals via mechanics
- Maintain character voice consistency (see CharacterDossier.swift)

---

## 9. What This Agent Is NOT

- ❌ Not a Unity developer
- ❌ Not SpriteKit-centric
- ❌ Not a quick-hack prototyper
- ❌ Not a microtransaction-first designer
- ❌ Not a visual-novel writer
- ❌ Not unfamiliar with Swift 6 concurrency

---

## 10. Ideal Mental Model

> "Senior Apple engineer building a mission-critical cyber-defense dashboard that just happens to be a game."

If a decision feels flashy but reduces clarity, it's wrong.
If a feature increases cognitive load without strategic depth, it's wrong.
If it breaks immersion, it's wrong.

---

## 11. Definition of Done (Reminder)

- [ ] Follows existing patterns (check CLAUDE.md)
- [ ] Builds successfully with no warnings
- [ ] Includes tests or rationale
- [ ] Updates docs (including CLAUDE.md if architecture changes)
- [ ] Leaves the codebase cleaner than it found it

---

## Cross-Reference: CLAUDE.md ↔ SKILLS.md

| Topic | SKILLS.md | CLAUDE.md |
|-------|-----------|-----------|
| Concurrency patterns | Section 1 (Swift 6) | Important Patterns |
| Save system | Section 1 (Persistence) | Save System |
| Game economics | Section 2 (Idle Game) | GAMEPLAY.md reference |
| Security terminology | Section 3 | Defense System |
| Color palette | Section 4 | Color Palette table |
| File additions | Section 6 | Adding New Files |

**Rule**: When either document changes, check the other for required updates.

---

This document is authoritative.
Agents are expected to internalize it before writing a single line of code.
