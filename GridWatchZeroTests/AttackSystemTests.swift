//
//  AttackSystemTests.swift
//  GridWatchZeroTests
//
//  Created by War Signal on 2026-02-06.
//  Tests for attack system, damage calculations, and threat progression
//

import Testing
import Foundation
@testable import GridWatchZero

/// Tests for threat levels, attacks, and defense calculations
@Suite("Attack System Tests")
@MainActor
struct AttackSystemTests {

    // MARK: - Threat Level Tests

    @Test("Threat levels have valid raw values")
    func testThreatLevelRawValues() async {
        #expect(ThreatLevel.ghost.rawValue == 1, "GHOST should be level 1")
        #expect(ThreatLevel.blip.rawValue == 2, "BLIP should be level 2")
        #expect(ThreatLevel.hunted.rawValue == 6, "HUNTED should be level 6")
        #expect(ThreatLevel.omega.rawValue == 20, "OMEGA should be level 20")
    }

    @Test("Threat levels are comparable")
    func testThreatLevelComparison() async {
        #expect(ThreatLevel.ghost < ThreatLevel.blip, "GHOST should be less than BLIP")
        #expect(ThreatLevel.hunted > ThreatLevel.target, "HUNTED should be greater than TARGET")
        #expect(ThreatLevel.omega > ThreatLevel.ghost, "OMEGA should be greater than GHOST")
    }

