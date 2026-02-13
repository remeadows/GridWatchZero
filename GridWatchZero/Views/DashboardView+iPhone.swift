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

    // P0 FIX: All tick-driven reads go through `ds` (TickDisplayState).
    // Only structural/infrequent reads (levelConfiguration, loreState, isInCampaignMode)
    // and action closures (engine.upgradeSource()) stay on engine.
    // This scopes observation so only TickDisplayState triggers view invalidation per tick.

    var iPhoneLayout: some View {
        let ds = engine.displayState!

        return ZStack(alignment: .top) {
            // Main content in VStack
            VStack(spacing: 0) {
                // Tutorial hint banner (Level 1 only)
                if tutorialManager.shouldShowTutorial && !tutorialManager.isShowingDialogue {
                    TutorialHintBanner(tutorialManager: tutorialManager)
                }

                // Header with stats + threat indicator
                StatsHeaderView(
                credits: ds.credits,
                tickStats: ds.lastTickStats,
                currentTick: ds.currentTick,
                isRunning: ds.isRunning,
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
                threatState: ds.threatState,
                activeAttack: ds.activeAttack,
                attacksSurvived: ds.threatState.attacksSurvived,
                earlyWarning: ds.activeEarlyWarning
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
                        source: ds.source,
                        credits: ds.credits,
                        onUpgrade: { _ = engine.upgradeSource() }
                    )
                    .tutorialHighlight(.sourceCard, manager: tutorialManager)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Source node: \(ds.source.name), level \(ds.source.level), output \(ds.source.productionPerTick.formatted) per tick")
                    .accessibilityHint("Double tap to upgrade for \(ds.source.upgradeCost.formatted) credits")

                    // Connection: Source -> Link
                    ConnectionLineView(
                        isActive: ds.isRunning,
                        throughput: ds.lastTickStats.dataGenerated,
                        maxThroughput: ds.source.productionPerTick
                    )
                    .frame(height: 30)
                    .accessibilityHidden(true)

                    // Link Node (with attack indicator overlay)
                    ZStack {
                        LinkCardView(
                            link: ds.link,
                            credits: ds.credits,
                            onUpgrade: { _ = engine.upgradeLink() },
                            bufferedData: ds.totalBufferedData
                        )

                        // DDoS attack overlay
                        if let attack = ds.activeAttack,
                           attack.type == .ddos && attack.isActive {
                            DDoSOverlay()
                        }
                    }
                    .tutorialHighlight(.linkCard, manager: tutorialManager)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Link node: \(ds.link.name), level \(ds.link.level), bandwidth \(ds.link.bandwidth.formatted) per tick")
                    .accessibilityHint("Double tap to upgrade for \(ds.link.upgradeCost.formatted) credits")

                    // Connection: Link -> Sink
                    ConnectionLineView(
                        isActive: ds.isRunning,
                        throughput: ds.lastTickStats.dataTransferred,
                        maxThroughput: ds.link.bandwidth
                    )
                    .frame(height: 30)
                    .accessibilityHidden(true)

                    // Sink Node
                    SinkCardView(
                        sink: ds.sink,
                        credits: ds.credits,
                        onUpgrade: { _ = engine.upgradeSink() }
                    )
                    .tutorialHighlight(.sinkCard, manager: tutorialManager)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Sink node: \(ds.sink.name), level \(ds.sink.level), processing \(ds.sink.processingPerTick.formatted) per tick")
                    .accessibilityHint("Double tap to upgrade for \(ds.sink.upgradeCost.formatted) credits")

                    // Network Topology
                    NetworkTopologyView(
                        source: ds.source,
                        link: ds.link,
                        sink: ds.sink,
                        stack: ds.defenseStack,
                        isRunning: ds.isRunning,
                        tickStats: ds.lastTickStats,
                        threatLevel: ds.threatState.currentLevel,
                        activeAttack: ds.activeAttack,
                        malusIntel: ds.malusIntel
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .accessibilityLabel("Network topology visualization showing \(Int((1.0 - ds.lastTickStats.dropRate) * 100)) percent efficiency")

                    // Defense section header
                    sectionHeader("PERIMETER DEFENSE")
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 8)

                    // Firewall Node (legacy - still needed)
                    FirewallCardView(
                        firewall: ds.firewall,
                        credits: ds.credits,
                        damageAbsorbed: ds.lastTickStats.damageAbsorbed,
                        onUpgrade: { _ = engine.upgradeFirewall() },
                        onRepair: { _ = engine.repairFirewall() },
                        onPurchase: { _ = engine.purchaseFirewall() }
                    )
                    .tutorialHighlight(.firewallSection, manager: tutorialManager)
                    .padding(.horizontal)

                    // Security Applications Stack
                    DefenseStackView(
                        stack: ds.defenseStack,
                        credits: ds.credits,
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
                        threatState: ds.threatState,
                        totalGenerated: ds.totalDataGenerated,
                        totalTransferred: ds.totalDataTransferred,
                        totalDropped: ds.totalDataDropped,
                        totalProcessed: ds.totalDataProcessed
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Malus Intelligence Panel - moved after stats for stability
                    MalusIntelPanel(
                        intel: ds.malusIntel,
                        onSendReport: {
                            _ = engine.sendMalusReport()
                        },
                        onSendAll: {
                            _ = engine.sendAllMalusReports()
                        },
                        canSendAll: engine.canSendAllReports,
                        batchUpload: ds.batchUploadState,
                        earlyWarning: ds.activeEarlyWarning
                    )
                    .tutorialHighlight(.intelPanel, manager: tutorialManager)
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Prestige section (only in endless mode)
                    if !engine.isInCampaignMode {
                        PrestigeCardView(
                            prestigeState: ds.prestigeState,
                            totalCredits: ds.threatState.totalCreditsEarned,
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
