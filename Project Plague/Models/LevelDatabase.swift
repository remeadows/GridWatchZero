// LevelDatabase.swift
// ProjectPlague
// Campaign level definitions - all 7 levels

import Foundation

// MARK: - Level Database

@MainActor
class LevelDatabase {
    static let shared = LevelDatabase()

    private init() {}

    // MARK: - All Levels

    let allLevels: [CampaignLevel] = [
        // LEVEL 1: Home Protection
        CampaignLevel(
            id: 1,
            name: "Home Protection",
            subtitle: "Level 1 - Tutorial",
            description: """
            Your first assignment: protect a simple home network.

            Learn the basics of cyber defense. Deploy your first firewall, \
            monitor threats, and keep the network running.

            The threats are minimal here. Perfect for learning the ropes.
            """,
            startingCredits: 500,
            startingThreatLevel: .ghost,
            availableTiers: [1],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 1,
                requiredDefensePoints: 50,
                requiredRiskLevel: .ghost,
                requiredCredits: 100000,
                requiredAttacksSurvived: nil,  // Tutorial level - no attack requirement
                requiredReportsSent: 5,        // Send 5 intel reports to help the team
                timeLimit: nil
            ),
            unlockRequirement: .none,
            networkSize: .smallHome,
            introStoryId: "level1_intro",
            victoryStoryId: "level1_victory",
            insaneModifiers: .standard,
            minimumAttackChance: nil  // Tutorial - no attack floor
        ),

        // LEVEL 2: Small Office
        CampaignLevel(
            id: 2,
            name: "Small Office",
            subtitle: "Level 2",
            description: """
            A local business needs your help.

            Their network is getting probed. Someone's noticed them. \
            You'll need to deploy better defenses to keep them safe.

            Time to upgrade to Tier 2 equipment.
            """,
            startingCredits: 1000,
            startingThreatLevel: .blip,
            availableTiers: [1, 2],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 2,
                requiredDefensePoints: 150,
                requiredRiskLevel: .ghost,
                requiredCredits: 250000,
                requiredAttacksSurvived: nil,  // Removed - conflicts with keeping risk low
                requiredReportsSent: 10,       // Send 10 intel reports
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(1),
            networkSize: .smallOffice,
            introStoryId: "level2_intro",
            victoryStoryId: "level2_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 0.3  // Minimum 0.3% attack chance per tick
        ),

        // LEVEL 3: Office Network
        CampaignLevel(
            id: 3,
            name: "Office Network",
            subtitle: "Level 3",
            description: """
            Corporate intrusions are on the rise.

            This mid-size company has caught Malus's attention. \
            The attacks are getting more sophisticated. You'll need \
            advanced countermeasures to survive.

            Deploy SIEM systems. Start collecting intel.
            """,
            startingCredits: 5000,
            startingThreatLevel: .signal,
            availableTiers: [1, 2, 3],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 3,
                requiredDefensePoints: 350,
                requiredRiskLevel: .blip,
                requiredCredits: 750000,
                requiredAttacksSurvived: 15,
                requiredReportsSent: 20,       // Send 20 intel reports
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(2),
            networkSize: .office,
            introStoryId: "level3_intro",
            victoryStoryId: "level3_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 0.5  // Minimum 0.5% attack chance per tick
        ),

        // LEVEL 4: Large Office (balanced: +50% starting, -30% credit requirement)
        CampaignLevel(
            id: 4,
            name: "Large Office",
            subtitle: "Level 4",
            description: """
            Malus has marked this location.

            You're in a full cyber war now. DDoS attacks, intrusion \
            attempts, and the occasional MALUS STRIKE.

            This is where the real fight begins.
            """,
            startingCredits: 25000,
            startingThreatLevel: .target,
            availableTiers: [1, 2, 3, 4],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 4,
                requiredDefensePoints: 500,
                requiredRiskLevel: .blip,
                requiredCredits: 2000000,
                requiredAttacksSurvived: 20,
                requiredReportsSent: 40,       // Send 40 intel reports
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(3),
            networkSize: .largeOffice,
            introStoryId: "level4_intro",
            victoryStoryId: "level4_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 1.0  // Minimum 1.0% attack chance per tick
        ),

        // LEVEL 5: Campus Network (balanced for smooth T5 progression)
        CampaignLevel(
            id: 5,
            name: "Campus Network",
            subtitle: "Level 5",
            description: """
            University research data attracts dangerous attention.

            Nation-state actors are circling. Coordinated assaults incoming. \
            You're now TARGETED by advanced persistent threats.

            Deploy Quantum Firewall and Predictive SIEM to survive.
            """,
            startingCredits: 120000,
            startingThreatLevel: .targeted,
            availableTiers: [1, 2, 3, 4, 5],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 5,
                requiredDefensePoints: 800,
                requiredRiskLevel: .blip,
                requiredCredits: 6000000,
                requiredAttacksSurvived: 25,
                requiredReportsSent: 80,       // Send 80 intel reports
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(4),
            networkSize: .campus,
            introStoryId: "level5_intro",
            victoryStoryId: "level5_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 1.5  // Minimum 1.5% attack chance per tick
        ),

