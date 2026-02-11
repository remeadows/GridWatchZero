// Link.swift
// GridWatchZero
// Network links connecting nodes in the grid

import Foundation

// MARK: - Link Protocol

/// Represents a connection between nodes with bandwidth constraints
protocol LinkProtocol: Identifiable, Codable {
    var id: UUID { get }
    var name: String { get }
    var level: Int { get set }

    /// Maximum data throughput per tick
    var bandwidth: Double { get }

    /// Ticks of delay (not implemented in MVP, but ready for expansion)
    var latency: Int { get }

    /// Chance of packet loss (0.0 - 1.0) - applied to excess traffic
    var packetLossChance: Double { get }

    var upgradeCost: Double { get }

    mutating func upgrade()
}

// MARK: - Transport Link

/// Standard network link with bandwidth limitations
struct TransportLink: LinkProtocol {
    let id: UUID
    var name: String
    var level: Int

    /// Factory unit type ID for checkpoint restoration
    let unitTypeId: String

    /// Base bandwidth at level 1
    let baseBandwidth: Double

    /// Base latency in ticks
    let baseLatency: Int

    /// Stats for current tick
    var lastTickTransferred: Double = 0
    var lastTickDropped: Double = 0

    init(
        id: UUID = UUID(),
        name: String,
        level: Int = 1,
        baseBandwidth: Double,
        baseLatency: Int,
        unitTypeId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.baseBandwidth = baseBandwidth
        self.baseLatency = baseLatency
        // If unitTypeId not provided, look up from unit catalog by name
        self.unitTypeId = unitTypeId ?? UnitFactory.unitId(forName: name) ?? "link_t1_copper_vpn"
    }

    var bandwidth: Double {
        baseBandwidth * Double(level) * 1.4
    }

    var latency: Int {
        guard baseLatency > 0 else { return 0 }
        return max(1, baseLatency - (level / 3))
    }

    /// Packet loss only applies to data exceeding bandwidth
    var packetLossChance: Double {
        // At higher levels, overflow handling improves slightly
        max(0.8, 1.0 - (Double(level) * 0.02))
    }

    /// Upgrade cost uses exponential scaling (1.18^level)
    /// This makes upgrades increasingly expensive, creating meaningful progression
    var upgradeCost: Double {
        30.0 * pow(1.18, Double(level))
    }

    var throughputEfficiency: Double {
        guard lastTickTransferred + lastTickDropped > 0 else { return 1.0 }
        return lastTickTransferred / (lastTickTransferred + lastTickDropped)
    }

    mutating func upgrade() {
        level += 1
    }

    /// Transfer data through the link, applying bandwidth cap and packet loss
    /// Returns: (transferred amount, dropped amount)
    mutating func transfer(_ packet: DataPacket, maxAcceptable: Double) -> (transferred: Double, dropped: Double) {
        let incoming = packet.amount

        // Calculate how much can pass through
        let effectiveBandwidth = min(bandwidth, maxAcceptable)
        let transferred = min(incoming, effectiveBandwidth)

        // Excess data is subject to packet loss
        let excess = incoming - transferred
        var dropped: Double = 0

        if excess > 0 {
            // Apply packet loss to excess
            dropped = excess * packetLossChance
        }

        lastTickTransferred = transferred
        lastTickDropped = dropped

        return (transferred, dropped)
    }
}

// MARK: - TransportLink Tier Extensions

extension TransportLink {
    /// Tier of this link based on base bandwidth
    var tier: NodeTier {
        switch baseBandwidth {
        // Real-world tiers (T1-6)
        case 0..<10: return .tier1
        case 10..<30: return .tier2
        case 30..<80: return .tier3
        case 80..<200: return .tier4
        case 200..<500: return .tier5
        case 500..<1_000: return .tier6
        // Transcendence tiers (T7-10)
        case 1_000..<2_000: return .tier7
        case 2_000..<4_000: return .tier8
        case 4_000..<8_000: return .tier9
        case 8_000..<16_000: return .tier10
        // Dimensional tiers (T11-15)
        case 16_000..<32_000: return .tier11
        case 32_000..<65_000: return .tier12
        case 65_000..<130_000: return .tier13
        case 130_000..<260_000: return .tier14
        case 260_000..<520_000: return .tier15
        // Cosmic tiers (T16-20)
        case 520_000..<1_050_000: return .tier16
        case 1_050_000..<2_100_000: return .tier17
        case 2_100_000..<4_200_000: return .tier18
        case 4_200_000..<8_400_000: return .tier19
        case 8_400_000..<17_000_000: return .tier20
        // Infinite tiers (T21-25)
        case 17_000_000..<34_000_000: return .tier21
        case 34_000_000..<68_000_000: return .tier22
        case 68_000_000..<136_000_000: return .tier23
        case 136_000_000..<272_000_000: return .tier24
        default: return .tier25
        }
    }

    /// Maximum level this link can be upgraded to
    var maxLevel: Int {
        tier.maxLevel
    }

    /// Whether this link can be upgraded further
    var canUpgrade: Bool {
        level < maxLevel
    }

    /// Whether this link is at its tier's max level (required to unlock next tier)
    var isAtMaxLevel: Bool {
        tier.isAtMaxLevel(level)
    }
}
