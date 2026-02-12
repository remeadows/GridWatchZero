// GameEngine.swift
// GridWatchZero
// Core game loop and tick processing

import Foundation
import Combine
import Observation

// MARK: - Tick Statistics

/// Stats from a single tick for UI display
struct TickStats: Equatable {
    var dataGenerated: Double = 0
    var dataTransferred: Double = 0
    var dataDropped: Double = 0
    var creditsEarned: Double = 0
    var creditsDrained: Double = 0
    var damageAbsorbed: Double = 0
    var bufferUtilization: Double = 0

    var dropRate: Double {
        guard dataGenerated > 0 else { return 0 }
        return dataDropped / dataGenerated
    }

    var netCredits: Double {
        creditsEarned - creditsDrained
    }
}

// MARK: - Game Event

enum GameEvent: Equatable {
    case attackStarted(AttackType)
    case attackEnded(AttackType, survived: Bool)
    case threatLevelIncreased(ThreatLevel)
    case nodeDisabled(String)
    case malusMessage(String)
    case milestone(String)
    case unitUnlocked(String)
    case firewallDamaged(Double)
    case firewallDestroyed
    case randomEvent(String, String)  // title, message
    case loreUnlocked(String)  // fragment title
    case milestoneCompleted(String)  // milestone title
    case earlyWarning(AttackType, Int, Double)  // predicted type, ticks until attack, accuracy %
    case batchUploadStarted(Int)   // total reports in batch
    case batchUploadComplete(Int, Double)  // reports sent, batch credits earned

    var isAlert: Bool {
        switch self {
        case .attackStarted, .nodeDisabled, .malusMessage, .firewallDestroyed, .earlyWarning:
            return true
        default:
            return false
        }
    }

    var isPositive: Bool {
        switch self {
        case .milestone, .unitUnlocked, .loreUnlocked, .milestoneCompleted:
            return true
        case .randomEvent(let title, _):
            return !title.contains("GLITCH") && !title.contains("CRASH") && !title.contains("CORRUPTION") && !title.contains("CONGESTION")
        default:
            return false
        }
    }
}

// MARK: - Offline Progress

/// Represents earnings calculated while the player was away
struct OfflineProgress: Equatable {
    let secondsAway: Int
    let ticksSimulated: Int
    let creditsEarned: Double
    let dataProcessed: Double

    var formattedTimeAway: String {
        if secondsAway < 60 {
            return "\(secondsAway) seconds"
        } else if secondsAway < 3600 {
            let minutes = secondsAway / 60
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        } else if secondsAway < 86400 {
            let hours = secondsAway / 3600
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            let days = secondsAway / 86400
            return "\(days) day\(days == 1 ? "" : "s")"
        }
    }
}

// MARK: - Unlock State

struct UnlockState: Codable {
    var unlockedUnitIds: Set<String> = [
        "source_t1_mesh_sniffer",
        "link_t1_copper_vpn",
        "sink_t1_data_broker"
    ]

    func isUnlocked(_ unitId: String) -> Bool {
        unlockedUnitIds.contains(unitId)
    }

    mutating func unlock(_ unitId: String) {
        unlockedUnitIds.insert(unitId)
    }
}

// MARK: - Prestige State

/// Tracks prestige ("Network Wipe") progress and bonuses
struct PrestigeState: Codable {
    /// Number of times the player has prestiged
    var prestigeLevel: Int = 0

    /// Total helix cores earned across all runs
    var totalHelixCores: Int = 0

    /// Currently available helix cores to spend
    var availableHelixCores: Int = 0

    /// Permanent production multiplier from prestige
    var productionMultiplier: Double {
        1.0 + (Double(prestigeLevel) * 0.1) + (Double(totalHelixCores) * 0.05)
    }

    /// Permanent credit multiplier from prestige
    var creditMultiplier: Double {
        1.0 + (Double(prestigeLevel) * 0.15)
    }

    /// Credits required for next prestige
    static func creditsRequiredForPrestige(level: Int) -> Double {
        // Exponential scaling: 150K, 750K, 3.75M, 18.75M...
        // Increased base from 100K to 150K to encourage T3 exploration
        return 150_000 * pow(5.0, Double(level))
    }

    /// Helix cores earned from a prestige with given total credits
    static func helixCoresEarned(fromCredits credits: Double, atLevel level: Int) -> Int {
        let required = creditsRequiredForPrestige(level: level)
        let ratio = credits / required
        // Base 1 core + 1 per 2x the requirement
        return max(1, Int(ratio / 2) + 1)
    }
}

// MARK: - Game State