        // LEVEL 6: Enterprise Network (balanced for T6 acquisition)
        CampaignLevel(
            id: 6,
            name: "Enterprise Network",
            subtitle: "Level 6",
            description: """
            Fortune 500 infrastructure. Being HAMMERED by every threat.

            Neural hijacks. Quantum breaches. Malus is unleashing \
            everything in his arsenal.

            Neural Mesh Defense and Helix integration are your only hope.
            """,
            startingCredits: 300000,
            startingThreatLevel: .hammered,
            availableTiers: [1, 2, 3, 4, 5, 6],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 6,
                requiredDefensePoints: 1200,
                requiredRiskLevel: .signal,
                requiredCredits: 15000000,
                requiredAttacksSurvived: 35,
                requiredReportsSent: 160,      // Send 160 intel reports
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(5),
            networkSize: .enterprise,
            introStoryId: "level6_intro",
            victoryStoryId: "level6_victory",
            insaneModifiers: .standard,
            minimumAttackChance: 2.0  // Minimum 2.0% attack chance per tick
        ),

        // LEVEL 7: City Network (FINAL - balanced: +50% starting, -40% credit requirement, reduced attacks)
        CampaignLevel(
            id: 7,
            name: "City Network",
            subtitle: "Level 7 - FINAL",
            description: """
            CRITICAL threat level. The city grid is under total siege.

            Malus has revealed his true power. Quantum breaches cascade \
            across every node. This is the final stand.

            Channel Helix. Become the Guardian. End this.
            """,
            startingCredits: 400000,
            startingThreatLevel: .critical,
            availableTiers: [1, 2, 3, 4, 5, 6],
            victoryConditions: VictoryConditions(
                requiredDefenseTier: 6,
                requiredDefensePoints: 2000,
                requiredRiskLevel: .blip,
                requiredCredits: 40000000,
                requiredAttacksSurvived: 50,
                requiredReportsSent: 320,      // Send 320 intel reports - final level
                timeLimit: nil
            ),
            unlockRequirement: .previousLevel(6),
            networkSize: .cityWide,
            introStoryId: "level7_intro",
            victoryStoryId: "level7_victory_final",
            insaneModifiers: InsaneModifiers(
                threatFrequencyMultiplier: 2.0,  // Reduced from 2.5x for playability
                attackDamageMultiplier: 1.5,     // Reduced from 1.75x
                creditIncomeMultiplier: 0.7      // Increased from 0.6x
            ),
            minimumAttackChance: 2.5  // Minimum 2.5% attack chance per tick
        )
    ]

    // MARK: - Queries

    func level(forId id: Int) -> CampaignLevel? {
        allLevels.first { $0.id == id }
    }

    func nextLevel(after id: Int) -> CampaignLevel? {
        guard id < 7 else { return nil }
        return level(forId: id + 1)
    }

    func levelsForTier(_ tier: Int) -> [CampaignLevel] {
        allLevels.filter { $0.availableTiers.contains(tier) }
    }

    // MARK: - Level Summaries

    func levelSummary(for id: Int) -> LevelSummary? {
        guard let level = level(forId: id) else { return nil }
        return LevelSummary(level: level)
    }

    var allSummaries: [LevelSummary] {
        allLevels.map { LevelSummary(level: $0) }
    }
}

// MARK: - Level Summary (For UI)

struct LevelSummary {
    let id: Int
    let name: String
    let subtitle: String
    let threatRange: String
    let defenseTier: Int
    let networkSize: String
    let victoryHint: String

    init(level: CampaignLevel) {
        self.id = level.id
        self.name = level.name
        self.subtitle = level.subtitle
        self.defenseTier = level.victoryConditions.requiredDefenseTier
        self.networkSize = level.networkSize.rawValue

        // Generate threat range string
        let startThreat = level.startingThreatLevel.name
        let endRisk = level.victoryConditions.requiredRiskLevel.name
        self.threatRange = "\(startThreat) → \(endRisk)"

        // Generate victory hint
        let dp = level.victoryConditions.requiredDefensePoints
        let credits = level.victoryConditions.requiredCredits ?? 0
        self.victoryHint = "T\(defenseTier) defense, \(dp) DP, ₵\(credits.formatted)"
    }
}

// MARK: - Level Progression

extension LevelDatabase {
    /// Get the expected progression path
    var progressionPath: [(level: CampaignLevel, newMechanics: [String])] {
        [
            (allLevels[0], ["Basic Firewall", "Threat Levels", "Credits"]),
            (allLevels[1], ["Tier 2 Defense", "DDoS Attacks", "SIEM Basics"]),
            (allLevels[2], ["Tier 3 Defense", "Intel Reports", "Pattern Detection"]),
            (allLevels[3], ["Tier 4 Defense", "MALUS Strikes", "Automation"]),
            (allLevels[4], ["Tier 5 Defense", "Advanced Analytics", "Threat Hunting"]),
            (allLevels[5], ["Tier 6 Defense", "Counter-Intelligence", "Full Stack"]),
            (allLevels[6], ["Final Battle", "Team Integration", "Endgame"])
        ]
    }

    /// Estimated playtime per level (in minutes)
    func estimatedPlaytime(for levelId: Int) -> Int {
        switch levelId {
        case 1: return 5
        case 2: return 10
        case 3: return 15
        case 4: return 20
        case 5: return 25
        case 6: return 30
        case 7: return 45
        default: return 15
        }
    }

    /// Total estimated campaign playtime
    var totalEstimatedPlaytime: Int {
        (1...7).reduce(0) { $0 + estimatedPlaytime(for: $1) }
    }
}
