import Foundation

// MARK: - Persistence

extension GameEngine {

    func saveGame() {
        print("[GameEngine] ⚠️ saveGame() CALLED at \(Date())")
        print("[GameEngine] Current state: \(resources.credits.formatted) credits, tick \(currentTick)")

        let state = GameState(
            resources: resources,
            source: source,
            link: link,
            sink: sink,
            firewall: firewall,
            defenseStack: defenseStack,
            malusIntel: malusIntel,
            currentTick: currentTick,
            totalPlayTime: totalPlayTime,
            threatState: threatState,
            unlockState: unlockState,
            loreState: loreState,
            milestoneState: milestoneState,
            prestigeState: prestigeState,
            lastSaveTimestamp: Date(),
            criticalAlarmAcknowledged: criticalAlarmAcknowledged
        )

        do {
            let data = try JSONEncoder().encode(state)
            print("[GameEngine] ✅ State encoded successfully, size: \(data.count) bytes")

            UserDefaults.standard.set(data, forKey: saveKey)
            print("[GameEngine] ✅ Data written to UserDefaults with key: \(saveKey)")

            // Force immediate write to disk (deprecated but ensures persistence when backgrounding)
            UserDefaults.standard.synchronize()
            print("[GameEngine] ✅ synchronize() called")

            // VERIFY the save worked immediately
            if let verifyData = UserDefaults.standard.data(forKey: saveKey) {
                print("[GameEngine] ✅ VERIFIED: Data exists in UserDefaults (\(verifyData.count) bytes)")

                // Try to decode it to ensure it's valid
                if let verifyState = try? JSONDecoder().decode(GameState.self, from: verifyData) {
                    print("[GameEngine] ✅ VERIFIED: Data is decodable, credits=\(verifyState.resources.credits.formatted)")
                } else {
                    print("[GameEngine] ❌ WARNING: Data exists but cannot be decoded!")
                }
            } else {
                print("[GameEngine] ❌ CRITICAL: Data NOT found in UserDefaults after save!")
            }

            print("[GameEngine] ✅ Save completed at \(Date()): \(resources.credits.formatted) credits, tick \(currentTick)")
        } catch {
            print("[GameEngine] ❌ CRITICAL: Save failed during encoding - \(error)")
            print("[GameEngine] ❌ Error details: \(error.localizedDescription)")
        }
    }

    func loadGame() {
        print("[GameEngine] ⚠️ loadGame() CALLED at \(Date())")
        print("[GameEngine] Checking for save data with key: \(saveKey)")

        // Check if raw data exists first
        if let rawData = UserDefaults.standard.data(forKey: saveKey) {
            print("[GameEngine] ✅ Raw save data found: \(rawData.count) bytes")
        } else {
            print("[GameEngine] ❌ No raw data found in UserDefaults")
        }

        // Use migration manager to load (handles old versions automatically)
        guard let state = SaveMigrationManager.loadAndMigrate() else {
            print("[GameEngine] ❌ No save data found - starting new game")
            return
        }

        print("[GameEngine] ✅ Loading save: \(state.resources.credits.formatted) credits, tick \(state.currentTick)")
        print("[GameEngine] Save timestamp: \(state.lastSaveTimestamp?.formatted() ?? "none")")

        resources = state.resources
        source = state.source
        link = state.link
        sink = state.sink
        firewall = state.firewall
        defenseStack = state.defenseStack
        malusIntel = state.malusIntel
        currentTick = state.currentTick
        totalPlayTime = state.totalPlayTime
        threatState = state.threatState
        unlockState = state.unlockState
        loreState = state.loreState
        milestoneState = state.milestoneState
        prestigeState = state.prestigeState
        criticalAlarmAcknowledged = state.criticalAlarmAcknowledged

        // Calculate offline progress
        if let lastSave = state.lastSaveTimestamp {
            calculateOfflineProgress(since: lastSave)
        }

        print("[GameEngine] ✅ Load completed: \(resources.credits.formatted) credits")
    }

