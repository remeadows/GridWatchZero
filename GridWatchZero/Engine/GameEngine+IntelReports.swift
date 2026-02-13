import Foundation

// MARK: - Malus Intelligence

extension GameEngine {

    /// Send report to team - now with meaningful rewards!
    func sendMalusReport() -> Bool {
        // Get intel multiplier from SIEM/IDS systems
        let intelMultiplier = cachedDefenseTotals.intelMultiplier

        guard let result = malusIntel.sendReport(intelMultiplier: intelMultiplier) else {
            return false
        }

        // Award credits
        resources.addCredits(result.creditsEarned)

        // Check for milestone unlock
        if let milestone = result.milestone {
            // Emit milestone event
            emitEvent(.milestone("INTEL MILESTONE: \(milestone.title) - +₵\(Int(result.milestoneCredits).formatted())"))

            // Unlock lore fragment if available
            if let loreId = milestone.loreFragmentId {
                unlockLoreFragment(loreId)
            }

            AudioManager.shared.playSound(.milestone)
        } else {
            // Regular report
            emitEvent(.milestone("Intel Report #\(result.reportNumber) - +₵\(Int(result.creditsEarned).formatted())"))
            AudioManager.shared.playSound(.upgrade)
        }

        // Track for engagement system
        recordIntelReportSent()

        TutorialManager.shared.recordAction(.sentReport)
        syncDisplayState()
        saveGame()
        return true
    }

    // MARK: - Batch Intel Upload

    /// Start "Send ALL" batch intel upload
    /// - Returns: true if batch upload started, false if cannot (no reports, active attack, already uploading)
    func sendAllMalusReports() -> Bool {
        // Can't send during active attack
        guard activeAttack == nil else { return false }
        // Can't start if already uploading
        guard batchUploadState == nil else { return false }
        // Need at least 11 pending reports for batch mode
        let pending = malusIntel.pendingReportCount
        guard pending >= 11 else { return false }

        let latency = BatchUploadState.latency(forReportCount: pending)
        let bandwidthCost = BatchUploadState.bandwidthImpact(forReportCount: pending)

        batchUploadState = BatchUploadState(
            totalReports: pending,
            latencyTicks: latency,
            bandwidthCost: bandwidthCost
        )

        emitEvent(.batchUploadStarted(pending))
        AudioManager.shared.playSound(.upgrade)
        syncDisplayState()
        return true
    }

    /// Cancel an in-progress batch upload
    func cancelBatchUpload() {
        batchUploadState = nil
        syncDisplayState()
    }

    /// Whether the "Send ALL" button should be shown
    var canSendAllReports: Bool {
        malusIntel.pendingReportCount >= 11 && activeAttack == nil && batchUploadState == nil
    }

    /// Get info about next intel milestone
    var nextIntelMilestone: IntelMilestone? {
        malusIntel.nextMilestone
    }

    /// Reports needed for next milestone
    var reportsToNextMilestone: Int {
        malusIntel.reportsToNextMilestone
    }

    /// Collect footprint data from survived attack
    func collectMalusFootprint(_ attack: Attack) {
        // GATE: Must have at least one defense app deployed to collect intel
        // This makes defense apps essential for campaign progress (intel reports are required)
        guard defenseStack.deployedCount >= 1 else { return }

        // Base intel from attack: damage blocked + duration + severity bonus
        let damageBlocked = attack.blocked
        let durationBonus = Double(attack.type.baseDuration) * 15.0
        let severityBonus = attack.severity * 25.0
        let baseData = damageBlocked * 0.5 + durationBonus + severityBonus

        // Sprint B: Apply intel bonus from all defense categories
        let detectionMultiplier = cachedDefenseTotals.intelBonus
        malusIntel.addFootprintData(baseData, detectionMultiplier: detectionMultiplier)

        // Identify pattern based on attack type
        // Sprint B: SIEM pattern ID bonus added to milestone bonus
        let totalPatternBonus = malusIntel.patternIdSpeedBonus + defenseStack.totalPatternIdBonus
        let pattern = "\(attack.type.rawValue)_v\(Int(attack.severity * 10))"
        malusIntel.identifyPattern(pattern, patternSpeedBonus: totalPatternBonus)

        // Bonus pattern from high-tier attacks
        if attack.type == .malusStrike {
            let malusPattern = "MALUS_SIGNATURE_\(currentTick % 100)"
            malusIntel.identifyPattern(malusPattern, patternSpeedBonus: totalPatternBonus)
        }
    }
}
