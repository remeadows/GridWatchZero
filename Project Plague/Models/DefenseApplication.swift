// DefenseApplication.swift
// ProjectPlague
// Security application progression chains for network defense

import Foundation

// MARK: - Defense Application Category

enum DefenseCategory: String, Codable, CaseIterable {
    case firewall = "FIREWALL"
    case siem = "SIEM"
    case endpoint = "ENDPOINT"
    case ids = "IDS"
    case network = "NETWORK"
    case encryption = "ENCRYPTION"

    var displayName: String {
        switch self {
        case .firewall: return "Perimeter Defense"
        case .siem: return "Log Analysis"
        case .endpoint: return "Endpoint Protection"
        case .ids: return "Intrusion Detection"
        case .network: return "Network Security"
        case .encryption: return "Data Protection"
        }
    }

    var icon: String {
        switch self {
        case .firewall: return "flame.fill"
        case .siem: return "list.bullet.rectangle.fill"
        case .endpoint: return "desktopcomputer"
        case .ids: return "eye.trianglebadge.exclamationmark.fill"
        case .network: return "network"
        case .encryption: return "lock.shield.fill"
        }
    }

    var baseColor: String {
        switch self {
        case .firewall: return "neonRed"
        case .siem: return "neonCyan"
        case .endpoint: return "neonGreen"
        case .ids: return "neonAmber"
        case .network: return "neonCyan"
        case .encryption: return "neonGreen"
        }
    }

    /// Progression chain for this category
    var progressionChain: [DefenseAppTier] {
        switch self {
        case .firewall:
            return [.firewallBasic, .firewallNGFW, .firewallAIML, .firewallQuantum, .firewallNeural, .firewallHelix]
        case .siem:
            return [.siemSyslog, .siemSIEM, .siemSOAR, .siemAI, .siemPredictive, .siemHelix]
        case .endpoint:
            return [.endpointEDR, .endpointXDR, .endpointMXDR, .endpointAI, .endpointAutonomous, .endpointHelix]
        case .ids:
            return [.idsBasic, .idsIPS, .idsMLIPS, .idsAI, .idsQuantum, .idsHelix]
        case .network:
            return [.networkRouter, .networkISR, .networkCloudISR, .networkEncrypted, .networkNeural, .networkHelix]
        case .encryption:
            return [.encryptionBasic, .encryptionAdvanced, .encryptionQuantum, .encryptionNeural, .encryptionHelix]
        }
    }
}

// MARK: - Defense Application Tier

enum DefenseAppTier: String, Codable, CaseIterable {
    // Firewall chain: Firewall -> NGFW -> AI/ML -> Quantum -> Neural -> Helix
    case firewallBasic = "firewall_basic"
    case firewallNGFW = "firewall_ngfw"
    case firewallAIML = "firewall_aiml"
    case firewallQuantum = "firewall_quantum"      // T5
    case firewallNeural = "firewall_neural"        // T5+
    case firewallHelix = "firewall_helix"          // T6

    // SIEM chain: Syslog -> SIEM -> SOAR -> AI -> Predictive -> Helix
    case siemSyslog = "siem_syslog"
    case siemSIEM = "siem_siem"
    case siemSOAR = "siem_soar"
    case siemAI = "siem_ai"
    case siemPredictive = "siem_predictive"        // T5
    case siemHelix = "siem_helix"                  // T6

    // Endpoint chain: EDR -> XDR -> MXDR -> AI -> Autonomous -> Helix
    case endpointEDR = "endpoint_edr"
    case endpointXDR = "endpoint_xdr"
    case endpointMXDR = "endpoint_mxdr"
    case endpointAI = "endpoint_ai"
    case endpointAutonomous = "endpoint_autonomous" // T5
    case endpointHelix = "endpoint_helix"           // T6

    // IDS chain: IDS -> IPS -> ML/IPS -> AI -> Quantum -> Helix
    case idsBasic = "ids_basic"
    case idsIPS = "ids_ips"
    case idsMLIPS = "ids_mlips"
    case idsAI = "ids_ai"
    case idsQuantum = "ids_quantum"                // T5
    case idsHelix = "ids_helix"                    // T6

    // Network chain: Router -> ISR -> Cloud ISR -> Encrypted -> Neural -> Helix
    case networkRouter = "network_router"
    case networkISR = "network_isr"
    case networkCloudISR = "network_cloud"
    case networkEncrypted = "network_encrypted"
    case networkNeural = "network_neural"          // T5
    case networkHelix = "network_helix"            // T6

