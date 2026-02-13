// DashboardView.swift
// GridWatchZero
// Main game dashboard showing the neural grid network

import SwiftUI

struct DashboardView: View {
    @Environment(GameEngine.self) var engine
    @EnvironmentObject var cloudManager: CloudSaveManager
    @EnvironmentObject var campaignState: CampaignState
    @StateObject var tutorialManager = TutorialManager.shared
    @StateObject var engagementManager = EngagementManager.shared
    @StateObject var achievementManager = AchievementManager.shared
    @StateObject var collectionManager = CollectionManager.shared
    @State var showingEvent: GameEvent? = nil
    @State var screenShake: CGFloat = 0
    @State var showingShop = false
    @State var showingLore = false
    @State var showingMilestones = false
    @State var showingOfflineProgress = false
    @State var showingPrestige = false
    @State var showingCriticalAlarm = false
    @State var showingSettings = false
    @State private var eventBannerTask: Task<Void, Never>?
    @State private var shakeTask: Task<Void, Never>?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // Campaign exit callback (nil for endless mode)
    var onCampaignExit: (() -> Void)? = nil

    // iPad layout breakpoints
    enum IPadLayoutStyle {
        case compact    // iPad Mini, iPad in slide-over
        case regular    // Standard iPad (10.9", 11")
        case expanded   // iPad Pro 12.9" and larger

        var sidebarWidth: CGFloat {
            switch self {
            case .compact: return 300
            case .regular: return 320
            case .expanded: return 340
            }
        }

        var showsThirdColumn: Bool {
            self == .expanded
        }

        var thirdColumnWidth: CGFloat {
            280
        }

        // Use vertical card layout when center panel is narrow
        var useVerticalCardLayout: Bool {
            self == .compact
        }
    }

    func determineIPadLayout(for width: CGFloat) -> IPadLayoutStyle {
        if width >= 1200 {
            return .expanded  // iPad Pro 12.9" landscape
        } else if width >= 1000 {
            return .regular   // Standard iPad landscape
        } else {
            return .compact   // iPad portrait or smaller
        }
    }

