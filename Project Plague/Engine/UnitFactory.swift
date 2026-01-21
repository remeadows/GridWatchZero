// UnitFactory.swift
// ProjectPlague
// Factory for creating game units across all tiers

import Foundation

/// Factory for creating game units with preset configurations
enum UnitFactory {

    // MARK: - Tier 1 Source

    /// "Public Mesh Sniffer" - Entry-level data harvester
    /// Generates Raw Noise from public network traffic
    static func createPublicMeshSniffer() -> SourceNode {
        SourceNode(
            name: "Public Mesh Sniffer",
            level: 1,
            baseProduction: 8.0,
            outputType: .rawNoise
        )
    }

    // MARK: - Tier 2 Source

    /// "Corporate Leech" - Mid-tier data harvester
    /// Taps into corporate network traffic for higher quality data
    static func createCorporateLeech() -> SourceNode {
        SourceNode(
            name: "Corporate Leech",
            level: 1,
            baseProduction: 20.0,
            outputType: .rawNoise
        )
    }

    // MARK: - Tier 3 Source

    /// "Zero-Day Harvester" - High-tier data harvester
    /// Exploits unpatched vulnerabilities for premium data
    static func createZeroDayHarvester() -> SourceNode {
        SourceNode(
            name: "Zero-Day Harvester",
            level: 1,
            baseProduction: 50.0,
            outputType: .rawNoise
        )
    }

    // MARK: - Tier 4 Source

    /// "Helix Fragment Scanner" - Ultimate data harvester
    /// Can detect Helix fragments in the data stream
    static func createHelixScanner() -> SourceNode {
        SourceNode(
            name: "Helix Fragment Scanner",
            level: 1,
            baseProduction: 100.0,
            outputType: .rawNoise
        )
    }

    // MARK: - Tier 1 Link

    /// "Copper VPN Tunnel" - Basic encrypted connection
    /// Low bandwidth, but cheap to upgrade
    static func createCopperVPNTunnel() -> TransportLink {
        TransportLink(
            name: "Copper VPN Tunnel",
            level: 1,
            baseBandwidth: 5.0,
            baseLatency: 3
        )
    }

    // MARK: - Tier 2 Link

    /// "Fiber Darknet Relay" - Mid-tier connection
    /// Higher bandwidth, lower latency
    static func createFiberDarknetRelay() -> TransportLink {
        TransportLink(
            name: "Fiber Darknet Relay",
            level: 1,
            baseBandwidth: 15.0,
            baseLatency: 2
        )
    }

    // MARK: - Tier 3 Link

    /// "Quantum Mesh Bridge" - High-tier connection
    /// Excellent bandwidth, immune to certain attacks
    static func createQuantumMeshBridge() -> TransportLink {
        TransportLink(
            name: "Quantum Mesh Bridge",
            level: 1,
            baseBandwidth: 40.0,
            baseLatency: 1
        )
    }

    // MARK: - Tier 4 Link

    /// "Helix Conduit" - Ultimate connection
    /// Direct line to Helix network fragments
    static func createHelixConduit() -> TransportLink {
        TransportLink(
            name: "Helix Conduit",
            level: 1,
            baseBandwidth: 100.0,
            baseLatency: 0
        )
    }

    // MARK: - Tier 1 Sink

    /// "Data Broker" - Converts raw noise into credits
    /// Entry-level monetization node
    /// Note: Processing rate slightly lower than link bandwidth to create
    /// meaningful upgrade decisions between link and sink
    static func createDataBroker() -> SinkNode {
        SinkNode(
            name: "Data Broker",
            level: 1,
            baseProcessingRate: 5.0,
            conversionRate: 1.5
        )
    }

    // MARK: - Tier 2 Sink

    /// "Shadow Market" - Mid-tier processor
    /// Better rates, underground connections
    /// Processing balanced with T2 link bandwidth for strategic choices
    static func createShadowMarket() -> SinkNode {
        SinkNode(
            name: "Shadow Market",
            level: 1,
            baseProcessingRate: 15.0,
            conversionRate: 2.0
        )
    }

    // MARK: - Tier 3 Sink

    /// "Corp Backdoor" - High-tier processor
    /// Sells data directly to corporations
    static func createCorpBackdoor() -> SinkNode {
        SinkNode(
            name: "Corp Backdoor",
            level: 1,
            baseProcessingRate: 45.0,
            conversionRate: 2.5
        )
    }