    // Encryption chain: Basic -> Advanced -> Quantum -> Neural -> Helix
    case encryptionBasic = "encryption_basic"
    case encryptionAdvanced = "encryption_advanced"
    case encryptionQuantum = "encryption_quantum"
    case encryptionNeural = "encryption_neural"    // T5
    case encryptionHelix = "encryption_helix"      // T6

    var category: DefenseCategory {
        switch self {
        case .firewallBasic, .firewallNGFW, .firewallAIML, .firewallQuantum, .firewallNeural, .firewallHelix:
            return .firewall
        case .siemSyslog, .siemSIEM, .siemSOAR, .siemAI, .siemPredictive, .siemHelix:
            return .siem
        case .endpointEDR, .endpointXDR, .endpointMXDR, .endpointAI, .endpointAutonomous, .endpointHelix:
            return .endpoint
        case .idsBasic, .idsIPS, .idsMLIPS, .idsAI, .idsQuantum, .idsHelix:
            return .ids
        case .networkRouter, .networkISR, .networkCloudISR, .networkEncrypted, .networkNeural, .networkHelix:
            return .network
        case .encryptionBasic, .encryptionAdvanced, .encryptionQuantum, .encryptionNeural, .encryptionHelix:
            return .encryption
        }
    }

    var displayName: String {
        switch self {
        // Firewall
        case .firewallBasic: return "Basic Firewall"
        case .firewallNGFW: return "NGFW"
        case .firewallAIML: return "AI/ML Firewall"
        case .firewallQuantum: return "Quantum Firewall"
        case .firewallNeural: return "Neural Barrier"
        case .firewallHelix: return "Helix Shield"
        // SIEM
        case .siemSyslog: return "Syslog Server"
        case .siemSIEM: return "SIEM Platform"
        case .siemSOAR: return "SOAR System"
        case .siemAI: return "AI Analytics"
        case .siemPredictive: return "Predictive SIEM"
        case .siemHelix: return "Helix Insight"
        // Endpoint
        case .endpointEDR: return "EDR Agent"
        case .endpointXDR: return "XDR Platform"
        case .endpointMXDR: return "MXDR Service"
        case .endpointAI: return "AI Protection"
        case .endpointAutonomous: return "Autonomous Response"
        case .endpointHelix: return "Helix Sentinel"
        // IDS
        case .idsBasic: return "IDS Sensor"
        case .idsIPS: return "IPS Active"
        case .idsMLIPS: return "ML/IPS"
        case .idsAI: return "AI Detection"
        case .idsQuantum: return "Quantum IDS"
        case .idsHelix: return "Helix Watcher"
        // Network
        case .networkRouter: return "Edge Router"
        case .networkISR: return "ISR Gateway"
        case .networkCloudISR: return "Cloud ISR"
        case .networkEncrypted: return "Encrypted Mesh"
        case .networkNeural: return "Neural Mesh"
        case .networkHelix: return "Helix Conduit"
        // Encryption
        case .encryptionBasic: return "AES-256"
        case .encryptionAdvanced: return "E2E Crypto"
        case .encryptionQuantum: return "Quantum Safe"
        case .encryptionNeural: return "Neural Cipher"
        case .encryptionHelix: return "Helix Vault"
        }
    }

    var shortName: String {
        switch self {
        case .firewallBasic: return "FW"
        case .firewallNGFW: return "NGFW"
        case .firewallAIML: return "AI/ML"
        case .firewallQuantum: return "Q-FW"
        case .firewallNeural: return "N-FW"
        case .firewallHelix: return "H-FW"
        case .siemSyslog: return "SYSLOG"
        case .siemSIEM: return "SIEM"
        case .siemSOAR: return "SOAR"
        case .siemAI: return "AI-SIEM"
        case .siemPredictive: return "P-SIEM"
        case .siemHelix: return "H-SIEM"
        case .endpointEDR: return "EDR"
        case .endpointXDR: return "XDR"
        case .endpointMXDR: return "MXDR"
        case .endpointAI: return "AI-EP"
        case .endpointAutonomous: return "A-EP"
        case .endpointHelix: return "H-EP"
        case .idsBasic: return "IDS"
        case .idsIPS: return "IPS"
        case .idsMLIPS: return "ML/IPS"
        case .idsAI: return "AI-IDS"
        case .idsQuantum: return "Q-IDS"
        case .idsHelix: return "H-IDS"
        case .networkRouter: return "RTR"
        case .networkISR: return "ISR"
        case .networkCloudISR: return "CISR"
        case .networkEncrypted: return "ENC"
        case .networkNeural: return "N-NET"
        case .networkHelix: return "H-NET"
        case .encryptionBasic: return "AES"
        case .encryptionAdvanced: return "E2E"
        case .encryptionQuantum: return "QSafe"
        case .encryptionNeural: return "N-ENC"
        case .encryptionHelix: return "H-ENC"
        }
    }