/// Complete game state for saving/loading
struct GameState: Codable {
    var resources: PlayerResources
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var firewall: FirewallNode?
    var defenseStack: DefenseStack
    var malusIntel: MalusIntelligence
    var currentTick: Int
    var totalPlayTime: TimeInterval
    var threatState: ThreatState
    var unlockState: UnlockState
    var loreState: LoreState
    var milestoneState: MilestoneState
    var prestigeState: PrestigeState
    var lastSaveTimestamp: Date?  // For offline progress calculation
    var criticalAlarmAcknowledged: Bool  // Whether user dismissed critical alarm

    static func newGame(prestigeState: PrestigeState = PrestigeState()) -> GameState {
        var loreState = LoreState()
        // Unlock starter lore fragments
        for fragment in LoreDatabase.starterFragments() {
            loreState.unlock(fragment.id)
        }

        return GameState(
            resources: PlayerResources(),
            source: UnitFactory.createPublicMeshSniffer(),
            link: UnitFactory.createCopperVPNTunnel(),
            sink: UnitFactory.createDataBroker(),
            firewall: nil,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            currentTick: 0,
            totalPlayTime: 0,
            threatState: ThreatState(),
            unlockState: UnlockState(),
            loreState: loreState,
            milestoneState: MilestoneState(),
            prestigeState: prestigeState,
            criticalAlarmAcknowledged: false
        )
    }
}

// MARK: - Game Engine

@MainActor
@Observable
final class GameEngine {
    // MARK: - Published State

    var resources: PlayerResources
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var firewall: FirewallNode?

    var currentTick: Int = 0
    var lastTickStats: TickStats = TickStats()
    var isRunning: Bool = false

    // MARK: - Threat System

    var threatState: ThreatState = ThreatState()
    var activeAttack: Attack? = nil
    var lastEvent: GameEvent? = nil

    // MARK: - Unlock System

    var unlockState: UnlockState = UnlockState()

    // MARK: - Event & Story Systems

    var loreState: LoreState = LoreState()
    var milestoneState: MilestoneState = MilestoneState()
    var activeRandomEvent: RandomEvent? = nil
    var offlineProgress: OfflineProgress? = nil

    // MARK: - Prestige System

    var prestigeState: PrestigeState = PrestigeState()

    // MARK: - Defense Stack & Malus Intel

    var defenseStack: DefenseStack = DefenseStack()
    var malusIntel: MalusIntelligence = MalusIntelligence()
    var showCriticalAlarm: Bool = false
    var criticalAlarmAcknowledged: Bool = false

    // Sprint D: Early Warning System
    var activeEarlyWarning: EarlyWarning? = nil

    // Sprint D: Batch Upload State
    var batchUploadState: BatchUploadState? = nil

    // Sprint E: Link Latency Buffer (transient, not persisted)
    var latencyBuffer: [(amount: Double, ticksRemaining: Int)] = []

    /// Total data buffered in the latency buffer (for view display)
    var totalBufferedData: Double {
        latencyBuffer.reduce(0.0) { $0 + $1.amount }
    }

    // MARK: - Cached Defense Totals (recomputed each tick, not persisted)

    private(set) var cachedDefenseTotals = DefenseTotals()

    // MARK: - Event Multipliers (from random events)

    var sourceMultiplier: Double = 1.0
    var bandwidthMultiplier: Double = 1.0
    var creditMultiplier: Double = 1.0
    
    // MARK: - Debug Multiplier (for balance testing)
    
    /// DEBUG ONLY: Temporary multiplier for playtesting monetization balance
    /// Set to 2.0 to test "Grid Watch Pro" permanent multiplier
    /// Set to 1.5 to test rewarded ad temporary boost
    /// IMPORTANT: Remove before production release
    #if DEBUG
    var debugCreditMultiplier: Double = 1.0
    #endif

    // MARK: - Temporary Debuffs (from attacks)

    var bandwidthDebuff: Double = 0  // 0.0 - 1.0 reduction
    var processingDebuff: Double = 0  // 0.0 - 1.0 sink processing reduction

    // MARK: - Cumulative Stats

    var totalDataGenerated: Double = 0
    var totalDataTransferred: Double = 0
    var totalDataDropped: Double = 0

    // MARK: - Campaign Mode

    var levelConfiguration: LevelConfiguration?
    var levelStartTick: Int = 0
    var levelCreditsEarned: Double = 0
    var levelAttacksSurvived: Int = 0
    var levelDamageBlocked: Double = 0

    /// Callback when level is completed
    var onLevelComplete: ((LevelCompletionStats) -> Void)?

    /// Callback when level is failed
    var onLevelFailed: ((FailureReason) -> Void)?

    /// Callback when a unit is unlocked (for campaign persistence)
    var onUnitUnlocked: ((String) -> Void)?

    /// Whether we're in campaign mode
    var isInCampaignMode: Bool { levelConfiguration != nil }

