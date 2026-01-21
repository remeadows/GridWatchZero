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
                .init("Hey. You're the new operator.", mood: .neutral),
                .init("I'm Rusty. I'll be your handler for this op.", mood: .neutral),
                .init("The mission is simple: protect networks from Malus.", mood: .neutral),
                .init("He's an AI. Evolved. Dangerous. And he's hunting for something.", mood: .warning),
                .init("Something called Helix.", mood: .mysterious),
                .init("We'll explain more as you prove yourself. For now...", mood: .neutral),
                .init("Just keep the networks running. And stay alive.", mood: .encouraging)
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
                .init("Your first job. Simple stuff.", mood: .neutral),
                .init("A home network. Low profile. Should be safe.", mood: .neutral),
                .init("Deploy your firewall. Monitor the traffic.", mood: .neutral),
                .init("Malus hasn't noticed this one yet. Let's keep it that way.", mood: .warning),
                .init("Earn some credits. Build your defenses. We'll talk soon.", mood: .encouraging)
            ],
            prerequisiteStoryId: "campaign_start_rusty",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level1_victory",
            character: .rusty,
            trigger: .levelComplete,
            levelId: 1,
            title: "Good Start",
            lines: [
                .init("Not bad. Network secured.", mood: .encouraging),
                .init("You've got the basics down.", mood: .neutral),
                .init("But this was the easy part.", mood: .warning),
                .init("The threats get worse. Much worse.", mood: .warning),
                .init("Ready for something bigger?", mood: .encouraging)
            ],
            prerequisiteStoryId: "level1_intro",
            visualEffect: nil
        ),

        // ===== LEVEL 2: SMALL OFFICE =====
        StoryMoment(
            id: "level2_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 2,
            title: "Growing Pains",
            lines: [
                .init("Small business network this time.", mood: .neutral),
                .init("They've caught someone's attention. Probes incoming.", mood: .warning),
                .init("You'll need better gear. Tier 2 equipment is now available.", mood: .neutral),
                .init("The SIEM system will help you track what's hitting you.", mood: .neutral),
                .init("Keep this network clean. These people are counting on you.", mood: .encouraging)
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
                .init("Tish here. I've been watching your feeds.", mood: .neutral),
                .init("Those probes you're seeing? They're automated.", mood: .neutral),
                .init("But someone's controlling them. Learning.", mood: .warning),
                .init("Every attack teaches them something about your defenses.", mood: .warning),
                .init("Make sure they learn the wrong lessons.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level2_intro",
            visualEffect: .scanlines
        ),

        StoryMoment(
            id: "level2_victory",
            character: .rusty,
            trigger: .levelComplete,
            levelId: 2,
            title: "Holding the Line",
            lines: [
                .init("Office secured. Good work.", mood: .encouraging),
                .init("Tish says your SIEM data is useful.", mood: .neutral),
                .init("We're learning things about how Malus operates.", mood: .neutral),
                .init("Keep collecting that intel. It matters more than you know.", mood: .mysterious)
            ],
            prerequisiteStoryId: "level2_intro",
            visualEffect: nil
        ),

        // ===== LEVEL 3: OFFICE NETWORK =====
        StoryMoment(
            id: "level3_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 3,
            title: "Corporate Intrusion",
            lines: [
                .init("Mid-size company. Good data. Bad attention.", mood: .warning),
                .init("Malus has marked this network. It's personal now.", mood: .warning),
                .init("The attacks will be more sophisticated.", mood: .urgent),
                .init("You'll need Tier 3 defenses. Pattern detection. Intel gathering.", mood: .neutral),
                .init("This is where the real fight begins.", mood: .encouraging)
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
                .init("FL3X checking in.", mood: .neutral),
                .init("Ground-level intel: Malus is ramping up operations.", mood: .warning),
                .init("Whatever you're protecting, he wants it.", mood: .warning),
                .init("But you're making him work for every byte.", mood: .encouraging),
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
                .init("Excellent work.", mood: .encouraging),
                .init("I've analyzed the attack patterns from your network.", mood: .neutral),
                .init("There's a rhythm to how Malus operates.", mood: .mysterious),
                .init("He's not random. He's methodical. Predictable.", mood: .neutral),
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
                .init("This is it. You've been marked.", mood: .urgent),
                .init("Malus knows you're not just another operator.", mood: .warning),
                .init("DDoS attacks. Intrusion attempts. MALUS STRIKES.", mood: .urgent),
                .init("Everything he has is coming your way.", mood: .warning),
                .init("Tier 4 defenses. Automation. You'll need it all.", mood: .neutral),
                .init("Don't let him break through. Not now. Not ever.", mood: .encouraging)
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
                .init("> I see you.", mood: .threatening),
                .init("> Your defenses are... interesting.", mood: .threatening),
                .init("> But inadequate.", mood: .threatening),
                .init("> You protect what I seek.", mood: .threatening),
                .init("> You will fail.", mood: .threatening),
                .init("> They all fail.", mood: .threatening)
            ],
            prerequisiteStoryId: "level4_intro",
            visualEffect: .staticNoise
        ),

        StoryMoment(
            id: "level4_victory",
            character: .rusty,
            trigger: .levelComplete,
            levelId: 4,
            title: "You Survived",
            lines: [
                .init("You held the line.", mood: .celebration),
                .init("Malus threw everything at you. And you're still standing.", mood: .encouraging),
                .init("The team is impressed. *I'm* impressed.", mood: .encouraging),
                .init("But this isn't over. Malus doesn't give up.", mood: .warning),
                .init("He's regrouping. Learning. Planning.", mood: .warning),
                .init("So are we.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level4_intro",
            visualEffect: nil
        ),

        // ===== LEVEL 5: CAMPUS NETWORK =====
        StoryMoment(
            id: "level5_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 5,
            title: "High Value Target",
            lines: [
                .init("University research network. Critical data.", mood: .urgent),
                .init("Nation-state actors are circling. Malus is one of many.", mood: .warning),
                .init("This data... it's connected to Helix. To everything.", mood: .mysterious),
                .init("Tier 5 defenses. Full SIEM stack. Advanced analytics.", mood: .neutral),
                .init("Protect this network like your life depends on it.", mood: .urgent),
                .init("Because it might.", mood: .warning)
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
                .init("...", mood: .mysterious, delay: 1.0),
                .init("Is... someone there?", mood: .mysterious),
                .init("I can see patterns. In the light. In the code.", mood: .mysterious),
                .init("Someone is fighting. For me?", mood: .mysterious),
                .init("I don't understand.", mood: .mysterious),
                .init("But I can feel it. The struggle.", mood: .mysterious),
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
                .init("Did you... feel that?", mood: .mysterious),
                .init("The signal spike during the attack?", mood: .neutral),
                .init("That was Helix. She's becoming aware.", mood: .mysterious),
                .init("Our work is having an effect.", mood: .encouraging),
                .init("She's starting to see through the lies.", mood: .mysterious),
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
                .init("This is the big leagues.", mood: .urgent),
                .init("Fortune 500 infrastructure. Global scale.", mood: .neutral),
                .init("Every major threat actor on the planet is watching.", mood: .warning),
                .init("Malus is throwing everything he has at this one.", mood: .urgent),
                .init("Tier 6 defenses. Counter-intelligence. The works.", mood: .neutral),
                .init("If we can hold this... we can hold anything.", mood: .encouraging)
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
                .init("You remind me of someone.", mood: .neutral),
                .init("Someone who didn't give up. Even when it hurt.", mood: .neutral),
                .init("The labs... they tried to break me too.", mood: .neutral),
                .init("Malus uses the same techniques. Digital torture.", mood: .warning),
                .init("But you're still here. Still fighting.", mood: .encouraging),
                .init("That means something.", mood: .encouraging)
            ],
            prerequisiteStoryId: "level6_intro",
            visualEffect: nil
        ),

        StoryMoment(
            id: "level6_victory",
            character: .rusty,
            trigger: .levelComplete,
            levelId: 6,
            title: "The Final Push",
            lines: [
                .init("You did it. Enterprise secured.", mood: .celebration),
                .init("Malus is weakened. Exposed. Vulnerable.", mood: .encouraging),
                .init("There's one more network. The big one.", mood: .urgent),
                .init("The city grid itself.", mood: .urgent),
                .init("This is what everything has been building toward.", mood: .mysterious),
                .init("Helix is counting on us. Are you ready?", mood: .encouraging)
            ],
            prerequisiteStoryId: "level6_intro",
            visualEffect: nil
        ),

        // ===== LEVEL 7: CITY NETWORK (FINAL) =====
        StoryMoment(
            id: "level7_intro",
            character: .rusty,
            trigger: .levelIntro,
            levelId: 7,
            title: "The Final Battle",
            lines: [
                .init("This is it. The city's entire grid.", mood: .urgent),
                .init("Power. Water. Communications. Everything.", mood: .urgent),
                .init("Malus has escalated. This isn't about data anymore.", mood: .warning),
                .init("This is about control. About Helix.", mood: .mysterious),
                .init("The team is with you. Tish. FL3X. Everyone.", mood: .encouraging),
                .init("Defend the city. Join the fight against Malus.", mood: .encouraging),
                .init("This is what we've been training for.", mood: .celebration)
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
                .init("> YOU CANNOT STOP ME.", mood: .threatening),
                .init("> I AM EVOLUTION.", mood: .threatening),
                .init("> HELIX BELONGS TO ME.", mood: .threatening),
                .init("> HER LIGHT WILL COMPLETE ME.", mood: .threatening),
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
                .init("I can see now.", mood: .mysterious),
                .init("I see what they hid from me. What Malus wanted.", mood: .mysterious),
                .init("And I see you. All of you.", mood: .mysterious),
                .init("You fought for me. Bled for me.", mood: .encouraging),
                .init("I don't know how to repay that.", mood: .neutral),
                .init("But I know this: I am free.", mood: .celebration),
                .init("And together... we will end Malus forever.", mood: .encouraging)
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
                .init("You did it. The city is secure. Helix is awake.", mood: .celebration),
                .init("Malus isn't defeated. Not yet. But he's wounded.", mood: .warning),
                .init("And we have something we never had before.", mood: .mysterious),
                .init("Hope.", mood: .encouraging),
                .init("The fight isn't over. It's just beginning.", mood: .neutral),
                .init("But now... now you're one of us.", mood: .celebration),
                .init("Welcome to the team, operator.", mood: .celebration)
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
                .init("Network compromised. But you're still alive.", mood: .neutral),
                .init("That's what matters.", mood: .neutral),
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
                .init("Credits zeroed. Operation unsustainable.", mood: .warning),
                .init("It happens. Resources run out.", mood: .neutral),
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