    var description: String {
        switch self {
        case .firewallBasic:
            return "Stateful packet inspection. Blocks known threats."
        case .firewallNGFW:
            return "Next-gen firewall with application awareness and deep packet inspection."
        case .firewallAIML:
            return "AI-powered threat detection. Adapts to zero-day attacks in real-time."
        case .firewallQuantum:
            return "Quantum-encrypted packet analysis. Unbreakable at the network edge."
        case .firewallNeural:
            return "Neural network barrier. Self-healing defense perimeter."
        case .firewallHelix:
            return "Helix consciousness integration. Threat elimination before detection."
        case .siemSyslog:
            return "Centralized log collection. Basic event correlation."
        case .siemSIEM:
            return "Security Information and Event Management. Advanced correlation rules."
        case .siemSOAR:
            return "Security Orchestration, Automation and Response. Automated playbooks."
        case .siemAI:
            return "AI-enhanced analytics. Predictive threat modeling and automated reporting."
        case .siemPredictive:
            return "Predictive analysis engine. Sees attacks before they form."
        case .siemHelix:
            return "Helix insight stream. Omniscient security awareness."
        case .endpointEDR:
            return "Endpoint Detection and Response. Monitors endpoint behavior."
        case .endpointXDR:
            return "Extended Detection. Cross-platform correlation and response."
        case .endpointMXDR:
            return "Managed XDR. 24/7 SOC monitoring and threat hunting."
        case .endpointAI:
            return "AI-driven protection. Behavioral analysis prevents unknown threats."
        case .endpointAutonomous:
            return "Autonomous response system. Zero-latency threat neutralization."
        case .endpointHelix:
            return "Helix sentinel presence. Endpoints become attack-immune."
        case .idsBasic:
            return "Intrusion Detection. Signature-based threat identification."
        case .idsIPS:
            return "Intrusion Prevention. Active blocking of detected threats."
        case .idsMLIPS:
            return "ML-enhanced IPS. Learns network patterns, detects anomalies."
        case .idsAI:
            return "AI threat recognition. Offensive maneuver prediction and counter."
        case .idsQuantum:
            return "Quantum detection matrix. Sees through any obfuscation."
        case .idsHelix:
            return "Helix watcher protocol. Malus patterns revealed in real-time."
        case .networkRouter:
            return "Basic edge routing with ACLs."
        case .networkISR:
            return "Integrated Services Router. VPN, QoS, and security services."
        case .networkCloudISR:
            return "Cloud-native ISR. Elastic scaling and global reach."
        case .networkEncrypted:
            return "Fully encrypted mesh network. Quantum-resistant key exchange."
        case .networkNeural:
            return "Neural mesh topology. Self-routing, self-healing network."
        case .networkHelix:
            return "Helix conduit network. Traffic becomes untraceable, unhackable."
        case .encryptionBasic:
            return "AES-256 encryption for data at rest."
        case .encryptionAdvanced:
            return "End-to-end encryption with perfect forward secrecy."
        case .encryptionQuantum:
            return "Post-quantum cryptography. Future-proof against quantum attacks."
        case .encryptionNeural:
            return "Neural cipher system. Encryption that thinks."
        case .encryptionHelix:
            return "Helix vault protection. Data secured by consciousness itself."
        }
    }

    /// Tier number (1-6)
    var tierNumber: Int {
        switch self {
        // Tier 1 - Basic
        case .firewallBasic, .siemSyslog, .endpointEDR, .idsBasic, .networkRouter, .encryptionBasic:
            return 1
        // Tier 2 - Advanced
        case .firewallNGFW, .siemSIEM, .endpointXDR, .idsIPS, .networkISR, .encryptionAdvanced:
            return 2
        // Tier 3 - Elite
        case .firewallAIML, .siemSOAR, .endpointMXDR, .idsMLIPS, .networkCloudISR, .encryptionQuantum:
            return 3
        // Tier 4 - AI-Powered
        case .siemAI, .endpointAI, .idsAI, .networkEncrypted:
            return 4
        // Tier 5 - Quantum/Neural
        case .firewallQuantum, .firewallNeural, .siemPredictive, .endpointAutonomous, .idsQuantum, .networkNeural, .encryptionNeural:
            return 5
        // Tier 6 - Helix Integration
        case .firewallHelix, .siemHelix, .endpointHelix, .idsHelix, .networkHelix, .encryptionHelix:
            return 6
        }
    }

