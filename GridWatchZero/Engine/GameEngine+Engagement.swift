import Foundation

// MARK: - Debug

extension GameEngine {

    func addDebugCredits(_ amount: Double) {
        resources.addCredits(amount)
        threatState.totalCreditsEarned += amount
    }
}

// MARK: - Engagement System Support

extension GameEngine {

    /// Add credits from engagement rewards (daily login, achievements, etc.)
    func addCredits(_ amount: Double) {
        resources.addCredits(amount)
        threatState.totalCreditsEarned += amount

        // Update engagement challenge progress
        EngagementManager.shared.updateProgress(type: .earnCredits, amount: amount)
    }

    /// Update engagement system with current game stats
    func updateEngagementStats() {
        // Update achievement stats
        AchievementManager.shared.updateStats { stats in
            stats.totalCreditsEarned = threatState.totalCreditsEarned
            stats.highestSingleRunCredits = max(stats.highestSingleRunCredits, resources.credits)
            stats.totalAttacksSurvived = threatState.attacksSurvived
            stats.highestDefensePoints = max(stats.highestDefensePoints, Int(defenseStack.totalDefensePoints))
            stats.prestigeLevel = prestigeState.prestigeLevel
            stats.loreFragmentsCollected = loreState.unlockedFragmentIds.count
            stats.dataChipsCollected = CollectionManager.shared.ownedCount
            stats.intelReportsSent = malusIntel.reportsSent

            // Login streak from engagement manager
            stats.longestLoginStreak = max(stats.longestLoginStreak, EngagementManager.shared.longestStreak)
        }
    }

    /// Called when an attack is survived - updates engagement systems
    func recordAttackSurvived(damageTaken: Double) {
        // Update engagement challenge progress
        EngagementManager.shared.updateProgress(type: .surviveAttacks, amount: 1)

        // Update achievement stats
        AchievementManager.shared.updateStats { stats in
            stats.totalAttacksSurvived += 1
            if damageTaken <= 0 {
                stats.consecutiveNoDamageAttacks += 1
                stats.perfectDefenseStreak += 1
            } else {
                stats.consecutiveNoDamageAttacks = 0
                stats.perfectDefenseStreak = 0
            }
        }
    }

    /// Called when intel report is sent
    func recordIntelReportSent() {
        EngagementManager.shared.updateProgress(type: .sendReports, amount: 1)

        AchievementManager.shared.updateStats { stats in
            stats.intelReportsSent += 1
        }
    }

    /// Called when a unit is upgraded
    func recordUnitUpgrade() {
        EngagementManager.shared.updateProgress(type: .upgradeUnits, amount: 1)
    }

    /// Called when a defense app is deployed
    func recordDefenseDeployed() {
        EngagementManager.shared.updateProgress(type: .deployDefense, amount: 1)
    }

    /// Called when level is completed - updates achievement stats
    func recordLevelCompletion(level: Int, damageTaken: Bool, timeInTicks: Int) {
        AchievementManager.shared.updateStats { stats in
            stats.highestLevelCompleted = max(stats.highestLevelCompleted, level)

            // Track best completion time
            if let existingTime = stats.levelCompletionTimes[level] {
                stats.levelCompletionTimes[level] = min(existingTime, timeInTicks)
            } else {
                stats.levelCompletionTimes[level] = timeInTicks
            }

            // Check for perfect level 1 completion
            if level == 1 && !damageTaken {
                stats.easterEggsFound.insert("perfect_level1")
            }
        }

        // Chance to award a data chip on level completion
        let _ = CollectionManager.shared.awardRandomChip(
            levelCompleted: level,
            threat: threatState.currentLevel.rawValue,
            attacks: threatState.attacksSurvived,
            reports: malusIntel.reportsSent,
            prestige: prestigeState.prestigeLevel
        )
    }

    /// Check for time-based easter eggs
    func checkTimeBasedEasterEggs() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour == 3 {
            AchievementManager.shared.triggerEasterEgg("night_3am")
        }
    }
}
