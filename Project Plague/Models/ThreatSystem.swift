// ThreatSystem.swift
// ProjectPlague
// Threat level tracking and attack mechanics

import Foundation

// MARK: - Threat Level

enum ThreatLevel: Int, Codable, CaseIterable, Comparable {
    case ghost = 1       // Starting - invisible
    case blip = 2        // Minor detection
    case signal = 3      // On the radar
    case target = 4      // Active interest
    case priority = 5    // High value target
    case hunted = 6      // Malus actively searching
    case marked = 7      // Malus locked on
    case targeted = 8    // Coordinated attack incoming
    case hammered = 9    // Sustained assault
    case critical = 10   // City-level threat response

    static func < (lhs: ThreatLevel, rhs: ThreatLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var name: String {
        switch self {
        case .ghost: return "GHOST"
        case .blip: return "BLIP"
        case .signal: return "SIGNAL"
        case .target: return "TARGET"
        case .priority: return "PRIORITY"
        case .hunted: return "HUNTED"
        case .marked: return "MARKED"
        case .targeted: return "TARGETED"
        case .hammered: return "HAMMERED"
        case .critical: return "CRITICAL"
        }
    }

    var description: String {
        switch self {
        case .ghost: return "Invisible to threat actors"
        case .blip: return "Minor anomaly detected"
        case .signal: return "You're on someone's radar"
        case .target: return "Active interest in your operation"
        case .priority: return "High-value target designation"
        case .hunted: return "Malus is searching for you"
        case .marked: return "Malus has locked onto your signature"
        case .targeted: return "Coordinated strike inbound"
        case .hammered: return "Under sustained heavy assault"
        case .critical: return "City-wide threat response activated"
        }
    }

    var color: String {
        switch self {
        case .ghost: return "dimGreen"
        case .blip: return "neonGreen"
        case .signal: return "neonCyan"
        case .target: return "neonAmber"
        case .priority: return "neonAmber"
        case .hunted: return "neonRed"
        case .marked: return "neonRed"
        case .targeted: return "neonRed"
        case .hammered: return "neonRed"
        case .critical: return "neonRed"
        }
    }

    /// Base chance of attack per tick (percentage)
    /// Even at GHOST, there's light probing/port scanning - the network is never truly safe
    var attackChancePerTick: Double {
        switch self {
        case .ghost: return 0.2     // Light probing - ~1 attack every 8+ minutes
        case .blip: return 0.5
        case .signal: return 1.0
        case .target: return 2.0
        case .priority: return 3.5
        case .hunted: return 5.0
        case .marked: return 8.0
        case .targeted: return 12.0
        case .hammered: return 18.0
        case .critical: return 25.0
        }
    }

    /// Multiplier for attack severity
    var severityMultiplier: Double {
        switch self {
        case .ghost: return 0.3     // Very light damage from probing attacks
        case .blip: return 0.5
        case .signal: return 1.0
        case .target: return 1.5
        case .priority: return 2.0
        case .hunted: return 3.0
        case .marked: return 5.0
        case .targeted: return 7.0
        case .hammered: return 10.0
        case .critical: return 15.0
        }
    }

    static func forCredits(_ totalCredits: Double, hasT2: Bool = false, hasT3: Bool = false, hasT4: Bool = false, hasT5: Bool = false, hasT6: Bool = false) -> ThreatLevel {
        // Late-game threat levels for campaign levels 5-7
        if hasT6 || totalCredits >= 50_000_000 { return .critical }
        if hasT5 || totalCredits >= 10_000_000 { return .hammered }
        if totalCredits >= 5_000_000 { return .targeted }
        // Original threat levels
        if hasT4 || hasT3 || totalCredits >= 1_000_000 { return .marked }
        if totalCredits >= 250_000 { return .hunted }
        if totalCredits >= 50_000 { return .priority }
        if hasT2 || totalCredits >= 10_000 { return .target }
        if totalCredits >= 1_000 { return .signal }
        if totalCredits >= 100 { return .blip }
        return .ghost
    }
}

// MARK: - NetDefense Level

/// Defense rating that counters threat level to determine actual risk
enum NetDefenseLevel: Int, Codable, CaseIterable, Comparable {
    case exposed = 0     // No defense
    case minimal = 1     // Basic firewall
    case basic = 2       // Upgraded firewall
    case moderate = 3    // Good defense
    case strong = 4      // Strong defense
    case fortified = 5   // Near-maximum protection
    case hardened = 6    // Military-grade protection
    case quantum = 7     // Quantum-encrypted defense (T5)
    case neural = 8      // Neural mesh protection (T5+)
    case helix = 9       // Helix-integrated defense (T6)

