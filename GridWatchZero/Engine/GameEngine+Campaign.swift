import Foundation

// MARK: - Campaign Mode

extension GameEngine {

    /// Start a campaign level with specific configuration
    /// - Parameters:
    ///   - config: Level configuration
    ///   - persistedUnlocks: Unit IDs unlocked in previous campaign levels (persisted across levels)
    func startCampaignLevel(_ config: LevelConfiguration, persistedUnlocks: Set<String> = []) {
        // Pause any existing game
        pause()

        // IMPORTANT: Clear any offline progress from endless mode
        // Campaign levels start fresh - offline progress doesn't apply to new levels
        offlineProgress = nil

        // Store configuration
        levelConfiguration = config

        // Reset to level's starting state
        let level = config.level
        resources = PlayerResources()
        resources.credits = config.startingCredits
        source = UnitFactory.createPublicMeshSniffer()
        link = UnitFactory.createCopperVPNTunnel()
        sink = UnitFactory.createDataBroker()
        firewall = nil

        // ISSUE-020: Auto-deploy starter firewall for elevated threat levels
        // "Rusty rigged an emergency firewall before you went in."
        if config.isInsane || level.startingThreatLevel.rawValue >= ThreatLevel.target.rawValue {
            firewall = UnitFactory.createBasicFirewall()
        }

        defenseStack = DefenseStack()
        malusIntel = MalusIntelligence()

        // Restore unlocked units from campaign progress
        // Start with base T1 units, then add persisted unlocks
        unlockState = UnlockState()
        for unitId in persistedUnlocks {
            unlockState.unlock(unitId)
        }

        // Set threat level
        threatState = ThreatState()
        threatState.currentLevel = level.startingThreatLevel

        // Reset level tracking
        levelStartTick = 0
        levelCreditsEarned = 0
        levelAttacksSurvived = 0
        levelDamageBlocked = 0
        currentTick = 0

        // Reset event multipliers
        sourceMultiplier = 1.0
        bandwidthMultiplier = 1.0
        creditMultiplier = config.incomeMultiplier  // Apply insane mode income penalty
        bandwidthDebuff = 0
        processingDebuff = 0

        // Clear any active states
        activeAttack = nil
        activeRandomEvent = nil
        showCriticalAlarm = false
        criticalAlarmAcknowledged = false
        activeEarlyWarning = nil
        batchUploadState = nil
        latencyBuffer = []

        // Start the level
        start()
    }

    /// End campaign mode and return to endless
    func exitCampaignMode() {
        levelConfiguration = nil
        onLevelComplete = nil
        onLevelFailed = nil

        // Reset multipliers
        creditMultiplier = 1.0
    }
}

// MARK: - Campaign Checkpoint Save

extension GameEngine {

    /// Save a checkpoint of the current campaign level progress
    func saveCampaignCheckpoint() {
        guard let config = levelConfiguration else {
            print("[GameEngine] ❌ Cannot save checkpoint - no level configuration")
            return
        }

        let checkpoint = LevelCheckpoint(
            levelId: config.level.id,
            isInsane: config.isInsane,
            savedAt: Date(),
            credits: resources.credits,
            data: resources.totalDataProcessed,
            ticksElapsed: currentTick - levelStartTick,
            attacksSurvived: levelAttacksSurvived,
            damageBlocked: levelDamageBlocked,
            creditsEarned: levelCreditsEarned,
            totalCreditsEarned: threatState.totalCreditsEarned,
            threatLevel: threatState.currentLevel,
            sourceUnitId: source.unitTypeId,
            sourceLevel: source.level,
            linkUnitId: link.unitTypeId,
            linkLevel: link.level,
            sinkUnitId: sink.unitTypeId,
            sinkLevel: sink.level,
            firewallUnitId: firewall?.unitTypeId,
            firewallHealth: firewall?.currentHealth,
            firewallMaxHealth: firewall?.maxHealth,
            firewallLevel: firewall?.level,
            defenseStack: defenseStack,
            malusIntel: malusIntel,
            unlockedUnits: unlockState.unlockedUnitIds
        )

        print("[GameEngine] ✅ CHECKPOINT SAVED:")
        print("  - Level ID: \(checkpoint.levelId), Insane: \(checkpoint.isInsane)")
        print("  - Credits: \(checkpoint.credits), Ticks: \(checkpoint.ticksElapsed)")
        print("  - Saved at: \(checkpoint.savedAt)")

        // Save checkpoint to campaign progress
        var progress = CampaignSaveManager.shared.load()
        progress.activeCheckpoint = checkpoint
        CampaignSaveManager.shared.save(progress)

        print("[GameEngine] ✅ Checkpoint persisted to disk via CampaignSaveManager")
    }

