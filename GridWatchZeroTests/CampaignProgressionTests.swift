//
//  CampaignProgressionTests.swift
//  GridWatchZeroTests
//
//  Created by War Signal on 2026-02-06.
//  Tests for campaign level progression, victory conditions, and stats tracking
//

import Testing
import Foundation
@testable import GridWatchZero

/// Tests for campaign progression mechanics
@Suite("Campaign Progression Tests")
@MainActor
struct CampaignProgressionTests {

    // MARK: - Helper Methods
    
    /// Helper to create LevelCompletionStats with reasonable defaults
    private func makeStats(
        levelId: Int = 1,
        isInsane: Bool = false,
        ticksToComplete: Int = 300,
        creditsEarned: Double = 50000,
        attacksSurvived: Int = 5,
        damageBlocked: Double = 1000,
        finalDefensePoints: Int = 500,
        intelReportsSent: Int = 5
    ) -> LevelCompletionStats {
        LevelCompletionStats(
            levelId: levelId,
            isInsane: isInsane,
            ticksToComplete: ticksToComplete,
            creditsEarned: creditsEarned,
            attacksSurvived: attacksSurvived,
            damageBlocked: damageBlocked,
            finalDefensePoints: finalDefensePoints,
            intelReportsSent: intelReportsSent,
            completionDate: Date()
        )
    }

    // MARK: - CampaignProgress Structure Tests

    @Test("CampaignProgress initializes with default state")
    func testCampaignProgressInitialization() async {
        let progress = CampaignProgress()

        #expect(progress.completedLevels.isEmpty, "Should start with no completed levels")
        #expect(progress.insaneCompletedLevels.isEmpty, "Should start with no insane completions")
        #expect(progress.unlockedTiers == [1], "Should start with tier 1 unlocked")
        #expect(progress.lifetimeStats.totalLevelsCompleted == 0, "Should have no completed levels")
    }

    @Test("CampaignProgress tracks level completion")
    func testLevelCompletion() async {
        var progress = CampaignProgress()
        
        let stats = makeStats(levelId: 1, isInsane: false)
        
        progress.completeLevel(1, stats: stats, isInsane: false)
        
        #expect(progress.completedLevels.contains(1), "Should have completed level 1")
        #expect(progress.levelStats[1] != nil, "Should have stats for level 1")
        #expect(progress.lifetimeStats.totalLevelsCompleted == 1, "Lifetime count should be 1")
    }

    @Test("CampaignProgress tracks insane mode separately")
    func testInsaneModeCompletion() async {
        var progress = CampaignProgress()
        
        let normalStats = makeStats(levelId: 1, isInsane: false)
        let insaneStats = makeStats(levelId: 1, isInsane: true, creditsEarned: 100000, attacksSurvived: 10, damageBlocked: 2000, finalDefensePoints: 1000, intelReportsSent: 10)
        
        progress.completeLevel(1, stats: normalStats, isInsane: false)
        progress.completeLevel(1, stats: insaneStats, isInsane: true)
        
        #expect(progress.completedLevels.contains(1), "Should have normal completion")
        #expect(progress.insaneCompletedLevels.contains(1), "Should have insane completion")
        #expect(progress.lifetimeStats.totalLevelsCompleted == 2, "Should count both completions")
        #expect(progress.lifetimeStats.totalInsaneLevelsCompleted == 1, "Should count insane separately")
    }

    @Test("CampaignProgress accumulates lifetime stats")
    func testLifetimeStatsAccumulation() async {
        var progress = CampaignProgress()
        
        let stats1 = makeStats(levelId: 1, isInsane: false)
        let stats2 = makeStats(levelId: 2, isInsane: false, ticksToComplete: 400, creditsEarned: 100000, attacksSurvived: 10, damageBlocked: 2000, finalDefensePoints: 800, intelReportsSent: 10)
        
        progress.completeLevel(1, stats: stats1, isInsane: false)
        progress.completeLevel(2, stats: stats2, isInsane: false)
        
        #expect(progress.lifetimeStats.totalCreditsEarned == 150000, "Should accumulate credits")
        #expect(progress.lifetimeStats.totalAttacksSurvived == 15, "Should accumulate attacks")
        #expect(progress.lifetimeStats.totalDamageBlocked == 3000, "Should accumulate damage")
        #expect(progress.lifetimeStats.totalPlaytimeTicks == 700, "Should accumulate playtime")
        #expect(progress.lifetimeStats.totalIntelReportsSent == 15, "Should accumulate intel reports")
    }

