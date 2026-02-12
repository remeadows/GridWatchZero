import Foundation

// MARK: - Critical Alarm

extension GameEngine {

    /// Check if critical alarm should show
    var shouldShowCriticalAlarm: Bool {
        // ISSUE-020: Suppress critical alarm during attack grace period
        // Without this, the alarm fires at tick 0 on elevated-threat levels and blocks the dashboard
        if isInCampaignMode,
           let gracePeriod = levelConfiguration?.attackGracePeriod,
           gracePeriod > 0,
           currentTick < levelStartTick + gracePeriod {
            return false
        }

        // Show if risk is HUNTED or MARKED and not acknowledged
        let riskLevel = threatState.effectiveRiskLevel
        return (riskLevel == .hunted || riskLevel == .marked) && !criticalAlarmAcknowledged
    }

    /// Acknowledge critical alarm
    func acknowledgeCriticalAlarm() {
        criticalAlarmAcknowledged = true
        showCriticalAlarm = false
        saveGame()
    }

    /// Reset alarm acknowledgement (called when risk drops)
    func checkCriticalAlarmReset() {
        // ISSUE-020: Don't trigger alarm during attack grace period
        if isInCampaignMode,
           let gracePeriod = levelConfiguration?.attackGracePeriod,
           gracePeriod > 0,
           currentTick < levelStartTick + gracePeriod {
            return
        }

        let riskLevel = threatState.effectiveRiskLevel
        if riskLevel.rawValue < ThreatLevel.hunted.rawValue {
            criticalAlarmAcknowledged = false
        } else if !criticalAlarmAcknowledged {
            showCriticalAlarm = true
        }
    }
}
