import SwiftUI

// MARK: - DashboardView iPhone Layout Extension

extension DashboardView {

    // MARK: - Shared Components

    func sectionHeader(_ title: String) -> some View {
        HStack {
            Text("[ \(title) ]")
                .font(.terminalSmall)
                .foregroundColor(.terminalGray)

            Rectangle()
                .fill(Color.terminalGray.opacity(0.3))
                .frame(height: 1)
        }
    }

    // MARK: - iPhone Layout (Original stacked layout)

    var iPhoneLayout: some View {
        ZStack(alignment: .top) {
            // Main content in VStack
            VStack(spacing: 0) {
                // Tutorial hint banner (Level 1 only)
                if tutorialManager.shouldShowTutorial && !tutorialManager.isShowingDialogue {
                    TutorialHintBanner(tutorialManager: tutorialManager)
                }

                // Header with stats + threat indicator
                StatsHeaderView(
                credits: engine.resources.credits,
                tickStats: engine.lastTickStats,
                currentTick: engine.currentTick,
                isRunning: engine.isRunning,
                unreadLore: engine.loreState.unreadCount,
                onToggle: { engine.toggle() },
                onReset: { engine.resetGame() },
                onShop: { showingShop = true },
                onLore: { showingLore = true },
                onMilestones: { showingMilestones = true },
                onSettings: { showingSettings = true },
                campaignLevelId: engine.levelConfiguration?.level.id,
                campaignLevelName: engine.levelConfiguration?.level.name,
                isInsaneMode: engine.levelConfiguration?.isInsane ?? false,
                onPauseCampaign: onCampaignExit
            )

            // Threat / Defense / Risk bar (fixed height to prevent layout shift)
            ThreatBarView(
                threatState: engine.threatState,
                activeAttack: engine.activeAttack,
                attacksSurvived: engine.threatState.attacksSurvived,
                earlyWarning: engine.activeEarlyWarning
            )
            .frame(height: 32)
            .clipped()

            // Reserved alert space — alerts populate here without pushing content
            // Maintains fixed height so ScrollView never shifts position
            ZStack {
                // Subtle background keeps the space from looking empty
                Color.terminalDarkGray.opacity(0.3)

                AlertBannerView(event: showingEvent)
            }
            .frame(height: 60)
            .clipped()

            // Network Map
            ScrollView {
                VStack(spacing: 0) {
                    // Section header
                    sectionHeader("NETWORK MAP")
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    // Source Node
                    SourceCardView(
                        source: engine.source,
                        credits: engine.resources.credits,
                        onUpgrade: { _ = engine.upgradeSource() }
                    )
                    .tutorialHighlight(.sourceCard, manager: tutorialManager)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Source node: \(engine.source.name), level \(engine.source.level), output \(engine.source.productionPerTick.formatted) per tick")
                    .accessibilityHint("Double tap to upgrade for \(engine.source.upgradeCost.formatted) credits")

                    // Connection: Source -> Link
                    ConnectionLineView(
                        isActive: engine.isRunning,
                        throughput: engine.lastTickStats.dataGenerated,
                        maxThroughput: engine.source.productionPerTick
                    )
                    .frame(height: 30)
                    .accessibilityHidden(true)

                    // Link Node (with attack indicator overlay)
                    ZStack {
                        LinkCardView(
                            link: engine.link,
                            credits: engine.resources.credits,
                            onUpgrade: { _ = engine.upgradeLink() },
                            bufferedData: engine.latencyBuffer.reduce(0.0) { $0 + $1.amount }
                        )

                        // DDoS attack overlay
                        if let attack = engine.activeAttack,
                           attack.type == .ddos && attack.isActive {
                            DDoSOverlay()
                        }
                    }
                    .tutorialHighlight(.linkCard, manager: tutorialManager)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Link node: \(engine.link.name), level \(engine.link.level), bandwidth \(engine.link.bandwidth.formatted) per tick")
                    .accessibilityHint("Double tap to upgrade for \(engine.link.upgradeCost.formatted) credits")

                    // Connection: Link -> Sink
                    ConnectionLineView(
                        isActive: engine.isRunning,
                        throughput: engine.lastTickStats.dataTransferred,
                        maxThroughput: engine.link.bandwidth
                    )
                    .frame(height: 30)
                    .accessibilityHidden(true)

                    // Sink Node
                    SinkCardView(
                        sink: engine.sink,
                        credits: engine.resources.credits,
                        onUpgrade: { _ = engine.upgradeSink() }
                    )
                    .tutorialHighlight(.sinkCard, manager: tutorialManager)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Sink node: \(engine.sink.name), level \(engine.sink.level), processing \(engine.sink.processingPerTick.formatted) per tick")
                    .accessibilityHint("Double tap to upgrade for \(engine.sink.upgradeCost.formatted) credits")

                    // Network Topology
                    NetworkTopologyView(
                        source: engine.source,
                        link: engine.link,
                        sink: engine.sink,
                        stack: engine.defenseStack,
                        isRunning: engine.isRunning,
                        tickStats: engine.lastTickStats,
                        threatLevel: engine.threatState.currentLevel,
                        activeAttack: engine.activeAttack,
                        malusIntel: engine.malusIntel
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .accessibilityLabel("Network topology visualization showing \(Int((1.0 - engine.lastTickStats.dropRate) * 100)) percent efficiency")

                    // Defense section header
                    sectionHeader("PERIMETER DEFENSE")
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 8)

                    // Firewall Node (legacy - still needed)
                    FirewallCardView(
                        firewall: engine.firewall,
                        credits: engine.resources.credits,
                        damageAbsorbed: engine.lastTickStats.damageAbsorbed,
                        onUpgrade: { _ = engine.upgradeFirewall() },
                        onRepair: { _ = engine.repairFirewall() },
                        onPurchase: { _ = engine.purchaseFirewall() }
                    )
                    .tutorialHighlight(.firewallSection, manager: tutorialManager)
                    .padding(.horizontal)

                    // Security Applications Stack
                    DefenseStackView(
                        stack: engine.defenseStack,
                        credits: engine.resources.credits,
                        maxTierAvailable: engine.maxTierAvailable,
                        onUpgrade: { category in
                            _ = engine.upgradeDefenseApp(category)
                        },
                        onDeploy: { tier in
                            _ = engine.deployDefenseApp(tier)
                        },
                        onUnlock: { tier in
                            _ = engine.unlockDefenseTier(tier)
                        }
                    )
                    .tutorialHighlight(.defenseApps, manager: tutorialManager)
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Bottom stats
                    ThreatStatsView(
                        threatState: engine.threatState,
                        totalGenerated: engine.totalDataGenerated,
                        totalTransferred: engine.totalDataTransferred,
                        totalDropped: engine.totalDataDropped,
                        totalProcessed: engine.resources.totalDataProcessed
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Malus Intelligence Panel - moved after stats for stability
                    MalusIntelPanel(
                        intel: engine.malusIntel,
                        onSendReport: {
                            _ = engine.sendMalusReport()
                        },
                        onSendAll: {
                            _ = engine.sendAllMalusReports()
                        },
                        canSendAll: engine.canSendAllReports,
                        batchUpload: engine.batchUploadState,
                        earlyWarning: engine.activeEarlyWarning
                    )
                    .tutorialHighlight(.intelPanel, manager: tutorialManager)
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Prestige section (only in endless mode)
                    if !engine.isInCampaignMode {
                        PrestigeCardView(
                            prestigeState: engine.prestigeState,
                            totalCredits: engine.threatState.totalCreditsEarned,
                            canPrestige: engine.canPrestige,
                            creditsRequired: engine.creditsRequiredForPrestige,
                            helixCoresReward: engine.helixCoresFromPrestige,
                            onPrestige: { showingPrestige = true }
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            }  // End of main VStack

            // Alert banner moved to reserved space between ThreatBarView and ScrollView
            // (see "Reserved alert space" above — replaces old floating overlay)
        }  // End of ZStack
        .offset(x: reduceMotion ? 0 : screenShake)
    }
}