    /// Clear the active campaign checkpoint (called on level complete/fail/abandon)
    func clearCampaignCheckpoint() {
        var progress = CampaignSaveManager.shared.load()
        progress.activeCheckpoint = nil
        CampaignSaveManager.shared.save(progress)
    }

    /// Check if there's a valid checkpoint for a specific level
    func hasValidCheckpoint(for levelId: Int, isInsane: Bool) -> Bool {
        let progress = CampaignSaveManager.shared.load()
        guard let checkpoint = progress.activeCheckpoint else { return false }
        return checkpoint.levelId == levelId &&
               checkpoint.isInsane == isInsane &&
               checkpoint.isValid
    }

    /// Resume from a saved checkpoint
    /// - Parameters:
    ///   - checkpoint: The saved checkpoint to resume from
    ///   - config: Level configuration
    ///   - persistedUnlocks: Unused (kept for API compatibility) - unlocks are restored from checkpoint
    func resumeFromCheckpoint(_ checkpoint: LevelCheckpoint, config: LevelConfiguration, persistedUnlocks: Set<String> = []) {
        // Set up the level first
        levelConfiguration = config

        // Calculate offline progress earned while away from this checkpoint
        let campaignOffline = calculateCampaignOfflineProgress(checkpoint: checkpoint)
        let bonusCredits = campaignOffline?.creditsEarned ?? 0

        // Restore level tracking
        levelStartTick = 0  // We'll offset tick calculations
        levelCreditsEarned = checkpoint.creditsEarned + bonusCredits  // Use saved credits earned + offline bonus
        levelAttacksSurvived = checkpoint.attacksSurvived
        levelDamageBlocked = checkpoint.damageBlocked
        currentTick = checkpoint.ticksElapsed

        // Restore resources (including offline bonus)
        resources = PlayerResources()
        resources.credits = checkpoint.credits + bonusCredits
        resources.totalDataProcessed = checkpoint.data + (campaignOffline?.dataProcessed ?? 0)

        // Restore unlocked units from checkpoint (includes units unlocked during this level)
        // Note: Unit unlocks do NOT persist across campaign levels
        unlockState = UnlockState()
        for unitId in checkpoint.unlockedUnits {
            unlockState.unlock(unitId)
        }

        // Restore nodes by their actual unit ID (not just T1 default)
        if let restoredSource = UnitFactory.createSource(fromId: checkpoint.sourceUnitId) {
            source = restoredSource
        } else {
            source = UnitFactory.createPublicMeshSniffer()
        }
        for _ in 1..<checkpoint.sourceLevel {
            source.upgrade()
        }

        if let restoredLink = UnitFactory.createLink(fromId: checkpoint.linkUnitId) {
            link = restoredLink
        } else {
            link = UnitFactory.createCopperVPNTunnel()
        }
        for _ in 1..<checkpoint.linkLevel {
            link.upgrade()
        }

        if let restoredSink = UnitFactory.createSink(fromId: checkpoint.sinkUnitId) {
            sink = restoredSink
        } else {
            sink = UnitFactory.createDataBroker()
        }
        for _ in 1..<checkpoint.sinkLevel {
            sink.upgrade()
        }

        // Restore firewall if it was present (by unit ID)
        if let fwUnitId = checkpoint.firewallUnitId,
           let fwHealth = checkpoint.firewallHealth {
            if let restoredFirewall = UnitFactory.createFirewall(fromId: fwUnitId) {
                firewall = restoredFirewall
            } else {
                firewall = UnitFactory.createBasicFirewall()
            }
            // Restore firewall level (maxHealth is computed from level, so upgrading restores it)
            if let fwLevel = checkpoint.firewallLevel {
                for _ in 1..<fwLevel {
                    firewall?.upgrade()
                }
            }
            firewall?.currentHealth = fwHealth
        } else {
            firewall = nil
        }

        // Restore defense stack and malus intel (FULL STATE)
        defenseStack = checkpoint.defenseStack
        malusIntel = checkpoint.malusIntel

        // Set threat state
        threatState = ThreatState()
        // Restore earned-credit progression so unlock/threat gates stay consistent after resume.
        let restoredTotalCredits = checkpoint.totalCreditsEarned ??
            max(checkpoint.creditsEarned, checkpoint.credits)
        threatState.totalCreditsEarned = max(0, restoredTotalCredits)
        threatState.attacksSurvived = checkpoint.attacksSurvived
        threatState.totalDamageBlocked = checkpoint.damageBlocked
        threatState.currentLevel = checkpoint.threatLevel ?? config.level.startingThreatLevel
        threatState.updateThreatLevel()
        // Honor explicit saved threat if it was higher than computed thresholds.
        if let savedThreat = checkpoint.threatLevel,
           savedThreat.rawValue > threatState.currentLevel.rawValue {
            threatState.currentLevel = savedThreat
        }

        // Reset event multipliers
        sourceMultiplier = 1.0
        bandwidthMultiplier = 1.0
        creditMultiplier = config.incomeMultiplier
        bandwidthDebuff = 0
        processingDebuff = 0

        // Clear active states
        activeAttack = nil
        activeRandomEvent = nil
        showCriticalAlarm = false
        criticalAlarmAcknowledged = false

        // Set offline progress to show the dialog (if there was progress)
        offlineProgress = campaignOffline

        // Start the level
        start()
    }