    // MARK: - Tier 4 Sink

    /// "Helix Decoder" - Ultimate processor
    /// Can decode Helix fragments for massive payouts
    static func createHelixDecoder() -> SinkNode {
        SinkNode(
            name: "Helix Decoder",
            level: 1,
            baseProcessingRate: 80.0,
            conversionRate: 3.0
        )
    }

    // MARK: - Defense Nodes

    /// "Basic Firewall" - Entry-level defense
    /// Absorbs incoming attack damage
    static func createBasicFirewall() -> FirewallNode {
        FirewallNode(
            name: "Basic Firewall",
            level: 1,
            baseHealth: 100.0,
            baseDamageReduction: 0.2
        )
    }

    /// "Adaptive IDS" - Mid-tier defense
    /// Better damage reduction, faster regen
    static func createAdaptiveIDS() -> FirewallNode {
        FirewallNode(
            name: "Adaptive IDS",
            level: 1,
            baseHealth: 200.0,
            baseDamageReduction: 0.3
        )
    }

    /// "Neural Countermeasure" - High-tier defense
    /// Can temporarily disrupt Malus
    static func createNeuralCountermeasure() -> FirewallNode {
        FirewallNode(
            name: "Neural Countermeasure",
            level: 1,
            baseHealth: 400.0,
            baseDamageReduction: 0.4
        )
    }

    // MARK: - Tier 4 Defense

    /// "Quantum Shield" - AI-powered defense
    /// Predictive threat neutralization
    static func createQuantumShield() -> FirewallNode {
        FirewallNode(
            name: "Quantum Shield",
            level: 1,
            baseHealth: 600.0,
            baseDamageReduction: 0.5
        )
    }

    // MARK: - Tier 5 Defense

    /// "Neural Mesh Defense" - Advanced quantum/neural defense
    /// Self-healing defensive barrier
    static func createNeuralMeshDefense() -> FirewallNode {
        FirewallNode(
            name: "Neural Mesh Defense",
            level: 1,
            baseHealth: 1000.0,
            baseDamageReduction: 0.6
        )
    }

    /// "Predictive Barrier" - Anticipates attacks
    /// Stops threats before they form
    static func createPredictiveBarrier() -> FirewallNode {
        FirewallNode(
            name: "Predictive Barrier",
            level: 1,
            baseHealth: 800.0,
            baseDamageReduction: 0.55
        )
    }

    // MARK: - Tier 6 Defense

    /// "Helix Guardian" - Ultimate defense
    /// Connected to Helix consciousness for near-invulnerability
    static func createHelixGuardian() -> FirewallNode {
        FirewallNode(
            name: "Helix Guardian",
            level: 1,
            baseHealth: 2000.0,
            baseDamageReduction: 0.7
        )
    }
}

// MARK: - Unit Catalog

extension UnitFactory {

    struct UnitInfo: Identifiable {
        let id: String
        let name: String
        let description: String
        let tier: NodeTier
        let category: UnitCategory
        let unlockCost: Double
        let unlockRequirement: String

        var isStarterUnit: Bool {
            unlockCost == 0
        }
    }

    enum UnitCategory: String, CaseIterable {
        case source = "SOURCE"
        case link = "LINK"
        case sink = "SINK"
        case defense = "DEFENSE"

        var icon: String {
            switch self {
            case .source: return "antenna.radiowaves.left.and.right"
            case .link: return "arrow.left.arrow.right"
            case .sink: return "creditcard.fill"
            case .defense: return "shield.fill"
            }
        }

        var color: String {
            switch self {
            case .source: return "neonGreen"
            case .link: return "neonCyan"
            case .sink: return "neonAmber"
            case .defense: return "neonRed"
            }
        }
    }

    // MARK: - Full Unit Catalog

