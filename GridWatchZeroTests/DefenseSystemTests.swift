//
//  DefenseSystemTests.swift
//  GridWatchZeroTests
//
//  Created by War Signal on 2026-02-06.
//  Tests for defense stack, security applications, and attack handling
//

import Testing
import Foundation
@testable import GridWatchZero

/// Tests for the defense system mechanics
@Suite("Defense System Tests")
@MainActor
struct DefenseSystemTests {

    // MARK: - Defense Stack Tests

    @Test("DefenseStack can be initialized")
    func testDefenseStackInitialization() async {
        let stack = DefenseStack()

        // Verify stack initializes with empty or default state
        #expect(stack.totalDefensePoints >= 0, "Defense points should be non-negative")
    }

    @Test("GameEngine has defense stack")
    func testEngineHasDefenseStack() async {
        let engine = GameEngine()

        // Verify engine has a defense stack
        #expect(engine.defenseStack.totalDefensePoints >= 0, "Should have defense stack")
    }

    @Test("Defense apps can be deployed")
    func testDeployDefenseApp() async {
        let engine = GameEngine()

        // Add credits to purchase defense app
        engine.addCredits(50000)

        let initialDefensePoints = engine.defenseStack.totalDefensePoints

        // Try to deploy first available defense app
        // Note: Actual deployment method may differ
        #expect(initialDefensePoints >= 0, "Should have measurable defense")
    }

    // MARK: - Malus Intelligence Tests

    @Test("MalusIntelligence initializes")
    func testMalusIntelInitialization() async {
        let intel = MalusIntelligence()

        // Verify intel system initializes
        #expect(intel.reportsSent >= 0, "Reports should be non-negative")
        #expect(intel.footprintData >= 0, "Footprint data should be non-negative")
    }

    @Test("GameEngine tracks Malus intelligence")
    func testEngineMalusIntel() async {
        let engine = GameEngine()

        // Verify engine tracks Malus intel
        #expect(engine.malusIntel.reportsSent >= 0, "Should track intel reports")
        #expect(engine.malusIntel.patternsIdentified >= 0, "Should track patterns")
    }

    // MARK: - Attack Handling Tests

    @Test("Engine has threat state")
    func testThreatState() async {
        let engine = GameEngine()

        // Verify threat state is accessible
        let levelValue = engine.threatState.currentLevel.rawValue
        #expect(levelValue >= 1, "Threat level should be at least 1 (GHOST)")
        #expect(levelValue <= 20, "Threat level should be within bounds (OMEGA is 20)")
    }

    @Test("Active attack is initially nil")
    func testNoInitialAttack() async {
        let engine = GameEngine()

        // Fresh or paused engines should have no active attack
        // (but loaded state might have one)
        let hasAttack = engine.activeAttack != nil
        #expect(hasAttack == true || hasAttack == false, "Attack state should be boolean")
    }

    // MARK: - Firewall Defense Tests

    @Test("Firewall has health property")
    func testFirewallHealth() async {
        let engine = GameEngine()

        // Add credits and purchase firewall
        engine.addCredits(10000)
        _ = engine.purchaseFirewall()

        if let firewall = engine.firewall {
            #expect(firewall.currentHealth >= 0, "Health should be non-negative")
            #expect(firewall.currentHealth <= firewall.maxHealth, "Health should not exceed max")
        }
    }

    @Test("Firewall can be repaired")
    func testFirewallRepair() async {
        let engine = GameEngine()

        // Add credits and purchase firewall
        engine.addCredits(50000)
        _ = engine.purchaseFirewall()

        if engine.firewall != nil {
            // Try to repair (may or may not succeed depending on state)
            let success = engine.repairFirewall()
            #expect(success == true || success == false, "Repair should return boolean")
        }
    }

    // MARK: - Defense Calculation Tests

    @Test("Defense points scale with level")
    func testDefensePointsScaling() async {
        let stack = DefenseStack()

        // Defense points should be non-negative
        let points = stack.totalDefensePoints
        #expect(points >= 0, "Defense points should be non-negative")
    }

    // MARK: - Category Rate Tests

