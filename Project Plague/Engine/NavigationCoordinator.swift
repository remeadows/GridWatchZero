// NavigationCoordinator.swift
// ProjectPlague
// Manages app navigation flow between screens

import SwiftUI
import Combine

// MARK: - App Screen Enum

enum AppScreen: Hashable {
    case title
    case mainMenu
    case home
    case gameplay(levelId: Int?, isInsane: Bool) // nil = endless mode
    case levelComplete(levelId: Int, isInsane: Bool)
    case levelFailed(levelId: Int, reason: FailureReason, isInsane: Bool)
    case playerProfile

    // Custom hash for FailureReason
    func hash(into hasher: inout Hasher) {
        switch self {
        case .title: hasher.combine(0)
        case .mainMenu: hasher.combine(1)
        case .home: hasher.combine(2)
        case .gameplay(let id, let insane): hasher.combine(3); hasher.combine(id); hasher.combine(insane)
        case .levelComplete(let id, let insane): hasher.combine(4); hasher.combine(id); hasher.combine(insane)
        case .levelFailed(let id, let reason, let insane): hasher.combine(5); hasher.combine(id); hasher.combine(reason.rawValue); hasher.combine(insane)
        case .playerProfile: hasher.combine(6)
        }
    }

    static func == (lhs: AppScreen, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.title, .title), (.mainMenu, .mainMenu), (.home, .home), (.playerProfile, .playerProfile): return true
        case (.gameplay(let a, let ia), .gameplay(let b, let ib)): return a == b && ia == ib
        case (.levelComplete(let a, let ia), .levelComplete(let b, let ib)): return a == b && ia == ib
        case (.levelFailed(let a1, let r1, let i1), .levelFailed(let a2, let r2, let i2)): return a1 == a2 && r1 == r2 && i1 == i2
        default: return false
        }
    }
}

// MARK: - Navigation Coordinator

@MainActor
class NavigationCoordinator: ObservableObject {
    @Published var currentScreen: AppScreen = .title
    @Published var navigationPath = NavigationPath()

    // Store completion stats for the level complete screen
    @Published var lastCompletionStats: LevelCompletionStats?

    // Story system state
    @Published var storyState: StoryState = StoryState()
    @Published var activeStoryMoment: StoryMoment?
    @Published var pendingNavigation: (() -> Void)?

    // Cloud sync
    private let cloudManager = CloudSaveManager.shared
    private var cloudSyncCancellable: AnyCancellable?

    // Track if user has seen title this session
    private var hasShownTitle = false
    private var hasShownCampaignStart = false

    private let storyDatabase = StoryDatabase.shared

    init() {
        setupCloudSync()
    }

    // MARK: - Cloud Sync Setup

    private func setupCloudSync() {
        // Listen for cloud data changes
        cloudSyncCancellable = NotificationCenter.default
            .publisher(for: .cloudDataChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleCloudDataChange(notification)
            }
    }

    private func handleCloudDataChange(_ notification: Notification) {
        // Cloud data changed externally - could prompt user to reload
        // For now, we handle this silently and let the next sync resolve it
    }

    /// Sync progress to cloud
    func syncToCloud(progress: CampaignProgress) {
        cloudManager.uploadProgress(progress, storyState: storyState)
    }

    /// Perform initial cloud sync on app launch
    func performInitialCloudSync(campaignState: CampaignState) async {
        // Capture progress state BEFORE async sync
        let progressBeforeSync = campaignState.progress.completedLevels
        let insaneProgressBeforeSync = campaignState.progress.insaneCompletedLevels

        let result = await cloudManager.syncProgress(
            local: campaignState.progress,
            localStory: storyState
        )

        switch result {
        case .downloaded(let progress, let story):
            // CRITICAL: Check if local progress advanced while sync was in flight
            // If user completed levels during the sync, don't overwrite their progress
            let currentCompleted = campaignState.progress.completedLevels
            let currentInsane = campaignState.progress.insaneCompletedLevels

            let localAdvanced = currentCompleted.count > progressBeforeSync.count ||
                               currentInsane.count > insaneProgressBeforeSync.count

            if localAdvanced {
                // Local progress advanced during sync - upload instead of overwrite
                print("[CloudSync] Local progress advanced during sync, uploading instead of downloading")
                cloudManager.uploadProgress(campaignState.progress, storyState: storyState)
                return
            }

            // Safe to apply cloud data - local hasn't changed
            campaignState.progress = progress
            campaignState.save()
            storyState = story
            saveStoryState()
        case .conflict:
            // Conflict will be handled by UI
            break
        default:
            break
        }
    }

