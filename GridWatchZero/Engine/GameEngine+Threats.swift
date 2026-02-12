import Foundation

// MARK: - Threat Processing

extension GameEngine {

    func processThreats(_ stats: inout TickStats) {
        // Check critical alarm state
        checkCriticalAlarmReset()

        // === AUTOMATION: Auto-repair firewall ===
        if defenseStack.totalAutomation >= 0.25 {
            autoRepairFirewall()
        }

        // === AUTOMATION: Passive intel generation ===
        // Only generates intel if defense apps are deployed (automation comes from apps anyway)
        if defenseStack.totalAutomation >= 0.75 && defenseStack.deployedCount >= 1 {
            let passiveIntel = 1.0 * defenseStack.totalAutomation
            malusIntel.addFootprintData(passiveIntel, detectionMultiplier: defenseStack.totalIntelBonus)
        }

        // Process active attack
        if var attack = activeAttack, attack.isActive {
            // Calculate player's current income for attack scaling
            let playerIncome = lastTickStats.creditsEarned
            var damage = attack.damagePerTick(playerIncomePerTick: playerIncome)

            // Apply damage multiplier from campaign mode (e.g., 1.5x for Insane)
            let damageMultiplier = levelConfiguration?.damageMultiplier ?? 1.0
            damage.creditDrain *= damageMultiplier
            damage.bandwidthReduction = min(1.0, damage.bandwidthReduction * damageMultiplier)
            damage.nodeDisableChance = min(1.0, damage.nodeDisableChance * damageMultiplier)
            damage.processingReduction = min(1.0, damage.processingReduction * damageMultiplier)

            // Defense reduces DAMAGE (not attack frequency)
            // 1. NetDefenseLevel provides base damage reduction (8% per level, up to 72%)
            let netDefenseReduction = threatState.riskCalculation.damageReduction
            // 2. Defense stack and intel add additional reduction
            let stackReduction = defenseStack.totalDamageReduction + malusIntel.damageReductionBonus
            // Combine reductions: apply NetDefense first, then stack reduction on remaining
            // This creates diminishing returns rather than simple addition
            let afterNetDefense = 1.0 - netDefenseReduction
            let totalReduction = netDefenseReduction + (afterNetDefense * min(0.65, stackReduction))
            // Cap total reduction at 90% for T8+ to help with late game (ISSUE-033)
            // Increased from 85% to 90% to make Levels 9-20 more survivable
            let cappedReduction = min(0.90, totalReduction)
            damage.creditDrain *= (1.0 - cappedReduction)
            damage.bandwidthReduction *= (1.0 - cappedReduction)

            // Firewall absorbs remaining damage
            if var fw = firewall, !fw.isDestroyed {
                let creditDamage = damage.creditDrain
                let remainingDamage = fw.absorbDamage(creditDamage)
                stats.damageAbsorbed = creditDamage - remainingDamage
                damage.creditDrain = remainingDamage

                // Write absorbed damage back to attack for stats and intel tracking
                attack.blocked += stats.damageAbsorbed

                // Check if firewall was destroyed
                if fw.isDestroyed && firewall?.isDestroyed != true {
                    emitEvent(.firewallDestroyed)
                }

                firewall = fw
            }

            // Sprint B: Apply Encryption credit protection + intel milestone bonus
            let creditProtection = min(0.90, defenseStack.totalCreditProtection + malusIntel.creditProtectionBonus)
            if creditProtection > 0 {
                damage.creditDrain *= (1.0 - creditProtection)
            }

            // Apply remaining credit drain
            if damage.creditDrain > 0 {
                let actualDrain = min(resources.credits, damage.creditDrain)
                resources.credits -= actualDrain
                stats.creditsDrained = actualDrain
                attack.damageDealt += actualDrain
                threatState.totalDamageReceived += actualDrain
            }

            // Apply bandwidth reduction
            // Sprint B: Network packet loss protection reduces bandwidth debuff
            let packetLossProtection = defenseStack.totalPacketLossProtection
            bandwidthDebuff = damage.bandwidthReduction * (1.0 - packetLossProtection)

            // Apply processing reduction (reduces sink credit output during attacks)
            processingDebuff = damage.processingReduction * (1.0 - cappedReduction)

            // Check for node disable
            if damage.nodeDisableChance > 0 {
                let roll = Double.random(in: 0...1, using: &rng)
                if roll < damage.nodeDisableChance {
                    emitEvent(.nodeDisabled("System temporarily disrupted"))
                }
            }

            // === AUTOMATION: Reduced attack duration ===
            var ticksToProcess = 1
            if defenseStack.totalAutomation >= 0.50 {
                // Chance to process extra tick (faster attack resolution)
                let extraTickChance = (defenseStack.totalAutomation - 0.50) * 2.0  // 0-100% at 0.5-1.0
                if Double.random(in: 0...1, using: &rng) < extraTickChance {
                    ticksToProcess = 2
                }
            }

            for _ in 0..<ticksToProcess {
                attack.tick()
            }
            activeAttack = attack

            // Check if attack ended
            if !attack.isActive {
                threatState.attacksSurvived += 1
                emitEvent(.attackEnded(attack.type, survived: true))
                AudioManager.shared.playSound(.attackEnd)

                // Unlock Malus dossier on first survived attack
                if threatState.attacksSurvived == 1 {
                    DossierManager.shared.unlockMalusDossier()
                }

                // Track for campaign mode
                if isInCampaignMode {
                    levelAttacksSurvived += 1
                    levelDamageBlocked += attack.blocked
                }

                // Track for engagement system (damage taken = damageDealt - blocked)
                let damageTaken = attack.damageDealt - attack.blocked
                recordAttackSurvived(damageTaken: damageTaken)

                // Collect Malus footprint data from the attack (with detection bonus)
                collectMalusFootprint(attack)
                activeAttack = nil
                bandwidthDebuff = 0
                processingDebuff = 0
            }
        } else {
            // No active attack - check for new attack
            bandwidthDebuff = 0
            processingDebuff = 0

            // ISSUE-020: Attack grace period — suppress new attacks early in level
            // Gives player time to earn credits and deploy initial defenses
            if isInCampaignMode,
               let gracePeriod = levelConfiguration?.attackGracePeriod,
               gracePeriod > 0,
               currentTick < levelStartTick + gracePeriod {
                return  // Skip attack generation during grace period
            }

            // Sprint D: Process active early warning countdown
            if var warning = activeEarlyWarning {
                warning.tick()
                if warning.isExpired {
                    // Warning countdown finished — decide if attack actually lands
                    let attackLands = Double.random(in: 0...1, using: &rng) < warning.accuracy
                    activeEarlyWarning = nil

                    if attackLands {
                        // Predicted attack arrives
                        let frequencyMultiplier = levelConfiguration?.threatMultiplier ?? 1.0
                        let severity = Double.random(in: 0.5...2.0, using: &rng) * frequencyMultiplier
                        let newAttack = Attack(type: warning.predictedAttackType, severity: severity, startTick: currentTick)
                        activeAttack = newAttack
                        emitEvent(.attackStarted(newAttack.type))
                        AudioManager.shared.playSound(.attackIncoming)
                    }
                    // If !attackLands: false positive — warning was wrong, no attack
                } else {
                    activeEarlyWarning = warning
                }
                return  // While warning is active, no other attack generation
            }

            // Sprint D: IDS Early Warning Prediction System
            // If IDS level >= 10, try to predict the next attack instead of just blocking
            let idsLevel = defenseStack.totalIdsLevel
            if let params = EarlyWarning.parameters(forIdsLevel: idsLevel) {
                // Roll to see if we would have generated an attack this tick
                let frequencyMultiplier = levelConfiguration?.threatMultiplier ?? 1.0
                let minimumAttackChance = levelConfiguration?.minimumAttackChance ?? 0.0
                if let predictedAttack = AttackGenerator.tryGenerateAttack(
                    threatLevel: threatState.currentLevel,
                    currentTick: currentTick,
                    random: &rng,
                    frequencyReduction: defenseStack.attackFrequencyReduction + malusIntel.attackFrequencyReductionBonus,
                    frequencyMultiplier: frequencyMultiplier,
                    minimumChance: minimumAttackChance
                ) {
                    // IDS detected incoming attack — start countdown instead of immediate attack
                    let warning = EarlyWarning(
                        predictedAttackType: predictedAttack.type,
                        warningTicks: params.ticks,
                        accuracy: params.accuracy,
                        ticksRemaining: params.ticks
                    )
                    activeEarlyWarning = warning
                    emitEvent(.earlyWarning(predictedAttack.type, params.ticks, params.accuracy))
                    AudioManager.shared.playSound(.warning)
                    return
                }
            } else {
                // Legacy behavior for IDS level < 10: simple block chance from milestones + IDS
                let warningChance = malusIntel.attackWarningChance + defenseStack.totalEarlyWarningChance
                var attackBlocked = false
                if warningChance > 0 && Double.random(in: 0...1, using: &rng) < warningChance {
                    attackBlocked = true
                }

                if !attackBlocked {
                    let frequencyMultiplier = levelConfiguration?.threatMultiplier ?? 1.0
                    let minimumAttackChance = levelConfiguration?.minimumAttackChance ?? 0.0
                    if let newAttack = AttackGenerator.tryGenerateAttack(
                        threatLevel: threatState.currentLevel,
                        currentTick: currentTick,
                        random: &rng,
                        frequencyReduction: defenseStack.attackFrequencyReduction + malusIntel.attackFrequencyReductionBonus,
                        frequencyMultiplier: frequencyMultiplier,
                        minimumChance: minimumAttackChance
                    ) {
                        activeAttack = newAttack
                        emitEvent(.attackStarted(newAttack.type))
                        AudioManager.shared.playSound(.attackIncoming)
                    }
                }
            }
        }
    }