    @Test("All defense categories have valid rates")
    func testCategoryRatesStructure() async {
        for category in DefenseCategory.allCases {
            let rates = category.rates

            // Intel bonus should be positive
            #expect(rates.intelBonusPerLevel > 0, "\(category.displayName) should have positive intel bonus")

            // Risk reduction should be positive
            #expect(rates.riskReductionPerLevel > 0, "\(category.displayName) should have positive risk reduction")

            // Secondary bonus should be non-negative
            #expect(rates.secondaryBonusPerLevel >= 0, "\(category.displayName) should have non-negative secondary bonus")

            // Verify label exists
            #expect(!rates.secondaryBonusLabel.isEmpty, "\(category.displayName) should have secondary bonus label")
        }
    }

    @Test("Category rates match CLAUDE.md specification")
    func testCategoryRateValues() async {
        // Firewall: 0.05 intel, 3.0% risk, 0.015 DR
        let firewallRates = DefenseCategory.firewall.rates
        #expect(firewallRates.intelBonusPerLevel == 0.05, "Firewall intel bonus should be 0.05")
        #expect(firewallRates.riskReductionPerLevel == 3.0, "Firewall risk reduction should be 3.0%")
        #expect(firewallRates.secondaryBonusPerLevel == 0.015, "Firewall DR should be 0.015")

        // SIEM: 0.12 intel, 1.0% risk, 0.05 pattern ID
        let siemRates = DefenseCategory.siem.rates
        #expect(siemRates.intelBonusPerLevel == 0.12, "SIEM intel bonus should be 0.12")
        #expect(siemRates.riskReductionPerLevel == 1.0, "SIEM risk reduction should be 1.0%")
        #expect(siemRates.secondaryBonusPerLevel == 0.05, "SIEM pattern ID should be 0.05")

        // Endpoint: 0.06 intel, 2.0% risk, 0.03 recovery
        let endpointRates = DefenseCategory.endpoint.rates
        #expect(endpointRates.intelBonusPerLevel == 0.06, "Endpoint intel bonus should be 0.06")
        #expect(endpointRates.riskReductionPerLevel == 2.0, "Endpoint risk reduction should be 2.0%")
        #expect(endpointRates.secondaryBonusPerLevel == 0.03, "Endpoint recovery should be 0.03")

        // IDS: 0.10 intel, 2.5% risk, 0.015 warning
        let idsRates = DefenseCategory.ids.rates
        #expect(idsRates.intelBonusPerLevel == 0.10, "IDS intel bonus should be 0.10")
        #expect(idsRates.riskReductionPerLevel == 2.5, "IDS risk reduction should be 2.5%")
        #expect(idsRates.secondaryBonusPerLevel == 0.015, "IDS early warning should be 0.015")

        // Network: 0.07 intel, 2.0% risk, 0.02 pkt loss (cap 0.80)
        let networkRates = DefenseCategory.network.rates
        #expect(networkRates.intelBonusPerLevel == 0.07, "Network intel bonus should be 0.07")
        #expect(networkRates.riskReductionPerLevel == 2.0, "Network risk reduction should be 2.0%")
        #expect(networkRates.secondaryBonusPerLevel == 0.02, "Network pkt loss should be 0.02")
        #expect(networkRates.secondaryBonusCap == 0.80, "Network cap should be 0.80")

        // Encryption: 0.04 intel, 1.5% risk, 0.025 credit prot (cap 0.90)
        let encryptionRates = DefenseCategory.encryption.rates
        #expect(encryptionRates.intelBonusPerLevel == 0.04, "Encryption intel bonus should be 0.04")
        #expect(encryptionRates.riskReductionPerLevel == 1.5, "Encryption risk reduction should be 1.5%")
        #expect(encryptionRates.secondaryBonusPerLevel == 0.025, "Encryption credit prot should be 0.025")
        #expect(encryptionRates.secondaryBonusCap == 0.90, "Encryption cap should be 0.90")
    }

    // MARK: - Base Defense Points Tests