    /// Cost to unlock this tier (balanced with unit costs)
    var unlockCost: Double {
        switch tierNumber {
        case 1: return 500
        case 2: return 5_000
        case 3: return 40_000
        case 4: return 120_000
        case 5: return 500_000
        case 6: return 2_000_000
        default: return 0
        }
    }

    /// Prerequisite tier (nil if this is the first in chain)
    var prerequisite: DefenseAppTier? {
        let chain = category.progressionChain
        guard let index = chain.firstIndex(of: self), index > 0 else { return nil }
        return chain[index - 1]
    }

    /// Next tier in the chain (nil if this is the last)
    var nextTier: DefenseAppTier? {
        let chain = category.progressionChain
        guard let index = chain.firstIndex(of: self), index < chain.count - 1 else { return nil }
        return chain[index + 1]
    }
}

// MARK: - Defense Application Instance

struct DefenseApplication: Identifiable, Codable {
    let id: UUID
    let tier: DefenseAppTier
    var level: Int
    var isOnline: Bool

    /// Current operational status
    var status: DefenseStatus

    init(tier: DefenseAppTier, level: Int = 1) {
        self.id = UUID()
        self.tier = tier
        self.level = level
        self.isOnline = true
        self.status = .nominal
    }

    var category: DefenseCategory { tier.category }
    var displayName: String { tier.displayName }
    var shortName: String { tier.shortName }

    // MARK: - Stats

    /// Defense points contributed - reduces attack frequency
    /// Higher tiers provide exponentially more points
    var defensePoints: Double {
        let tierMultiplier = pow(2.0, Double(tier.tierNumber - 1))  // T1=1x, T2=2x, T3=4x, T4=8x
        return Double(level) * 10.0 * tierMultiplier
    }

    /// Damage reduction percentage (0.0 - 1.0)
    /// BALANCED: Each tier has a different cap, making upgrades essential
    var damageReduction: Double {
        let tierCap: Double
        switch tier.tierNumber {
        case 1: tierCap = 0.05   // T1: max 5% per app (basic protection)
        case 2: tierCap = 0.10   // T2: max 10% per app (serious defense)
        case 3: tierCap = 0.15   // T3: max 15% per app (elite defense)
        case 4: tierCap = 0.20   // T4: max 20% per app (AI-powered)
        case 5: tierCap = 0.25   // T5: max 25% per app (quantum/neural)
        case 6: tierCap = 0.30   // T6: max 30% per app (Helix-integrated)
        default: tierCap = 0.05
        }
        // Level scaling: slower growth, tier matters more
        let levelBonus = 0.005 * Double(level)  // +0.5% per level
        let tierBase = 0.02 * Double(tier.tierNumber)  // T1=2%, T2=4%, ... T6=12%
        return min(tierCap, tierBase + levelBonus)
    }

    /// Detection bonus - multiplies intel collection from attacks
    /// SIEM/IDS categories are specialists, but all apps contribute slightly
    var detectionBonus: Double {
        let baseBonus: Double
        switch tier.category {
        case .siem:
            // SIEM is THE intel collection system
            baseBonus = 0.15 * Double(tier.tierNumber)  // T1=15%, T2=30%, T3=45%, T4=60%
        case .ids:
            // IDS helps identify patterns
            baseBonus = 0.10 * Double(tier.tierNumber)  // T1=10%, T2=20%, T3=30%, T4=40%
        case .endpoint:
            // Endpoints see attack behavior
            baseBonus = 0.05 * Double(tier.tierNumber)
        default:
            baseBonus = 0.02 * Double(tier.tierNumber)
        }
        let levelBonus = 0.01 * Double(level)  // +1% per level
        return baseBonus + levelBonus
    }

