import Foundation

// MARK: - Defense Stack Management

extension GameEngine {

    /// Unlock a defense application tier
    func unlockDefenseTier(_ tier: DefenseAppTier) -> Bool {
        guard defenseStack.canUnlock(tier) else { return false }
        guard resources.spendCredits(tier.unlockCost) else { return false }

        defenseStack.unlock(tier)
        emitEvent(.unitUnlocked(tier.displayName))
        AudioManager.shared.playSound(.equip)  // Play equip sound when unlocking new defense
        saveGame()
        return true
    }

    /// Deploy a defense application
    func deployDefenseApp(_ tier: DefenseAppTier) -> Bool {
        guard defenseStack.isUnlocked(tier) else { return false }

        defenseStack.deploy(tier)
        emitEvent(.milestone("Deployed: \(tier.displayName)"))
        AudioManager.shared.playSound(.equip)  // Play equip sound when deploying defense
        TutorialManager.shared.recordAction(.deployedDefenseApp)
        recordDefenseDeployed()
        saveGame()
        return true
    }

    /// Upgrade a deployed defense application
    func upgradeDefenseApp(_ category: DefenseCategory) -> Bool {
        guard let app = defenseStack.application(for: category) else { return false }
        guard resources.spendCredits(app.upgradeCost) else { return false }

        _ = defenseStack.upgrade(category)
        AudioManager.shared.playSound(.upgrade)
        saveGame()
        return true
    }
}