    // MARK: - Navigation Methods

    func showTitle() {
        currentScreen = .title
        navigationPath = NavigationPath()
    }

    func showMainMenu() {
        hasShownTitle = true
        currentScreen = .mainMenu
    }

    func showHome() {
        currentScreen = .home
    }

    func startLevel(_ levelId: Int, isInsane: Bool = false) {
        currentScreen = .gameplay(levelId: levelId, isInsane: isInsane)
    }

    func startEndlessMode() {
        currentScreen = .gameplay(levelId: nil, isInsane: false)
    }

    func completeLevel(_ levelId: Int, stats: LevelCompletionStats) {
        lastCompletionStats = stats
        currentScreen = .levelComplete(levelId: levelId, isInsane: stats.isInsane)
    }

    func failLevel(_ levelId: Int, reason: FailureReason, isInsane: Bool) {
        currentScreen = .levelFailed(levelId: levelId, reason: reason, isInsane: isInsane)
    }

    func returnToHome() {
        currentScreen = .home
    }

    func returnToMainMenu() {
        currentScreen = .mainMenu
    }

    func showPlayerProfile() {
        currentScreen = .playerProfile
    }

    // MARK: - Game Flow Helpers

    /// Check if save data exists
    var hasSaveData: Bool {
        UserDefaults.standard.data(forKey: "ProjectPlague.GameState.v5") != nil
    }

    /// Called when "New Game" is selected
    func handleNewGame() {
        // Clear existing save data
        UserDefaults.standard.removeObject(forKey: "ProjectPlague.GameState.v5")
        // Reset story state for new game
        storyState = StoryState()
        hasShownCampaignStart = false
        // Show campaign start story, then go to home
        showStoryThenNavigate(.campaignStart, levelId: nil) {
            self.showHome()
        }
    }

    /// Called when "Continue" is selected
    func handleContinue() {
        // For now, go to home - later we can restore last position
        showHome()
    }

    // MARK: - Story Integration

    /// Show a story moment if one exists for the trigger, then execute navigation
    func showStoryThenNavigate(_ trigger: StoryTrigger, levelId: Int?, then navigate: @escaping () -> Void) {
        if let story = storyDatabase.nextUnseenStory(for: trigger, levelId: levelId, storyState: storyState) {
            activeStoryMoment = story
            pendingNavigation = navigate
        } else {
            navigate()
        }
    }

    /// Called when a story dialogue completes
    func dismissStory() {
        if let story = activeStoryMoment {
            storyState.markSeen(story.id)
        }
        activeStoryMoment = nil

        // Execute pending navigation if any
        if let pending = pendingNavigation {
            pendingNavigation = nil
            withAnimation(.easeInOut(duration: 0.3)) {
                pending()
            }
        }
    }

    /// Get the level intro story if not yet seen
    func levelIntroStory(for levelId: Int) -> StoryMoment? {
        guard let story = storyDatabase.levelIntro(for: levelId),
              !storyState.hasSeen(story.id) else {
            return nil
        }
        return story
    }

    /// Get the level complete story if not yet seen
    func levelCompleteStory(for levelId: Int) -> StoryMoment? {
        guard let story = storyDatabase.levelComplete(for: levelId),
              !storyState.hasSeen(story.id) else {
            return nil
        }
        return story
    }

    /// Get the failure story
    func levelFailedStory(for levelId: Int?, reason: FailureReason) -> StoryMoment? {
        storyDatabase.levelFailed(for: levelId, reason: reason)
    }

    /// Save story state
    func saveStoryState() {
        if let data = try? JSONEncoder().encode(storyState) {
            UserDefaults.standard.set(data, forKey: "ProjectPlague.StoryState.v1")
        }
    }