    /// Automation level - enables auto-features
    /// SOAR/AI tiers unlock: auto-repair, attack duration reduction, passive intel
    var automationLevel: Double {
        switch tier {
        case .siemSOAR:
            return 0.15 + (0.02 * Double(level))  // 15% base + 2%/level
        case .siemAI:
            return 0.30 + (0.03 * Double(level))  // 30% base + 3%/level
        case .endpointMXDR:
            return 0.20 + (0.02 * Double(level))  // Managed service
        case .endpointAI, .idsAI:
            return 0.25 + (0.025 * Double(level)) // AI-powered
        case .firewallAIML:
            return 0.10 + (0.015 * Double(level)) // Some automation
        // T5 - Advanced automation
        case .siemPredictive:
            return 0.40 + (0.035 * Double(level)) // Predictive = better automation
        case .endpointAutonomous:
            return 0.50 + (0.04 * Double(level))  // Autonomous = high automation
        case .firewallQuantum, .firewallNeural, .idsQuantum, .networkNeural, .encryptionNeural:
            return 0.35 + (0.03 * Double(level))  // Quantum/Neural systems
        // T6 - Helix automation (near-perfect)
        case .siemHelix:
            return 0.60 + (0.04 * Double(level))  // Helix insight
        case .endpointHelix:
            return 0.65 + (0.045 * Double(level)) // Helix sentinel
        case .firewallHelix, .idsHelix, .networkHelix, .encryptionHelix:
            return 0.55 + (0.04 * Double(level))  // Helix integration
        default:
            return 0
        }
    }

    /// Intel multiplier - how much this app boosts intel from reports
    /// Makes sending reports more valuable with better apps
    var intelMultiplier: Double {
        switch tier.category {
        case .siem:
            return 1.0 + (0.25 * Double(tier.tierNumber)) + (0.05 * Double(level))
        case .ids:
            return 1.0 + (0.15 * Double(tier.tierNumber)) + (0.03 * Double(level))
        default:
            return 1.0
        }
    }

    // MARK: - Upgrade

    /// Upgrade cost uses exponential scaling like other units
    var upgradeCost: Double {
        25.0 * Double(tier.tierNumber) * pow(1.18, Double(level))
    }

    /// Maximum level for this tier (same as unit tiers)
    var maxLevel: Int {
        switch tier.tierNumber {
        case 1: return 10
        case 2: return 15
        case 3: return 20
        case 4: return 25
        case 5: return 30
        case 6: return 40
        default: return 10
        }
    }

    /// Whether this app can be upgraded further
    var canUpgrade: Bool {
        level < maxLevel
    }

    /// Whether this app is at its tier's max level (required to unlock next tier)
    var isAtMaxLevel: Bool {
        level >= maxLevel
    }

    mutating func upgrade() {
        guard canUpgrade else { return }
        level += 1
    }
}

// MARK: - Defense Status

enum DefenseStatus: String, Codable {
    case nominal = "NOMINAL"
    case degraded = "DEGRADED"
    case alert = "ALERT"
    case critical = "CRITICAL"
    case offline = "OFFLINE"

    var color: String {
        switch self {
        case .nominal: return "neonGreen"
        case .degraded: return "neonAmber"
        case .alert: return "neonAmber"
        case .critical: return "neonRed"
        case .offline: return "terminalGray"
        }
    }

    var icon: String {
        switch self {
        case .nominal: return "checkmark.circle.fill"
        case .degraded: return "exclamationmark.circle.fill"
        case .alert: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.octagon.fill"
        case .offline: return "minus.circle.fill"
        }
    }
}

// MARK: - Defense Stack

/// Represents all deployed defense applications
struct DefenseStack: Codable {
    /// Deployed applications by category
    var applications: [DefenseCategory: DefenseApplication] = [:]

    /// Unlocked tiers (can deploy these)
    var unlockedTiers: Set<DefenseAppTier> = []

    /// Get deployed app for category
    func application(for category: DefenseCategory) -> DefenseApplication? {
        applications[category]
    }

    /// Check if a tier is unlocked
    func isUnlocked(_ tier: DefenseAppTier) -> Bool {
        unlockedTiers.contains(tier)
    }

    /// Check if can unlock a tier (prereq met AND current tier at max level)
    func canUnlock(_ tier: DefenseAppTier) -> Bool {
        guard !isUnlocked(tier) else { return false }

        // Check if prerequisite tier is unlocked
        if let prereq = tier.prerequisite {
            guard isUnlocked(prereq) else { return false }

            // Must have current tier at max level before unlocking next
            if let currentApp = applications[tier.category] {
                guard currentApp.isAtMaxLevel else { return false }
            }
        }
        return true
    }