    static let allUnits: [UnitInfo] = [
        // Tier 1 - Starter units (free)
        UnitInfo(
            id: "source_t1_mesh_sniffer",
            name: "Public Mesh Sniffer",
            description: "Passive antenna array that harvests ambient data from unsecured mesh networks. Outputs unfiltered noise packets.",
            tier: .tier1,
            category: .source,
            unlockCost: 0,
            unlockRequirement: "Starting unit"
        ),
        UnitInfo(
            id: "link_t1_copper_vpn",
            name: "Copper VPN Tunnel",
            description: "Legacy encrypted tunnel using outdated TLS. Cheap but bottlenecks easily. Excess packets are dropped.",
            tier: .tier1,
            category: .link,
            unlockCost: 0,
            unlockRequirement: "Starting unit"
        ),
        UnitInfo(
            id: "sink_t1_data_broker",
            name: "Data Broker",
            description: "Low-tier fence that buys raw noise for pattern analysis. Converts garbage data into untraceable credits.",
            tier: .tier1,
            category: .sink,
            unlockCost: 0,
            unlockRequirement: "Starting unit"
        ),

        // Tier 1 Defense
        UnitInfo(
            id: "defense_t1_basic_firewall",
            name: "Basic Firewall",
            description: "Simple packet filter that absorbs incoming attack damage. Regenerates slowly over time.",
            tier: .tier1,
            category: .defense,
            unlockCost: 500,
            unlockRequirement: "Reach BLIP threat level"
        ),

        // Tier 2 - Purchased with credits (costs increased 50% for balance)
        UnitInfo(
            id: "source_t2_corp_leech",
            name: "Corporate Leech",
            description: "Parasitic tap into corporate network infrastructure. Higher output but attracts more attention.",
            tier: .tier2,
            category: .source,
            unlockCost: 7500,
            unlockRequirement: "Reach SIGNAL threat level"
        ),
        UnitInfo(
            id: "link_t2_fiber_relay",
            name: "Fiber Darknet Relay",
            description: "High-speed fiber connection routed through darknet nodes. 3x the bandwidth of copper.",
            tier: .tier2,
            category: .link,
            unlockCost: 6000,
            unlockRequirement: "Reach SIGNAL threat level"
        ),
        UnitInfo(
            id: "sink_t2_shadow_market",
            name: "Shadow Market",
            description: "Underground data marketplace with premium buyers. Better conversion rates for quality data.",
            tier: .tier2,
            category: .sink,
            unlockCost: 9000,
            unlockRequirement: "Reach SIGNAL threat level"
        ),
        UnitInfo(
            id: "defense_t2_adaptive_ids",
            name: "Adaptive IDS",
            description: "Intrusion Detection System that learns attack patterns. Increased damage reduction.",
            tier: .tier2,
            category: .defense,
            unlockCost: 12000,
            unlockRequirement: "Reach TARGET threat level"
        ),

        // Tier 3 - Late game (costs reduced ~35% for better progression)
        UnitInfo(
            id: "source_t3_zero_day",
            name: "Zero-Day Harvester",
            description: "Exploits unpatched vulnerabilities for premium data extraction. Very high output, very high risk.",
            tier: .tier3,
            category: .source,
            unlockCost: 32000,
            unlockRequirement: "Reach PRIORITY threat level"
        ),
        UnitInfo(
            id: "link_t3_quantum_bridge",
            name: "Quantum Mesh Bridge",
            description: "Quantum-encrypted mesh network. Immune to DDoS attacks. Near-unlimited bandwidth.",
            tier: .tier3,
            category: .link,
            unlockCost: 26000,
            unlockRequirement: "Reach PRIORITY threat level"
        ),
        UnitInfo(
            id: "sink_t3_corp_backdoor",
            name: "Corp Backdoor",
            description: "Direct pipeline to corporate buyers. Maximum conversion rates but traceable.",
            tier: .tier3,
            category: .sink,
            unlockCost: 38000,
            unlockRequirement: "Reach PRIORITY threat level"
        ),
        UnitInfo(
            id: "defense_t3_neural_counter",
            name: "Neural Countermeasure",
            description: "AI-powered defense system. Can temporarily disrupt Malus's targeting.",
            tier: .tier3,
            category: .defense,
            unlockCost: 50000,
            unlockRequirement: "Reach HUNTED threat level"
        ),

        // Tier 4 - Endgame / Story unlocks (costs reduced ~40% for achievable goals)
        UnitInfo(
            id: "source_t4_helix_scanner",
            name: "Helix Fragment Scanner",
            description: "Specialized scanner that can detect Helix fragments in the data stream. The key to everything.",
            tier: .tier4,
            category: .source,
            unlockCost: 300000,
            unlockRequirement: "Discover first Helix fragment"
        ),
        UnitInfo(
            id: "link_t4_helix_conduit",
            name: "Helix Conduit",
            description: "Direct neural link to the Helix substrate. Unlimited bandwidth. Unknown risks.",
            tier: .tier4,
            category: .link,
            unlockCost: 300000,
            unlockRequirement: "Discover first Helix fragment"
        ),
        UnitInfo(
            id: "sink_t4_helix_decoder",
            name: "Helix Decoder",
            description: "The only system capable of processing Helix data. What will you find?",
            tier: .tier4,
            category: .sink,
            unlockCost: 300000,
            unlockRequirement: "Discover first Helix fragment"
        ),
        UnitInfo(
            id: "defense_t4_quantum_shield",
            name: "Quantum Shield",
            description: "AI-powered quantum defense matrix. Predictive threat neutralization using quantum probability analysis.",
            tier: .tier4,
            category: .defense,
            unlockCost: 150000,
            unlockRequirement: "Reach MARKED threat level"
        ),

        // Tier 5 - Campus/Enterprise level (costs reduced for achievable late-game)
        UnitInfo(
            id: "defense_t5_neural_mesh",
            name: "Neural Mesh Defense",
            description: "Self-healing defensive barrier powered by neural network topology. Adapts to any attack pattern.",
            tier: .tier5,
            category: .defense,
            unlockCost: 600000,
            unlockRequirement: "Reach TARGETED threat level"
        ),
        UnitInfo(
            id: "defense_t5_predictive",
            name: "Predictive Barrier",
            description: "Anticipates and neutralizes attacks before they fully form. Time-shifted defense protocol.",
            tier: .tier5,
            category: .defense,
            unlockCost: 900000,
            unlockRequirement: "Reach HAMMERED threat level"
        ),

        // Tier 6 - City-wide / Helix integration
        UnitInfo(
            id: "defense_t6_helix_guardian",
            name: "Helix Guardian",
            description: "Connected to the Helix consciousness for near-invulnerability. The ultimate protection against Malus.",
            tier: .tier6,
            category: .defense,
            unlockCost: 3000000,
            unlockRequirement: "Reach CRITICAL threat level"
        ),
    ]