    /// Load story state
    func loadStoryState() {
        guard let data = UserDefaults.standard.data(forKey: "ProjectPlague.StoryState.v1"),
              let state = try? JSONDecoder().decode(StoryState.self, from: data) else {
            return
        }
        storyState = state
    }
}

// MARK: - Root Navigation View

struct RootNavigationView: View {
    @StateObject private var coordinator = NavigationCoordinator()
    @StateObject private var gameEngine = GameEngine()
    @StateObject private var campaignState = CampaignState()
    @StateObject private var cloudManager = CloudSaveManager.shared
    @State private var hasPerformedInitialSync = false

    var body: some View {
        ZStack {
            switch coordinator.currentScreen {
            case .title:
                TitleScreenView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        coordinator.showMainMenu()
                    }
                }
                .transition(.opacity)

            case .mainMenu:
                MainMenuView(
                    onNewGame: {
                        coordinator.handleNewGame()
                    },
                    onContinue: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.handleContinue()
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))

            case .home:
                HomeView(
                    onStartLevel: { level, isInsane in
                        // Show level intro story, then start level
                        coordinator.showStoryThenNavigate(.levelIntro, levelId: level.id) {
                            coordinator.startLevel(level.id, isInsane: isInsane)
                        }
                    },
                    onPlayEndless: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.startEndlessMode()
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))

            case .playerProfile:
                PlayerProfileView(campaignState: campaignState)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))

            case .gameplay(let levelId, let isInsane):
                GameplayContainerView(
                    gameEngine: gameEngine,
                    campaignState: campaignState,
                    levelId: levelId,
                    isInsane: isInsane,
                    onExit: {
                        gameEngine.exitCampaignMode()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.returnToHome()
                        }
                    },
                    onLevelComplete: { stats in
                        // Save progress
                        campaignState.completeCurrentLevel(stats: stats)

                        // Update campaign milestones
                        gameEngine.updateCampaignMilestones(
                            campaignCompleted: campaignState.progress.completedLevels.count,
                            insaneCompleted: campaignState.progress.insaneCompletedLevels.count
                        )

                        // Update cosmetic unlocks
                        CosmeticState.shared.updateInsaneProgress(
                            campaignState.progress.insaneCompletedLevels.count
                        )

                        gameEngine.exitCampaignMode()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.completeLevel(stats.levelId, stats: stats)
                        }
                    },
                    onLevelFailed: { levelId, reason in
                        campaignState.failCurrentLevel(reason: reason)
                        gameEngine.exitCampaignMode()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.failLevel(levelId, reason: reason, isInsane: isInsane)
                        }
                    }
                )
                .transition(.opacity)

            case .levelComplete(let levelId, let isInsane):
                LevelCompleteView(
                    levelId: levelId,
                    isInsane: isInsane,
                    stats: coordinator.lastCompletionStats,
                    onNextLevel: {
                        // Show next level intro, then start (normal mode for next level)
                        coordinator.showStoryThenNavigate(.levelIntro, levelId: levelId + 1) {
                            coordinator.startLevel(levelId + 1, isInsane: false)
                        }
                    },
                    onReturnHome: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.returnToHome()
                        }
                    }
                )
                .transition(.opacity)
                .onAppear {
                    // Show level complete story
                    if let story = coordinator.levelCompleteStory(for: levelId) {
                        coordinator.activeStoryMoment = story
                    }
                }

            case .levelFailed(let levelId, let reason, let isInsane):
                LevelFailedView(
                    levelId: levelId,
                    reason: reason,
                    onRetry: {
                        // Retry with same insane mode setting
                        coordinator.showStoryThenNavigate(.levelIntro, levelId: levelId) {
                            coordinator.startLevel(levelId, isInsane: isInsane)
                        }
                    },
                    onReturnHome: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.returnToHome()
                        }
                    }
                )
                .transition(.opacity)
                .onAppear {
                    // Show failure story
                    if let story = coordinator.levelFailedStory(for: levelId, reason: reason) {
                        coordinator.activeStoryMoment = story
                    }
                }
            }

            // Story overlay - shown on top of everything
            if let story = coordinator.activeStoryMoment {
                StoryDialogueView(storyMoment: story) {
                    coordinator.dismissStory()
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .environmentObject(coordinator)
        .environmentObject(campaignState)
        .environmentObject(cloudManager)
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentScreen)
        .animation(.easeInOut(duration: 0.3), value: coordinator.activeStoryMoment?.id)
        .onAppear {
            coordinator.loadStoryState()
            // Perform initial cloud sync only once per app session
            if !hasPerformedInitialSync {
                hasPerformedInitialSync = true
                Task {
                    await coordinator.performInitialCloudSync(campaignState: campaignState)
                }
            }
        }
    }
}

