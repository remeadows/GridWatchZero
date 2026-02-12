import Foundation

// MARK: - Random Event Processing

extension GameEngine {

    func processRandomEvents() {
        // Check if active event expired
        if let event = activeRandomEvent {
            if let expires = event.expiresAtTick, currentTick >= expires {
                // Event expired, reset multipliers
                sourceMultiplier = 1.0
                bandwidthMultiplier = 1.0
                creditMultiplier = 1.0
                activeRandomEvent = nil
            }
        }

        // Only try to generate new event if none active
        guard activeRandomEvent == nil else { return }

        if let newEvent = EventGenerator.tryGenerateEvent(
            threatLevel: threatState.currentLevel,
            currentTick: currentTick,
            totalCredits: threatState.totalCreditsEarned,
            random: &rng
        ) {
            activeRandomEvent = newEvent
            applyEventEffect(newEvent.effect)
            emitEvent(.randomEvent(newEvent.title, newEvent.message))

            // Play sound based on event type
            if newEvent.type.isPositive {
                AudioManager.shared.playSound(.milestone)
            } else {
                AudioManager.shared.playSound(.warning)
            }
        }
    }

    func applyEventEffect(_ effect: EventEffect) {
        // Apply multipliers
        sourceMultiplier = effect.sourceMultiplier
        bandwidthMultiplier = effect.bandwidthMultiplier
        creditMultiplier = effect.creditMultiplier

        // Instant credits
        if effect.instantCredits > 0 {
            resources.addCredits(effect.instantCredits)
        }

        // Data loss (affects sink buffer)
        if effect.dataLoss > 0 {
            let loss = sink.inputBuffer * effect.dataLoss
            sink.inputBuffer -= loss
        }

        // Lore unlock
        if let fragmentId = effect.loreFragmentId {
            unlockLoreFragment(fragmentId)
        }
    }
}

// MARK: - Milestone Processing

extension GameEngine {

    func updateMilestoneProgress() {
        milestoneState.totalCreditsEarned = threatState.totalCreditsEarned
        milestoneState.totalDataProcessed = resources.totalDataProcessed
        milestoneState.attacksSurvived = threatState.attacksSurvived
        milestoneState.highestThreatLevel = max(milestoneState.highestThreatLevel, threatState.currentLevel)
        milestoneState.unitsUnlocked = unlockState.unlockedUnitIds.count
        milestoneState.totalPlayTimeSeconds = Int(totalPlayTime)
        milestoneState.loreFragmentsCollected = loreState.unlockedFragmentIds.count
    }

    /// Update campaign completion counts for milestone tracking
    func updateCampaignMilestones(campaignCompleted: Int, insaneCompleted: Int) {
        milestoneState.campaignLevelsCompleted = campaignCompleted
        milestoneState.insaneLevelsCompleted = insaneCompleted
        checkMilestones()
        saveGame()
    }

    func checkMilestones() {
        let completable = MilestoneDatabase.checkProgress(state: milestoneState)

        for milestone in completable {
            milestoneState.complete(milestone.id)
            emitEvent(.milestoneCompleted(milestone.title))
            AudioManager.shared.playSound(.milestone)

            // Apply reward
            applyMilestoneReward(milestone.reward)
        }
    }

    func applyMilestoneReward(_ reward: MilestoneReward) {
        switch reward {
        case .credits(let amount):
            resources.addCredits(amount)

        case .loreUnlock(let fragmentId):
            unlockLoreFragment(fragmentId)

        case .unitUnlock(let unitId):
            unlockState.unlock(unitId)
            if let unit = UnitFactory.unit(withId: unitId) {
                emitEvent(.unitUnlocked(unit.name))
            }

        case .multiplier(_, _):
            // TODO: Implement temporary multiplier from milestone
            break
        }
    }
}

// MARK: - Lore Processing

extension GameEngine {

    func checkLoreUnlocks() {
        // Check credit-based lore unlocks
        let creditUnlocks = LoreDatabase.fragmentsUnlockedByCredits(upTo: threatState.totalCreditsEarned)
        for fragment in creditUnlocks {
            if !loreState.isUnlocked(fragment.id) {
                // Check prerequisite
                if let prereq = fragment.prerequisiteFragmentId {
                    guard loreState.isUnlocked(prereq) else { continue }
                }
                unlockLoreFragment(fragment.id)
            }
        }
    }

    func unlockLoreFragment(_ fragmentId: String) {
        guard !loreState.isUnlocked(fragmentId) else { return }

        loreState.unlock(fragmentId)

        if let fragment = LoreDatabase.fragment(withId: fragmentId) {
            emitEvent(.loreUnlocked(fragment.title))
        }
    }

    func markLoreRead(_ fragmentId: String) {
        loreState.markRead(fragmentId)
        saveGame()
    }
}
