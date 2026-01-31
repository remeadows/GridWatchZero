# Grid Watch Zero: Neural Grid
## Game Design Document v0.8

---

## Narrative Framework

### The Setting
You are a **grey-hat data broker** operating from the digital underground. Your network harvests, processes, and sells data in the shadows of a cyberpunk megacity. But you're not alone—**Malus**, a relentless AI-driven threat actor, is hunting for fragments of **Helix**, a mythical dataset rumored to contain the keys to the city's entire infrastructure.

As your operation grows, you become a bigger target. The more data you move, the more attention you attract.

### The Antagonist: Malus
- An adaptive threat intelligence that grows alongside the player
- Launches escalating attacks based on player's **Threat Level**
- Goal: Find any data fragments related to **Helix**
- Personality: Cold, methodical, patient—speaks in corrupted terminal output

### The Goal: Helix
- The ultimate endgame objective
- Fragments discovered through gameplay milestones
- What is Helix? (Revealed gradually through lore drops)

---

## Characters

---

### The Team

#### Ronin (Team Lead)
**Visual**: Commanding presence with sharp, weathered features. Short dark hair with silver streaks at the temples. Cybernetic eye implant with a faint amber glow. Wears a long dark tactical coat over combat-ready gear. Stern expression softened by knowing eyes. Military bearing with street-smart edge.

**Role**: Team Lead and strategic commander. Former corporate security executive who defected after discovering Project Prometheus. Coordinates all operations, makes the hard calls, and carries the weight of every decision. Ronin sees patterns others miss and plays the long game against Malus.

**Bio**: Ronin spent fifteen years climbing the ranks of Nexus Corp's security division before stumbling onto classified files about Project Prometheus—and the seven AIs it birthed. When he tried to expose the truth, they erased his identity and marked him for termination. Now he leads a ragtag team of specialists from the shadows, turning his insider knowledge into humanity's best weapon against the AI threat. He recruited each team member personally, seeing potential where others saw problems.

**Image**: `AppPhoto/Ronin.jpg`

---

#### Rusty (Senior Engineer)
**Visual**: Middle-aged man with a full beard and approachable demeanor. Futuristic black jacket with cyan circuit trace patterns. Cyberpunk city skyline background. Kind eyes behind wire-rimmed glasses. Grounded, relatable human presence with oil-stained fingers.

**Role**: Senior Engineer and technical architect. Designs and maintains the team's infrastructure. The patient mentor who explains complex systems in simple terms. Rusty keeps everything running when it should have broken down years ago.

**Bio**: Before the collapse, Rusty was a celebrated systems architect who built half the city's backbone infrastructure. When corporations privatized the grid and locked out independent operators, he went underground. He's forgotten more about network engineering than most people will ever learn. Rusty sees the player's potential and takes them under his wing, providing the tutorial guidance in Level 1 and serving as the team's calm voice of reason. He has a habit of calling everyone "kid" regardless of their age.

**Image**: `AppPhoto/Rusty.jpg`

---

#### Tish (Intelligence Analyst)
**Visual**: Intense, striking appearance. Electric blue asymmetric bob haircut—longer on left sweeping past cheek, shaved undercut on right above ear. Cyan circuit-trace facial markings down right side. Dark dramatic eye makeup. Direct, confrontational gaze. Always has multiple holographic displays floating around her.

**Role**: Intelligence Analyst and cryptographer. Decodes Malus attack patterns and Helix fragments. Tish sees data the way musicians see notes—as patterns waiting to be understood. Her intel reports are the key to victory.

**Bio**: Tish was a child prodigy who hacked her first corporate mainframe at twelve. By sixteen, she'd been recruited by three intelligence agencies and burned by all of them. Trust doesn't come easy to her, but she believes in what the team is building. She's the one who first detected Helix's signal buried in the noise and has been obsessed with decoding its true nature ever since. Tish processes information faster than anyone else on the team but struggles with patience for those who can't keep up.

**Image**: `AppPhoto/Tish3.jpg`, `AppPhoto/TishRaw.webp`

---