    /// Maximum tier available in current level (6 if sandbox/endless mode)
    var maxTierAvailable: Int {
        levelConfiguration?.level.availableTiers.max() ?? 6
    }

    // MARK: - Private

    private var tickTimer: AnyCancellable?
    private let tickInterval: TimeInterval = 1.0
    var totalPlayTime: TimeInterval = 0
    var rng: RandomNumberGenerator = SystemRandomNumberGenerator()

    // MARK: - Persistence

    var saveKey: String { SaveVersion.current.saveKey }

    // MARK: - Init

    init() {
        // Start with default new game state
        let state = GameState.newGame()
        self.resources = state.resources
        self.source = state.source
        self.link = state.link
        self.sink = state.sink
        self.firewall = state.firewall
        self.defenseStack = state.defenseStack
        self.malusIntel = state.malusIntel
        self.currentTick = state.currentTick
        self.totalPlayTime = state.totalPlayTime
        self.threatState = state.threatState
        self.unlockState = state.unlockState
        self.loreState = state.loreState
        self.milestoneState = state.milestoneState
        self.prestigeState = state.prestigeState
        self.criticalAlarmAcknowledged = state.criticalAlarmAcknowledged

        // Load saved game (with migration support)
        loadGame()
    }

    // MARK: - Game Loop Control