    static func < (lhs: NetDefenseLevel, rhs: NetDefenseLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var name: String {
        switch self {
        case .exposed: return "EXPOSED"
        case .minimal: return "MINIMAL"
        case .basic: return "BASIC"
        case .moderate: return "MODERATE"
        case .strong: return "STRONG"
        case .fortified: return "FORTIFIED"
        case .hardened: return "HARDENED"
        case .quantum: return "QUANTUM"
        case .neural: return "NEURAL"
        case .helix: return "HELIX"
        }
    }

    var description: String {
        switch self {
        case .exposed: return "No active defenses"
        case .minimal: return "Basic firewall protection"
        case .basic: return "Standard security measures"
        case .moderate: return "Improved defensive posture"
        case .strong: return "Robust security infrastructure"
        case .fortified: return "Advanced threat mitigation"
        case .hardened: return "Military-grade protection"
        case .quantum: return "Quantum-encrypted security mesh"
        case .neural: return "Adaptive neural defense network"
        case .helix: return "Helix consciousness protection"
        }
    }

    /// How many threat levels this defense can reduce
    var threatReduction: Int {
        return rawValue
    }

    /// Calculate defense level based on firewall stats
    static func calculate(
        firewallTier: Int,
        firewallLevel: Int,
        firewallHealthPercent: Double
    ) -> NetDefenseLevel {
        // No firewall = exposed
        guard firewallTier > 0 else { return .exposed }

        // Base score from firewall tier (1-6 tiers available)
        var score = firewallTier

        // Bonus from firewall level (every 5 levels = +1)
        score += firewallLevel / 5

        // Penalty if firewall is damaged (below 50% = -1, below 25% = -2)
        if firewallHealthPercent < 0.25 {
            score -= 2
        } else if firewallHealthPercent < 0.5 {
            score -= 1
        }

        // Clamp to valid range (0-9)
        let clampedScore = max(0, min(9, score))
        return NetDefenseLevel(rawValue: clampedScore) ?? .exposed
    }
}

// MARK: - Risk Level (Effective Threat)

/// Actual risk = Threat - NetDefense (clamped to minimum GHOST)
struct RiskCalculation {
    let threatLevel: ThreatLevel
    let netDefenseLevel: NetDefenseLevel
    let effectiveRiskLevel: ThreatLevel

    /// Attack chance uses effective risk, not raw threat
    var attackChancePerTick: Double {
        effectiveRiskLevel.attackChancePerTick
    }

    /// Severity uses effective risk
    var severityMultiplier: Double {
        effectiveRiskLevel.severityMultiplier
    }

    init(threat: ThreatLevel, defense: NetDefenseLevel) {
        self.threatLevel = threat
        self.netDefenseLevel = defense

        // Calculate effective risk: threat level - defense reduction
        let effectiveRawValue = max(1, threat.rawValue - defense.threatReduction)
        self.effectiveRiskLevel = ThreatLevel(rawValue: effectiveRawValue) ?? .ghost
    }
}

// MARK: - Attack Types

enum AttackType: String, Codable, CaseIterable {
    case probe = "PROBE"
    case ddos = "DDoS"
    case intrusion = "INTRUSION"
    case malusStrike = "MALUS_STRIKE"
    case coordinatedAssault = "COORDINATED_ASSAULT"
    case neuralHijack = "NEURAL_HIJACK"
    case quantumBreach = "QUANTUM_BREACH"

    var displayName: String {
        switch self {
        case .probe: return "Network Probe"
        case .ddos: return "DDoS Attack"
        case .intrusion: return "Intrusion Attempt"
        case .malusStrike: return "MALUS STRIKE"
        case .coordinatedAssault: return "COORDINATED ASSAULT"
        case .neuralHijack: return "NEURAL HIJACK"
        case .quantumBreach: return "QUANTUM BREACH"
        }
    }

    var description: String {
        switch self {
        case .probe: return "Scanning your network..."
        case .ddos: return "Flooding your bandwidth..."
        case .intrusion: return "Attempting system access..."
        case .malusStrike: return ">> MALUS HAS FOUND YOU <<"
        case .coordinatedAssault: return ">> MULTIPLE ATTACK VECTORS <<"
        case .neuralHijack: return ">> AI OVERRIDE DETECTED <<"
        case .quantumBreach: return ">> QUANTUM DECRYPTION IN PROGRESS <<"
        }
    }

    var icon: String {
        switch self {
        case .probe: return "eye.fill"
        case .ddos: return "bolt.fill"
        case .intrusion: return "lock.open.fill"
        case .malusStrike: return "exclamationmark.triangle.fill"
        case .coordinatedAssault: return "arrow.triangle.merge"
        case .neuralHijack: return "brain.head.profile"
        case .quantumBreach: return "atom"
        }
    }