    @Test("CampaignProgress tracks highest defense points")
    func testHighestDefensePointsTracking() async {
        var progress = CampaignProgress()
        
        let stats1 = makeStats(levelId: 1, isInsane: false, finalDefensePoints: 500)
        let stats2 = makeStats(levelId: 2, isInsane: false, finalDefensePoints: 1200)
        
        progress.completeLevel(1, stats: stats1, isInsane: false)
        #expect(progress.lifetimeStats.highestDefensePoints == 500, "Should track highest")
        
        progress.completeLevel(2, stats: stats2, isInsane: false)
        #expect(progress.lifetimeStats.highestDefensePoints == 1200, "Should update highest")
    }

    @Test("CampaignProgress calculates total stars")
    func testTotalStarsCalculation() async {
        var progress = CampaignProgress()
        
        // A grade: ticksToComplete < 0.75 * expectedTicks (for level 1: < 450 ticks)
        let statsA = makeStats(levelId: 1, isInsane: false, ticksToComplete: 400)
        // S grade: ticksToComplete < 0.5 * expectedTicks (for level 1: < 300 ticks)
        let statsS = makeStats(levelId: 1, isInsane: true, ticksToComplete: 200)
        
        // Complete level 1 with A grade (1 star for completion + 1 star for A/S grade = 2 stars)
        progress.completeLevel(1, stats: statsA, isInsane: false)
        #expect(progress.totalStars == 2, "Should have 2 stars (complete + grade)")
        
        // Complete level 1 insane mode (adds 1 insane star = 3 stars total)
        progress.completeLevel(1, stats: statsS, isInsane: true)
        #expect(progress.totalStars == 3, "Should have 3 stars (complete + grade + insane)")
    }

    @Test("CampaignProgress calculates campaign progress percentage")
    func testCampaignProgressPercentage() async {
        var progress = CampaignProgress()
        
        let stats = makeStats(levelId: 1, isInsane: false)
        
        progress.completeLevel(1, stats: stats, isInsane: false)
        progress.completeLevel(2, stats: stats, isInsane: false)
        
        // 2 out of 20 levels = 0.1 (10%)
        #expect(progress.campaignProgress == 0.1, "Should be 10% complete")
    }

    @Test("CampaignProgress insane mode requires normal completion")
    func testInsaneModeUnlockRequirement() async {
        var progress = CampaignProgress()
        
        // Level 1 not completed yet
        #expect(!progress.isInsaneModeUnlocked(for: 1), "Insane should be locked")
        
        // Complete level 1 normal
        let stats = makeStats(levelId: 1, isInsane: false)
        progress.completeLevel(1, stats: stats, isInsane: false)
        
        #expect(progress.isInsaneModeUnlocked(for: 1), "Insane should be unlocked")
    }

    @Test("CampaignProgress tracks unit unlocks")
    func testUnitUnlockTracking() async {
        var progress = CampaignProgress()
        
        #expect(!progress.unlockedUnits.contains("source_t2_botnet_scraper"), "Should not have T2 source")
        
        progress.unlockUnit("source_t2_botnet_scraper")
        
        #expect(progress.unlockedUnits.contains("source_t2_botnet_scraper"), "Should have T2 source")
    }

    // MARK: - VictoryConditions Tests

    @Test("VictoryConditions requires defense tier")
    func testVictoryConditionsDefenseTier() async {
        let conditions = VictoryConditions(
            requiredDefenseTier: 2,
            requiredDefensePoints: 500,
            requiredRiskLevel: .signal,
            requiredCredits: 50000,
            requiredAttacksSurvived: nil,
            requiredReportsSent: 5,
            timeLimit: nil
        )
        
        var stack = DefenseStack()
        // Deploy a T1 app - not enough
        stack.applications[.firewall] = DefenseApplication(tier: .firewallBasic, level: 1)
        
        let satisfied = conditions.isSatisfied(
            defenseStack: stack,
            riskLevel: .ghost,
            totalCredits: 100000,
            attacksSurvived: 10,
            reportsSent: 10,
            currentTick: 100
        )
        
        #expect(!satisfied, "Should not be satisfied with T1 defense when T2 required")
    }