    var body: some View {
        ZStack {
            // Glass HUD background with micro-noise texture
            GlassDashboardBackground()

            // Scanline overlay effect
            ScanlineOverlay()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // iPad uses split view, iPhone uses stacked view
            if horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }

            // Critical Alarm Overlay
            if showingCriticalAlarm {
                CriticalAlarmView(
                    threatLevel: engine.threatState.currentLevel,
                    riskLevel: engine.threatState.effectiveRiskLevel,
                    activeAttack: engine.activeAttack,
                    defenseStack: engine.defenseStack,
                    onAcknowledge: {
                        engine.acknowledgeCriticalAlarm()
                        showingCriticalAlarm = false
                    },
                    onBoostDefenses: {
                        showingCriticalAlarm = false
                        showingShop = true
                    }
                )
                .transition(.opacity)
                .zIndex(200)
            }

            // Tutorial Overlay (Level 1 only)
            if tutorialManager.shouldShowTutorial {
                TutorialOverlayView(tutorialManager: tutorialManager)
                    .zIndex(300)
            }

            // Daily Reward Popup
            if engagementManager.showDailyRewardPopup {
                DailyRewardPopupView(
                    engagementManager: engagementManager,
                    onClaim: { credits in
                        engine.addCredits(credits)
                        AudioManager.shared.playSound(.milestone)
                    }
                )
                .zIndex(400)
            }

            // Achievement Unlock Popup
            if achievementManager.showAchievementPopup,
               let achievement = achievementManager.pendingUnlocks.first {
                AchievementUnlockPopupView(
                    achievement: achievement,
                    onDismiss: {
                        engine.addCredits(achievement.rewardCredits)
                        achievementManager.dismissAchievementPopup()
                    }
                )
                .zIndex(401)
            }

            // Data Chip Unlock Popup
            if collectionManager.showChipUnlock,
               let chip = collectionManager.pendingChips.first {
                DataChipUnlockPopupView(
                    chip: chip,
                    onDismiss: {
                        collectionManager.dismissChipPopup()
                    }
                )
                .zIndex(402)
            }
        }
        .onAppear {
            engine.start()
            // Check for offline progress
            if engine.offlineProgress != nil {
                showingOfflineProgress = true
            }
            // Check for critical alarm
            if engine.shouldShowCriticalAlarm {
                showingCriticalAlarm = true
            }
            // Start tutorial for Level 1 (if not completed)
            if engine.levelConfiguration?.level.id == 1 && !tutorialManager.state.hasCompletedTutorial {
                // Delay to let intro story finish
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    tutorialManager.startTutorialForLevel1()
                }
            }
        }
        .onChange(of: engine.lastEvent) { _, newEvent in
            handleEvent(newEvent)
        }
        .onChange(of: engine.showCriticalAlarm) { _, shouldShow in
            if shouldShow {
                withAnimation {
                    showingCriticalAlarm = true
                }
            }
        }
        .onChange(of: engine.offlineProgress) { _, newValue in
            if newValue != nil {
                showingOfflineProgress = true
            }
        }
        .sheet(isPresented: $showingShop) {
            UnitShopView(engine: engine)
        }
        .sheet(isPresented: $showingLore) {
            LoreView(engine: engine)
        }
        .sheet(isPresented: $showingMilestones) {
            MilestonesView(engine: engine)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environment(engine)
                .environmentObject(cloudManager)
                .environmentObject(campaignState)
        }
        .sheet(isPresented: $showingOfflineProgress) {
            if let progress = engine.offlineProgress {
                OfflineProgressView(progress: progress) {
                    engine.dismissOfflineProgress()
                    showingOfflineProgress = false
                }
            }
        }
        .sheet(isPresented: $showingPrestige) {
            PrestigeConfirmView(
                prestigeState: engine.prestigeState,
                totalCredits: engine.threatState.totalCreditsEarned,
                creditsRequired: engine.creditsRequiredForPrestige,
                helixCoresReward: engine.helixCoresFromPrestige,
                onConfirm: {
                    _ = engine.performPrestige()
                    showingPrestige = false
                },
                onCancel: {
                    showingPrestige = false
                }
            )
        }
        .preferredColorScheme(.dark)
    }

    // P3 fix: Cancellable Tasks replace DispatchQueue.main.asyncAfter
    // Prevents event banner stacking and orphaned shake animations

    private func handleEvent(_ event: GameEvent?) {
        guard let event = event else { return }

        // Cancel any pending banner dismissal
        eventBannerTask?.cancel()

        // Show banner
        withAnimation {
            showingEvent = event
        }

        // Screen shake for attacks
        if case .attackStarted = event {
            triggerScreenShake()
        }

        // Auto-hide banner after delay (cancellable)
        let hideDelay: UInt64 = {
            switch event {
            case .malusMessage: return 5_000_000_000
            case .attackStarted: return 3_000_000_000
            default: return 2_000_000_000
            }
        }()

        eventBannerTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: hideDelay)
            guard !Task.isCancelled else { return }
            withAnimation {
                if showingEvent == event {
                    showingEvent = nil
                }
            }
        }
    }

    private func triggerScreenShake() {
        // Cancel any in-progress shake sequence
        shakeTask?.cancel()

        let shakeAnimation = Animation.spring(response: 0.1, dampingFraction: 0.3)

        shakeTask = Task { @MainActor in
            withAnimation(shakeAnimation) { screenShake = 8 }
            try? await Task.sleep(nanoseconds: 100_000_000)
            guard !Task.isCancelled else { return }

            withAnimation(shakeAnimation) { screenShake = -6 }
            try? await Task.sleep(nanoseconds: 100_000_000)
            guard !Task.isCancelled else { return }

            withAnimation(shakeAnimation) { screenShake = 4 }
            try? await Task.sleep(nanoseconds: 100_000_000)
            guard !Task.isCancelled else { return }

            withAnimation(shakeAnimation) { screenShake = 0 }
        }
    }
}

// Layout extensions:
// - DashboardView+iPhone.swift (iPhoneLayout, sectionHeader)
// - DashboardView+iPad.swift (iPadLayout, sidebar, center, header, stats)
//
// Standalone structs extracted to Components/:
// - ThreatBarView.swift, DDoSOverlay.swift, ThreatStatsView.swift
// - PrestigeCardView.swift, PrestigeConfirmView.swift
// - ScanlineOverlay.swift, OfflineProgressView.swift
// - IPadCompactCards.swift (4 compact node cards)