    func start() {
        guard !isRunning else { return }
        isRunning = true

        tickTimer = Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.processTick()
            }
    }

    func pause() {
        isRunning = false
        tickTimer?.cancel()
        tickTimer = nil
        if isInCampaignMode {
            saveCampaignCheckpoint()
        }
        saveGame()
    }

    func toggle() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    // MARK: - Core Tick Processing (NetOps Math)

    func processTick() {
        currentTick += 1
        totalPlayTime += tickInterval

        var stats = TickStats()

        // Cache defense totals once per tick (avoids repeated .reduce traversals)
        cachedDefenseTotals = defenseStack.computeTotals()

        // === DEFENSE PHASE ===
        firewall?.regenerate()

        // === THREAT PHASE ===
        processThreats(&stats)

        // === RANDOM EVENT PHASE ===
        processRandomEvents()

        // === BATCH UPLOAD PHASE (Sprint D) ===
        var batchBandwidthCost: Double = 0
        if var upload = batchUploadState {
            // Cancel batch upload if an attack starts
            if activeAttack != nil {
                batchUploadState = nil
            } else {
                upload.ticksElapsed += 1
                // Calculate reports to send this tick (spread evenly across latency)
                let reportsPerTick = max(1, upload.totalReports / max(1, upload.latencyTicks))
                let reportsThisTick = min(reportsPerTick, upload.totalReports - upload.reportsSent)

                var batchCreditsEarned: Double = 0
                for _ in 0..<reportsThisTick {
                    if malusIntel.canSendReport {
                        let intelMultiplier = defenseStack.totalIntelMultiplier
                        if let result = malusIntel.sendReport(intelMultiplier: intelMultiplier) {
                            resources.addCredits(result.creditsEarned)
                            batchCreditsEarned += result.creditsEarned
                            upload.reportsSent += 1
                        }
                    } else {
                        break  // No more footprint data
                    }
                }

                batchBandwidthCost = upload.bandwidthCost

                if upload.isComplete || upload.ticksElapsed >= upload.latencyTicks || !malusIntel.canSendReport {
                    // Upload finished
                    emitEvent(.batchUploadComplete(upload.reportsSent, batchCreditsEarned))
                    AudioManager.shared.playSound(.milestone)
                    batchUploadState = nil
                } else {
                    batchUploadState = upload
                }
            }
        }

        // === PRODUCTION PHASE ===

        // Sprint C: Compute certification multiplier once per tick
        let certMultiplier = CertificateManager.shared.totalCertificationMultiplier

        // Shared bandwidth calculation (used by both buffer drain and direct transfer)
        let effectiveBandwidth = link.bandwidth * (1.0 - bandwidthDebuff) * (1.0 - batchBandwidthCost) * bandwidthMultiplier

        // Sprint E: Step 0 — Drain latency buffer (matured entries transfer this tick)
        var bufferTransferred: Double = 0
        var bufferDropped: Double = 0
        if !latencyBuffer.isEmpty {
            // Decrement all countdowns
            for i in latencyBuffer.indices {
                latencyBuffer[i].ticksRemaining -= 1
            }
            // Collect matured entries (ticksRemaining <= 0)
            let maturedAmount = latencyBuffer.filter { $0.ticksRemaining <= 0 }.reduce(0.0) { $0 + $1.amount }
            latencyBuffer.removeAll { $0.ticksRemaining <= 0 }

            // Transfer matured data through link
            if maturedAmount > 0 {
                let sinkCanAcceptForBuffer = sink.bufferRemaining
                let bufferPacket = DataPacket(type: .rawNoise, amount: maturedAmount, createdAtTick: currentTick)
                var bufferLink = link
                let (bt, bd) = bufferLink.transfer(bufferPacket, maxAcceptable: min(sinkCanAcceptForBuffer, effectiveBandwidth))
                bufferTransferred = bt
                bufferDropped = bd
                _ = sink.receiveData(bt)
            }
        }

        // Step 1: Source generates data (apply event + prestige + cert multipliers)
        var packet = source.produce(atTick: currentTick)
        packet.amount *= sourceMultiplier * prestigeState.productionMultiplier * certMultiplier
        stats.dataGenerated = packet.amount
        totalDataGenerated += packet.amount

        // Sprint E: Step 2 — Route data through latency buffer or direct transfer
        var directTransferred: Double = 0
        var directDropped: Double = 0

        if link.latency > 0 {
            // Buffer the data — it will transfer after latency ticks
            latencyBuffer.append((amount: packet.amount, ticksRemaining: link.latency))
        } else {
            // Instant transfer (T4+ links, or leveled-up links that reach 0 latency)
            let sinkCanAccept = sink.bufferRemaining - bufferTransferred
            var modifiedLink = link
            let (dt, dd) = modifiedLink.transfer(packet, maxAcceptable: min(max(0, sinkCanAccept), effectiveBandwidth))
            directTransferred = dt
            directDropped = dd
            _ = sink.receiveData(dt)
        }

        // Combine buffer + direct transfer stats
        let transferred = bufferTransferred + directTransferred
        let dropped = bufferDropped + directDropped
        link.lastTickTransferred = transferred
        link.lastTickDropped = dropped

        stats.dataTransferred = transferred
        stats.dataDropped = dropped
        totalDataTransferred += transferred
        totalDataDropped += dropped
        resources.totalPacketsLost += dropped

        // Step 6: Sink processes its buffer and generates credits (apply event + prestige + engagement + cert multipliers)
        let baseCredits = sink.process()
        let engagementBonus = EngagementManager.shared.activeMultiplier
        #if DEBUG
        let debugMultiplier = debugCreditMultiplier
        #else
        let debugMultiplier = 1.0
        #endif
        let credits = baseCredits * creditMultiplier * prestigeState.creditMultiplier * engagementBonus * certMultiplier * debugMultiplier * (1.0 - processingDebuff)
        stats.creditsEarned = credits
        resources.addCredits(credits)
        resources.totalDataProcessed += transferred

        // Step 7: Track total for threat calculation
        threatState.totalCreditsEarned += credits

        // Step 7b: Track credits for campaign mode
        if isInCampaignMode {
            levelCreditsEarned += credits
        }

        // Step 8: Calculate buffer utilization
        stats.bufferUtilization = sink.loadPercentage

        lastTickStats = stats

        // === UPDATE THREAT LEVEL ===
        let previousLevel = threatState.currentLevel
        threatState.updateThreatLevel()
        if threatState.currentLevel != previousLevel {
            emitEvent(.threatLevelIncreased(threatState.currentLevel))
            triggerMalusMessage(for: threatState.currentLevel)
        }

        // === UPDATE NET DEFENSE ===
        if let fw = firewall {
            threatState.updateNetDefense(
                firewallTier: fw.tier,
                firewallLevel: fw.level,
                firewallHealthPercent: fw.healthPercentage
            )
        } else {
            threatState.updateNetDefense(firewallTier: 0, firewallLevel: 0, firewallHealthPercent: 0)
        }

        // === MILESTONE & LORE CHECK ===
        updateMilestoneProgress()
        // Full milestone/lore scans are O(n) over all entries — throttle to every 5 ticks
        if currentTick % 5 == 0 {
            checkMilestones()
            checkLoreUnlocks()
        }

        // === CAMPAIGN VICTORY CHECK ===
        if isInCampaignMode {
            checkLevelVictoryConditions()
        }

        // Auto-save every 30 ticks
        if currentTick % 30 == 0 {
            if isInCampaignMode {
                // Save campaign checkpoint for resume capability
                saveCampaignCheckpoint()
            } else {
                saveGame()
            }

            // Update engagement stats periodically
            updateEngagementStats()

            // Update playtime challenge progress (convert ticks to minutes)
            EngagementManager.shared.updateProgress(type: .playMinutes, amount: 0.5)  // 30 ticks = 0.5 min
        }

        // Tick engagement bonus multiplier
        EngagementManager.shared.tickBonus()
    }

    func emitEvent(_ event: GameEvent) {
        lastEvent = event
    }

}
