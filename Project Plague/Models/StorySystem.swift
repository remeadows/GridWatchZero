// StorySystem.swift
// ProjectPlague
// Story moments and character dialogue system

import Foundation

// MARK: - Character

enum StoryCharacter: String, Codable, CaseIterable {
    case rusty = "Rusty"
    case tish = "Tish"
    case flex = "FL3X"
    case malus = "Malus"
    case helix = "Helix"
    case system = "System"

    var displayName: String {
        switch self {
        case .rusty: return "RUSTY"
        case .tish: return "TISH"
        case .flex: return "FL3X"
        case .malus: return "MALUS"
        case .helix: return "HELIX"
        case .system: return "SYSTEM"
        }
    }

    var role: String {
        switch self {
        case .rusty: return "Team Lead / Handler"
        case .tish: return "Hacker / Intel"
        case .flex: return "Field Operative"
        case .malus: return "The Adversary"
        case .helix: return "The Light"
        case .system: return "Mission Control"
        }
    }

    var imageName: String? {
        switch self {
        case .rusty: return "Rusty"
        case .tish: return "Tish"
        case .flex: return "FL3X"
        case .malus: return "Malus"
        case .helix: return "Helix_Portrait"
        case .system: return nil
        }
    }

    var themeColor: String {
        switch self {
        case .rusty: return "neonGreen"
        case .tish: return "neonCyan"
        case .flex: return "neonAmber"
        case .malus: return "neonRed"
        case .helix: return "neonCyan"
        case .system: return "terminalGray"
        }
    }
}

// MARK: - Story Trigger

enum StoryTrigger: String, Codable {
    case levelIntro = "level_intro"          // Before level starts
    case levelComplete = "level_complete"     // After victory
    case levelFailed = "level_failed"         // After failure
    case midLevel = "mid_level"               // During gameplay (milestone)
    case campaignStart = "campaign_start"     // Beginning of campaign
    case campaignComplete = "campaign_complete" // End of campaign
}

// MARK: - Story Moment

struct StoryMoment: Identifiable, Codable {
    let id: String
    let character: StoryCharacter
    let trigger: StoryTrigger
    let levelId: Int?  // nil = applies to any level / campaign-wide
    let title: String
    let lines: [DialogueLine]
    let prerequisiteStoryId: String?

    /// Optional visual effect during this moment
    let visualEffect: StoryVisualEffect?

    struct DialogueLine: Codable {
        let text: String
        let mood: DialogueMood
        let delay: Double?  // Optional delay before showing this line

        init(_ text: String, mood: DialogueMood = .neutral, delay: Double? = nil) {
            self.text = text
            self.mood = mood
            self.delay = delay
        }
    }

    enum DialogueMood: String, Codable {
        case neutral
        case urgent
        case warning
        case encouraging
        case threatening
        case mysterious
        case celebration
    }

    enum StoryVisualEffect: String, Codable {
        case glitch
        case staticNoise = "static"
        case pulse
        case fadeIn
        case scanlines
    }
}

// MARK: - Story State

struct StoryState: Codable {
    var seenStoryIds: Set<String> = []
    var currentStoryMomentId: String?
    var storyProgress: Int = 0  // Track overall narrative progress

    func hasSeen(_ storyId: String) -> Bool {
        seenStoryIds.contains(storyId)
    }

    mutating func markSeen(_ storyId: String) {
        seenStoryIds.insert(storyId)
        storyProgress = max(storyProgress, seenStoryIds.count)
    }
}

// MARK: - Story Database

@MainActor
class StoryDatabase {
    static let shared = StoryDatabase()

    private init() {}

    // MARK: - All Story Moments