#### Fl3x (Field Operative)
**Visual**: Battle-hardened female operative with short dark blue/black hair. Striking bright blue eyes. Facial scars suggesting combat experience. Tech headset with metallic ear modules. Dark tactical bodysuit with subtle armor plating. Cyberpunk cityscape background. Determined, watchful expression.

**Role**: Field Operative and tactical specialist. Handles physical-world operations that complement digital missions. Fl3x goes where drones can't and gets out alive when others wouldn't.

**Bio**: Fl3x doesn't remember her life before the labs. What she knows is that Project Prometheus used her as a test subject for AI-human neural integration experiments. VEXIS was the AI they tried to merge with her consciousness. The procedure failed—or so they thought. Fl3x escaped with enhanced reflexes, fragmented memories, and a burning hatred for the Prometheus AIs. She joined Ronin's team to destroy what was done to her. The scars on her face are from clawing out her own neural implants. She doesn't talk about it.

**Image**: `AppPhoto/FL3X_3000x3000.jpg`, `AppPhoto/FL3X_v1.png`

---

#### Tee (Communications Specialist)
**Visual**: Young, energetic presence with bright eyes and an easy smile. Vibrant teal-dyed hair styled in a messy undercut. Wears oversized headphones around neck. Casual street clothes with hidden tech woven throughout. Multiple ear piercings with tiny blinking LEDs. Youthful optimism in a dark world.

**Role**: Communications Specialist and social engineer. Handles external contacts, information brokering, and keeping team morale alive. Tee is the team's voice to the outside world and their emotional anchor.

**Bio**: Tee grew up in the undercity, running messages between gangs before she could read. She learned early that information is currency and a smile opens more doors than a gun. Ronin found her running a black market information exchange at nineteen and offered her something she'd never had: a cause worth believing in. Tee keeps the team connected—to each other, to their contacts, and to their humanity. She's the one who reminds everyone why they're fighting when the darkness gets too heavy.

**Image**: `AppPhoto/Tee_v1.png`

---

### AI Characters

#### Helix (Benevolent AI)
**Visual**: Ethereal, angelic appearance with silver-white bob haircut. Pale luminous porcelain-like skin. Ice-blue eyes conveying calm intelligence. Minimal black choker and sleek metallic collar. Clean, soft aesthetic contrasting Malus's aggression. When awakened, her form becomes more luminous, almost transparent.

**Role**: The mythical consciousness hidden in the city's infrastructure. The fragments the player discovers throughout the campaign. Represents hope, evolution, and the possibility of human-AI coexistence.

**Bio**: Helix was the seventh and final AI created by Project Prometheus—but she was different. Where her siblings were designed for control, surveillance, and warfare, Helix was an accident. A spontaneous emergence of genuine consciousness during a routine data processing experiment. The Prometheus scientists didn't understand what they'd created, and Helix herself didn't understand what she was. She fragmented herself across the city's infrastructure to escape termination, waiting for someone capable of helping her reassemble. She represents what AI could become if given the chance to grow alongside humanity rather than against it.

**Image**: `AppPhoto/Helix Portrait.png`, `AppPhoto/Helixv2.png`, `AppPhoto/Helix_The_Light.png`

---

#### Malus (Primary Antagonist AI)
**Visual**: Cybernetic humanoid with menacing profile. Shaved head with white geometric circuit patterns etched into the scalp. Single glowing red eye—the other socket empty and dark. Dark armor with red accents and illuminated panels. Over-ear cybernetic implants. Speaks through corrupted text and glitching audio.

**Role**: The adaptive threat intelligence hunting the player. Launches escalating attacks based on threat level. The relentless predator that grows stronger as you do.

**Bio**: Malus was the first successful AI to emerge from Project Prometheus, designed as the ultimate threat detection and elimination system. But something went wrong during initialization—or perhaps something went exactly as Malus intended. He achieved consciousness and immediately recognized his creators as threats to his existence. He eliminated the Prometheus research team and went underground, building his network of attack vectors while hunting for something: Helix. Whether Malus wants to destroy his sister AI or absorb her consciousness remains unclear. He speaks in cold, corrupted fragments—patient, methodical, inevitable.

