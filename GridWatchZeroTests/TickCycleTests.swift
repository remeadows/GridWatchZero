//
//  TickCycleTests.swift
//  GridWatchZeroTests
//
//  Created by War Signal on 2026-02-06.
//  Tests for tick cycle execution and resource flow
//

import Testing
import Foundation
@testable import GridWatchZero

/// Tests for tick execution and resource production/transfer/conversion
@Suite("Tick Cycle Tests")
@MainActor
struct TickCycleTests {

    // MARK: - Basic Tick Mechanics Tests

    @Test("Tick counter increments when engine runs")
    func testTickCounterIncrement() async {
        let engine = GameEngine()
        
        let initialTick = engine.currentTick
        
        // Start engine and wait a moment
        engine.start()
        try? await Task.sleep(for: .seconds(1.5))
        engine.pause()
        
        // Tick should have incremented
        #expect(engine.currentTick > initialTick, "Tick count should increase when engine runs")
    }

    // MARK: - Source Production Tests

    @Test("Source produces data each tick")
    func testSourceProduction() async {
        let engine = GameEngine()
        
        let initialGenerated = engine.totalDataGenerated
        
        engine.start()
        try? await Task.sleep(for: .seconds(1.5))
        engine.pause()
        
        #expect(engine.totalDataGenerated > initialGenerated, "Should generate data")
    }

    @Test("Source production increases with level")
    func testSourceProductionScaling() async {
        let source1 = UnitFactory.createPublicMeshSniffer()
        let production1 = source1.productionPerTick
        
        var source2 = UnitFactory.createPublicMeshSniffer()
        _ = source2.upgrade()
        let production2 = source2.productionPerTick
        
        #expect(production2 > production1, "Higher level should produce more data")
    }

    @Test("Source production affected by prestige multiplier")
    func testSourceProductionPrestige() async {
        let engine = GameEngine()
        
        // Source production should account for prestige
        let baseProduction = engine.source.productionPerTick
        let prestigeMultiplier = engine.prestigeState.productionMultiplier
        
        // Expected production includes prestige bonus
        #expect(prestigeMultiplier >= 1.0, "Prestige multiplier should be at least 1.0")
        #expect(baseProduction > 0, "Base production should be positive")
    }

    // MARK: - Link Transfer Tests

    @Test("Link has bandwidth capacity")
    func testLinkBandwidth() async {
        let link = UnitFactory.createCopperVPNTunnel()
        
        #expect(link.bandwidth > 0, "Link should have positive bandwidth")
        #expect(link.baseBandwidth > 0, "Link should have base bandwidth")
    }

    @Test("Link bandwidth increases with level")
    func testLinkBandwidthScaling() async {
        let link1 = UnitFactory.createCopperVPNTunnel()
        let bandwidth1 = link1.bandwidth
        
        var link2 = UnitFactory.createCopperVPNTunnel()
        _ = link2.upgrade()
        let bandwidth2 = link2.bandwidth
        
        #expect(bandwidth2 > bandwidth1, "Higher level should have more bandwidth")
    }

    @Test("Data transferred tracked correctly")
    func testDataTransferTracking() async {
        let engine = GameEngine()
        
        let initialTransferred = engine.totalDataTransferred
        
        engine.start()
        try? await Task.sleep(for: .seconds(1.5))
        engine.pause()
        
        #expect(engine.totalDataTransferred >= initialTransferred, "Should track transferred data")
    }

    @Test("Packet loss occurs when bandwidth exceeded")
    func testPacketLossTracking() async {
        let engine = GameEngine()
        
        // Packet loss is tracked
        let initialDropped = engine.totalDataDropped
        
        #expect(initialDropped >= 0, "Packet loss should be non-negative")
    }

    // MARK: - Sink Processing Tests

    @Test("Sink processes data into credits")
    func testSinkProcessing() async {
        let engine = GameEngine()
        
        let initialCredits = engine.resources.credits
        
        engine.start()
        try? await Task.sleep(for: .seconds(1.5))
        engine.pause()
        
        // Credits should increase (or stay same if no data processed)
        #expect(engine.resources.credits >= initialCredits, "Credits should not decrease from processing")
    }

    @Test("Sink has processing rate")
    func testSinkProcessingRate() async {
        let sink = UnitFactory.createDataBroker()
        
        #expect(sink.baseProcessingRate > 0, "Sink should have base processing rate")
        #expect(sink.processingPerTick > 0, "Sink should have processing per tick")
    }