    /// Auto-repair firewall when automation is high enough
    func autoRepairFirewall() {
        guard var fw = firewall, fw.currentHealth < fw.maxHealth else { return }

        // Auto-repair rate: 1% of max health per tick at 0.25 automation, up to 3% at 1.0
        // Sprint B: Endpoint recovery bonus boosts repair rate
        let recoveryBonus = defenseStack.totalRecoveryBonus
        let repairRate = 0.01 + (defenseStack.totalAutomation - 0.25) * 0.027 + recoveryBonus
        let repairAmount = fw.maxHealth * repairRate
        fw.currentHealth = min(fw.maxHealth, fw.currentHealth + repairAmount)
        firewall = fw
    }

    // MARK: - Malus Messages

    func triggerMalusMessage(for level: ThreatLevel) {
        let messages: [ThreatLevel: String] = [
            .blip: "> anomaly detected...",
            .signal: "> tracing signal origin...",
            .target: "> target acquired. monitoring.",
            .priority: "> escalating priority. resources allocated.",
            .hunted: "> MALUS ONLINE. HUNTING PROTOCOL ACTIVE.",
            .marked: ">> I SEE YOU. HELIX WILL BE MINE. <<"
        ]

        if let message = messages[level] {
            emitEvent(.malusMessage(message))
            threatState.malusEncounters += 1
            threatState.lastMalusMessageTick = currentTick
        }
    }
}