    /// Duration in ticks
    var baseDuration: Int {
        switch self {
        case .probe: return 3
        case .ddos: return 8
        case .intrusion: return 5
        case .malusStrike: return 15
        case .coordinatedAssault: return 20
        case .neuralHijack: return 12
        case .quantumBreach: return 25
        }
    }

    /// Minimum threat level required
    var minThreatLevel: ThreatLevel {
        switch self {
        case .probe: return .blip
        case .ddos: return .signal
        case .intrusion: return .target
        case .malusStrike: return .hunted
        case .coordinatedAssault: return .targeted
        case .neuralHijack: return .hammered
        case .quantumBreach: return .critical
        }
    }

    /// Weight for random selection (higher = more common)
    var weight: Int {
        switch self {
        case .probe: return 50
        case .ddos: return 30
        case .intrusion: return 15
        case .malusStrike: return 5
        case .coordinatedAssault: return 8
        case .neuralHijack: return 4
        case .quantumBreach: return 2
        }
    }
}

// MARK: - Attack Instance

struct Attack: Identifiable, Codable {
    let id: UUID
    let type: AttackType
    let severity: Double      // 0.5 - 3.0 multiplier
    let startTick: Int
    let duration: Int
    var ticksRemaining: Int
    var damageDealt: Double = 0
    var blocked: Double = 0

    var isActive: Bool { ticksRemaining > 0 }
    var progress: Double { 1.0 - (Double(ticksRemaining) / Double(duration)) }

    init(type: AttackType, severity: Double, startTick: Int) {
        self.id = UUID()
        self.type = type
        self.severity = severity
        self.startTick = startTick
        self.duration = type.baseDuration
        self.ticksRemaining = type.baseDuration
    }

    /// Calculate damage for this tick
    /// - Parameter playerIncomePerTick: Current player income for scaling (optional)
    func damagePerTick(playerIncomePerTick: Double = 0) -> AttackDamage {
        // Income-based scaling: attacks scale to remain threatening
        // Base scaling: 1.0 at 10 credits/tick, scales up with income
        let incomeScale = max(1.0, playerIncomePerTick / 10.0)
        // Cap the scaling to prevent absurd damage at high incomes
        let cappedScale = min(incomeScale, 10.0)  // Capped at 10x to prevent brutal damage spikes
        // Blend: 70% base damage + 30% income-scaled damage
        let effectiveScale = 0.7 + (0.3 * cappedScale)

        switch type {
        case .probe:
            // Probes steal credits (scales with income to stay relevant)
            let baseDrain = 5 * severity
            return AttackDamage(creditDrain: baseDrain * effectiveScale)

        case .ddos:
            // DDoS reduces bandwidth by percentage (doesn't need income scaling)
            return AttackDamage(bandwidthReduction: 0.3 * severity)

        case .intrusion:
            // Intrusions steal credits and can disable nodes
            let baseDrain = 20 * severity
            return AttackDamage(creditDrain: baseDrain * effectiveScale, nodeDisableChance: 0.1 * severity)

        case .malusStrike:
            // Malus hits everything hard (scales with income)
            let baseDrain = 50 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.5 * severity,
                nodeDisableChance: 0.2 * severity
            )

        case .coordinatedAssault:
            // Multi-vector attack: hits credits, bandwidth, and processing
            let baseDrain = 100 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.4 * severity,
                nodeDisableChance: 0.15 * severity,
                processingReduction: 0.3 * severity
            )

        case .neuralHijack:
            // AI-targeted attack: heavy processing reduction, node hijack
            let baseDrain = 75 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                nodeDisableChance: 0.3 * severity,
                processingReduction: 0.5 * severity
            )

        case .quantumBreach:
            // Ultimate attack: devastating across all vectors
            let baseDrain = 200 * severity
            return AttackDamage(
                creditDrain: baseDrain * effectiveScale,
                bandwidthReduction: 0.6 * severity,
                nodeDisableChance: 0.25 * severity,
                processingReduction: 0.4 * severity
            )
        }
    }

    mutating func tick() {
        ticksRemaining = max(0, ticksRemaining - 1)
    }
}

// MARK: - Attack Damage

struct AttackDamage {
    var creditDrain: Double = 0
    var bandwidthReduction: Double = 0  // 0.0 - 1.0 percentage
    var nodeDisableChance: Double = 0   // 0.0 - 1.0 percentage
    var processingReduction: Double = 0

    static let zero = AttackDamage()
}