    @Test("VictoryConditions requires defense points")
    func testVictoryConditionsDefensePoints() async {
        let conditions = VictoryConditions(
            requiredDefenseTier: 1,
            requiredDefensePoints: 1000,
            requiredRiskLevel: .signal,
            requiredCredits: 50000,
            requiredAttacksSurvived: nil,
            requiredReportsSent: 5,
            timeLimit: nil
        )
        
        let stack = DefenseStack()
        // Empty stack = 0 defense points
        
        let satisfied = conditions.isSatisfied(
            defenseStack: stack,
            riskLevel: .ghost,
            totalCredits: 100000,
            attacksSurvived: 10,
            reportsSent: 10,
            currentTick: 100
        )
        
        #expect(!satisfied, "Should not be satisfied with insufficient defense points")
    }

    @Test("VictoryConditions requires credits")
    func testVictoryConditionsCredits() async {
        let conditions = VictoryConditions(
            requiredDefenseTier: 1,
            requiredDefensePoints: 100,
            requiredRiskLevel: .signal,
            requiredCredits: 50000,
            requiredAttacksSurvived: nil,
            requiredReportsSent: 5,
            timeLimit: nil
        )
        
        var stack = DefenseStack()
        stack.applications[.firewall] = DefenseApplication(tier: .firewallBasic, level: 1)
        
        let satisfied = conditions.isSatisfied(
            defenseStack: stack,
            riskLevel: .ghost,
            totalCredits: 10000,  // Not enough
            attacksSurvived: 10,
            reportsSent: 10,
            currentTick: 100
        )
        
        #expect(!satisfied, "Should not be satisfied with insufficient credits")
    }

    @Test("VictoryConditions requires intel reports")
    func testVictoryConditionsIntelReports() async {
        let conditions = VictoryConditions(
            requiredDefenseTier: 1,
            requiredDefensePoints: 100,
            requiredRiskLevel: .signal,
            requiredCredits: 50000,
            requiredAttacksSurvived: nil,
            requiredReportsSent: 5,
            timeLimit: nil
        )
        
        var stack = DefenseStack()
        stack.applications[.firewall] = DefenseApplication(tier: .firewallBasic, level: 1)
        
        let satisfied = conditions.isSatisfied(
            defenseStack: stack,
            riskLevel: .ghost,
            totalCredits: 100000,
            attacksSurvived: 10,
            reportsSent: 3,  // Not enough
            currentTick: 100
        )
        
        #expect(!satisfied, "Should not be satisfied with insufficient intel reports")
    }

    // MARK: - LevelCompletionStats Tests

    @Test("LevelCompletionStats has valid grade")
    func testLevelCompletionStatsGrade() async {
        // For level 1, expected ticks = 600. A grade < 75% = < 450 ticks
        let stats = makeStats(levelId: 1, isInsane: false, ticksToComplete: 400)
        
        #expect(stats.grade == .a, "Should have A grade")
        #expect(stats.creditsEarned == 50000, "Should track credits earned")
        #expect(stats.intelReportsSent == 5, "Should track intel reports sent")
    }

    @Test("LevelCompletionStats tracks all metrics")
    func testLevelCompletionStatsMetrics() async {
        let stats = makeStats(
            levelId: 1,
            isInsane: false,
            ticksToComplete: 500,
            creditsEarned: 100000,
            attacksSurvived: 10,
            damageBlocked: 2000,
            finalDefensePoints: 1200,
            intelReportsSent: 10
        )
        
        #expect(stats.attacksSurvived == 10, "Should track attacks survived")
        #expect(stats.damageBlocked == 2000, "Should track damage blocked")
        #expect(stats.ticksToComplete == 500, "Should track time to complete")
        #expect(stats.finalDefensePoints == 1200, "Should track final defense points")
    }

    // MARK: - LifetimeStats Tests

    @Test("LifetimeStats formats playtime correctly")
    func testLifetimeStatsPlaytimeFormatting() async {
        var stats = LifetimeStats()
        
        // 30 minutes = 1800 ticks
        stats.totalPlaytimeTicks = 1800
        #expect(stats.playtimeFormatted == "30m", "Should format as minutes")
        
        // 2 hours 15 minutes = 8100 ticks
        stats.totalPlaytimeTicks = 8100
        #expect(stats.playtimeFormatted == "2h 15m", "Should format as hours and minutes")
    }