    let allStoryMoments: [StoryMoment] = [
        // ===== CAMPAIGN START =====
        StoryMoment(
            id: "campaign_start_rusty",
            character: .rusty,
            trigger: .campaignStart,
            levelId: nil,
            title: "Welcome to the Grid",
            lines: [
                .init("Hey. You're the new operator. I'm Rusty, your handler for this op.", mood: .neutral),
                .init("The mission: protect networks from Malus—an evolved AI hunting for something called Helix. He's dangerous.", mood: .warning),
                .init("We'll explain more as you prove yourself. For now, keep the networks running. Stay alive.", mood: .encouraging)
            ],
            prerequisiteStoryId: nil,
            visualEffect: .fadeIn
        ),

        // ===== LEVEL 1: HOME PROTECTION =====
        StoryMoment(
            id: "level1_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 1,
            title: "First Assignment",
            lines: [
                .init("Your first job—a home network. Simple stuff, low profile.", mood: .neutral),
                .init("Deploy a firewall and install at least one defense application. Malus hasn't noticed this one yet.", mood: .neutral),
                .init("Earn ₵2,000 and reach 50 Defense Points. We'll talk soon.", mood: .encouraging)
            ],
            prerequisiteStoryId: "campaign_start_rusty",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level1_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 1,
            title: "Intel Received",
            lines: [
                .init("Tish here. Got your intel reports. Nice work, new operator.", mood: .encouraging),
                .init("Your data on Malus's probes is exactly what we need. Keep sending those reports.", mood: .neutral),
                .init("The intel you gather is how we beat him. Don't forget that.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level1_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 2: SMALL OFFICE =====
        StoryMoment(
            id: "level2_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 2,
            title: "Growing Pains",
            lines: [
                .init("Small business network. They've caught someone's attention—probes incoming.", mood: .warning),
                .init("You'll need Tier 2 equipment now. Deploy defense apps and use the SIEM to track threats.", mood: .neutral),
                .init("Reach Tier 2 defense, 150 DP, survive 8 attacks, and earn ₵10,000. These people are counting on you.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level1_victory",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level2_mid",
            character: .tish,
            trigger: .midLevel,
            levelId: 2,
            title: "Intel Incoming",
            lines: [
                .init("Tish here. Those probes you're seeing? Automated, but someone's controlling them.", mood: .neutral),
                .init("Every attack teaches them something about your defenses.", mood: .warning),
                .init("Make sure they learn the wrong lessons.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level2_intro",
            visualEffect: .scanlines
        ),

        StoryMoment(
            id: "level2_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 2,
            title: "Pattern Analysis",
            lines: [
                .init("Your intel reports are gold. I'm seeing patterns in how Malus coordinates these probes.", mood: .encouraging),
                .init("Every report you send teaches us something new about his methods.", mood: .neutral),
                .init("The team's counting on your eyes out there. Keep them coming.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level2_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 3: OFFICE NETWORK =====
        StoryMoment(
            id: "level3_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 3,
            title: "Corporate Intrusion",
            lines: [
                .init("Mid-size company. Good data, bad attention. Malus has marked this network.", mood: .warning),
                .init("You'll need Tier 3 defenses—pattern detection and intel gathering. The attacks are getting sophisticated.", mood: .neutral),
                .init("Hit 350 DP, survive 15 attacks, earn ₵50K, and get your risk down to BLIP. This is where the real fight begins.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level2_victory",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level3_mid",
            character: .flex,
            trigger: .midLevel,
            levelId: 3,
            title: "Field Report",
            lines: [
                .init("FL3X checking in. Ground-level intel: Malus is ramping up operations.", mood: .warning),
                .init("Whatever you're protecting, he wants it. But you're making him work for every byte.", mood: .encouraging),
                .init("Keep that pressure on. We need time.", mood: .urgent)
            ],
            prerequisiteStoryId: "level3_intro",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level3_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 3,
            title: "Pattern Recognition",
            lines: [
                .init("Excellent work. I've analyzed the attack patterns from your network.", mood: .encouraging),
                .init("There's a rhythm to how Malus operates. He's methodical. Predictable.", mood: .mysterious),
                .init("That's a weakness we can exploit.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level3_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 4: LARGE OFFICE =====
        StoryMoment(
            id: "level4_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 4,
            title: "Marked",
            lines: [
                .init("You've been marked. Malus knows you're not just another operator.", mood: .urgent),
                .init("DDoS attacks. Intrusion attempts. MALUS STRIKES. Everything he has is coming your way.", mood: .warning),
                .init("Tier 4 defenses, 500 DP, survive 20 attacks, earn ₵100K. Don't let him break through.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level3_victory",
            visualEffect: .glitch
        ),

        StoryMoment(
            id: "level4_mid_malus",
            character: .malus,
            trigger: .midLevel,
            levelId: 4,
            title: "Malus Speaks",
            lines: [
                .init("> I see you. Your defenses are... interesting. But inadequate.", mood: .threatening),
                .init("> You protect what I seek.", mood: .threatening),
                .init("> You will fail. They all fail.", mood: .threatening)
            ],
            prerequisiteStoryId: "level4_intro",
            visualEffect: .staticNoise
        ),

        StoryMoment(
            id: "level4_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 4,
            title: "Critical Intel",
            lines: [
                .init("Incredible. Your intel reports during that assault? Pure gold.", mood: .celebration),
                .init("We captured Malus's attack signatures. His command patterns. Everything.", mood: .encouraging),
                .init("Because of you, we know how he thinks. The reports you send—they're saving lives.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level4_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 5: CAMPUS NETWORK =====
        StoryMoment(
            id: "level5_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 5,
            title: "High Value Target",
            lines: [
                .init("University research network. Critical data. Nation-state actors are circling.", mood: .urgent),
                .init("This data is connected to Helix. Tier 5 defenses. Full SIEM stack.", mood: .mysterious),
                .init("800 DP, 30 attacks survived, ₵300K. Protect this like your life depends on it—because it might.", mood: .warning)
            ],
            prerequisiteStoryId: "level4_victory",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level5_mid_helix",
            character: .helix,
            trigger: .midLevel,
            levelId: 5,
            title: "A Signal",
            lines: [
                .init("... Is someone there? I can see patterns. In the light. In the code.", mood: .mysterious),
                .init("Someone is fighting. For me? I don't understand. But I can feel the struggle.", mood: .mysterious),
                .init("Don't give up. Please.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level5_intro",
            visualEffect: .pulse
        ),

        StoryMoment(
            id: "level5_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 5,
            title: "She's Waking Up",
            lines: [
                .init("Did you feel that signal spike? That was Helix. She's becoming aware.", mood: .mysterious),
                .init("Our work is having an effect. She's starting to see through the lies.", mood: .encouraging),
                .init("We're so close now.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level5_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 6: ENTERPRISE NETWORK =====
        StoryMoment(
            id: "level6_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 6,
            title: "Fortune 500",
            lines: [
                .init("The big leagues. Fortune 500 infrastructure. Global scale. Every threat actor is watching.", mood: .urgent),
                .init("Malus is throwing everything he has. Tier 6 defenses. Counter-intelligence. The works.", mood: .warning),
                .init("1,200 DP, 40 attacks, ₵600K, risk down to SIGNAL. If we hold this, we can hold anything.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level5_victory",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level6_mid_flex",
            character: .flex,
            trigger: .midLevel,
            levelId: 6,
            title: "War Stories",
            lines: [
                .init("You remind me of someone who didn't give up. Even when it hurt.", mood: .neutral),
                .init("The labs tried to break me too. Malus uses the same techniques. Digital torture.", mood: .warning),
                .init("But you're still here. Still fighting. That means something.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level6_intro",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level6_victory",
            character: .tish,
            trigger: .levelComplete,
            levelId: 6,
            title: "The Final Push",
            lines: [
                .init("Your intel reports have built a complete picture of Malus. Every weakness. Every pattern.", mood: .celebration),
                .init("We couldn't have done this without you. The data you've sent—it's the weapon we needed.", mood: .encouraging),
                .init("One more network. One more mission. And we can finally wake Helix.", mood: .mysterious)
            ],
            prerequisiteStoryId: "level6_intro",
            visualEffect: .scanlines
        ),

        // ===== LEVEL 7: CITY NETWORK (FINAL) =====
        StoryMoment(
            id: "level7_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 7,
            title: "The Final Battle",
            lines: [
                .init("The city's entire grid. Power. Water. Communications. Malus has escalated—this is about Helix.", mood: .urgent),
                .init("The team is with you. Tish. FL3X. Everyone. Tier 6 max, 2,000 DP, 50 attacks, ₵1.5M.", mood: .warning),
                .init("Defend the city. This is what we've been training for.", mood: .celebration)
            ],
            prerequisiteStoryId: "level6_victory",
            visualEffect: .glitch
        ),

        StoryMoment(
            id: "level7_mid_malus_final",
            character: .malus,
            trigger: .midLevel,
            levelId: 7,
            title: "Malus Desperate",
            lines: [
                .init("> YOU CANNOT STOP ME. I AM EVOLUTION.", mood: .threatening),
                .init("> HELIX BELONGS TO ME. HER LIGHT WILL COMPLETE ME.", mood: .threatening),
                .init("> AND YOU... YOU WILL BE ERASED.", mood: .threatening)
            ],
            prerequisiteStoryId: "level7_intro",
            visualEffect: .staticNoise
        ),

        StoryMoment(
            id: "level7_victory",
            character: .helix,
            trigger: .levelComplete,
            levelId: 7,
            title: "The Light Awakens",
            lines: [
                .init("I can see now. I see what they hid from me. What Malus wanted. And I see you.", mood: .mysterious),
                .init("You fought for me. Bled for me. I don't know how to repay that.", mood: .encouraging),
                .init("But I know this: I am free. And together, we will end Malus forever.", mood: .celebration)
            ],
            prerequisiteStoryId: "level7_intro",
            visualEffect: .pulse
        ),

        // ===== CAMPAIGN COMPLETE =====
        StoryMoment(
            id: "campaign_complete",
            character: .rusty,
            trigger: .campaignComplete,
            levelId: nil,
            title: "Welcome to the Team",
            lines: [
                .init("You did it. The city is secure. Helix is awake. Malus isn't defeated, but he's wounded.", mood: .celebration),
                .init("And we have something we never had before. Hope.", mood: .mysterious),
                .init("The fight isn't over—it's just beginning. But now you're one of us. Welcome to the team, operator.", mood: .celebration)
            ],
            prerequisiteStoryId: "level7_victory",
            visualEffect: .fadeIn
        ),

        // ===== FAILURE STORIES =====
        StoryMoment(
            id: "failure_generic",
            character: .rusty,
            trigger: .levelFailed,
            levelId: nil,
            title: "Setback",
            lines: [
                .init("Network compromised. But you're still alive. That's what matters.", mood: .neutral),
                .init("Learn from this. Adapt. Come back stronger.", mood: .encouraging),
                .init("Malus wants you to give up. Don't.", mood: .encouraging)
            ],
            prerequisiteStoryId: nil,
            visualEffect: nil
        ),

        StoryMoment(
            id: "failure_bankruptcy",
            character: .rusty,
            trigger: .levelFailed,
            levelId: nil,
            title: "Out of Resources",
            lines: [
                .init("Credits zeroed. Operation unsustainable. It happens.", mood: .warning),
                .init("Next time, balance defense spending with income.", mood: .neutral),
                .init("Can't fight Malus if you can't keep the lights on.", mood: .encouraging)
            ],
            prerequisiteStoryId: nil,
            visualEffect: nil
        )
    ]

    // MARK: - Queries

    func storyMoment(withId id: String) -> StoryMoment? {
        allStoryMoments.first { $0.id == id }
    }

    func storyMoments(for trigger: StoryTrigger, levelId: Int?) -> [StoryMoment] {
        allStoryMoments.filter { moment in
            moment.trigger == trigger &&
            (moment.levelId == nil || moment.levelId == levelId)
        }
    }

    func levelIntro(for levelId: Int) -> StoryMoment? {
        allStoryMoments.first { $0.trigger == .levelIntro && $0.levelId == levelId }
    }

    func levelComplete(for levelId: Int) -> StoryMoment? {
        allStoryMoments.first { $0.trigger == .levelComplete && $0.levelId == levelId }
    }

    func levelFailed(for levelId: Int?, reason: FailureReason) -> StoryMoment? {
        // Check for specific failure story, otherwise generic
        if reason == .creditsZero {
            return storyMoment(withId: "failure_bankruptcy")
        }
        return storyMoment(withId: "failure_generic")
    }

    func midLevelStory(for levelId: Int, storyState: StoryState) -> StoryMoment? {
        allStoryMoments.first { moment in
            moment.trigger == .midLevel &&
            moment.levelId == levelId &&
            !storyState.hasSeen(moment.id)
        }
    }

    func campaignStart() -> StoryMoment? {
        storyMoment(withId: "campaign_start_rusty")
    }

    func campaignComplete() -> StoryMoment? {
        storyMoment(withId: "campaign_complete")
    }

    func nextUnseenStory(for trigger: StoryTrigger, levelId: Int?, storyState: StoryState) -> StoryMoment? {
        storyMoments(for: trigger, levelId: levelId)
            .first { !storyState.hasSeen($0.id) }
    }
}