    /// Get the reason why a tier can't be unlocked (for UI display)
    func tierGateReason(for tier: DefenseAppTier) -> String? {
        guard !isUnlocked(tier) else { return nil }

        if let prereq = tier.prerequisite {
            if !isUnlocked(prereq) {
                return "Unlock T\(prereq.tierNumber) first"
            }

            if let currentApp = applications[tier.category] {
                if !currentApp.isAtMaxLevel {
                    return "Max level T\(currentApp.tier.tierNumber) first (\(currentApp.level)/\(currentApp.maxLevel))"
                }
            }
        }
        return nil
    }

    /// Unlock a tier
    mutating func unlock(_ tier: DefenseAppTier) {
        unlockedTiers.insert(tier)
    }

    /// Deploy an application
    mutating func deploy(_ tier: DefenseAppTier) {
        guard isUnlocked(tier) else { return }
        applications[tier.category] = DefenseApplication(tier: tier)
    }

    /// Upgrade deployed application (returns false if at max level)
    mutating func upgrade(_ category: DefenseCategory) -> Bool {
        guard var app = applications[category] else { return false }
        guard app.canUpgrade else { return false }
        app.upgrade()
        applications[category] = app
        return true
    }

    // MARK: - Aggregate Stats

    /// Total defense points - reduces attack frequency
    /// Formula: each 100 points = 1% reduced attack chance
    var totalDefensePoints: Double {
        applications.values.reduce(0) { $0 + $1.defensePoints }
    }

    /// Attack frequency reduction from defense points (0.0 - 0.5 cap)
    var attackFrequencyReduction: Double {
        min(0.5, totalDefensePoints / 10000.0)  // 10K points = 50% reduction cap
    }

    /// Total damage reduction (capped at 80% for T5/T6)
    /// With all T1 apps maxed: ~30% max
    /// With all T2 apps: ~45% max
    /// With all T3 apps: ~55% max
    /// With mixed T3/T4: can reach 60%
    /// With T5 apps: can reach 70%
    /// With T6 apps: can reach 80% cap
    var totalDamageReduction: Double {
        let maxTier = applications.values.map { $0.tier.tierNumber }.max() ?? 1
        let cap: Double = maxTier >= 6 ? 0.80 : (maxTier >= 5 ? 0.70 : 0.60)
        return min(cap, applications.values.reduce(0) { $0 + $1.damageReduction })
    }

    /// Total detection bonus - multiplies intel collection
    var totalDetectionBonus: Double {
        applications.values.reduce(0) { $0 + $1.detectionBonus }
    }

    /// Total automation level - enables special features
    /// 0.25+ = auto-repair firewall
    /// 0.50+ = reduced attack duration
    /// 0.75+ = passive intel generation
    var totalAutomation: Double {
        min(1.0, applications.values.reduce(0) { $0 + $1.automationLevel })
    }

    /// Total intel multiplier for report rewards
    var totalIntelMultiplier: Double {
        let multiplier = applications.values.reduce(1.0) { result, app in
            result * app.intelMultiplier
        }
        return multiplier
    }

    /// Count of deployed applications
    var deployedCount: Int {
        applications.count
    }

    /// Overall stack health
    var overallStatus: DefenseStatus {
        let statuses = applications.values.map { $0.status }
        if statuses.contains(.critical) { return .critical }
        if statuses.contains(.alert) { return .alert }
        if statuses.contains(.degraded) { return .degraded }
        if statuses.isEmpty { return .offline }
        return .nominal
    }
}

// MARK: - Malus Intelligence

/// Intel report milestone rewards
enum IntelMilestone: Int, CaseIterable {
    case firstReport = 1       // First report sent
    case patternAnalyst = 3    // 3 reports - basic pattern recognition
    case signatureExpert = 5   // 5 reports - signature database
    case threatHunter = 10     // 10 reports - predictive analysis
    case malusTracker = 15     // 15 reports - tracking Malus movements
    case originDiscovery = 20  // 20 reports - discover Malus origin
    case counterIntel = 25     // 25 reports - counter-intelligence ops

    var title: String {
        switch self {
        case .firstReport: return "First Contact"
        case .patternAnalyst: return "Pattern Analyst"
        case .signatureExpert: return "Signature Expert"
        case .threatHunter: return "Threat Hunter"
        case .malusTracker: return "Malus Tracker"
        case .originDiscovery: return "Origin Discovery"
        case .counterIntel: return "Counter-Intelligence"
        }
    }

    var description: String {
        switch self {
        case .firstReport: return "Sent your first intel report to the team"
        case .patternAnalyst: return "Team can now predict basic attack patterns"
        case .signatureExpert: return "Signature database online - faster pattern ID"
        case .threatHunter: return "Predictive threat analysis active"
        case .malusTracker: return "Team is tracking Malus movements"
        case .originDiscovery: return "Discovered Malus's true origin"
        case .counterIntel: return "Counter-intelligence operations enabled"
        }
    }

