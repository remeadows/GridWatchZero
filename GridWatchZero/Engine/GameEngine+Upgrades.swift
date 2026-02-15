import Foundation

// MARK: - Upgrades

extension GameEngine {

    func upgradeSource() -> Bool {
        // Check if at max level for this tier
        guard source.canUpgrade else { return false }
        let cost = source.upgradeCost
        guard resources.spendCredits(cost) else { return false }
        source.upgrade()
        playUpgradeFeedbackIfNeeded()
        TutorialManager.shared.recordAction(.upgradedSource)
        recordUnitUpgrade()
        saveGame()
        return true
    }

    func upgradeLink() -> Bool {
        // Check if at max level for this tier
        guard link.canUpgrade else { return false }
        let cost = link.upgradeCost
        guard resources.spendCredits(cost) else { return false }
        link.upgrade()
        playUpgradeFeedbackIfNeeded()
        TutorialManager.shared.recordAction(.upgradedLink)
        recordUnitUpgrade()
        saveGame()
        return true
    }

    func upgradeSink() -> Bool {
        // Check if at max level for this tier
        guard sink.canUpgrade else { return false }
        let cost = sink.upgradeCost
        guard resources.spendCredits(cost) else { return false }
        sink.upgrade()
        playUpgradeFeedbackIfNeeded()
        TutorialManager.shared.recordAction(.upgradedSink)
        recordUnitUpgrade()
        saveGame()
        return true
    }

    func upgradeFirewall() -> Bool {
        guard var fw = firewall else { return false }
        // Check if at max level for this tier
        guard fw.canUpgrade else { return false }
        let cost = fw.upgradeCost
        guard resources.spendCredits(cost) else { return false }
        fw.upgrade()
        firewall = fw
        playUpgradeFeedbackIfNeeded()
        recordUnitUpgrade()
        saveGame()
        return true
    }

    private func playUpgradeFeedbackIfNeeded() {
        #if targetEnvironment(simulator)
        // Rapid upgrade loops in simulator are bottlenecked by repeated SFX scheduling.
        return
        #else
        let now = Date().timeIntervalSinceReferenceDate
        guard now - lastUpgradeFeedbackTimestamp >= upgradeFeedbackMinimumInterval else { return }
        lastUpgradeFeedbackTimestamp = now
        AudioManager.shared.playSound(.upgrade)
        #endif
    }
}

// MARK: - Unit Unlock/Purchase

extension GameEngine {

    /// Check if a unit can be unlocked (credits + tier gate + campaign tier cap)
    func canUnlock(_ unitInfo: UnitFactory.UnitInfo) -> Bool {
        guard !unlockState.isUnlocked(unitInfo.id) else { return false }
        guard resources.credits >= unitInfo.unlockCost else { return false }

        // Campaign mode: enforce availableTiers cap for all unit types
        if isInCampaignMode {
            let maxAllowedTier = maxUnlockTierInCampaign(for: unitInfo)
            guard unitInfo.tier.rawValue <= maxAllowedTier else { return false }
        }

        // Tier gate: must have previous tier at max level
        guard isTierGateSatisfied(for: unitInfo) else { return false }

        return true
    }

    /// Returns the campaign tier ceiling for this category.
    /// Insane mode ignores per-mission caps so full tier progression remains possible.
    /// Normal mode on early T1-only levels still exposes Tier 2 so upgrades don't dead-end.
    private func maxUnlockTierInCampaign(for _: UnitFactory.UnitInfo) -> Int {
        guard isInCampaignMode else { return 25 }

        if levelConfiguration?.isInsane == true {
            return NodeTier.tier25.rawValue
        }

        let missionCap = maxTierAvailable
        let earlyNormalRunwayCap = max(missionCap, 2)
        // Early campaign levels that publish only T1 still need a visible/usable progression path.
        return missionCap <= 1 ? earlyNormalRunwayCap : missionCap
    }

    /// Check if the tier gate requirement is satisfied
    /// To unlock a T(N) unit, the player must have a T(N-1) unit at max level
    func isTierGateSatisfied(for unitInfo: UnitFactory.UnitInfo) -> Bool {
        let targetTier = unitInfo.tier.rawValue

        // T1 units have no tier gate
        guard targetTier > 1 else { return true }

        // Check if we have the previous tier at max level for the same category
        let previousTier = NodeTier(rawValue: targetTier - 1) ?? .tier1

        switch unitInfo.category {
        case .source:
            // Check if current source is at max level AND is the previous tier
            return source.tier.rawValue >= previousTier.rawValue && source.isAtMaxLevel
        case .link:
            return link.tier.rawValue >= previousTier.rawValue && link.isAtMaxLevel
        case .sink:
            return sink.tier.rawValue >= previousTier.rawValue && sink.isAtMaxLevel
        case .defense:
            if let fw = firewall {
                return fw.nodeTier.rawValue >= previousTier.rawValue && fw.isAtMaxLevel
            }
            // If no firewall, T1 defense has no gate
            return targetTier == 1
        }
    }