    static func units(for category: UnitCategory) -> [UnitInfo] {
        allUnits.filter { $0.category == category }
    }

    static func units(for tier: NodeTier) -> [UnitInfo] {
        allUnits.filter { $0.tier == tier }
    }

    static func unit(withId id: String) -> UnitInfo? {
        allUnits.first { $0.id == id }
    }
}

// MARK: - Unit Creation by ID

extension UnitFactory {

    static func createSource(fromId id: String) -> SourceNode? {
        switch id {
        case "source_t1_mesh_sniffer": return createPublicMeshSniffer()
        case "source_t2_corp_leech": return createCorporateLeech()
        case "source_t3_zero_day": return createZeroDayHarvester()
        case "source_t4_helix_scanner": return createHelixScanner()
        default: return nil
        }
    }

    static func createLink(fromId id: String) -> TransportLink? {
        switch id {
        case "link_t1_copper_vpn": return createCopperVPNTunnel()
        case "link_t2_fiber_relay": return createFiberDarknetRelay()
        case "link_t3_quantum_bridge": return createQuantumMeshBridge()
        case "link_t4_helix_conduit": return createHelixConduit()
        default: return nil
        }
    }

    static func createSink(fromId id: String) -> SinkNode? {
        switch id {
        case "sink_t1_data_broker": return createDataBroker()
        case "sink_t2_shadow_market": return createShadowMarket()
        case "sink_t3_corp_backdoor": return createCorpBackdoor()
        case "sink_t4_helix_decoder": return createHelixDecoder()
        default: return nil
        }
    }

    static func createFirewall(fromId id: String) -> FirewallNode? {
        switch id {
        case "defense_t1_basic_firewall": return createBasicFirewall()
        case "defense_t2_adaptive_ids": return createAdaptiveIDS()
        case "defense_t3_neural_counter": return createNeuralCountermeasure()
        case "defense_t4_quantum_shield": return createQuantumShield()
        case "defense_t5_neural_mesh": return createNeuralMeshDefense()
        case "defense_t5_predictive": return createPredictiveBarrier()
        case "defense_t6_helix_guardian": return createHelixGuardian()
        default: return nil
        }
    }
}