// MARK: - Gameplay Container

/// Wrapper that adds campaign UI elements around DashboardView
struct GameplayContainerView: View {
    @ObservedObject var gameEngine: GameEngine
    @ObservedObject var campaignState: CampaignState
    let levelId: Int?
    let isInsane: Bool
    var onExit: () -> Void
    var onLevelComplete: (LevelCompletionStats) -> Void
    var onLevelFailed: (Int, FailureReason) -> Void

    @State private var showExitConfirm = false
    @State private var showVictoryProgress = false

    var body: some View {
        ZStack {
            // Main gameplay (existing DashboardView)
            DashboardView()
                .environmentObject(gameEngine)

            // Campaign overlay (only for campaign levels)
            if let levelId = levelId {
                VStack {
                    // Top bar with level info and exit
                    campaignTopBar(levelId: levelId)
                    Spacer()

                    // Victory progress bar at bottom
                    if let progress = gameEngine.victoryProgress {
                        VictoryProgressBar(progress: progress)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }
                }
            } else {
                // Endless mode - just show exit button
                VStack {
                    endlessTopBar
                    Spacer()
                }
            }
        }
        .alert("Exit Mission?", isPresented: $showExitConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                gameEngine.pause()
                onExit()
            }
        } message: {
            Text("Your progress in this mission will be lost.")
        }
        .onAppear {
            setupLevel()
        }
    }

    private func setupLevel() {
        if let levelId = levelId {
            // Campaign mode - configure and start level
            if let level = LevelDatabase.shared.level(forId: levelId) {
                let config = LevelConfiguration(level: level, isInsane: isInsane)
                gameEngine.startCampaignLevel(config)

                // Set up callbacks
                gameEngine.onLevelComplete = { stats in
                    onLevelComplete(stats)
                }
                gameEngine.onLevelFailed = { reason in
                    onLevelFailed(levelId, reason)
                }
            }
        } else {
            // Endless mode - just start normally
            gameEngine.start()
        }
    }

    private func campaignTopBar(levelId: Int) -> some View {
        HStack {
            // Level indicator
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text("LEVEL \(levelId)")
                        .font(.terminalMicro)
                        .foregroundColor(.neonCyan)

                    if isInsane {
                        Text("INSANE")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.terminalBlack)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.neonRed)
                            .cornerRadius(2)
                    }
                }

                if let level = LevelDatabase.shared.level(forId: levelId) {
                    Text(level.name)
                        .font(.terminalSmall)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.terminalBlack.opacity(0.9))
            .cornerRadius(4)

            Spacer()

            // Victory progress button
            Button {
                showVictoryProgress.toggle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "flag.fill")
                    if let progress = gameEngine.victoryProgress {
                        Text("\(Int(progress.overallProgress * 100))%")
                            .font(.terminalMicro)
                    }
                }
                .foregroundColor(.neonGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.terminalBlack.opacity(0.9))
                .cornerRadius(4)
            }

            // Exit button
            Button {
                showExitConfirm = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.terminalGray)
                    .padding(8)
                    .background(Color.terminalBlack.opacity(0.9))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var endlessTopBar: some View {
        HStack {
            // Endless mode indicator
            HStack(spacing: 6) {
                Image(systemName: "infinity")
                    .foregroundColor(.neonAmber)
                Text("ENDLESS")
                    .font(.terminalMicro)
                    .foregroundColor(.neonAmber)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.terminalBlack.opacity(0.9))
            .cornerRadius(4)

            Spacer()

            // Menu button
            Button {
                showExitConfirm = true
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title3)
                    .foregroundColor(.terminalGray)
                    .padding(8)
                    .background(Color.terminalBlack.opacity(0.9))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Victory Progress Bar

struct VictoryProgressBar: View {
    let progress: VictoryProgress

    var body: some View {
        VStack(spacing: 6) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.terminalDarkGray)

                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progress.allConditionsMet ? Color.neonGreen : Color.neonCyan)
                        .frame(width: geo.size.width * progress.overallProgress)
                }
            }
            .frame(height: 8)

            // Condition indicators
            HStack(spacing: 12) {
                ConditionPill(label: "T\(progress.defenseTierRequired)", met: progress.defenseTierMet)
                ConditionPill(label: "\(progress.defensePointsRequired)DP", met: progress.defensePointsMet)
                ConditionPill(label: progress.riskLevelRequired.name, met: progress.riskLevelMet)

                if progress.creditsRequired != nil {
                    ConditionPill(label: "₵", met: progress.creditsMet)
                }
                if progress.attacksRequired != nil {
                    ConditionPill(label: "ATK", met: progress.attacksMet)
                }
            }
        }
        .padding(12)
        .background(Color.terminalBlack.opacity(0.9))
        .cornerRadius(8)
    }
}