    var loreFragmentId: String? {
        switch self {
        case .firstReport: return "intel_first_report"
        case .patternAnalyst: return "intel_patterns"
        case .signatureExpert: return "malus_signatures"
        case .threatHunter: return "intel_threat_hunting"
        case .malusTracker: return "malus_tracked"
        case .originDiscovery: return "malus_origin"
        case .counterIntel: return "intel_counter_ops"
        }
    }

    /// Credit reward for reaching this milestone
    var creditReward: Double {
        switch self {
        case .firstReport: return 1_000
        case .patternAnalyst: return 5_000
        case .signatureExpert: return 15_000
        case .threatHunter: return 50_000
        case .malusTracker: return 100_000
        case .originDiscovery: return 250_000
        case .counterIntel: return 500_000
        }
    }

    /// Permanent bonus unlocked
    var permanentBonus: IntelBonus {
        switch self {
        case .firstReport: return .intelCollectionRate(0.10)      // +10% intel collection
        case .patternAnalyst: return .patternIdSpeed(0.25)        // +25% faster pattern ID
        case .signatureExpert: return .intelCollectionRate(0.15)  // +15% more intel
        case .threatHunter: return .attackWarning(0.20)           // 20% chance early warning
        case .malusTracker: return .damageReduction(0.05)         // +5% damage reduction
        case .originDiscovery: return .intelCollectionRate(0.25)  // +25% more intel
        case .counterIntel: return .attackFrequencyReduction(0.10) // 10% fewer attacks
        }
    }

    /// Short name for UI display
    var name: String {
        switch self {
        case .firstReport: return "First Contact"
        case .patternAnalyst: return "Pattern Analyst"
        case .signatureExpert: return "Signature Expert"
        case .threatHunter: return "Threat Hunter"
        case .malusTracker: return "Malus Tracker"
        case .originDiscovery: return "Origin Found"
        case .counterIntel: return "Counter-Intel"
        }
    }

    /// Human-readable description of the bonus
    var bonusDescription: String {
        switch self {
        case .firstReport: return "+10% intel collection"
        case .patternAnalyst: return "+25% pattern ID speed"
        case .signatureExpert: return "+15% intel collection"
        case .threatHunter: return "20% attack early warning"
        case .malusTracker: return "+5% damage reduction"
        case .originDiscovery: return "+25% intel collection"
        case .counterIntel: return "10% fewer attacks"
        }
    }
}

enum IntelBonus {
    case intelCollectionRate(Double)
    case patternIdSpeed(Double)
    case attackWarning(Double)
    case damageReduction(Double)
    case attackFrequencyReduction(Double)
}

/// Tracks what we know about Malus
struct MalusIntelligence: Codable {
    /// Footprint data collected
    var footprintData: Double = 0

    /// Attack patterns identified
    var patternsIdentified: Int = 0

    /// Reports sent to team
    var reportsSent: Int = 0

    /// Current analysis progress (0-100)
    var analysisProgress: Double = 0

    /// Known Malus signatures
    var knownSignatures: [String] = []

    /// Whether Malus origin is discovered (unlocked at 20 reports)
    var originDiscovered: Bool = false

    /// Milestones already claimed (by rawValue)
    var claimedMilestones: Set<Int> = []

    /// Total credits earned from intel reports
    var totalIntelCredits: Double = 0

    /// Add footprint data from defended attack
    /// - Parameter detectionMultiplier: Bonus from SIEM/IDS systems
    mutating func addFootprintData(_ amount: Double, detectionMultiplier: Double = 1.0) {
        let bonusMultiplier = 1.0 + detectionMultiplier + intelCollectionBonus
        footprintData += amount * bonusMultiplier
        // Update analysis progress (scales with total footprint)
        analysisProgress = min(100, (footprintData / 500.0) * 100.0)
    }

    /// Identify a new pattern
    /// - Parameter patternSpeedBonus: Bonus from milestone unlocks
    mutating func identifyPattern(_ pattern: String, patternSpeedBonus: Double = 0) {
        if !knownSignatures.contains(pattern) {
            knownSignatures.append(pattern)
            patternsIdentified += 1
            // Bonus patterns from speed bonus (chance to identify variant)
            if patternSpeedBonus > 0 && Double.random(in: 0...1) < patternSpeedBonus {
                let variant = "\(pattern)_variant"
                if !knownSignatures.contains(variant) {
                    knownSignatures.append(variant)
                    patternsIdentified += 1
                }
            }
        }
    }