    @Test("LifetimeStats tracks all categories")
    func testLifetimeStatsCategoriesTracking() async {
        var stats = LifetimeStats()
        
        stats.totalCreditsEarned = 500000
        stats.totalAttacksSurvived = 50
        stats.totalDamageBlocked = 10000
        stats.totalPlaytimeTicks = 3600
        stats.totalLevelsCompleted = 10
        stats.totalInsaneLevelsCompleted = 5
        stats.totalIntelReportsSent = 100
        stats.highestDefensePoints = 2000
        
        #expect(stats.totalCreditsEarned == 500000, "Should track total credits")
        #expect(stats.totalAttacksSurvived == 50, "Should track attacks survived")
        #expect(stats.totalDamageBlocked == 10000, "Should track damage blocked")
        #expect(stats.totalPlaytimeTicks == 3600, "Should track playtime")
        #expect(stats.totalLevelsCompleted == 10, "Should track levels completed")
        #expect(stats.totalInsaneLevelsCompleted == 5, "Should track insane completions")
        #expect(stats.totalIntelReportsSent == 100, "Should track intel reports")
        #expect(stats.highestDefensePoints == 2000, "Should track highest defense")
    }

    // MARK: - LevelCheckpoint Tests

    @Test("LevelCheckpoint is valid when recent")
    func testLevelCheckpointValidity() async {
        let recentCheckpoint = LevelCheckpoint(
            levelId: 1,
            isInsane: false,
            savedAt: Date(),  // Now
            credits: 10000,
            data: 5000,
            ticksElapsed: 100,
            attacksSurvived: 2,
            damageBlocked: 500,
            creditsEarned: 10000,
            totalCreditsEarned: 10000,
            threatLevel: .signal,
            sourceUnitId: "source_t1_mesh_sniffer",
            sourceLevel: 5,
            linkUnitId: "link_t1_copper_vpn",
            linkLevel: 5,
            sinkUnitId: "sink_t1_data_broker",
            sinkLevel: 5,
            firewallUnitId: nil,
            firewallHealth: nil,
            firewallMaxHealth: nil,
            firewallLevel: nil,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            unlockedUnits: []
        )
        
        #expect(recentCheckpoint.isValid, "Recent checkpoint should be valid")
        
        // Old checkpoint (25 hours ago)
        let oldDate = Date().addingTimeInterval(-25 * 3600)
        let oldCheckpoint = LevelCheckpoint(
            levelId: 1,
            isInsane: false,
            savedAt: oldDate,
            credits: 10000,
            data: 5000,
            ticksElapsed: 100,
            attacksSurvived: 2,
            damageBlocked: 500,
            creditsEarned: 10000,
            totalCreditsEarned: 10000,
            threatLevel: .signal,
            sourceUnitId: "source_t1_mesh_sniffer",
            sourceLevel: 5,
            linkUnitId: "link_t1_copper_vpn",
            linkLevel: 5,
            sinkUnitId: "sink_t1_data_broker",
            sinkLevel: 5,
            firewallUnitId: nil,
            firewallHealth: nil,
            firewallMaxHealth: nil,
            firewallLevel: nil,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            unlockedUnits: []
        )
        
        #expect(!oldCheckpoint.isValid, "Old checkpoint should be invalid")
    }

    @Test("LevelCheckpoint saves game state")
    func testLevelCheckpointGameState() async {
        let checkpoint = LevelCheckpoint(
            levelId: 1,
            isInsane: false,
            savedAt: Date(),
            credits: 15000,
            data: 7500,
            ticksElapsed: 200,
            attacksSurvived: 5,
            damageBlocked: 1000,
            creditsEarned: 15000,
            totalCreditsEarned: 15000,
            threatLevel: .target,
            sourceUnitId: "source_t1_mesh_sniffer",
            sourceLevel: 10,
            linkUnitId: "link_t1_copper_vpn",
            linkLevel: 8,
            sinkUnitId: "sink_t1_data_broker",
            sinkLevel: 9,
            firewallUnitId: "fw_t1_basic",
            firewallHealth: 500,
            firewallMaxHealth: 1000,
            firewallLevel: 5,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            unlockedUnits: ["source_t2_botnet_scraper"]
        )
        
        #expect(checkpoint.levelId == 1, "Should save level ID")
        #expect(checkpoint.credits == 15000, "Should save credits")
        #expect(checkpoint.sourceLevel == 10, "Should save source level")
        #expect(checkpoint.linkLevel == 8, "Should save link level")
        #expect(checkpoint.sinkLevel == 9, "Should save sink level")
        #expect(checkpoint.firewallLevel == 5, "Should save firewall level")
        #expect(checkpoint.unlockedUnits.contains("source_t2_botnet_scraper"), "Should save unlocked units")
    }
}