    /// Get the tier gate reason for UI display
    func tierGateReason(for unitInfo: UnitFactory.UnitInfo) -> String? {
        guard !isTierGateSatisfied(for: unitInfo) else { return nil }

        let targetTier = unitInfo.tier.rawValue
        guard targetTier > 1 else { return nil }

        let previousTier = NodeTier(rawValue: targetTier - 1) ?? .tier1

        switch unitInfo.category {
        case .source:
            if source.tier.rawValue < previousTier.rawValue {
                return "Requires T\(previousTier.rawValue) Source"
            }
            return "T\(previousTier.rawValue) Source must be at max level (\(previousTier.maxLevel))"
        case .link:
            if link.tier.rawValue < previousTier.rawValue {
                return "Requires T\(previousTier.rawValue) Link"
            }
            return "T\(previousTier.rawValue) Link must be at max level (\(previousTier.maxLevel))"
        case .sink:
            if sink.tier.rawValue < previousTier.rawValue {
                return "Requires T\(previousTier.rawValue) Sink"
            }
            return "T\(previousTier.rawValue) Sink must be at max level (\(previousTier.maxLevel))"
        case .defense:
            guard let fw = firewall else { return "Requires T\(previousTier.rawValue) Defense" }
            if fw.nodeTier.rawValue < previousTier.rawValue {
                return "Requires T\(previousTier.rawValue) Defense"
            }
            return "T\(previousTier.rawValue) Defense must be at max level (\(previousTier.maxLevel))"
        }
    }

    /// Campaign tier cap reason for UI display
    func campaignTierGateReason(for unitInfo: UnitFactory.UnitInfo) -> String? {
        guard isInCampaignMode else { return nil }
        let maxAllowedTier = maxUnlockTierInCampaign(for: unitInfo)
        guard unitInfo.tier.rawValue > maxAllowedTier else { return nil }
        if levelConfiguration?.isInsane == true {
            return "Insane runway currently allows up to T\(maxAllowedTier)"
        }
        return "Mission tier cap is T\(maxAllowedTier)"
    }

    /// Primary unlock block reason for UI display
    func unlockBlockReason(for unitInfo: UnitFactory.UnitInfo) -> String? {
        guard !unlockState.isUnlocked(unitInfo.id) else { return nil }
        if resources.credits < unitInfo.unlockCost {
            return "Need ¢\(unitInfo.unlockCost.formatted)"
        }
        if let campaignCapReason = campaignTierGateReason(for: unitInfo) {
            return campaignCapReason
        }
        if let tierReason = tierGateReason(for: unitInfo) {
            return tierReason
        }
        if !canUnlock(unitInfo) {
            return "Unlock requirements not met"
        }
        return nil
    }

    func unlockUnit(_ unitInfo: UnitFactory.UnitInfo) -> Bool {
        guard canUnlock(unitInfo) else { return false }
        guard resources.spendCredits(unitInfo.unlockCost) else { return false }

        unlockState.unlock(unitInfo.id)
        emitEvent(.unitUnlocked(unitInfo.name))
        AudioManager.shared.playSound(.milestone)

        // Notify campaign system of unlock (for persistence across levels)
        onUnitUnlocked?(unitInfo.id)

        saveGame()
        return true
    }
}

// MARK: - Unit Swapping

extension GameEngine {

    func setSource(_ unitId: String) -> Bool {
        guard unlockState.isUnlocked(unitId),
              let newSource = UnitFactory.createSource(fromId: unitId) else {
            return false
        }
        source = newSource
        saveGame()
        return true
    }

    func setLink(_ unitId: String) -> Bool {
        guard unlockState.isUnlocked(unitId),
              let newLink = UnitFactory.createLink(fromId: unitId) else {
            return false
        }
        link = newLink
        saveGame()
        return true
    }

    func setSink(_ unitId: String) -> Bool {
        guard unlockState.isUnlocked(unitId),
              let newSink = UnitFactory.createSink(fromId: unitId) else {
            return false
        }
        sink = newSink
        saveGame()
        return true
    }

    func setFirewall(_ unitId: String?) -> Bool {
        if let unitId = unitId {
            guard unlockState.isUnlocked(unitId),
                  let newFirewall = UnitFactory.createFirewall(fromId: unitId) else {
                return false
            }
            firewall = newFirewall
        } else {
            firewall = nil
        }
        saveGame()
        return true
    }
}

// MARK: - Firewall Actions

extension GameEngine {

    func purchaseFirewall() -> Bool {
        guard firewall == nil else { return false }

        let firewallInfo = UnitFactory.unit(withId: "defense_t1_basic_firewall")
        guard let info = firewallInfo else { return false }

        // Unlock if needed
        if !unlockState.isUnlocked(info.id) {
            guard unlockUnit(info) else { return false }
        }

        firewall = UnitFactory.createBasicFirewall()
        TutorialManager.shared.recordAction(.purchasedFirewall)
        saveGame()
        return true
    }

    func repairFirewall() -> Bool {
        guard var fw = firewall, fw.currentHealth < fw.maxHealth else {
            return false
        }

        let repairCost = fw.repair()
        guard resources.spendCredits(repairCost) else { return false }

        firewall = fw
        saveGame()
        return true
    }
}