    /// Check victory conditions (called each tick in campaign mode)
    func checkLevelVictoryConditions() {
        guard let config = levelConfiguration else { return }

        let conditions = config.level.victoryConditions

        // Check for time limit failure first
        if conditions.isTimeLimitExceeded(currentTick: currentTick - levelStartTick) {
            handleLevelFailed(.timeLimitExceeded)
            return
        }

        // Check for bankruptcy
        if resources.credits <= 0 && currentTick > levelStartTick + 60 {
            // Give 60 ticks grace period at start
            handleLevelFailed(.creditsZero)
            return
        }

        // Check victory conditions (apply Insane mode multipliers to thresholds)
        let creditsOverride = conditions.requiredCredits.map { $0 * config.creditRequirementMultiplier }
        let reportsOverride = conditions.requiredReportsSent.map { Int(Double($0) * config.reportRequirementMultiplier) }

        if conditions.isSatisfied(
            defenseStack: defenseStack,
            riskLevel: threatState.effectiveRiskLevel,
            totalCredits: levelCreditsEarned,
            attacksSurvived: levelAttacksSurvived,
            reportsSent: malusIntel.reportsSent,
            currentTick: currentTick - levelStartTick,
            creditOverride: creditsOverride,
            reportOverride: reportsOverride
        ) {
            handleLevelComplete()
        }
    }

    /// Handle successful level completion
    func handleLevelComplete() {
        guard let config = levelConfiguration else { return }

        pause()

        // Clear checkpoint on completion
        clearCampaignCheckpoint()

        let stats = LevelCompletionStats(
            levelId: config.level.id,
            isInsane: config.isInsane,
            ticksToComplete: currentTick - levelStartTick,
            creditsEarned: levelCreditsEarned,
            attacksSurvived: levelAttacksSurvived,
            damageBlocked: levelDamageBlocked,
            finalDefensePoints: Int(defenseStack.totalDefensePoints),
            intelReportsSent: malusIntel.reportsSent,
            completionDate: Date()
        )

        onLevelComplete?(stats)
    }

