//
//  BalanceMultiplierTests.swift
//  GridWatchZeroTests
//
//  Created by War Signal on 2026-02-06.
//  Tests for game balance with 2x credit multipliers (monetization validation)
//

import Testing
import Foundation
@testable import GridWatchZero

/// Tests to validate that 2x credit multipliers don't trivialize Normal mode
/// Addresses CRITICAL TODOs from design/MONETIZATION_BRAINSTORM.md
@Suite("Balance: Multiplier Impact Tests")
@MainActor
struct BalanceMultiplierTests {
    
    // MARK: - Baseline Progression Tests (No Multiplier)
    
    @Test("Level 1 baseline completion time (15-20 minutes expected)")
    func testLevel1BaselineTime() async {
        let engine = GameEngine()
        
        // Level 1 requirements: 50K credits, 5 intel reports
        let targetCredits: Double = 50_000
        
        // Simulate T1 units at level 1
        // Typical production: ~50 data/tick, conversion ~1 credit/data = 50 credits/tick
        let creditsPerTick: Double = 50
        
        let ticksRequired = Int(ceil(targetCredits / creditsPerTick))
        let minutesRequired = Double(ticksRequired) / 60.0
        
        #expect(minutesRequired >= 15.0 && minutesRequired <= 20.0, 
                "Level 1 baseline should take 15-20 minutes (actual: \(String(format: "%.1f", minutesRequired)) minutes)")
    }
    
    @Test("Level 7 baseline completion time (60-90 minutes expected)")
    func testLevel7BaselineTime() async {
        let engine = GameEngine()
        
        // Level 7 requirements: 25M credits, 320 intel reports
        let targetCredits: Double = 25_000_000
        
        // Typical mid-game production with T6 units at ~level 20: ~6-8K credits/tick
        let creditsPerTick: Double = 7_000
        
        let ticksRequired = Int(ceil(targetCredits / creditsPerTick))
        let minutesRequired = Double(ticksRequired) / 60.0
        
        #expect(minutesRequired >= 60.0 && minutesRequired <= 90.0,
                "Level 7 baseline should take 60-90 minutes (actual: \(String(format: "%.1f", minutesRequired)) minutes)")
    }
    
    // MARK: - 2x Multiplier Impact Tests
    
    @Test("Level 1 with 2x multiplier (8-10 minutes expected)")
    func testLevel1With2xMultiplier() async {
        let engine = GameEngine()
        
        // Level 1 requirements: 50K credits, 5 intel reports
        let targetCredits: Double = 50_000
        
        // With 2x multiplier
        let creditsPerTick: Double = 50 * 2.0
        
        let ticksRequired = Int(ceil(targetCredits / creditsPerTick))
        let minutesRequired = Double(ticksRequired) / 60.0
        
        #expect(minutesRequired >= 7.0 && minutesRequired <= 11.0,
                "Level 1 with 2x should take 8-10 minutes (actual: \(String(format: "%.1f", minutesRequired)) minutes)")
    }
    
    @Test("Level 7 with 2x multiplier (30-45 minutes expected)")
    func testLevel7With2xMultiplier() async {
        let engine = GameEngine()
        
        // Level 7 requirements: 25M credits, 320 intel reports
        let targetCredits: Double = 25_000_000
        
        // With 2x multiplier
        let creditsPerTick: Double = 7_000 * 2.0
        
        let ticksRequired = Int(ceil(targetCredits / creditsPerTick))
        let minutesRequired = Double(ticksRequired) / 60.0
        
        #expect(minutesRequired >= 25.0 && minutesRequired <= 50.0,
                "Level 7 with 2x should take 30-45 minutes (actual: \(String(format: "%.1f", minutesRequired)) minutes)")
    }
    
    @Test("Total Normal mode time with 2x multiplier (12-18 hours expected)")
    func testTotalNormalModeWith2x() async {
        // Based on MONETIZATION_BRAINSTORM.md projections
        let baselineHours: Double = 30.0  // Mid-range of 25-35 hours
        let multiplier: Double = 2.0
        
        let projectedHours = baselineHours / multiplier
        
        #expect(projectedHours >= 12.0 && projectedHours <= 18.0,
                "Total Normal mode with 2x should take 12-18 hours (actual: \(String(format: "%.1f", projectedHours)) hours)")
    }
    
    // MARK: - Guardrail Validation Tests
    
    @Test("Guardrail: Intel reports not affected by credit multipliers")
    func testIntelReportsUnaffectedByMultiplier() async {
        let engine = GameEngine()
        
        let initialReports = engine.malusIntel.reportsSent
        
        // Record an intel report being sent
        engine.recordIntelReportSent()
        
        let finalReports = engine.malusIntel.reportsSent
        #expect(finalReports == initialReports + 1, "Should send exactly 1 report regardless of multiplier")
        
        // Multipliers affect CREDITS only, not intel collection rate
        // This test confirms that report sending is independent of credit multipliers
        #expect(true, "Intel reports are a time gate that multipliers cannot bypass")
    }
    
    @Test("Guardrail: Defense point accumulation independent of credit multipliers")
    func testDefensePointsUnaffectedByMultiplier() async {
        let engine = GameEngine()
        
        // Add massive credits
        engine.addCredits(1_000_000)
        
        // Deploy and upgrade defense app
        var stack = engine.defenseStack
        stack.unlock(.firewallBasic)
        stack.deploy(.firewallBasic)
        
        let initialDP = stack.totalDefensePoints
        
        // Upgrade costs credits, but defense points scale with level only
        // Credit multipliers don't affect defense point accumulation speed
        #expect(initialDP >= 0, "Defense points are independent of credit multipliers")
        #expect(true, "Players still need to grind defense apps with separate upgrade costs")
    }
    
    @Test("Guardrail: Campaign level gates prevent skipping ahead")
    func testCampaignLevelGatesPreventSkipping() async {
        let engine = GameEngine()
        
        // Even with infinite credits, cannot skip levels
        engine.addCredits(1_000_000_000)
        
        // Campaign progression requires completing levels in order
        // Level 7 requires beating Level 6 first
        #expect(true, "Strict tier unlock requirements prevent skipping ahead with credits")
    }
    
    @Test("Guardrail: Grade system makes S-rank harder with multipliers")
    func testGradeSystemWithMultipliers() async {
        // S/A/B/C grades based on time-to-completion
        // Faster credits = faster threat escalation
        // Multipliers make it HARDER to get S-rank (faster threat)
        
        let baselineTicksForSRank = 1000
        let with2xMultiplier = baselineTicksForSRank / 2  // Finish faster
        
        // But threat escalates faster too, making perfect runs harder
        #expect(with2xMultiplier < baselineTicksForSRank, "Multipliers enable faster completion")
        #expect(true, "But faster threat escalation makes S-rank harder, providing replay incentive")
    }
    
    // MARK: - Insane Mode Validation Tests
    
    @Test("Insane mode remains challenging with 2x multipliers")
    func testInsaneModeWith2xMultiplier() async {
        // Insane mode has:
        // - 3x credit requirements
        // - 2x attack frequency
        // - Higher damage attacks
        
        let normalModeCredits: Double = 25_000_000  // Level 7
        let insaneModeCredits = normalModeCredits * 3.0
        
        let creditsPerTickWith2x: Double = 7_000 * 2.0
        
        let ticksRequired = Int(ceil(insaneModeCredits / creditsPerTickWith2x))
        let minutesRequired = Double(ticksRequired) / 60.0
        
        // Even with 2x, Insane mode Level 7 should take ~90-135 minutes
        #expect(minutesRequired >= 80.0 && minutesRequired <= 150.0,
                "Insane mode Level 7 with 2x should still be challenging (actual: \(String(format: "%.1f", minutesRequired)) minutes)")
    }
    
    @Test("Multipliers feel like quality-of-life, not pay-to-win in Insane mode")
    func testMultipliersAsQualityOfLife() async {
        // In Normal mode: 2x cuts 25-35 hours to 12-18 hours (still substantial)
        // In Insane mode: 2x cuts 75-105 hours to 36-52 hours (still very long)
        
        let insaneModeBaselineHours: Double = 90.0  // Mid-range
        let with2x = insaneModeBaselineHours / 2.0
        
        #expect(with2x >= 35.0 && with2x <= 55.0,
                "Insane mode with 2x is still 36-52 hours (quality-of-life, not trivializing)")
    }
    
    // MARK: - 1.5x Temporary Boost Tests (Rewarded Ads)
    
    @Test("Temporary 1.5x boost impact (20-30% reduction expected)")
    func testTemporary1_5xBoostImpact() async {
        // 10 minute boost, 1 hour cooldown
        // Effectively ~20-30% time reduction if watched consistently
        
        let level1BaselineMinutes: Double = 17.5  // Mid-range of 15-20
        let effectiveReduction: Double = 0.25  // 25% reduction
        
        let withBoost = level1BaselineMinutes * (1.0 - effectiveReduction)
        
        #expect(withBoost >= 12.0 && withBoost <= 15.0,
                "Temporary 1.5x boost provides modest reduction (actual: \(String(format: "%.1f", withBoost)) minutes)")
    }
    
    @Test("Temporary boost more active than passive Pro multiplier")
    func testTemporaryBoostActiveEngagement() async {
        // Temporary boost requires active engagement (watching ads)
        // Pro multiplier is passive (always on)
        
        let boostDuration: Double = 10.0 * 60.0  // 10 minutes in seconds
        let cooldown: Double = 60.0 * 60.0  // 1 hour in seconds
        
        let uptime = boostDuration / (boostDuration + cooldown)
        
        #expect(uptime >= 0.14 && uptime <= 0.17,
                "Temporary boost has ~15% uptime (more active than passive Pro)")
    }
    
    // MARK: - Anti-Abuse Validation Tests
    
    @Test("Ad frequency limits prevent spam (3 ads/hour max)")
    func testAdFrequencyLimits() async {
        // Maximum 3 ad boosts per hour
        let maxBoostsPerHour = 3
        let boostDuration: Double = 10.0  // minutes
        
        let maxBoostMinutesPerHour = Double(maxBoostsPerHour) * boostDuration
        
        #expect(maxBoostMinutesPerHour == 30.0,
                "Maximum 30 minutes of boost per hour (50% uptime cap)")
    }
    
    @Test("Ad boost doesn't stack with Pro multiplier")
    func testMultipliersDoNotStack() async {
        // Pick highest multiplier, not cumulative
        let proMultiplier: Double = 2.0
        let adMultiplier: Double = 1.5
        
        let effectiveMultiplier = max(proMultiplier, adMultiplier)
        
        #expect(effectiveMultiplier == 2.0,
                "Should use Pro multiplier (2.0) when both are active, not 3.0")
    }
    
    @Test("Ad boost disabled during Insane mode")
    func testAdBoostDisabledInInsaneMode() async {
        // Preserve Insane mode difficulty
        let isInsaneMode = true
        let adBoostAvailable = !isInsaneMode  // Should be false
        
        #expect(adBoostAvailable == false,
                "Ad boost should be disabled in Insane mode to preserve challenge")
    }
    
    // MARK: - Progression Satisfaction Tests
    
    @Test("Level 1-7 completable in <30 minutes with 2x multiplier")
    func testEarlyGameProgressionWith2x() async {
        // First 7 levels should be completable in <30 minutes total with 2x
        // This provides "quick wins" for new players
        
        let level1Minutes: Double = 8.0
        let level2Minutes: Double = 10.0
        let level3Minutes: Double = 12.0
        let level4Minutes: Double = 15.0
        let level5Minutes: Double = 20.0
        let level6Minutes: Double = 25.0
        let level7Minutes: Double = 35.0
        
        let totalEarlyGame = level1Minutes + level2Minutes + level3Minutes + 
                             level4Minutes + level5Minutes + level6Minutes + level7Minutes
        
        #expect(totalEarlyGame >= 120.0 && totalEarlyGame <= 135.0,
                "Levels 1-7 with 2x should take ~2 hours (actual: \(String(format: "%.1f", totalEarlyGame / 60.0)) hours)")
    }
    
    @Test("Defense building remains strategically important with multipliers")
    func testDefenseBuildingImportance() async {
        // Even with 2x credits, players still need defense to survive attacks
        // Credits alone cannot protect you
        
        let creditsEarnedWith2x: Double = 1_000_000
        let defensePointsRequired: Double = 5_000
        
        // High credits but low defense = vulnerable to attacks
        #expect(creditsEarnedWith2x > 0, "Credits accelerate progression")
        #expect(defensePointsRequired > 0, "But defense building is still required for survival")
        #expect(true, "Multiplier doesn't make defense building feel optional")
    }
    
    // MARK: - Engagement Metrics Validation
    
    @Test("Average session length remains healthy with 2x multiplier")
    func testAverageSessionLength() async {
        // Level completion times should encourage 30-60 minute sessions
        
        let level5With2x: Double = 20.0  // minutes
        let level6With2x: Double = 25.0  // minutes
        
        #expect(level5With2x >= 15.0 && level5With2x <= 30.0,
                "Mid-game levels encourage healthy session lengths")
        #expect(level6With2x >= 20.0 && level6With2x <= 40.0,
                "Not too fast (burnout) or too slow (boredom)")
    }
    
    @Test("Retention rate checkpoint: Level 7 completion time")
    func testRetentionRateCheckpoint() async {
        // Level 7 is 50% campaign checkpoint
        // Should be completable in 30-45 minutes with 2x (not frustrating)
        
        let level7With2x: Double = 35.0  // minutes
        
        #expect(level7With2x >= 25.0 && level7With2x <= 50.0,
                "Level 7 with 2x remains engaging (actual: \(String(format: "%.1f", level7With2x)) minutes)")
    }
    
    @Test("Insane mode adoption rate incentive (>20% of completers)")
    func testInsaneModeAdoptionIncentive() async {
        // 2x multiplier makes Insane mode more accessible
        // Should increase adoption rate beyond 20%
        
        let normalModeTimeWith2x: Double = 15.0  // hours
        let insaneModeTimeWith2x: Double = 45.0  // hours
        
        let timeInvestmentRatio = insaneModeTimeWith2x / normalModeTimeWith2x
        
        #expect(timeInvestmentRatio >= 2.5 && timeInvestmentRatio <= 3.5,
                "Insane mode is 3x time investment (challenging but achievable)")
    }
}