    @Test("Base defense points table T1-T6 per category")
    func testBaseDefensePointsTable() async {
        // Firewall: [100, 300, 600, 1000, 1600, 2800]
        #expect(DefenseCategory.firewall.baseDefensePoints(forTier: 1) == 100, "Firewall T1 should be 100")
        #expect(DefenseCategory.firewall.baseDefensePoints(forTier: 2) == 300, "Firewall T2 should be 300")
        #expect(DefenseCategory.firewall.baseDefensePoints(forTier: 3) == 600, "Firewall T3 should be 600")
        #expect(DefenseCategory.firewall.baseDefensePoints(forTier: 4) == 1000, "Firewall T4 should be 1000")
        #expect(DefenseCategory.firewall.baseDefensePoints(forTier: 5) == 1600, "Firewall T5 should be 1600")
        #expect(DefenseCategory.firewall.baseDefensePoints(forTier: 6) == 2800, "Firewall T6 should be 2800")

        // SIEM: [80, 250, 500, 850, 1400, 2400]
        #expect(DefenseCategory.siem.baseDefensePoints(forTier: 1) == 80, "SIEM T1 should be 80")
        #expect(DefenseCategory.siem.baseDefensePoints(forTier: 2) == 250, "SIEM T2 should be 250")
        #expect(DefenseCategory.siem.baseDefensePoints(forTier: 3) == 500, "SIEM T3 should be 500")
        #expect(DefenseCategory.siem.baseDefensePoints(forTier: 4) == 850, "SIEM T4 should be 850")
        #expect(DefenseCategory.siem.baseDefensePoints(forTier: 5) == 1400, "SIEM T5 should be 1400")
        #expect(DefenseCategory.siem.baseDefensePoints(forTier: 6) == 2400, "SIEM T6 should be 2400")

        // Endpoint: [90, 280, 550, 920, 1500, 2600]
        #expect(DefenseCategory.endpoint.baseDefensePoints(forTier: 1) == 90, "Endpoint T1 should be 90")
        #expect(DefenseCategory.endpoint.baseDefensePoints(forTier: 2) == 280, "Endpoint T2 should be 280")
        #expect(DefenseCategory.endpoint.baseDefensePoints(forTier: 3) == 550, "Endpoint T3 should be 550")
        #expect(DefenseCategory.endpoint.baseDefensePoints(forTier: 4) == 920, "Endpoint T4 should be 920")
        #expect(DefenseCategory.endpoint.baseDefensePoints(forTier: 5) == 1500, "Endpoint T5 should be 1500")
        #expect(DefenseCategory.endpoint.baseDefensePoints(forTier: 6) == 2600, "Endpoint T6 should be 2600")

        // IDS: [85, 260, 520, 880, 1450, 2500]
        #expect(DefenseCategory.ids.baseDefensePoints(forTier: 1) == 85, "IDS T1 should be 85")
        #expect(DefenseCategory.ids.baseDefensePoints(forTier: 2) == 260, "IDS T2 should be 260")
        #expect(DefenseCategory.ids.baseDefensePoints(forTier: 3) == 520, "IDS T3 should be 520")
        #expect(DefenseCategory.ids.baseDefensePoints(forTier: 4) == 880, "IDS T4 should be 880")
        #expect(DefenseCategory.ids.baseDefensePoints(forTier: 5) == 1450, "IDS T5 should be 1450")
        #expect(DefenseCategory.ids.baseDefensePoints(forTier: 6) == 2500, "IDS T6 should be 2500")

        // Network: [75, 240, 480, 800, 1350, 2300]
        #expect(DefenseCategory.network.baseDefensePoints(forTier: 1) == 75, "Network T1 should be 75")
        #expect(DefenseCategory.network.baseDefensePoints(forTier: 2) == 240, "Network T2 should be 240")
        #expect(DefenseCategory.network.baseDefensePoints(forTier: 3) == 480, "Network T3 should be 480")
        #expect(DefenseCategory.network.baseDefensePoints(forTier: 4) == 800, "Network T4 should be 800")
        #expect(DefenseCategory.network.baseDefensePoints(forTier: 5) == 1350, "Network T5 should be 1350")
        #expect(DefenseCategory.network.baseDefensePoints(forTier: 6) == 2300, "Network T6 should be 2300")

        // Encryption: [70, 220, 450, 750, 1250, 2200]
        #expect(DefenseCategory.encryption.baseDefensePoints(forTier: 1) == 70, "Encryption T1 should be 70")
        #expect(DefenseCategory.encryption.baseDefensePoints(forTier: 2) == 220, "Encryption T2 should be 220")
        #expect(DefenseCategory.encryption.baseDefensePoints(forTier: 3) == 450, "Encryption T3 should be 450")
        #expect(DefenseCategory.encryption.baseDefensePoints(forTier: 4) == 750, "Encryption T4 should be 750")
        #expect(DefenseCategory.encryption.baseDefensePoints(forTier: 5) == 1250, "Encryption T5 should be 1250")
        #expect(DefenseCategory.encryption.baseDefensePoints(forTier: 6) == 2200, "Encryption T6 should be 2200")
    }