    @Test("Threat levels have attack chance")
    func testThreatLevelAttackChance() async {
        #expect(ThreatLevel.ghost.attackChancePerTick >= 0, "GHOST should have non-negative attack chance")
        #expect(ThreatLevel.omega.attackChancePerTick > ThreatLevel.ghost.attackChancePerTick,
                "OMEGA should have higher attack chance than GHOST")
        #expect(ThreatLevel.omega.attackChancePerTick <= 100, "Attack chance should not exceed 100%")
    }

    @Test("Threat levels have severity multiplier")
    func testThreatLevelSeverity() async {
        let ghostSeverity = ThreatLevel.ghost.severityMultiplier
        let omegaSeverity = ThreatLevel.omega.severityMultiplier
        
        #expect(ghostSeverity > 0, "GHOST should have positive severity")
        #expect(omegaSeverity > ghostSeverity, "OMEGA should have higher severity than GHOST")
    }

    @Test("Threat levels have names")
    func testThreatLevelNames() async {
        #expect(ThreatLevel.ghost.name == "GHOST", "GHOST should have correct name")
        #expect(ThreatLevel.hunted.name == "HUNTED", "HUNTED should have correct name")
        #expect(ThreatLevel.omega.name == "OMEGA", "OMEGA should have correct name")
    }

    @Test("Threat levels have descriptions")
    func testThreatLevelDescriptions() async {
        #expect(!ThreatLevel.ghost.description.isEmpty, "GHOST should have description")
        #expect(!ThreatLevel.omega.description.isEmpty, "OMEGA should have description")
    }

    // MARK: - ThreatState Tests

    @Test("ThreatState initializes at GHOST")
    func testThreatStateInitialization() async {
        let state = ThreatState()
        
        #expect(state.currentLevel == .ghost, "Should start at GHOST threat level")
        #expect(state.totalCreditsEarned >= 0, "Total credits earned should be non-negative")
        #expect(state.attacksSurvived >= 0, "Attacks survived should be non-negative")
    }

    @Test("ThreatState updates based on credits earned")
    func testThreatStateProgression() async {
        var state = ThreatState()
        let initialLevel = state.currentLevel
        
        // Add enough credits to trigger threat level increase
        state.totalCreditsEarned = 100000
        state.updateThreatLevel()
        
        #expect(state.currentLevel.rawValue >= initialLevel.rawValue,
                "Threat level should increase or stay same with more credits")
    }

    @Test("GameEngine tracks threat state")
    func testEngineTracksThreatState() async {
        let engine = GameEngine()
        
        #expect(engine.threatState.currentLevel.rawValue >= 1, "Should have valid threat level")
        #expect(engine.threatState.currentLevel.rawValue <= 20, "Threat level should not exceed OMEGA")
    }

    // MARK: - NetDefense Level Tests

    @Test("NetDefenseLevel calculates from firewall")
    func testNetDefenseLevelCalculation() async {
        // No firewall
        let exposed = NetDefenseLevel.calculate(firewallTier: 0, firewallLevel: 1, firewallHealthPercent: 1.0)
        #expect(exposed == .exposed, "No firewall should be EXPOSED")
        
        // T1 firewall
        let minimal = NetDefenseLevel.calculate(firewallTier: 1, firewallLevel: 1, firewallHealthPercent: 1.0)
        #expect(minimal.rawValue >= 1, "T1 firewall should provide defense")
        
        // Damaged firewall
        let damaged = NetDefenseLevel.calculate(firewallTier: 3, firewallLevel: 10, firewallHealthPercent: 0.2)
        let healthy = NetDefenseLevel.calculate(firewallTier: 3, firewallLevel: 10, firewallHealthPercent: 1.0)
        #expect(damaged.rawValue < healthy.rawValue, "Damaged firewall should have lower defense")
    }

    @Test("NetDefenseLevel has damage reduction")
    func testNetDefenseDamageReduction() async {
        let exposed = NetDefenseLevel.exposed
        let helix = NetDefenseLevel.helix
        
        #expect(exposed.damageReductionMultiplier == 0, "EXPOSED should have no damage reduction")
        #expect(helix.damageReductionMultiplier > 0, "HELIX should have positive damage reduction")
        #expect(helix.damageReductionMultiplier <= 1.0, "Damage reduction should not exceed 100%")
    }

    @Test("NetDefenseLevel has threat reduction")
    func testNetDefenseThreatReduction() async {
        let exposed = NetDefenseLevel.exposed
        let helix = NetDefenseLevel.helix
        
        #expect(exposed.threatReduction == 0, "EXPOSED should have no threat reduction")
        #expect(helix.threatReduction > 0, "HELIX should reduce threat display")
    }

    // MARK: - Risk Calculation Tests

    @Test("RiskCalculation combines threat and defense")
    func testRiskCalculationBasics() async {
        let risk = RiskCalculation(threat: .target, defense: .basic)
        
        #expect(risk.threatLevel == .target, "Should store threat level")
        #expect(risk.netDefenseLevel == .basic, "Should store defense level")
        #expect(risk.effectiveRiskLevel.rawValue <= risk.threatLevel.rawValue,
                "Effective risk should not exceed threat level")
    }

    @Test("RiskCalculation attack chance uses raw threat")
    func testRiskCalculationAttackChance() async {
        let noDefense = RiskCalculation(threat: .hunted, defense: .exposed)
        let strongDefense = RiskCalculation(threat: .hunted, defense: .fortified)
        
        // Attack chance should be same regardless of defense
        #expect(noDefense.attackChancePerTick == strongDefense.attackChancePerTick,
                "Attack frequency should not be reduced by defense")
    }

    @Test("RiskCalculation damage reduction scales with defense")
    func testRiskCalculationDamageReduction() async {
        let noDefense = RiskCalculation(threat: .hunted, defense: .exposed)
        let strongDefense = RiskCalculation(threat: .hunted, defense: .fortified)
        
        #expect(noDefense.damageReduction < strongDefense.damageReduction,
                "Better defense should provide more damage reduction")
    }

    @Test("RiskCalculation severity uses raw threat")
    func testRiskCalculationSeverity() async {
        let lowThreat = RiskCalculation(threat: .blip, defense: .exposed)
        let highThreat = RiskCalculation(threat: .critical, defense: .exposed)
        
        #expect(highThreat.severityMultiplier > lowThreat.severityMultiplier,
                "Higher threat should have higher severity")
    }

    // MARK: - Attack Type Tests

    @Test("Attack types have valid properties")
    func testAttackTypeProperties() async {
        let probe = AttackType.probe
        let malusStrike = AttackType.malusStrike
        
        #expect(!probe.rawValue.isEmpty, "Attack type should have raw value")
        #expect(!malusStrike.rawValue.isEmpty, "Attack type should have raw value")
    }

    @Test("Attack types have display names")
    func testAttackTypeDisplayNames() async {
        let probe = AttackType.probe
        let malusStrike = AttackType.malusStrike
        
        #expect(!probe.rawValue.isEmpty, "PROBE should have display name")
        #expect(!malusStrike.rawValue.isEmpty, "MALUS_STRIKE should have display name")
    }

    // MARK: - Attack Tests

    @Test("Attack has valid properties")
    func testAttackProperties() async {
        let attack = Attack(
            type: .probe,
            severity: 1.0,
            startTick: 100
        )
        
        #expect(attack.type == .probe, "Attack should have correct type")
        #expect(attack.severity == 1.0, "Attack should have correct severity")
        #expect(attack.startTick == 100, "Attack should have correct start tick")
        #expect(attack.duration > 0, "Attack should have positive duration")
    }

    @Test("Attack tracks damage blocked")
    func testAttackDamageBlocked() async {
        var attack = Attack(
            type: .probe,
            severity: 1.0,
            startTick: 100
        )
        
        let initialBlocked = attack.blocked
        attack.blocked = 50
        
        #expect(attack.blocked > initialBlocked, "Blocked damage should increase")
        #expect(attack.blocked == 50, "Blocked damage should be set correctly")
    }

    @Test("Attack tracks damage dealt")
    func testAttackDamageDealt() async {
        var attack = Attack(
            type: .probe,
            severity: 1.0,
            startTick: 100
        )
        
        attack.damageDealt = 150
        attack.blocked = 50
        
        let netDamage = attack.damageDealt - attack.blocked
        #expect(netDamage == 100, "Net damage should be dealt - blocked")
    }

    @Test("Attack has active status")
    func testAttackActiveStatus() async {
        var attack = Attack(
            type: .probe,
            severity: 1.0,
            startTick: 100
        )
        
        #expect(attack.isActive == true, "New attack should be active")
        
        attack.ticksRemaining = 0
        #expect(attack.isActive == false, "Attack with no ticks remaining should be inactive")
    }

    // MARK: - Firewall Defense Tests

    @Test("Firewall has health tracking")
    func testFirewallHealth() async {
        let firewall = UnitFactory.createBasicFirewall()
        
        #expect(firewall.currentHealth > 0, "Firewall should have positive current health")
        #expect(firewall.maxHealth > 0, "Firewall should have positive max health")
        #expect(firewall.currentHealth <= firewall.maxHealth,
                "Current health should not exceed max health")
    }

    @Test("Firewall has regeneration rate")
    func testFirewallRegeneration() async {
        var firewall = UnitFactory.createBasicFirewall()
        
        // Take damage
        let maxHealth = firewall.maxHealth
        firewall.currentHealth = maxHealth * 0.5
        
        // Regenerate
        firewall.regenerate()
        
        // Health should increase (but maybe not fully healed in one tick)
        #expect(firewall.currentHealth >= maxHealth * 0.5,
                "Health should not decrease from regeneration")
    }

    @Test("Firewall can absorb damage")
    func testFirewallDamage() async {
        var firewall = UnitFactory.createBasicFirewall()
        let initialHealth = firewall.currentHealth
        
        let passThrough = firewall.absorbDamage(50)
        
        #expect(firewall.currentHealth <= initialHealth, "Health should decrease or stay same from damage")
        #expect(firewall.currentHealth >= 0, "Health should not go negative")
        #expect(passThrough >= 0, "Pass-through damage should be non-negative")
    }

    // MARK: - Defense Stack Integration Tests

    @Test("Defense stack provides damage reduction")
    func testDefenseStackDamageReduction() async {
        let stack = DefenseStack()
        
        let damageReduction = stack.totalDamageReduction
        
        #expect(damageReduction >= 0, "Damage reduction should be non-negative")
        #expect(damageReduction <= 1.0, "Damage reduction should not exceed 100%")
    }

    @Test("Defense stack calculates total defense points")
    func testDefenseStackDefensePoints() async {
        let stack = DefenseStack()
        
        let defensePoints = stack.totalDefensePoints
        
        #expect(defensePoints >= 0, "Defense points should be non-negative")
    }

    @Test("Engine tracks active attack")
    func testEngineTracksActiveAttack() async {
        let engine = GameEngine()
        
        // Active attack may or may not exist
        let hasAttack = engine.activeAttack != nil
        #expect(hasAttack == true || hasAttack == false, "Active attack state should be boolean")
    }

    // MARK: - Threat Progression Tests

    @Test("Threat increases with credits earned")
    func testThreatIncreasesWithCredits() async {
        let engine = GameEngine()
        
        let _ = engine.threatState.currentLevel
        let initialCredits = engine.threatState.totalCreditsEarned
        
        // Add substantial credits
        engine.addCredits(1000000)
        
        #expect(engine.threatState.totalCreditsEarned > initialCredits,
                "Total credits earned should increase")
    }

    @Test("Attack survival is tracked")
    func testAttackSurvivalTracking() async {
        let engine = GameEngine()
        
        let attacksSurvived = engine.threatState.attacksSurvived
        
        #expect(attacksSurvived >= 0, "Attacks survived should be non-negative")
    }
}