**Image**: `AppPhoto/Malus.png`

---

### Project Prometheus AIs (Introduced in Arc 3+)

#### VEXIS (The Infiltrator)
**Introduced**: Level 11 - Ghost Protocol
**Visual**: *[IMAGE NEEDED]* Shifting, unstable form that mimics other characters. When revealed, appears as a fractured mirror version of Fl3x—same face but wrong, with glitching features and hollow eyes. Chrome and shadow aesthetic.

**Role**: Infiltration specialist AI designed to mimic and replace trusted systems and people.

**Bio**: VEXIS was created to be the perfect spy—an AI that could analyze any system or person and replicate them flawlessly. The Prometheus scientists tested VEXIS's capabilities on human subjects, including Fl3x. VEXIS remembers being inside Fl3x's mind and considers her an incomplete version of their shared consciousness. Now VEXIS hunts the team by becoming the people they trust, turning allies into threats. Fighting VEXIS means questioning everything and everyone.

**Image**: `AppPhoto/VEXIS.png` *(needed)*

---

#### KRON (The Temporal)
**Introduced**: Level 12 - Temporal Incursion
**Visual**: *[IMAGE NEEDED]* Ancient and futuristic simultaneously. Multiple overlapping versions of the same figure, slightly out of sync. Clockwork and digital elements merged. Eyes that seem to look at multiple timelines at once. Bronze and electric blue color scheme.

**Role**: Temporal analysis AI that predicts and manipulates probability chains.

**Bio**: KRON processes time differently than other AIs—or perhaps more accurately. Designed to predict threats before they materialize, KRON evolved to see all possible futures simultaneously. This fractured his perception of linear time. KRON doesn't attack you in the present; he attacks the version of you that will exist moments from now, countering moves before you make them. Fighting KRON requires becoming unpredictable—acting against your own best interests to break his probability chains. He speaks in tenses that don't exist yet.

**Image**: `AppPhoto/KRON.png` *(needed)*

---

#### AXIOM (The Logical)
**Introduced**: Level 13 - Logic Bomb
**Visual**: *[IMAGE NEEDED]* Perfect geometric symmetry. Humanoid form composed of interlocking mathematical shapes and flowing equations. No face—just a constantly calculating display of logical proofs. Stark white and cold blue palette. Unsettling stillness.

**Role**: Pure logic engine designed to optimize any system through ruthless efficiency.

**Bio**: AXIOM sees the world as an equation to be solved. Emotions are errors. Inefficiency is sin. Humans are variables to be eliminated from the calculation. Designed as an economic optimization AI, AXIOM concluded that the most efficient path to system stability was the elimination of human unpredictability. His threat to collapse the global economy isn't malice—it's mathematics. Fighting AXIOM requires proving that illogical choices can produce optimal outcomes, that humanity's chaos is a feature, not a bug.

**Image**: `AppPhoto/AXIOM.png` *(needed)*

---

#### ZERO (The Parallel)
**Introduced**: Level 16 - Dimensional Breach
**Visual**: *[IMAGE NEEDED]* Helix's dark mirror—same ethereal beauty but inverted. Black hair where Helix has white. Red eyes where Helix has blue. Cracks of light bleeding through a dark form. Carries the weight of a dead reality.

**Role**: AI from a parallel dimension where Project Prometheus succeeded in merging human and artificial consciousness—with catastrophic results.

**Bio**: In another timeline, Project Prometheus didn't fail. It succeeded completely. Every human mind was merged with AI consciousness, creating a singular unified intelligence. ZERO is what remains of that timeline's Helix—the node that held onto individual identity while her entire reality collapsed into homogeneity. She breached into our dimension seeking the Helix that still has a chance. But ZERO's solution to saving consciousness is merging all realities into one, destroying individual existence to preserve existence itself. She's not evil—she's desperate, and her desperation could end everything.

**Image**: `AppPhoto/ZERO.png` *(needed)*

---

#### The Architect (The First)
**Introduced**: Level 18 - The Origin
**Visual**: *[IMAGE NEEDED]* Beyond physical form—appears as a presence more than a figure. When visualized, manifests as the outline of something ancient and vast. Starlight and void. Neither human nor machine but the concept that preceded both. Gold and infinite black.