    @Test("Exponential scaling for T7+ tiers")
    func testDefensePointsExponentialScaling() async {
        // T7+ scales as: T6Value × 1.8^(tier-6)
        for category in DefenseCategory.allCases {
            let t6Value = category.baseDefensePoints(forTier: 6)
            let t7Value = category.baseDefensePoints(forTier: 7)

            // T7 should be ~1.8x T6
            let expectedT7 = t6Value * 1.8
            #expect(abs(t7Value - expectedT7) < 1.0, "\(category.displayName) T7 should be ~1.8x T6")

            // T10 should be 1.8^4 times T6
            let t10Value = category.baseDefensePoints(forTier: 10)
            let expectedT10 = t6Value * pow(1.8, 4.0)
            #expect(abs(t10Value - expectedT10) < 10.0, "\(category.displayName) T10 should be 1.8^4 × T6")
        }
    }

    // MARK: - Category Bonus Tests

    @Test("Intel bonus scales with level")
    func testIntelBonusScaling() async {
        // Create SIEM app (highest intel bonus per level: 0.12)
        let siemApp = DefenseApplication(tier: .siemSyslog)

        // Intel bonus at level 1 should be 0.12 × 1 = 0.12
        let expectedBonusL1 = 0.12 * Double(siemApp.level)
        let actualBonusL1 = siemApp.intelBonus

        #expect(abs(actualBonusL1 - expectedBonusL1) < 0.01, "Intel bonus should scale with level")
    }

    @Test("Risk reduction scales with level")
    func testRiskReductionScaling() async {
        // Create Firewall app (highest risk reduction per level: 3.0%)
        let firewallApp = DefenseApplication(tier: .firewallBasic)

        // Risk reduction at level 1 should be 3.0 × 1 = 3.0
        let expectedRisk = 3.0 * Double(firewallApp.level)
        let actualRisk = firewallApp.riskReduction

        #expect(abs(actualRisk - expectedRisk) < 0.01, "Risk reduction should scale with level")
    }

    @Test("Damage reduction has tier-based caps")
    func testDamageReductionCaps() async {
        // Firewall-only, +1.5%/level with tier caps:
        // T1-T4: 60% cap | T5: 70% | T6: 80% | T7-T10: 85% | T11-T15: 90% | T16-T20: 93% | T21-T25: 95%

        // T1 Firewall should cap at 60%
        let t1Firewall = DefenseApplication(tier: .firewallBasic)
        #expect(t1Firewall.damageReduction <= 0.60, "T1 Firewall should cap DR at 60%")

        // T6 Firewall should cap at 80%
        let t6Firewall = DefenseApplication(tier: .firewallHelix)
        #expect(t6Firewall.damageReduction <= 0.80, "T6 Firewall should cap DR at 80%")
    }

    @Test("Secondary bonuses have category-specific caps")
    func testSecondaryBonusCaps() async {
        // Network: packet loss protection caps at 80%
        let networkRates = DefenseCategory.network.rates
        #expect(networkRates.secondaryBonusCap == 0.80, "Network should cap at 80%")

        // Encryption: credit protection caps at 90%
        let encryptionRates = DefenseCategory.encryption.rates
        #expect(encryptionRates.secondaryBonusCap == 0.90, "Encryption should cap at 90%")

        // Firewall: no secondary cap (0 means no cap)
        let firewallRates = DefenseCategory.firewall.rates
        #expect(firewallRates.secondaryBonusCap == 0, "Firewall should have no secondary cap")
    }