    /// Calculate and apply credits earned while player was away
    func calculateOfflineProgress(since lastSave: Date) {
        let now = Date()
        let secondsAway = Int(now.timeIntervalSince(lastSave))

        // Only count offline progress if away for at least 60 seconds
        guard secondsAway >= 60 else { return }

        // Cap offline time at 8 hours (28800 seconds) for balance
        let maxOfflineSeconds = 28800
        let effectiveSeconds = min(secondsAway, maxOfflineSeconds)

        // Calculate ticks (1 tick per second)
        let ticksToSimulate = effectiveSeconds

        // Calculate earnings at reduced rate (50% of normal)
        // This prevents offline from being better than active play
        let offlineEfficiency = 0.5

        // Estimate production per tick based on current setup
        let estimatedProduction = source.productionPerTick
        let effectiveBandwidth = link.bandwidth
        let estimatedTransfer = min(estimatedProduction, effectiveBandwidth)
        let estimatedProcessing = min(estimatedTransfer, sink.processingPerTick)
        let offlineCertMultiplier = CertificateManager.shared.totalCertificationMultiplier
        let creditsPerTick = estimatedProcessing * sink.conversionRate * offlineEfficiency * offlineCertMultiplier

        // Calculate totals
        let totalCredits = creditsPerTick * Double(ticksToSimulate)
        let totalData = estimatedProcessing * Double(ticksToSimulate)

        // Apply earnings
        resources.addCredits(totalCredits)
        resources.totalDataProcessed += totalData
        threatState.totalCreditsEarned += totalCredits
        currentTick += ticksToSimulate
        totalPlayTime += TimeInterval(effectiveSeconds)

        // Create offline progress report
        offlineProgress = OfflineProgress(
            secondsAway: secondsAway,
            ticksSimulated: ticksToSimulate,
            creditsEarned: totalCredits,
            dataProcessed: totalData
        )
    }

    /// Calculate offline progress for a campaign level checkpoint
    /// Returns the bonus credits earned while away (to be added to checkpoint credits)
    func calculateCampaignOfflineProgress(checkpoint: LevelCheckpoint) -> OfflineProgress? {
        let now = Date()
        let secondsAway = Int(now.timeIntervalSince(checkpoint.savedAt))

        // Only count offline progress if away for at least 60 seconds
        guard secondsAway >= 60 else { return nil }

        // Cap offline time at 4 hours for campaign (shorter than endless)
        let maxOfflineSeconds = 14400
        let effectiveSeconds = min(secondsAway, maxOfflineSeconds)

        // Calculate ticks (1 tick per second)
        let ticksToSimulate = effectiveSeconds

        // Calculate earnings at reduced rate (30% for campaign - lower than endless)
        let offlineEfficiency = 0.3

        // Use checkpoint's node levels to estimate production
        // Base T1 values scaled by level
        let estimatedProduction = 10.0 * Double(checkpoint.sourceLevel)  // ~10/tick at T1
        let effectiveBandwidth = 15.0 * Double(checkpoint.linkLevel)     // ~15/tick at T1
        let estimatedTransfer = min(estimatedProduction, effectiveBandwidth)
        let estimatedProcessing = min(estimatedTransfer, 12.0 * Double(checkpoint.sinkLevel))
        let campaignCertMultiplier = CertificateManager.shared.totalCertificationMultiplier
        let creditsPerTick = estimatedProcessing * 1.0 * offlineEfficiency * campaignCertMultiplier  // 1.0 conversion rate

        // Calculate totals
        let totalCredits = creditsPerTick * Double(ticksToSimulate)
        let totalData = estimatedProcessing * Double(ticksToSimulate)

        return OfflineProgress(
            secondsAway: secondsAway,
            ticksSimulated: ticksToSimulate,
            creditsEarned: totalCredits,
            dataProcessed: totalData
        )
    }

    /// Dismiss offline progress notification
    func dismissOfflineProgress() {
        offlineProgress = nil
    }

    func resetGame() {
        pause()
        let state = GameState.newGame()
        resources = state.resources
        source = state.source
        link = state.link
        sink = state.sink
        firewall = nil
        defenseStack = DefenseStack()
        malusIntel = MalusIntelligence()
        currentTick = 0
        totalPlayTime = 0
        totalDataGenerated = 0
        totalDataTransferred = 0
        totalDataDropped = 0
        lastTickStats = TickStats()
        threatState = ThreatState()
        unlockState = UnlockState()
        loreState = state.loreState
        milestoneState = MilestoneState()
        prestigeState = PrestigeState()  // Reset prestige on full reset
        activeAttack = nil
        activeRandomEvent = nil
        lastEvent = nil
        bandwidthDebuff = 0
        processingDebuff = 0
        sourceMultiplier = 1.0
        bandwidthMultiplier = 1.0
        creditMultiplier = 1.0
        showCriticalAlarm = false
        criticalAlarmAcknowledged = false
        activeEarlyWarning = nil
        batchUploadState = nil
        latencyBuffer = []
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
}
