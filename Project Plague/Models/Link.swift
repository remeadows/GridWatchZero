// Link.swift
// ProjectPlague
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
        baseLatency: Int
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.baseBandwidth = baseBandwidth
        self.baseLatency = baseLatency
    }

    var bandwidth: Double {
        baseBandwidth * Double(level) * 1.4
    }

    var latency: Int {
        max(1, baseLatency - (level / 3))
    }

    /// Packet loss only applies to data exceeding bandwidth
    var packetLossChance: Double {
        // At higher levels, overflow handling improves slightly
        max(0.8, 1.0 - (Double(level) * 0.02))
    }

    var upgradeCost: Double {
        Double(level) * 30.0
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
