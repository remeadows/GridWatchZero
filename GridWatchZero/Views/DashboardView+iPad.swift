import SwiftUI

// MARK: - DashboardView iPad Layout Extension

extension DashboardView {

    // MARK: - iPad Layout (Side-by-side panels)

    var iPadLayout: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                let layoutMode = determineIPadLayout(for: geo.size.width)

                HStack(spacing: 0) {
                    // Left sidebar - Stats, Defense
                    iPadLeftSidebar(layoutMode: layoutMode)
                        .frame(width: layoutMode.sidebarWidth)
                        .background(Color.terminalDarkGray.opacity(0.5))

                    // Divider
                    Rectangle()
                        .fill(Color.neonGreen.opacity(0.3))
                        .frame(width: 1)

                    // Center main area - Network Map
                    iPadCenterPanel(layoutMode: layoutMode)
                        .frame(maxWidth: .infinity)
                        .background(Color.terminalDarkGray.opacity(0.3))

                    // Third column for expanded layout (Intel/Milestones)
                    if layoutMode.showsThirdColumn {
                        // Divider
                        Rectangle()
                            .fill(Color.neonCyan.opacity(0.3))
                            .frame(width: 1)

                        iPadRightSidebar
                            .frame(width: layoutMode.thirdColumnWidth)
                            .background(Color.terminalDarkGray.opacity(0.5))
                    }
                }
            }

            // Alert banner overlay (floats on top without pushing content)
            // Uses .overlay modifier approach for true floating behavior
            Color.clear
                .frame(height: 0)
                .overlay(alignment: .top) {
                    AlertBannerView(event: showingEvent)
                        .padding(.top, 60)  // Below the header
                }
                .allowsHitTesting(false)
                .zIndex(100)
        }
        .offset(x: reduceMotion ? 0 : screenShake)
    }

    // MARK: - iPad Left Sidebar

    func iPadLeftSidebar(layoutMode: IPadLayoutStyle) -> some View {
        VStack(spacing: 0) {
            // Header with stats
            iPadHeaderView

            // Threat bar
            ThreatBarView(
                threatState: engine.threatState,
                activeAttack: engine.activeAttack,
                attacksSurvived: engine.threatState.attacksSurvived,
                earlyWarning: engine.activeEarlyWarning
            )

            // Sidebar content
            ScrollView {
                VStack(spacing: 16) {
                    // Quick stats panel
                    iPadQuickStatsPanel

                    // Defense section
                    sectionHeader("PERIMETER DEFENSE")

                    // Compact firewall card matching Source/Link/Sink design
                    IPadCompactFirewallCard(
                        firewall: engine.firewall,
                        credits: engine.resources.credits,
                        onRepair: { _ = engine.repairFirewall() },
                        onUpgrade: { _ = engine.upgradeFirewall() },
                        onPurchase: { _ = engine.purchaseFirewall() }
                    )

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

                    // Prestige (only in endless mode, and only in 2-column)
                    if !layoutMode.showsThirdColumn && !engine.isInCampaignMode {
                        PrestigeCardView(
                            prestigeState: engine.prestigeState,
                            totalCredits: engine.threatState.totalCreditsEarned,
                            canPrestige: engine.canPrestige,
                            creditsRequired: engine.creditsRequiredForPrestige,
                            helixCoresReward: engine.helixCoresFromPrestige,
                            onPrestige: { showingPrestige = true }
                        )
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - iPad Center Panel (Network Map)

    func iPadCenterPanel(layoutMode: IPadLayoutStyle) -> some View {
        VStack(spacing: 0) {
            sectionHeader("NETWORK MAP")
                .padding(.top, 16)
                .padding(.horizontal)

            // Network map with wider cards
            ScrollView {
                VStack(spacing: 0) {
                    // Network Topology at top for iPad
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
                    .padding(.horizontal, layoutMode == .expanded ? 40 : 24)
                    .padding(.top, 16)

                    // Node cards - use horizontal layout with proper sizing
                    iPadNodeCards(layoutMode: layoutMode)
                        .padding(.horizontal, layoutMode == .expanded ? 40 : 24)
                        .padding(.top, 24)

                    // Network stats at bottom
                    ThreatStatsView(
                        threatState: engine.threatState,
                        totalGenerated: engine.totalDataGenerated,
                        totalTransferred: engine.totalDataTransferred,
                        totalDropped: engine.totalDataDropped,
                        totalProcessed: engine.resources.totalDataProcessed
                    )
                    .padding(.horizontal, layoutMode == .expanded ? 40 : 24)
                    .padding(.top, 24)

                    // Malus Intelligence - in center for 2-column, right sidebar for 3-column
                    if !layoutMode.showsThirdColumn {
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
                        .padding(.horizontal, layoutMode == .expanded ? 40 : 24)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
    }

    // MARK: - iPad Node Cards Layout

    @ViewBuilder
    func iPadNodeCards(layoutMode: IPadLayoutStyle) -> some View {
        if layoutMode.useVerticalCardLayout {
            // Vertical stack for compact mode (portrait)
            VStack(spacing: 0) {
                SourceCardView(
                    source: engine.source,
                    credits: engine.resources.credits,
                    onUpgrade: { _ = engine.upgradeSource() }
                )

                ConnectionLineView(
                    isActive: engine.isRunning,
                    throughput: engine.lastTickStats.dataGenerated,
                    maxThroughput: engine.source.productionPerTick
                )
                .frame(height: 30)

                ZStack {
                    LinkCardView(
                        link: engine.link,
                        credits: engine.resources.credits,
                        onUpgrade: { _ = engine.upgradeLink() },
                        bufferedData: engine.totalBufferedData
                    )
                    if let attack = engine.activeAttack,
                       attack.type == .ddos && attack.isActive {
                        DDoSOverlay()
                    }
                }

                ConnectionLineView(
                    isActive: engine.isRunning,
                    throughput: engine.lastTickStats.dataTransferred,
                    maxThroughput: engine.link.bandwidth
                )
                .frame(height: 30)

                SinkCardView(
                    sink: engine.sink,
                    credits: engine.resources.credits,
                    onUpgrade: { _ = engine.upgradeSink() }
                )
            }
        } else {
            // Horizontal layout for regular/expanded mode (landscape)
            // Use compact inline cards that stack stats vertically
            HStack(alignment: .top, spacing: 12) {
                // Source Card - Compact
                IPadCompactSourceCard(
                    source: engine.source,
                    credits: engine.resources.credits,
                    onUpgrade: { _ = engine.upgradeSource() }
                )
                .frame(minWidth: 180, maxWidth: .infinity)

                // Link Card - Compact
                IPadCompactLinkCard(
                    link: engine.link,
                    credits: engine.resources.credits,
                    activeAttack: engine.activeAttack,
                    onUpgrade: { _ = engine.upgradeLink() }
                )
                .frame(minWidth: 180, maxWidth: .infinity)

                // Sink Card - Compact
                IPadCompactSinkCard(
                    sink: engine.sink,
                    credits: engine.resources.credits,
                    onUpgrade: { _ = engine.upgradeSink() }
                )
                .frame(minWidth: 180, maxWidth: .infinity)
            }
        }
    }

    // MARK: - iPad Right Sidebar (Intel/Milestones - 3-column only)

    var iPadRightSidebar: some View {
        VStack(spacing: 0) {
            // Section header
            sectionHeader("INTEL & PROGRESS")
                .padding(.horizontal)
                .padding(.top, 16)

            ScrollView {
                VStack(spacing: 16) {
                    // Malus Intel
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

                    // Recent lore/intel teaser
                    iPadRecentIntelPanel

                    // Prestige (only in endless mode)
                    if !engine.isInCampaignMode {
                        PrestigeCardView(
                            prestigeState: engine.prestigeState,
                            totalCredits: engine.threatState.totalCreditsEarned,
                            canPrestige: engine.canPrestige,
                            creditsRequired: engine.creditsRequiredForPrestige,
                            helixCoresReward: engine.helixCoresFromPrestige,
                            onPrestige: { showingPrestige = true }
                        )
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - iPad Recent Intel Panel (for 3-column layout)

    var iPadRecentIntelPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Text("[ RECENT INTEL ]")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                Spacer()

                if engine.loreState.unreadCount > 0 {
                    Text("\(engine.loreState.unreadCount) NEW")
                        .font(.terminalMicro)
                        .foregroundColor(.neonAmber)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.neonAmber.opacity(0.2))
                        .cornerRadius(2)
                }
            }

            // Show last unlocked lore fragment preview
            if let lastFragment = engine.loreState.unlockedFragments.last {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: lastFragment.category.icon)
                            .font(.system(size: 12))
                            .foregroundColor(loreCategoryColor(lastFragment.category))

                        Text(lastFragment.title)
                            .font(.terminalSmall)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }

                    Text(String(lastFragment.content.prefix(80)) + (lastFragment.content.count > 80 ? "..." : ""))
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                        .lineLimit(2)
                }
                .padding(10)
                .background(Color.terminalDarkGray)
                .cornerRadius(4)
            }

            Button(action: { showingLore = true }) {
                HStack {
                    Image(systemName: "book.fill")
                    Text("VIEW ALL INTEL")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.terminalSmall)
                .foregroundColor(.neonCyan)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.terminalDarkGray)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .terminalCard(borderColor: .terminalGray)
    }

    func loreCategoryColor(_ category: LoreCategory) -> Color {
        switch category {
        case .world: return .terminalGray
        case .helix: return .neonCyan
        case .malus: return .neonRed
        case .team: return .neonGreen
        case .intel: return .neonAmber
        }
    }

    // MARK: - iPad Header View

    var iPadHeaderView: some View {
        VStack(spacing: 0) {
            // Campaign level bar (if in campaign mode)
            if let config = engine.levelConfiguration {
                HStack(spacing: 8) {
                    // Back button
                    if let exitAction = onCampaignExit {
                        Button(action: exitAction) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("EXIT")
                                    .font(.terminalMicro)
                            }
                            .foregroundColor(.neonCyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonCyan.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .accessibilityLabel("Exit to campaign menu")
                    }

                    // Level info
                    HStack(spacing: 6) {
                        Text("LEVEL \(config.level.id)")
                            .font(.terminalMicro)
                            .foregroundColor(.neonCyan)

                        Text("•")
                            .foregroundColor(.terminalGray)

                        Text(config.level.name.uppercased())
                            .font(.terminalMicro)
                            .foregroundColor(.white)
                            .lineLimit(1)

                        if config.isInsane {
                            Text("INSANE")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalBlack)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.neonRed)
                                .cornerRadius(2)
                        }
                    }

                    Spacer()

                    // Campaign objective progress
                    HStack(spacing: 12) {
                        // Credits progress (if required)
                        if let creditsRequired = config.level.victoryConditions.requiredCredits {
                            HStack(spacing: 4) {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.neonAmber)
                                Text("\(engine.resources.credits.formatted)/\(creditsRequired.formatted)")
                                    .font(.terminalMicro)
                                    .foregroundColor(engine.resources.credits >= creditsRequired ? .neonGreen : .terminalGray)
                            }
                        }

                        // Intel reports progress (if required)
                        if let reportsRequired = config.level.victoryConditions.requiredReportsSent {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.neonCyan)
                                Text("\(engine.malusIntel.reportsSent)/\(reportsRequired)")
                                    .font(.terminalMicro)
                                    .foregroundColor(engine.malusIntel.reportsSent >= reportsRequired ? .neonGreen : .terminalGray)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.neonCyan.opacity(0.1))
            }

            // Main header row
            HStack(spacing: 12) {
                // Title
                Text("GRID WATCH ZERO")
                    .font(.terminalTitle)
                    .foregroundColor(.neonGreen)
                    .glow(.neonGreen, radius: 4)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                // Credits
                HStack(spacing: 4) {
                    Text("¢")
                        .font(.terminalBody)
                        .foregroundColor(.neonAmber)
                    Text(engine.resources.credits.formatted)
                        .font(.terminalTitle)
                        .foregroundColor(.neonAmber)
                        .glow(.neonAmber, radius: 3)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(engine.resources.credits.formatted) credits")

                // Control buttons
                HStack(spacing: 4) {
                    Button(action: { showingLore = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.neonCyan)
                                .frame(width: 36, height: 36)
                                .background(Color.terminalDarkGray)
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.neonCyan.opacity(0.5), lineWidth: 1)
                                )

                            if engine.loreState.unreadCount > 0 {
                                Circle()
                                    .fill(Color.neonAmber)
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        Text("\(min(engine.loreState.unreadCount, 9))")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.terminalBlack)
                                    )
                                    .offset(x: 3, y: -3)
                            }
                        }
                    }
                    .accessibilityLabel("Intel. \(engine.loreState.unreadCount) unread")

                    Button(action: { showingMilestones = true }) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.neonAmber)
                            .frame(width: 36, height: 36)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonAmber.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Milestones")

                    Button(action: { showingShop = true }) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.neonAmber)
                            .frame(width: 36, height: 36)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonAmber.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Shop")

                    Button(action: { engine.toggle() }) {
                        Image(systemName: engine.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.neonGreen)
                            .frame(width: 36, height: 36)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonGreen.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel(engine.isRunning ? "Pause game" : "Resume game")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(Color.terminalDarkGray)
    }

    // MARK: - iPad Quick Stats Panel

    var iPadQuickStatsPanel: some View {
        VStack(spacing: 12) {
            sectionHeader("LIVE STATS")

            HStack(spacing: 16) {
                iPadStatBox(label: "GEN", value: engine.lastTickStats.dataGenerated.formatted, color: .neonGreen)
                iPadStatBox(label: "TX", value: engine.lastTickStats.dataTransferred.formatted, color: .neonCyan)
                iPadStatBox(label: "DROP", value: engine.lastTickStats.dataDropped.formatted, color: engine.lastTickStats.dataDropped > 0 ? .neonRed : .terminalGray)
                iPadStatBox(label: "EARN", value: "¢\(engine.lastTickStats.creditsEarned.formatted)", color: .neonAmber)
            }

            // Tick indicator
            HStack {
                Circle()
                    .fill(engine.isRunning ? Color.neonGreen : Color.neonRed)
                    .frame(width: 8, height: 8)
                    .glow(engine.isRunning ? .neonGreen : .neonRed, radius: 3)

                Text("Tick \(engine.currentTick)")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                Spacer()

                Text(engine.isRunning ? "RUNNING" : "PAUSED")
                    .font(.terminalMicro)
                    .foregroundColor(engine.isRunning ? .neonGreen : .neonRed)
            }
        }
        .terminalCard(borderColor: .terminalGray)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Live stats: Generated \(engine.lastTickStats.dataGenerated.formatted), transferred \(engine.lastTickStats.dataTransferred.formatted), dropped \(engine.lastTickStats.dataDropped.formatted), earned \(engine.lastTickStats.creditsEarned.formatted) credits. Tick \(engine.currentTick), \(engine.isRunning ? "running" : "paused")")
    }

    func iPadStatBox(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.terminalMicro)
                .foregroundColor(.terminalGray)
            Text(value)
                .font(.terminalBody)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}