// MARK: - Defense Stats

struct DefenseStats: Codable {
    var firewallHealth: Double = 0
    var firewallMaxHealth: Double = 0
    var idsLevel: Int = 0
    var honeypotActive: Bool = false
    var encryptionLevel: Int = 0

    var hasFirewall: Bool { firewallMaxHealth > 0 }

    /// Chance to detect attack early (0.0 - 1.0)
    var detectionChance: Double {
        Double(idsLevel) * 0.15
    }

    /// Chance to redirect attack to honeypot
    var redirectChance: Double {
        honeypotActive ? 0.25 : 0.0
    }

    /// Damage reduction from encryption
    var damageReduction: Double {
        min(0.5, Double(encryptionLevel) * 0.1)
    }

    mutating func absorbDamage(_ amount: Double) -> Double {
        guard firewallHealth > 0 else { return amount }
        let absorbed = min(firewallHealth, amount)
        firewallHealth -= absorbed
        return amount - absorbed
    }
}

// MARK: - Threat State

struct ThreatState: Codable {
    var currentLevel: ThreatLevel = .ghost
    var totalCreditsEarned: Double = 0
    var attacksSurvived: Int = 0
    var totalDamageReceived: Double = 0
    var totalDamageBlocked: Double = 0
    var activeAttacks: [Attack] = []
    var defenseStats: DefenseStats = DefenseStats()

    // NetDefense tracking
    var netDefenseLevel: NetDefenseLevel = .exposed

    // Malus tracking
    var malusAwareness: Double = 0  // 0-100, triggers events
    var malusEncounters: Int = 0
    var lastMalusMessageTick: Int = 0

    mutating func updateThreatLevel() {
        let newLevel = ThreatLevel.forCredits(totalCreditsEarned)
        if newLevel.rawValue > currentLevel.rawValue {
            currentLevel = newLevel
        }
    }

    /// Update NetDefense based on current firewall state
    mutating func updateNetDefense(firewallTier: Int, firewallLevel: Int, firewallHealthPercent: Double) {
        netDefenseLevel = NetDefenseLevel.calculate(
            firewallTier: firewallTier,
            firewallLevel: firewallLevel,
            firewallHealthPercent: firewallHealthPercent
        )
    }

    /// Calculate current risk (threat reduced by defense)
    var riskCalculation: RiskCalculation {
        RiskCalculation(threat: currentLevel, defense: netDefenseLevel)
    }

    /// Effective risk level after defense mitigation
    var effectiveRiskLevel: ThreatLevel {
        riskCalculation.effectiveRiskLevel
    }

    /// Attack chance based on effective risk (not raw threat)
    var effectiveAttackChance: Double {
        riskCalculation.attackChancePerTick
    }
}

// MARK: - Attack Generator

struct AttackGenerator {
    /// Attempt to generate an attack based on threat level
    /// - Parameters:
    ///   - threatLevel: Current effective threat level
    ///   - currentTick: Game tick for attack timing
    ///   - random: Random number generator
    ///   - frequencyReduction: Reduction to attack chance from defense points (0.0 - 1.0)
    ///   - frequencyMultiplier: Multiplier for attack frequency (e.g., 2.0 for Insane mode)
    static func tryGenerateAttack(
        threatLevel: ThreatLevel,
        currentTick: Int,
        random: inout RandomNumberGenerator,
        frequencyReduction: Double = 0,
        frequencyMultiplier: Double = 1.0
    ) -> Attack? {
        // Roll for attack chance (reduced by defense points, multiplied by insane mode)
        let baseChance = threatLevel.attackChancePerTick * frequencyMultiplier
        let reducedChance = baseChance * (1.0 - frequencyReduction)
        let roll = Double.random(in: 0...100, using: &random)
        guard roll < reducedChance else { return nil }

        // Select attack type based on threat level and weights
        let availableTypes = AttackType.allCases.filter {
            $0.minThreatLevel.rawValue <= threatLevel.rawValue
        }

        guard !availableTypes.isEmpty else { return nil }

        // Weighted random selection
        let totalWeight = availableTypes.reduce(0) { $0 + $1.weight }
        var selection = Int.random(in: 0..<totalWeight, using: &random)

        var selectedType: AttackType = .probe
        for type in availableTypes {
            selection -= type.weight
            if selection < 0 {
                selectedType = type
                break
            }
        }

        // Calculate severity based on threat level
        let baseSeverity = threatLevel.severityMultiplier
        let variance = Double.random(in: 0.8...1.2, using: &random)
        let severity = baseSeverity * variance

        return Attack(type: selectedType, severity: severity, startTick: currentTick)
    }
}
