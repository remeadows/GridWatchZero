// Node.swift
// ProjectPlague
// Protocol-oriented node system for the neural grid

import Foundation

// MARK: - Node Protocol

/// Base protocol for all grid nodes (sources, processors, sinks)
protocol NodeProtocol: Identifiable, Codable {
    var id: UUID { get }
    var name: String { get }
    var level: Int { get set }
    var currentLoad: Double { get set }
    var maxCapacity: Double { get }
    var isOnline: Bool { get set }

    /// Cost to upgrade to next level
    var upgradeCost: Double { get }

    /// Apply level-up effects
    mutating func upgrade()
}

extension NodeProtocol {
    var loadPercentage: Double {
        guard maxCapacity > 0 else { return 0 }
        return min(currentLoad / maxCapacity, 1.0)
    }

    var isOverloaded: Bool {
        currentLoad >= maxCapacity
    }
}

// MARK: - Source Node

/// Generates raw data each tick
struct SourceNode: NodeProtocol {
    let id: UUID
    var name: String
    var level: Int
    var currentLoad: Double = 0
    var isOnline: Bool = true

    /// Base production per tick at level 1
    let baseProduction: Double

    /// Resource type this source generates
    let outputType: ResourceType

    init(
        id: UUID = UUID(),
        name: String,
        level: Int = 1,
        baseProduction: Double,
        outputType: ResourceType
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.baseProduction = baseProduction
        self.outputType = outputType
    }

    var maxCapacity: Double {
        // Sources don't buffer, they push immediately
        productionPerTick * 2
    }

    /// Data generated per tick (scales with level)
    var productionPerTick: Double {
        baseProduction * Double(level) * 1.5
    }

    /// Upgrade cost uses exponential scaling (1.18^level)
    /// This makes upgrades increasingly expensive, creating meaningful progression
    var upgradeCost: Double {
        25.0 * pow(1.18, Double(level))
    }

    mutating func upgrade() {
        level += 1
    }

    /// Generate data for this tick
    mutating func produce(atTick tick: Int) -> DataPacket {
        let amount = productionPerTick
        currentLoad = amount
        return DataPacket(type: outputType, amount: amount, createdAtTick: tick)
    }
}

// MARK: - Processor/Sink Node

/// Processes incoming data and converts it to credits
struct SinkNode: NodeProtocol {
    let id: UUID
    var name: String
    var level: Int
    var currentLoad: Double = 0
    var isOnline: Bool = true

    /// Base processing rate per tick
    let baseProcessingRate: Double

    /// Credits earned per unit of data processed
    let conversionRate: Double

    /// Input buffer - data waiting to be processed
    var inputBuffer: Double = 0

    init(
        id: UUID = UUID(),
        name: String,
        level: Int = 1,
        baseProcessingRate: Double,
        conversionRate: Double
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.baseProcessingRate = baseProcessingRate
        self.conversionRate = conversionRate
    }

    var maxCapacity: Double {
        // Buffer capacity scales with level
        baseProcessingRate * Double(level) * 3.0
    }

    /// How much data can be processed per tick
    var processingPerTick: Double {
        baseProcessingRate * Double(level) * 1.3
    }

    var bufferRemaining: Double {
        max(0, maxCapacity - inputBuffer)
    }

    /// Upgrade cost uses exponential scaling (1.18^level)
    /// This makes upgrades increasingly expensive, creating meaningful progression
    var upgradeCost: Double {
        40.0 * pow(1.18, Double(level))
    }

    mutating func upgrade() {
        level += 1
    }

    /// Accept incoming data into buffer (returns amount actually accepted)
    mutating func receiveData(_ amount: Double) -> Double {
        let accepted = min(amount, bufferRemaining)
        inputBuffer += accepted
        currentLoad = inputBuffer
        return accepted
    }

    /// Process buffered data and return credits earned
    mutating func process() -> Double {
        let toProcess = min(inputBuffer, processingPerTick)
        inputBuffer -= toProcess
        currentLoad = inputBuffer
        let creditsEarned = toProcess * conversionRate
        return creditsEarned
    }
}

// MARK: - Firewall Node (Defense)

/// Absorbs incoming attack damage before it hits other systems
struct FirewallNode: NodeProtocol {
    let id: UUID
    var name: String
    var level: Int
    var currentLoad: Double = 0  // Current damage absorbed this tick
    var isOnline: Bool = true

    /// Base health pool at level 1
    let baseHealth: Double

    /// Current health (regenerates slowly)
    var currentHealth: Double

    /// Damage reduction percentage (0.0 - 1.0)
    let baseDamageReduction: Double

    init(
        id: UUID = UUID(),
        name: String,
        level: Int = 1,
        baseHealth: Double,
        baseDamageReduction: Double = 0.2
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.baseHealth = baseHealth
        self.currentHealth = baseHealth * Double(level)
        self.baseDamageReduction = baseDamageReduction
    }

    var maxCapacity: Double {
        // Max health scales with level
        baseHealth * Double(level) * 1.5
    }

    var maxHealth: Double {
        maxCapacity
    }

    var healthPercentage: Double {
        guard maxHealth > 0 else { return 0 }
        return currentHealth / maxHealth
    }

    /// Damage reduction increases with level
    var damageReduction: Double {
        min(0.6, baseDamageReduction + (Double(level) * 0.05))
    }