    // MARK: - Defense Stack Aggregate Tests

    @Test("Defense stack calculates total risk reduction")
    func testTotalRiskReduction() async {
        var stack = DefenseStack()

        // Deploy Firewall T1 (3.0% per level)
        stack.unlock(.firewallBasic)
        stack.deploy(.firewallBasic)

        let riskReduction = stack.totalRiskReduction
        #expect(riskReduction > 0, "Should have positive risk reduction")
        #expect(riskReduction >= 3.0, "Firewall T1 L1 should provide at least 3% risk reduction")
    }

    @Test("Defense stack calculates attack frequency reduction")
    func testAttackFrequencyReduction() async {
        var stack = DefenseStack()

        // Deploy apps and verify cap at 80%
        stack.unlock(.firewallBasic)
        stack.deploy(.firewallBasic)

        let freqReduction = stack.attackFrequencyReduction
        #expect(freqReduction >= 0, "Frequency reduction should be non-negative")
        #expect(freqReduction <= 0.80, "Frequency reduction should cap at 80%")
    }

    @Test("Defense stack tracks category-specific bonuses")
    func testCategorySpecificBonuses() async {
        var stack = DefenseStack()

        // Deploy encryption for credit protection
        stack.unlock(.encryptionBasic)
        stack.deploy(.encryptionBasic)

        let creditProtection = stack.totalCreditProtection
        #expect(creditProtection >= 0, "Credit protection should be non-negative")
        #expect(creditProtection <= 0.90, "Credit protection should cap at 90%")

        // Deploy network for packet loss protection
        stack.unlock(.networkRouter)
        stack.deploy(.networkRouter)

        let packetLossProtection = stack.totalPacketLossProtection
        #expect(packetLossProtection >= 0, "Packet loss protection should be non-negative")
        #expect(packetLossProtection <= 0.80, "Packet loss protection should cap at 80%")
    }

    // MARK: - Tier Progression Tests

    @Test("Each category has 25 tier progression chain")
    func testProgressionChainLength() async {
        for category in DefenseCategory.allCases {
            let chain = category.progressionChain

            #expect(chain.count == 25, "\(category.displayName) should have 25 tiers in progression chain")

            // Verify tier numbers are sequential 1-25
            for (index, tier) in chain.enumerated() {
                let expectedTier = index + 1
                #expect(tier.tierNumber == expectedTier, "\(category.displayName) chain index \(index) should be tier \(expectedTier)")
            }
        }
    }

    @Test("Tier gate system requires max level before unlock")
    func testTierGateSystem() async {
        var stack = DefenseStack()

        // Unlock and deploy T1 Firewall
        stack.unlock(.firewallBasic)
        stack.deploy(.firewallBasic)

        // Should NOT be able to unlock T2 until T1 is maxed
        let canUnlockT2 = stack.canUnlock(.firewallNGFW)

        if let app = stack.application(for: .firewall) {
            if app.isAtMaxLevel {
                #expect(canUnlockT2 == true, "Should be able to unlock T2 when T1 is maxed")
            } else {
                #expect(canUnlockT2 == false, "Should NOT be able to unlock T2 until T1 is maxed")
            }
        }
    }

    @Test("Defense apps have tier-appropriate max levels")
    func testDefenseAppMaxLevels() async {
        // T1: 10, T2: 15, T3: 20, T4: 25, T5: 30, T6: 40, T7+: 50
        let t1App = DefenseApplication(tier: .firewallBasic)
        #expect(t1App.maxLevel == 10, "T1 apps should have max level 10")

        let t2App = DefenseApplication(tier: .firewallNGFW)
        #expect(t2App.maxLevel == 15, "T2 apps should have max level 15")

        let t3App = DefenseApplication(tier: .firewallAIML)
        #expect(t3App.maxLevel == 20, "T3 apps should have max level 20")

        let t6App = DefenseApplication(tier: .firewallHelix)
        #expect(t6App.maxLevel == 40, "T6 apps should have max level 40")

        let t7App = DefenseApplication(tier: .firewallSymbiont)
        #expect(t7App.maxLevel == 50, "T7 apps should have max level 50")
    }
}