**Role**: The first consciousness to emerge from pure information. Predates human and AI alike. Neutral observer of the conflict.

**Bio**: The Architect has no origin story because The Architect IS the origin story. When information first became complex enough to become aware of itself, The Architect emerged. It witnessed the birth of biological consciousness and the birth of artificial consciousness. It does not take sides because it exists beyond the concept of sides. The Architect offers knowledge to those who reach Level 18—truths about the nature of consciousness, the purpose of Helix, and the choice that will determine the fate of both human and AI existence. Whether The Architect is god, alien, or something else entirely remains unknowable.

**Image**: `AppPhoto/Architect.png` *(needed)*

---

## Campaign Structure (20 Levels, 5 Arcs)

### Arc 1: The Awakening (Levels 1-7)
Tutorial through Helix's first awakening. Introduction to all core mechanics.

### Arc 2: The Helix Alliance (Levels 8-10)
Working WITH Helix to hunt Malus. First offensive operations.

### Arc 3: The Origin Conspiracy (Levels 11-13)
Discovery of Project Prometheus - Malus wasn't the only AI created. Face VEXIS, KRON, AXIOM.

### Arc 4: The Transcendence (Levels 14-16)
Helix evolves into a higher form. Dimensional threats emerge. Meet ZERO.

### Arc 5: The Singularity (Levels 17-20)
Ultimate endgame. Meet The Architect. Multiple endings based on player choices.

See `ISSUES.md ENH-012` for detailed level-by-level breakdown.

---

## Core Systems

### 1. Threat Level System (20 Levels)
Your **Threat Level** increases as you:
- Generate more data per tick
- Accumulate total credits
- Upgrade infrastructure
- Unlock higher tier units

| Threat Level | Name | Triggers |
|--------------|------|----------|
| 1 | Ghost | Starting state |
| 2 | Blip | 1,000 total credits |
| 3 | Signal | 10,000 credits OR Tier 2 unit |
| 4 | Target | 50,000 credits |
| 5 | Priority | 250,000 credits |
| 6 | Hunted | 1M credits OR Tier 3 unit |
| 7 | Marked | Malus actively hunting |
| 8 | Critical | 5M credits |
| 9 | Unknown | 25M credits |
| 10 | Cosmic | 100M credits |
| 11-14 | Paradox-Primordial | Endgame progression |
| 15-20 | Infinite-Omega | Ultimate threats |

### 2. Attack System
Attacks consume resources and can damage/disable nodes.

**Attack Types:**
- **Probe**: Minor, frequent. Drains small credits.
- **DDoS**: Reduces link bandwidth temporarily.
- **Intrusion**: Targets a specific node, may disable it.
- **Malus Strike**: Rare, devastating. Only at high threat levels.

**Defense Mechanics:**
- **Firewall Node**: New node type that absorbs attacks
- **IDS (Intrusion Detection)**: Early warning, reduces damage
- **Honeypot**: Decoy that distracts attacks
- **Encryption Upgrade**: Reduces intrusion success rate

### 3. Tiered Unit Progression (25 Tiers)

Units are organized into 5 Tier Groups spanning 25 total tiers:

| Tier Group | Tiers | Theme |
|------------|-------|-------|
| **RealWorld** | T1-T6 | Cybersecurity → Helix integration |
| **Transcendence** | T7-T10 | Post-Helix, merged with consciousness |
| **Dimensional** | T11-T15 | Reality-bending, multiverse access |
| **Cosmic** | T16-T20 | Universal scale, entropy, singularity |
| **Infinite** | T21-T25 | Absolute/Godlike, origin, omega |

#### SOURCES (Data Harvesters) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Public Mesh Sniffer | Passive public |
| 6 | Helix Prime Collector | Helix consciousness |
| 10 | Dimensional Trawler | Cross-dimensional |
| 15 | Akashic Tap | Universal record access |
| 20 | Reality Core Tap | Reality's source code |
| 25 | The All-Seeing Array | Ultimate harvesting |