struct ConditionPill: View {
    let label: String
    let met: Bool

    var body: some View {
        Text(label)
            .font(.terminalMicro)
            .foregroundColor(met ? .neonGreen : .terminalGray)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(met ? Color.dimGreen : Color.terminalDarkGray)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(met ? Color.neonGreen.opacity(0.5) : Color.clear, lineWidth: 1)
            )
    }
}

// MARK: - Level Complete View

struct LevelCompleteView: View {
    let levelId: Int
    let isInsane: Bool
    let stats: LevelCompletionStats?
    var onNextLevel: () -> Void
    var onReturnHome: () -> Void

    @State private var showContent = false

    private var accentColor: Color {
        isInsane ? .neonRed : .neonGreen
    }

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Success icon with animation
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 120, height: 120)
                    Circle()
                        .stroke(accentColor, lineWidth: 3)
                        .frame(width: 120, height: 120)
                    Image(systemName: isInsane ? "flame.fill" : "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(accentColor)
                }
                .glow(accentColor, radius: 20)
                .scaleEffect(showContent ? 1 : 0.5)

                // Title and grade
                VStack(spacing: 8) {
                    if isInsane {
                        Text("INSANE COMPLETE")
                            .font(.terminalLarge)
                            .foregroundColor(.neonRed)
                    } else {
                        Text("MISSION COMPLETE")
                            .font(.terminalLarge)
                            .foregroundColor(.neonGreen)
                    }

                    if let level = LevelDatabase.shared.level(forId: levelId) {
                        Text(level.name)
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                    }

                    if let stats = stats {
                        HStack(spacing: 4) {
                            Text("GRADE:")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                            Text(stats.grade.rawValue)
                                .font(.terminalLarge)
                                .foregroundColor(gradeColor(stats.grade))
                        }
                        .padding(.top, 8)
                    }
                }

                // Stats card
                if let stats = stats {
                    VStack(spacing: 12) {
                        StatDisplayRow(icon: "clock", label: "Time", value: formatTime(stats.ticksToComplete))
                        StatDisplayRow(icon: "creditcard", label: "Credits", value: "₵\(stats.creditsEarned.formatted)")
                        StatDisplayRow(icon: "shield", label: "Attacks Survived", value: "\(stats.attacksSurvived)")
                        StatDisplayRow(icon: "bolt.shield", label: "Damage Blocked", value: stats.damageBlocked.formatted)
                        StatDisplayRow(icon: "chart.bar", label: "Defense Points", value: "\(stats.finalDefensePoints)")
                    }
                    .padding(20)
                    .background(Color.terminalDarkGray)
                    .cornerRadius(8)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    if levelId < 7 {
                        Button(action: onNextLevel) {
                            HStack {
                                Text("NEXT MISSION")
                                Image(systemName: "arrow.right")
                            }
                            .font(.terminalTitle)
                            .foregroundColor(.terminalBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.neonGreen)
                            .cornerRadius(4)
                        }
                    } else {
                        // Final level complete!
                        Text("🎉 CAMPAIGN COMPLETE! 🎉")
                            .font(.terminalTitle)
                            .foregroundColor(.neonAmber)
                            .padding(.vertical, 14)
                    }

                    Button(action: onReturnHome) {
                        Text("RETURN TO HUB")
                            .font(.terminalTitle)
                            .foregroundColor(.neonGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.neonGreen.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(32)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }

    private func gradeColor(_ grade: LevelGrade) -> Color {
        switch grade {
        case .s: return .neonAmber
        case .a: return .neonGreen
        case .b: return .neonCyan
        case .c: return .terminalGray
        }
    }

    private func formatTime(_ ticks: Int) -> String {
        let minutes = ticks / 60
        let seconds = ticks % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatDisplayRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.terminalSmall)
                .foregroundColor(.neonCyan)
                .frame(width: 20)

            Text(label)
                .font(.terminalBody)
                .foregroundColor(.terminalGray)

            Spacer()

            Text(value)
                .font(.terminalTitle)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Level Failed View

struct LevelFailedView: View {
    let levelId: Int
    let reason: FailureReason
    var onRetry: () -> Void
    var onReturnHome: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Failure icon
                ZStack {
                    Circle()
                        .fill(Color.neonRed.opacity(0.2))
                        .frame(width: 120, height: 120)
                    Circle()
                        .stroke(Color.neonRed, lineWidth: 3)
                        .frame(width: 120, height: 120)
                    Image(systemName: failureIcon)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.neonRed)
                }
                .glow(.neonRed, radius: 20)
                .scaleEffect(showContent ? 1 : 0.5)

                // Title
                VStack(spacing: 8) {
                    Text("MISSION FAILED")
                        .font(.terminalLarge)
                        .foregroundColor(.neonRed)

                    if let level = LevelDatabase.shared.level(forId: levelId) {
                        Text(level.name)
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                    }
                }

                // Failure reason card
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.neonRed)
                        Text(reason.rawValue.uppercased())
                            .font(.terminalTitle)
                            .foregroundColor(.neonRed)
                    }

                    Text(failureTip)
                        .font(.terminalBody)
                        .foregroundColor(.terminalGray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.dimRed.opacity(0.3))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.neonRed.opacity(0.3), lineWidth: 1)
                )

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: onRetry) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("RETRY MISSION")
                        }
                        .font(.terminalTitle)
                        .foregroundColor(.terminalBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.neonAmber)
                        .cornerRadius(4)
                    }

                    Button(action: onReturnHome) {
                        Text("RETURN TO HUB")
                            .font(.terminalTitle)
                            .foregroundColor(.terminalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.terminalGray.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(32)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }

    private var failureIcon: String {
        switch reason {
        case .timeLimitExceeded: return "clock.badge.xmark"
        case .networkedDestroyed: return "network.slash"
        case .creditsZero: return "creditcard.trianglebadge.exclamationmark"
        case .userQuit: return "xmark.circle"
        }
    }

    private var failureTip: String {
        switch reason {
        case .timeLimitExceeded:
            return "You ran out of time. Try deploying defenses faster and prioritizing efficiency."
        case .networkedDestroyed:
            return "Your network was compromised. Focus on building stronger defenses and maintaining your firewall."
        case .creditsZero:
            return "You went bankrupt. Balance your spending on defenses with maintaining income flow."
        case .userQuit:
            return "Mission abandoned. Return when you're ready to try again."
        }
    }
}

#Preview("Root Navigation") {
    RootNavigationView()
}

#Preview("Level Complete") {
    LevelCompleteView(
        levelId: 1,
        isInsane: false,
        stats: LevelCompletionStats(
            levelId: 1,
            isInsane: false,
            ticksToComplete: 180,
            creditsEarned: 2500,
            attacksSurvived: 5,
            damageBlocked: 150,
            finalDefensePoints: 75,
            completionDate: Date()
        ),
        onNextLevel: {},
        onReturnHome: {}
    )
}

#Preview("Level Failed") {
    LevelFailedView(
        levelId: 1,
        reason: .creditsZero,
        onRetry: {},
        onReturnHome: {}
    )
}
