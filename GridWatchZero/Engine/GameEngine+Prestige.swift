import Foundation

// MARK: - Prestige System

extension GameEngine {

    /// Check if player can prestige at current level
    var canPrestige: Bool {
        let required = PrestigeState.creditsRequiredForPrestige(level: prestigeState.prestigeLevel)
        return threatState.totalCreditsEarned >= required
    }

    /// Credits required for next prestige
    var creditsRequiredForPrestige: Double {
        PrestigeState.creditsRequiredForPrestige(level: prestigeState.prestigeLevel)
    }

    /// Helix cores that would be earned from prestiging now
    var helixCoresFromPrestige: Int {
        PrestigeState.helixCoresEarned(
            fromCredits: threatState.totalCreditsEarned,
            atLevel: prestigeState.prestigeLevel
        )
    }

    /// Perform a prestige (Network Wipe) - resets progress but grants permanent bonuses
    func performPrestige() -> Bool {
        guard canPrestige else { return false }

        // Calculate rewards before resetting
        let coresEarned = helixCoresFromPrestige

        // Update prestige state
        var newPrestigeState = prestigeState
        newPrestigeState.prestigeLevel += 1
        newPrestigeState.totalHelixCores += coresEarned
        newPrestigeState.availableHelixCores += coresEarned

        // Reset game but keep prestige
        pause()
        let state = GameState.newGame(prestigeState: newPrestigeState)
        resources = state.resources
        source = state.source
        link = state.link
        sink = state.sink
        firewall = nil
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
        prestigeState = newPrestigeState
        activeAttack = nil
        activeRandomEvent = nil
        lastEvent = nil
        bandwidthDebuff = 0
        processingDebuff = 0
        sourceMultiplier = 1.0
        bandwidthMultiplier = 1.0
        creditMultiplier = 1.0
        activeEarlyWarning = nil
        batchUploadState = nil
        latencyBuffer = []

        // Emit event
        emitEvent(.milestone("NETWORK WIPE COMPLETE - Helix Core +\(coresEarned)"))
        AudioManager.shared.playSound(.milestone)

        saveGame()
        return true
    }
}