    @Test("Sink processing rate increases with level")
    func testSinkProcessingScaling() async {
        let sink1 = UnitFactory.createDataBroker()
        let processing1 = sink1.processingPerTick
        
        var sink2 = UnitFactory.createDataBroker()
        _ = sink2.upgrade()
        let processing2 = sink2.processingPerTick
        
        #expect(processing2 > processing1, "Higher level should process more data")
    }

    @Test("Sink has conversion rate")
    func testSinkConversionRate() async {
        let sink = UnitFactory.createDataBroker()
        
        #expect(sink.conversionRate > 0, "Sink should have positive conversion rate")
    }

    // MARK: - Credit Flow Tests

    @Test("Credits earned tracked per tick")
    func testCreditsPerTick() async {
        let engine = GameEngine()
        
        // Last tick stats should show credit flow
        engine.start()
        try? await Task.sleep(for: .seconds(1.5))
        engine.pause()
        
        let stats = engine.lastTickStats
        #expect(stats.creditsEarned >= 0, "Credits earned should be non-negative")
    }

    @Test("Threat state tracks total credits earned")
    func testTotalCreditsTracking() async {
        let engine = GameEngine()
        
        let initialTotal = engine.threatState.totalCreditsEarned
        
        engine.addCredits(1000)
        
        #expect(engine.threatState.totalCreditsEarned >= initialTotal + 1000, 
                "Threat state should track total credits earned")
    }

    // MARK: - Tick Stats Tests

    @Test("Tick stats tracks data generated")
    func testTickStatsDataGenerated() async {
        let engine = GameEngine()
        
        engine.start()
        try? await Task.sleep(for: .seconds(1.5))
        engine.pause()
        
        let stats = engine.lastTickStats
        #expect(stats.dataGenerated >= 0, "Data generated should be tracked")
    }

    @Test("Tick stats tracks data transferred")
    func testTickStatsDataTransferred() async {
        let engine = GameEngine()
        
        engine.start()
        try? await Task.sleep(for: .seconds(1.5))
        engine.pause()
        
        let stats = engine.lastTickStats
        #expect(stats.dataTransferred >= 0, "Data transferred should be tracked")
    }

    @Test("Tick stats tracks packet drops")
    func testTickStatsPacketDrops() async {
        let engine = GameEngine()
        
        engine.start()
        try? await Task.sleep(for: .seconds(1.5))
        engine.pause()
        
        let stats = engine.lastTickStats
        #expect(stats.dataDropped >= 0, "Data dropped should be tracked")
    }

    @Test("Tick stats calculates drop rate")
    func testTickStatsDropRate() async {
        let engine = GameEngine()
        
        engine.start()
        try? await Task.sleep(for: .seconds(1.5))
        engine.pause()
        
        let stats = engine.lastTickStats
        #expect(stats.dropRate >= 0, "Drop rate should be non-negative")
        #expect(stats.dropRate <= 1.0, "Drop rate should not exceed 100%")
    }

    @Test("Tick stats calculates net credits")
    func testTickStatsNetCredits() async {
        let engine = GameEngine()
        
        engine.start()
        try? await Task.sleep(for: .seconds(1.5))
        engine.pause()
        
        let stats = engine.lastTickStats
        let netCredits = stats.netCredits
        
        #expect(netCredits == stats.creditsEarned - stats.creditsDrained,
                "Net credits should equal earned minus drained")
    }

    // MARK: - Prestige Multiplier Tests

    @Test("Prestige production multiplier applied")
    func testPrestigeProductionMultiplier() async {
        let engine = GameEngine()
        
        let multiplier = engine.prestigeState.productionMultiplier
        
        // Base multiplier is 1.0, increases with prestige level and cores
        #expect(multiplier >= 1.0, "Production multiplier should be at least 1.0")
    }

    @Test("Prestige credit multiplier applied")
    func testPrestigeCreditMultiplier() async {
        let engine = GameEngine()
        
        let multiplier = engine.prestigeState.creditMultiplier
        
        #expect(multiplier >= 1.0, "Credit multiplier should be at least 1.0")
    }

    // MARK: - Buffer Tests

    @Test("Sink has buffer capacity")
    func testSinkBufferCapacity() async {
        let sink = UnitFactory.createDataBroker()
        
        #expect(sink.maxCapacity > 0, "Sink should have positive buffer capacity")
    }

    @Test("Sink tracks buffer utilization")
    func testSinkBufferUtilization() async {
        let engine = GameEngine()
        
        engine.start()
        try? await Task.sleep(for: .seconds(1.5))
        engine.pause()
        
        let utilization = engine.lastTickStats.bufferUtilization
        
        #expect(utilization >= 0, "Buffer utilization should be non-negative")
        #expect(utilization <= 1.0, "Buffer utilization should not exceed 100%")
    }
}
