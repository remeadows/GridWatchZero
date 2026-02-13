// TickDisplayState.swift
// GridWatchZero
// Scoped observable for tick-driven UI updates
//
// PERFORMANCE FIX (P0): Isolates frequently-mutating tick data from
// structural game state. Views subscribe to this instead of GameEngine
// for per-tick display values, eliminating full-tree invalidation storms.

import Foundation
import Observation

@MainActor
@Observable
final class TickDisplayState {
    // MARK: - Tick Stats (updated every tick)
    var lastTickStats: TickStats = TickStats()
    var currentTick: Int = 0
    var isRunning: Bool = false
    var credits: Double = 0

    // MARK: - Node Display State (updated every tick)
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var firewall: FirewallNode?

    // MARK: - Threat Display State (updated every tick)
    var threatState: ThreatState = ThreatState()
    var activeAttack: Attack? = nil
    var activeEarlyWarning: EarlyWarning? = nil

    // MARK: - Cached Computed Values
    var totalBufferedData: Double = 0
    var totalDataGenerated: Double = 0
    var totalDataTransferred: Double = 0
    var totalDataDropped: Double = 0
    var totalDataProcessed: Double = 0

    // MARK: - Defense Display
    var defenseStack: DefenseStack = DefenseStack()
    var cachedDefenseTotals: DefenseTotals = DefenseTotals()

    // MARK: - Intel Display
    var malusIntel: MalusIntelligence = MalusIntelligence()
    var batchUploadState: BatchUploadState? = nil

    // MARK: - Prestige Display
    var prestigeState: PrestigeState = PrestigeState()

    // MARK: - Init

    init(source: SourceNode, link: TransportLink, sink: SinkNode) {
        self.source = source
        self.link = link
        self.sink = sink
    }
}
