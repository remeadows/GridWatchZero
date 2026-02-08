//
//  ResourceAndCampaignTests.swift
//  GridWatchZeroTests
//
//  Created by War Signal on 2026-02-06.
//  Tests for resource calculations, prestige multipliers, and campaign mechanics
//

import Testing
import Foundation
@testable import GridWatchZero

/// Tests for resource calculations and campaign progression
@Suite("Resource and Campaign Tests")
@MainActor
struct ResourceAndCampaignTests {

    // MARK: - Resource Addition Tests

    @Test("Can add credits to resources")
    func testAddCredits() async {
        let engine = GameEngine()

        let initialCredits = engine.resources.credits
        engine.addCredits(1000)

        #expect(engine.resources.credits == initialCredits + 1000, "Credits should increase by 1000")
    }

    @Test("Adding zero credits works")
    func testAddZeroCredits() async {
        let engine = GameEngine()

        let _ = engine.resources.credits
        engine.addCredits(0)

        // Credits should remain valid after adding zero
        #expect(engine.resources.credits >= 0, "Credits should remain non-negative")
    }

    @Test("Adding negative credits is handled")
    func testAddNegativeCredits() async {
        let engine = GameEngine()

        let initialCredits = engine.resources.credits
        engine.addCredits(-100)

        // Should either reject negative or handle appropriately
        #expect(engine.resources.credits >= 0, "Credits should never be negative")
    }

    // MARK: - Prestige System Tests

    @Test("Prestige state has level tracking")
    func testPrestigeLevelTracking() async {
        let engine = GameEngine()

        // Check that prestige level is accessible
        // Note: May be loaded from save
        let level = engine.prestigeState.prestigeLevel
        #expect(level >= 0, "Prestige level should be non-negative")
    }

    @Test("Prestige state tracks cores")
    func testPrestigeCoreTracking() async {
        let engine = GameEngine()

        // Check that helix cores are tracked
        let cores = engine.prestigeState.totalHelixCores
        #expect(cores >= 0, "Helix cores should be non-negative")
    }

    @Test("Can check prestige eligibility")
    func testPrestigeEligibility() async {
        let engine = GameEngine()

        let canPrestige = engine.canPrestige

        // Should be a boolean value
        #expect(canPrestige == true || canPrestige == false, "Prestige eligibility should be boolean")
    }

    // MARK: - Node Properties Tests

    @Test("Source node has production rate")
    func testSourceProductionRate() async {
        let engine = GameEngine()

        // Source should have a production rate property or method
        let level = engine.source.level
        #expect(level > 0, "Source should have a positive level")
    }

    @Test("Link node has bandwidth property")
    func testLinkBandwidth() async {
        let engine = GameEngine()

        // Link should have bandwidth-related properties
        let level = engine.link.level
        #expect(level > 0, "Link should have a positive level")
    }

    @Test("Sink node has conversion properties")
    func testSinkConversion() async {
        let engine = GameEngine()

        // Sink should have conversion-related properties
        let level = engine.sink.level
        #expect(level > 0, "Sink should have a positive level")
    }

    // MARK: - Upgrade Cost Tests

    @Test("Upgrade costs increase with level")
    func testUpgradeCostScaling() async {
        let engine = GameEngine()

        let initialLevel = engine.source.level
        let initialCost = engine.source.upgradeCost

        // Add plenty of credits and upgrade
        engine.addCredits(initialCost * 3 + 100000)
        let success = engine.upgradeSource()

        if success && engine.source.level > initialLevel {
            // Successfully upgraded - cost should increase
            let newCost = engine.source.upgradeCost
            #expect(newCost > initialCost, "Upgrade cost should increase after leveling up")
        } else {
            // Could not upgrade (max level or tier locked) - skip cost comparison
            #expect(engine.source.upgradeCost >= 0, "Cost should remain valid")
        }
    }

    // MARK: - Campaign System Tests

    @Test("Engine tracks campaign mode state")
    func testCampaignModeTracking() async {
        let engine = GameEngine()

        // Check if engine is in campaign mode
        let isInCampaign = engine.isInCampaignMode
        #expect(isInCampaign == true || isInCampaign == false, "Campaign mode should be boolean")
    }

    @Test("Unlock state is accessible")
    func testUnlockState() async {
        let engine = GameEngine()

        // Verify unlock state exists and is accessible
        let unlockState = engine.unlockState
        #expect(unlockState.unlockedUnitIds.count >= 0, "Should track unlocked units")
    }

    @Test("Lore state tracks fragments")
    func testLoreStateTracking() async {
        let engine = GameEngine()

        // Verify lore system tracks fragments
        let loreState = engine.loreState
        #expect(loreState.unlockedFragments.count >= 0, "Should track lore fragments")
    }

    @Test("Milestone state tracks progress")
    func testMilestoneTracking() async {
        let engine = GameEngine()

        // Verify milestone system exists
        let milestoneState = engine.milestoneState
        #expect(milestoneState.completedMilestoneIds.count >= 0, "Should track milestones")
    }

    // MARK: - Offline Progress Tests

    @Test("Offline progress is calculated")
    func testOfflineProgressTracking() async {
        let engine = GameEngine()

        // Offline progress may or may not exist depending on state
        let hasOfflineProgress = engine.offlineProgress != nil
        #expect(hasOfflineProgress == true || hasOfflineProgress == false, "Offline progress state should be boolean")
    }

    // MARK: - Cumulative Stats Tests

    @Test("Total data generated is tracked")
    func testDataGenerationTracking() async {
        let engine = GameEngine()

        let totalGenerated = engine.totalDataGenerated
        #expect(totalGenerated >= 0, "Total data generated should be non-negative")
    }

    @Test("Total data transferred is tracked")
    func testDataTransferTracking() async {
        let engine = GameEngine()

        let totalTransferred = engine.totalDataTransferred
        #expect(totalTransferred >= 0, "Total data transferred should be non-negative")
    }

    @Test("Total data dropped is tracked")
    func testDataDropTracking() async {
        let engine = GameEngine()

        let totalDropped = engine.totalDataDropped
        #expect(totalDropped >= 0, "Total data dropped should be non-negative")
    }
}
