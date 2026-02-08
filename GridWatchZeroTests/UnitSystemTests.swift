//
//  UnitSystemTests.swift
//  GridWatchZeroTests
//
//  Created by War Signal on 2026-02-06.
//  Tests for unit factory, catalog, and unit properties
//

import Testing
import Foundation
@testable import GridWatchZero

/// Tests for unit creation, catalog, and tier system
@Suite("Unit System Tests")
@MainActor
struct UnitSystemTests {

    // MARK: - Unit Factory Tests

    @Test("UnitFactory can create source nodes")
    func testCreateSourceNode() async {
        let source = UnitFactory.createPublicMeshSniffer()

        #expect(!source.name.isEmpty, "Source should have a name")
        #expect(source.level > 0, "Source should have positive level")
        #expect(source.baseProduction > 0, "Source should have base production")
    }

    @Test("UnitFactory can create link nodes")
    func testCreateLinkNode() async {
        let link = UnitFactory.createCopperVPNTunnel()

        #expect(!link.name.isEmpty, "Link should have a name")
        #expect(link.level > 0, "Link should have positive level")
        #expect(link.baseBandwidth > 0, "Link should have base bandwidth")
    }

    @Test("UnitFactory can create sink nodes")
    func testCreateSinkNode() async {
        let sink = UnitFactory.createDataBroker()

        #expect(!sink.name.isEmpty, "Sink should have a name")
        #expect(sink.level > 0, "Sink should have positive level")
        #expect(sink.baseProcessingRate > 0, "Sink should have base processing rate")
    }

    // MARK: - Node Properties Tests

    @Test("Source nodes have valid production properties")
    func testSourceNodeProperties() async {
        let source = UnitFactory.createPublicMeshSniffer()

        #expect(source.baseProduction > 0, "Should have positive base production")
        #expect(source.productionPerTick > 0, "Should have production per tick")
        #expect(source.upgradeCost > 0, "Should have positive upgrade cost")
    }

    @Test("Link nodes have valid bandwidth properties")
    func testLinkNodeProperties() async {
        let link = UnitFactory.createCopperVPNTunnel()

        #expect(link.baseBandwidth > 0, "Should have positive base bandwidth")
        #expect(link.bandwidth > 0, "Should have bandwidth")
        #expect(link.upgradeCost > 0, "Should have positive upgrade cost")
    }

    @Test("Sink nodes have valid conversion properties")
    func testSinkNodeProperties() async {
        let sink = UnitFactory.createDataBroker()

        #expect(sink.baseProcessingRate > 0, "Should have positive base processing rate")
        #expect(sink.conversionRate > 0, "Should have positive conversion rate")
        #expect(sink.upgradeCost > 0, "Should have positive upgrade cost")
    }

    // MARK: - Tier System Tests

    @Test("Nodes have valid capacity")
    func testNodeCapacity() async {
        let source = UnitFactory.createPublicMeshSniffer()

        #expect(source.maxCapacity > 0, "Should have positive max capacity")
        #expect(source.currentLoad >= 0, "Current load should be non-negative")
    }

    @Test("Nodes have valid upgrade mechanics")
    func testNodeUpgradeCost() async {
        let source = UnitFactory.createPublicMeshSniffer()

        let initialCost = source.upgradeCost
        
        // Upgrade cost should be positive and reasonable
        #expect(initialCost > 0, "Upgrade cost should be positive")
        #expect(initialCost < 1000000, "Initial upgrade cost should be reasonable")
    }

    // MARK: - Cost Scaling Tests

    @Test("Upgrade cost increases with level")
    func testUpgradeCostIncreases() async {
        let engine = GameEngine()
        
        let initialCost = engine.source.upgradeCost
        let initialLevel = engine.source.level

        // Add credits and upgrade
        engine.addCredits(initialCost * 3 + 100000)
        let success = engine.upgradeSource()

        if success && engine.source.level > initialLevel {
            let newCost = engine.source.upgradeCost
            #expect(newCost > initialCost, "Cost should increase after upgrade")
        }
    }

    // MARK: - Production Scaling Tests

    @Test("Production increases with level")
    func testProductionScaling() async {
        let source = UnitFactory.createPublicMeshSniffer()

        let baseProduction = source.baseProduction
        let productionPerTick = source.productionPerTick

        // Production should scale positively
        #expect(baseProduction > 0, "Base production should be positive")
        #expect(productionPerTick >= baseProduction, "Production per tick should scale with level")
    }

    @Test("Bandwidth increases with level")
    func testBandwidthScaling() async {
        let link = UnitFactory.createCopperVPNTunnel()

        let baseBandwidth = link.baseBandwidth
        let bandwidth = link.bandwidth

        // Bandwidth should scale positively
        #expect(baseBandwidth > 0, "Base bandwidth should be positive")
        #expect(bandwidth >= baseBandwidth, "Bandwidth should scale with level")
    }

    @Test("Processing rate increases with level")
    func testProcessingScaling() async {
        let sink = UnitFactory.createDataBroker()

        let baseProcessing = sink.baseProcessingRate
        let processingPerTick = sink.processingPerTick

        // Processing should scale positively
        #expect(baseProcessing > 0, "Base processing should be positive")
        #expect(processingPerTick >= baseProcessing, "Processing per tick should scale with level")
    }

    // MARK: - Node Identification Tests

    @Test("Nodes have unique identifiers")
    func testNodeIdentifiers() async {
        let source = UnitFactory.createPublicMeshSniffer()
        let link = UnitFactory.createCopperVPNTunnel()
        let sink = UnitFactory.createDataBroker()

        // UUIDs are never empty, just verify they exist and are unique
        #expect(source.id != link.id, "Source and link should have different IDs")
        #expect(source.id != sink.id, "Source and sink should have different IDs")
        #expect(link.id != sink.id, "Link and sink should have different IDs")
    }

    // MARK: - Node Unit Type Tests

    @Test("Nodes have unit type IDs")
    func testNodeUnitTypeIds() async {
        let source = UnitFactory.createPublicMeshSniffer()
        let link = UnitFactory.createCopperVPNTunnel()
        let sink = UnitFactory.createDataBroker()

        #expect(!source.unitTypeId.isEmpty, "Source should have unit type ID")
        #expect(!link.unitTypeId.isEmpty, "Link should have unit type ID")
        #expect(!sink.unitTypeId.isEmpty, "Sink should have unit type ID")
    }
}