    /// Check if ready to send report
    var canSendReport: Bool {
        footprintData >= reportCost
    }

    /// Cost to send next report (scales slightly with reports sent)
    var reportCost: Double {
        let baseCost = 200.0
        let scaling = 1.0 + (Double(reportsSent) * 0.05)  // +5% per report sent
        return baseCost * scaling
    }

    /// Send report to team (costs footprint data, returns reward info)
    /// - Parameter intelMultiplier: Bonus from SIEM systems
    mutating func sendReport(intelMultiplier: Double = 1.0) -> IntelReportResult? {
        guard canSendReport else { return nil }

        let cost = reportCost
        footprintData -= cost
        reportsSent += 1

        // Base credit reward scales with patterns known
        let baseReward = 100.0 + (Double(patternsIdentified) * 10.0)
        let multipliedReward = baseReward * intelMultiplier

        // Check for milestone
        var unlockedMilestone: IntelMilestone?
        for milestone in IntelMilestone.allCases {
            if reportsSent >= milestone.rawValue && !claimedMilestones.contains(milestone.rawValue) {
                claimedMilestones.insert(milestone.rawValue)
                unlockedMilestone = milestone
                if milestone == .originDiscovery {
                    originDiscovered = true
                }
                break  // Only one milestone per report
            }
        }

        let milestoneReward = unlockedMilestone?.creditReward ?? 0
        let totalReward = multipliedReward + milestoneReward
        totalIntelCredits += totalReward

        return IntelReportResult(
            creditsEarned: totalReward,
            baseCredits: multipliedReward,
            milestoneCredits: milestoneReward,
            milestone: unlockedMilestone,
            reportNumber: reportsSent
        )
    }

    /// Get next unclaimed milestone
    var nextMilestone: IntelMilestone? {
        for milestone in IntelMilestone.allCases {
            if !claimedMilestones.contains(milestone.rawValue) {
                return milestone
            }
        }
        return nil
    }

    /// Reports needed for next milestone
    var reportsToNextMilestone: Int {
        guard let next = nextMilestone else { return 0 }
        return max(0, next.rawValue - reportsSent)
    }

    // MARK: - Cumulative Bonuses from Milestones

    /// Total intel collection rate bonus from milestones
    var intelCollectionBonus: Double {
        var bonus = 0.0
        for milestone in IntelMilestone.allCases {
            guard claimedMilestones.contains(milestone.rawValue) else { continue }
            if case .intelCollectionRate(let rate) = milestone.permanentBonus {
                bonus += rate
            }
        }
        return bonus
    }

    /// Pattern identification speed bonus
    var patternIdSpeedBonus: Double {
        var bonus = 0.0
        for milestone in IntelMilestone.allCases {
            guard claimedMilestones.contains(milestone.rawValue) else { continue }
            if case .patternIdSpeed(let speed) = milestone.permanentBonus {
                bonus += speed
            }
        }
        return bonus
    }

    /// Early attack warning chance
    var attackWarningChance: Double {
        var bonus = 0.0
        for milestone in IntelMilestone.allCases {
            guard claimedMilestones.contains(milestone.rawValue) else { continue }
            if case .attackWarning(let chance) = milestone.permanentBonus {
                bonus += chance
            }
        }
        return bonus
    }

    /// Bonus damage reduction from intel
    var damageReductionBonus: Double {
        var bonus = 0.0
        for milestone in IntelMilestone.allCases {
            guard claimedMilestones.contains(milestone.rawValue) else { continue }
            if case .damageReduction(let reduction) = milestone.permanentBonus {
                bonus += reduction
            }
        }
        return bonus
    }

    /// Attack frequency reduction from counter-intel
    var attackFrequencyReductionBonus: Double {
        var bonus = 0.0
        for milestone in IntelMilestone.allCases {
            guard claimedMilestones.contains(milestone.rawValue) else { continue }
            if case .attackFrequencyReduction(let reduction) = milestone.permanentBonus {
                bonus += reduction
            }
        }
        return bonus
    }
}

/// Result of sending an intel report
struct IntelReportResult {
    let creditsEarned: Double
    let baseCredits: Double
    let milestoneCredits: Double
    let milestone: IntelMilestone?
    let reportNumber: Int

    var hasMilestone: Bool { milestone != nil }
}