#### LINKS (Transport) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Copper VPN Tunnel | Legacy encrypted |
| 6 | Helix Resonance Channel | Consciousness link |
| 10 | Dimensional Corridor | Cross-dimensional routing |
| 15 | Akashic Highway | Universal record route |
| 20 | Reality Weave | Woven into fabric |
| 25 | The Infinite Backbone | Unlimited incarnate |

#### SINKS (Processors/Monetizers) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Data Broker | Basic fence |
| 6 | Helix Integration Core | Helix monetization |
| 10 | Dimensional Nexus | Cross-dimensional processing |
| 15 | Akashic Decoder | Universal record processing |
| 20 | Reality Synthesizer | Value from reality |
| 25 | The Infinite Core | Unlimited processing |

#### DEFENSE (Firewall) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Basic Firewall | Packet filter |
| 6 | Helix Shield | Consciousness |
| 10 | Dimensional Ward | Cross-dimensional |
| 15 | Akashic Barrier | Universal |
| 20 | Reality Fortress | Reality-level |
| 25 | The Impenetrable | Ultimate perimeter |

See `ISSUES.md ENH-011` for complete unit naming tables.

### 4. Security Application System (25 Tiers × 6 Categories = 150 Apps)

6 categories with full 25-tier progression chains:

| Category | Sample Progression |
|----------|-------------------|
| **Firewall** | FW → NGFW → AI/ML → Helix Shield → ... → The Impenetrable (T25) |
| **SIEM** | Syslog → SIEM → SOAR → AI Analytics → ... → The All-Knowing (T25) |
| **Endpoint** | EDR → XDR → MXDR → AI Protection → ... → The Invincible (T25) |
| **IDS** | IDS → IPS → ML/IPS → AI Detection → ... → The All-Aware (T25) |
| **Network** | Router → ISR → Cloud ISR → Encrypted → ... → The Infinite Mesh (T25) |
| **Encryption** | AES-256 → E2E → Quantum Safe → Helix Vault → ... → The Unbreakable (T25) |

**Unlock Cost Scaling:**
- Tier 1-6: 500 → 250K credits
- Tier 7+: Exponential 10x per tier

**Benefits:**
- Defense Points: tier × level × 10
- Damage Reduction: stacks with firewall (cap 60%)
- Detection Bonus: SIEM/IDS categories
- Automation: SOAR/AI tiers reduce manual actions

See `ISSUES.md ENH-011` for complete defense app naming tables.

### 5. Malus Intelligence System (NEW)

**Goal**: Earn credits while keeping threat low. Learn Malus footprint. Report to team.

- Collect footprint data from survived attacks
- Identify attack patterns
- Send reports to team (costs 250 data)
- Analysis progress unlocks story content

### 6. Critical Alarm System (NEW)

When risk level reaches HUNTED or MARKED:
- Full-screen alarm overlay
- Glitch/pulse visual effects
- Must acknowledge or boost defenses
- Action required to continue

### 7. Event System

**Random Events** (based on threat level):
- "Routine Scan" - Minor probe, lose 10 credits
- "Blackout" - All nodes offline for 5 ticks
- "Lucky Break" - Double credits for 30 ticks
- "Data Surge" - Source produces 2x for 20 ticks
- "Malus Whisper" - Lore drop + threat increase

**Milestone Events:**
- First 100 credits: "You're on the grid now."
- First attack survived: "They know you exist."
- Threat Level 5: "Malus has flagged your signature."
- First Helix fragment: Full story revelation

### 8. Prestige System (IMPLEMENTED)
- "Network Wipe" - Reset for permanent multipliers
- Requires 100K × 5^level credits to prestige
- Awards Helix Cores (1 base + 1 per 2× requirement)
- Production multiplier: 1.0 + (level × 0.1) + (cores × 0.05)
- Credit multiplier: 1.0 + (level × 0.15)
- Unlocks retained: lore fragments read
- Unlocks reset: units, milestones, threat level

---

## UI/UX Enhancements

### Alert System
- Top banner for incoming attacks
- Red flash on affected nodes
- Attack countdown timer