    /// Handle level failure
    func handleLevelFailed(_ reason: FailureReason) {
        pause()

        // Clear checkpoint on failure
        clearCampaignCheckpoint()

        onLevelFailed?(reason)
    }

    /// Get current victory progress for UI display
    var victoryProgress: VictoryProgress? {
        guard let config = levelConfiguration else { return nil }

        let conditions = config.level.victoryConditions
        let highestTier = defenseStack.applications.values.map { $0.tier.tierNumber }.max() ?? 0

        return VictoryProgress(
            defenseTierRequired: conditions.requiredDefenseTier,
            defenseTierCurrent: highestTier,
            defensePointsRequired: conditions.requiredDefensePoints,
            defensePointsCurrent: Int(defenseStack.totalDefensePoints),
            riskLevelRequired: conditions.requiredRiskLevel,
            riskLevelCurrent: threatState.effectiveRiskLevel,
            creditsRequired: conditions.requiredCredits,
            creditsCurrent: levelCreditsEarned,
            attacksRequired: conditions.requiredAttacksSurvived,
            attacksCurrent: levelAttacksSurvived,
            reportsRequired: conditions.requiredReportsSent,
            reportsCurrent: malusIntel.reportsSent
        )
    }
}

// MARK: - Victory Progress (For UI)

struct VictoryProgress {
    let defenseTierRequired: Int
    let defenseTierCurrent: Int
    let defensePointsRequired: Int
    let defensePointsCurrent: Int
    let riskLevelRequired: ThreatLevel
    let riskLevelCurrent: ThreatLevel
    let creditsRequired: Double?
    let creditsCurrent: Double
    let attacksRequired: Int?
    let attacksCurrent: Int
    let reportsRequired: Int?
    let reportsCurrent: Int

    var defenseTierMet: Bool { defenseTierCurrent >= defenseTierRequired }
    var defensePointsMet: Bool { defensePointsCurrent >= defensePointsRequired }
    var riskLevelMet: Bool { riskLevelCurrent.rawValue <= riskLevelRequired.rawValue }

    var creditsMet: Bool {
        guard let required = creditsRequired else { return true }
        return creditsCurrent >= required
    }

    var attacksMet: Bool {
        guard let required = attacksRequired else { return true }
        return attacksCurrent >= required
    }

    var reportsMet: Bool {
        guard let required = reportsRequired else { return true }
        return reportsCurrent >= required
    }

    var allConditionsMet: Bool {
        defenseTierMet && defensePointsMet && riskLevelMet && creditsMet && attacksMet && reportsMet
    }

    var overallProgress: Double {
        var progress = 0.0
        var count = 0.0

        // Defense tier (weighted heavily)
        progress += min(1.0, Double(defenseTierCurrent) / Double(defenseTierRequired)) * 2
        count += 2

        // Defense points
        progress += min(1.0, Double(defensePointsCurrent) / Double(defensePointsRequired))
        count += 1

        // Risk level (1.0 if met, partial otherwise)
        let riskProgress = riskLevelMet ? 1.0 : max(0, 1.0 - Double(riskLevelCurrent.rawValue - riskLevelRequired.rawValue) * 0.2)
        progress += riskProgress
        count += 1

        // Credits
        if let required = creditsRequired {
            progress += min(1.0, creditsCurrent / required)
            count += 1
        }

        // Attacks
        if let required = attacksRequired {
            progress += min(1.0, Double(attacksCurrent) / Double(required))
            count += 1
        }

        // Intel Reports (weighted heavily - main objective)
        if let required = reportsRequired {
            progress += min(1.0, Double(reportsCurrent) / Double(required)) * 2
            count += 2
        }

        return progress / count
    }
}