    /// Health regeneration per tick
    var regenPerTick: Double {
        maxHealth * 0.02 * Double(level) // 2% per tick per level
    }

    /// Upgrade cost uses exponential scaling (1.18^level)
    /// This makes upgrades increasingly expensive, creating meaningful progression
    var upgradeCost: Double {
        50.0 * pow(1.18, Double(level))
    }

    var isDestroyed: Bool {
        currentHealth <= 0
    }

    mutating func upgrade() {
        level += 1
        // Heal to new max on upgrade
        currentHealth = maxHealth
    }

    /// Absorb incoming damage, returns remaining damage that passes through
    mutating func absorbDamage(_ damage: Double) -> Double {
        guard isOnline && !isDestroyed else { return damage }

        // Apply damage reduction
        let reducedDamage = damage * (1.0 - damageReduction)

        // Absorb what we can
        let absorbed = min(currentHealth, reducedDamage)
        currentHealth -= absorbed
        currentLoad = absorbed

        // Return any damage that got through
        let passThrough = reducedDamage - absorbed
        return passThrough
    }

    /// Regenerate health each tick
    mutating func regenerate() {
        guard isOnline else { return }
        currentHealth = min(maxHealth, currentHealth + regenPerTick)
    }

    /// Repair firewall (costs credits, returns cost)
    mutating func repair() -> Double {
        let missingHealth = maxHealth - currentHealth
        let repairCost = missingHealth * 0.5
        currentHealth = maxHealth
        return repairCost
    }
}

// MARK: - Node Tier

enum NodeTier: Int, Codable, CaseIterable {
    case tier1 = 1
    case tier2 = 2
    case tier3 = 3
    case tier4 = 4
    case tier5 = 5
    case tier6 = 6

    var name: String {
        switch self {
        case .tier1: return "Basic"
        case .tier2: return "Advanced"
        case .tier3: return "Elite"
        case .tier4: return "Helix"
        case .tier5: return "Quantum"
        case .tier6: return "Neural"
        }
    }

    var color: String {
        switch self {
        case .tier1: return "terminalGray"
        case .tier2: return "neonGreen"
        case .tier3: return "neonCyan"
        case .tier4: return "neonAmber"
        case .tier5: return "neonRed"
        case .tier6: return "neonAmber"
        }
    }

    /// Maximum level for this tier (hard cap)
    /// Players must reach max level before unlocking the next tier
    var maxLevel: Int {
        switch self {
        case .tier1: return 10
        case .tier2: return 15
        case .tier3: return 20
        case .tier4: return 25
        case .tier5: return 30
        case .tier6: return 40
        }
    }

    /// Returns true if the given level is at or above the max for this tier
    func isAtMaxLevel(_ level: Int) -> Bool {
        level >= maxLevel
    }
}

// MARK: - Source Variants (Tiers)

extension SourceNode {
    /// Tier of this source based on base production
    var tier: NodeTier {
        switch baseProduction {
        case 0..<15: return .tier1
        case 15..<40: return .tier2
        case 40..<80: return .tier3
        case 80..<150: return .tier4
        case 150..<400: return .tier5
        default: return .tier6
        }
    }

    /// Maximum level this source can be upgraded to
    var maxLevel: Int {
        tier.maxLevel
    }

    /// Whether this source can be upgraded further
    var canUpgrade: Bool {
        level < maxLevel
    }

    /// Whether this source is at its tier's max level (required to unlock next tier)
    var isAtMaxLevel: Bool {
        tier.isAtMaxLevel(level)
    }
}

// MARK: - Sink Variants (Tiers)

extension SinkNode {
    /// Tier of this sink based on conversion rate
    var tier: NodeTier {
        switch conversionRate {
        case 0..<1.8: return .tier1
        case 1.8..<2.3: return .tier2
        case 2.3..<2.8: return .tier3
        case 2.8..<3.3: return .tier4
        case 3.3..<4.0: return .tier5
        default: return .tier6
        }
    }

    /// Maximum level this sink can be upgraded to
    var maxLevel: Int {
        tier.maxLevel
    }

    /// Whether this sink can be upgraded further
    var canUpgrade: Bool {
        level < maxLevel
    }

    /// Whether this sink is at its tier's max level (required to unlock next tier)
    var isAtMaxLevel: Bool {
        tier.isAtMaxLevel(level)
    }
}

// MARK: - Firewall Variants (Tiers)

extension FirewallNode {
    /// Tier of this firewall based on base health
    var tier: Int {
        switch baseHealth {
        case 0..<150: return 1
        case 150..<400: return 2
        case 400..<700: return 3
        case 700..<900: return 4
        case 900..<1500: return 5
        default: return 6
        }
    }

    /// Node tier enum for this firewall
    var nodeTier: NodeTier {
        NodeTier(rawValue: tier) ?? .tier1
    }

    /// Maximum level this firewall can be upgraded to
    var maxLevel: Int {
        nodeTier.maxLevel
    }

    /// Whether this firewall can be upgraded further
    var canUpgrade: Bool {
        level < maxLevel
    }

    /// Whether this firewall is at its tier's max level (required to unlock next tier)
    var isAtMaxLevel: Bool {
        nodeTier.isAtMaxLevel(level)
    }
}