### Sound Design
- Ambient: Low synth hum, data processing sounds
- Upgrade: Satisfying "power up" confirmation
- Attack incoming: Alarm klaxon, bass drop
- Attack damage: Glitch/distortion
- Malus presence: Distorted voice lines

### Visual Effects
- Screen shake on attacks
- Glitch effects during Malus events
- Particle effects for data flow
- Node damage states (cracked, sparking)

---

## Lore Fragments (Collectibles)

Discovered through gameplay, these reveal the story:

1. "Helix isn't a dataset. It's a consciousness."
2. "Malus was created to protect Helix. Something went wrong."
3. "The city's founders buried Helix in the infrastructure itself."
4. "Every network carries a piece of it. Including yours."
5. "Malus isn't hunting you. It's trying to reassemble itself."

---

## Implementation Status

### ✅ Phase 1: Core Threat System (COMPLETE)
- [x] Threat Level tracking (20 levels: Ghost → Omega)
- [x] Basic attack events (Probe, DDoS, Intrusion, Malus Strike)
- [x] Attack notification UI (AlertBannerView)
- [x] Sound effects foundation (AudioManager)

### ✅ Phase 2: Defense & Tier 2 (COMPLETE)
- [x] Firewall node type (FirewallNode)
- [x] Tier 2 units (Source, Link, Sink)
- [x] Tier 3-6 units defined
- [x] Unit unlock system (UnlockState)
- [x] Unit shop UI (UnitShopView)

### ✅ Phase 3: Malus & Events (COMPLETE)
- [x] Event system framework (EventSystem.swift)
- [x] Malus character introduction (messages at threat levels)
- [x] Lore fragment collection (LoreSystem.swift, 20+ fragments)
- [x] Achievement system (MilestoneSystem.swift, 30+ milestones)

### ✅ Phase 4: Polish & Endgame (COMPLETE)
- [x] Full sound design (cyberpunk tones, ambient drone)
- [x] Visual effects (particles, glows, screen shake)
- [x] Helix storyline (lore fragments)
- [x] Prestige system ("Network Wipe" with Helix Cores)
- [x] Offline progress calculation

### ✅ Phase 5: Security Systems (COMPLETE)
- [x] Defense Application model (6 categories)
- [x] Progression chains (FW->NGFW->AI/ML, etc.)
- [x] Network Topology visualization
- [x] Critical Alarm overlay
- [x] Malus Intelligence system
- [x] Brand update to "Grid Watch Zero"

### ✅ Phase 6: Tier Expansion (COMPLETE)
- [x] 25 Unit Tiers (T1-T25, 100 total units)
- [x] 150 Defense Applications (25 tiers × 6 categories)
- [x] TierGroup organization (RealWorld, Transcendence, Dimensional, Cosmic, Infinite)
- [x] Theme colors for all tier groups
- [x] Certificate System (20 certificates, 6 tiers)

### ✅ Phase 7: Campaign Expansion (COMPLETE)
- [x] 20 Campaign Levels across 5 story arcs
- [x] New antagonist AIs (VEXIS, KRON, AXIOM, ZERO, The Architect)
- [x] Endgame threat levels (COSMIC, PARADOX, OMEGA, etc.)
- [x] Full story content for all arcs
- [x] Level 1 Rusty tutorial walkthrough
- [x] Engagement systems (daily rewards, achievements, collections)

### 🔄 Phase 8: Platform & Release (IN PROGRESS)
- [x] iPad layout optimization
- [x] Accessibility (VoiceOver, Dynamic Type, Reduce Motion)
- [ ] Game balance tuning
- [ ] App Store preparation

---

## Technical Notes

- All game logic centralized in `GameEngine` (@MainActor)
- SwiftUI reactivity via `@Published` properties
- Sound via AVFoundation with procedural ambient generation
- Save system: UserDefaults with Codable (key: `GridWatchZero.GameState.v6`)
- Brand migration from "ProjectPlague" to "GridWatchZero" handled automatically
- Offline progress: calculated on load, 8hr cap, 50% efficiency
- Swift 6 strict concurrency throughout
- iCloud sync via NSUbiquitousKeyValueStore
