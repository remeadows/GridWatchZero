// NavigationCoordinator.swift
// GridWatchZero
// Manages app navigation flow between screens

import SwiftUI
import Combine

// MARK: - App Screen Enum

enum AppScreen: Hashable {
    case brandIntro // War Signal Labs video intro (first screen)
    case title
    case mainMenu
    case home
    case gameplay(levelId: Int?, isInsane: Bool) // nil = endless mode
    case levelComplete(levelId: Int, isInsane: Bool)
    case levelFailed(levelId: Int, reason: FailureReason, isInsane: Bool)
    case playerProfile
    case helixAwakening // Cinematic after Level 7 completion

    // Custom hash for FailureReason
    func hash(into hasher: inout Hasher) {
        switch self {
        case .brandIntro: hasher.combine(-1)
        case .title: hasher.combine(0)
        case .mainMenu: hasher.combine(1)
        case .home: hasher.combine(2)
        case .gameplay(let id, let insane): hasher.combine(3); hasher.combine(id); hasher.combine(insane)
        case .levelComplete(let id, let insane): hasher.combine(4); hasher.combine(id); hasher.combine(insane)
        case .levelFailed(let id, let reason, let insane): hasher.combine(5); hasher.combine(id); hasher.combine(reason.rawValue); hasher.combine(insane)
        case .playerProfile: hasher.combine(6)
        case .helixAwakening: hasher.combine(7)
        }
    }

    static func == (lhs: AppScreen, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.brandIntro, .brandIntro), (.title, .title), (.mainMenu, .mainMenu), (.home, .home), (.playerProfile, .playerProfile), (.helixAwakening, .helixAwakening): return true
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
    @Published var currentScreen: AppScreen = .brandIntro // Start with brand intro
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
    weak var campaignState: CampaignState?

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
        guard let syncable = notification.userInfo?["cloudData"] as? SyncableProgress,
              let campaignState = campaignState else {
            return
        }

        // Only apply cloud data if cloud has more completed levels
        let localLevels = campaignState.progress.completedLevels.count
        let cloudLevels = syncable.progress.completedLevels.count
        guard cloudLevels > localLevels else { return }

        // Cloud is ahead — apply it
        campaignState.progress = syncable.progress
        campaignState.save()
        storyState = syncable.storyState
        saveStoryState()
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

        // Award certificate for level completion (Normal or Insane track)
        if stats.isInsane {
            CertificateManager.shared.earnInsaneCertificateForLevel(levelId)
        } else {
            CertificateManager.shared.earnCertificateForLevel(levelId)
        }

        // Unlock character dossiers based on level completion
        DossierManager.shared.unlockDossiersForLevel(levelId)

        // Unlock Insane Mode exclusive dossiers
        if stats.isInsane {
            DossierManager.shared.unlockDossiersForInsaneLevel(levelId)
        }

        // For Level 7, show Helix awakening cinematic first
        if levelId == 7 {
            currentScreen = .helixAwakening
        } else {
            currentScreen = .levelComplete(levelId: levelId, isInsane: stats.isInsane)
        }
    }

    /// Called after Helix awakening cinematic completes
    func completeHelixAwakening() {
        // Now show the level 7 complete screen
        if let stats = lastCompletionStats {
            currentScreen = .levelComplete(levelId: 7, isInsane: stats.isInsane)
        } else {
            currentScreen = .levelComplete(levelId: 7, isInsane: false)
        }
    }

    func failLevel(_ levelId: Int, reason: FailureReason, isInsane: Bool) {
        currentScreen = .levelFailed(levelId: levelId, reason: reason, isInsane: isInsane)
    }

    func returnToHome() {
        // Exit gameplay mode - allows music to resume in menus
        AmbientAudioManager.shared.exitGameplayMode()
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
        UserDefaults.standard.data(forKey: "GridWatchZero.GameState.v6") != nil
    }

    /// Called when "New Game" is selected
    func handleNewGame() {
        // Clear existing save data
        UserDefaults.standard.removeObject(forKey: "GridWatchZero.GameState.v6")
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
            UserDefaults.standard.set(data, forKey: "GridWatchZero.StoryState.v1")
        }
    }

    /// Load story state
    func loadStoryState() {
        guard let data = UserDefaults.standard.data(forKey: "GridWatchZero.StoryState.v1"),
              let state = try? JSONDecoder().decode(StoryState.self, from: data) else {
            return
        }
        storyState = state
    }
}

// MARK: - Root Navigation View

struct RootNavigationView: View {
    @StateObject private var coordinator = NavigationCoordinator()
    @State private var gameEngine = GameEngine()
    @StateObject private var campaignState = CampaignState()
    @StateObject private var cloudManager = CloudSaveManager.shared
    @State private var hasPerformedInitialSync = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            switch coordinator.currentScreen {
            case .brandIntro:
                BrandIntroView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        coordinator.currentScreen = .title
                    }
                }
                .ignoresSafeArea(.all)  // Full-screen video
                .transition(.opacity)
            
            case .title:
                TitleScreenView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        // Skip main menu and go directly to campaign hub
                        coordinator.showHome()
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
                        // Ensure we return to hub state properly
                        campaignState.returnToHub()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.returnToHome()
                        }
                    },
                    onLevelComplete: { stats in
                        // Save progress first - this is critical
                        campaignState.completeCurrentLevel(stats: stats)

                        // Force save to persist immediately
                        campaignState.save()

                        // Update campaign milestones
                        gameEngine.updateCampaignMilestones(
                            campaignCompleted: campaignState.progress.completedLevels.count,
                            insaneCompleted: campaignState.progress.insaneCompletedLevels.count
                        )

                        // Update cosmetic unlocks
                        CosmeticState.shared.updateInsaneProgress(
                            campaignState.progress.insaneCompletedLevels.count
                        )

                        // Sync to cloud after saving locally
                        coordinator.syncToCloud(progress: campaignState.progress)

                        gameEngine.exitCampaignMode()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.completeLevel(stats.levelId, stats: stats)
                        }
                    },
                    onLevelFailed: { levelId, reason in
                        campaignState.failCurrentLevel(reason: reason)
                        // Force save on failure too
                        campaignState.save()
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
                        // Clear checkpoint since level is complete
                        campaignState.returnToHub(clearCheckpoint: true)
                        // Show next level intro, then start (normal mode for next level)
                        coordinator.showStoryThenNavigate(.levelIntro, levelId: levelId + 1) {
                            coordinator.startLevel(levelId + 1, isInsane: false)
                        }
                    },
                    onReturnHome: {
                        // Clear checkpoint since level is complete
                        campaignState.returnToHub(clearCheckpoint: true)
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
                        // Clear checkpoint on retry - start fresh
                        campaignState.returnToHub(clearCheckpoint: true)
                        // Retry with same insane mode setting
                        coordinator.showStoryThenNavigate(.levelIntro, levelId: levelId) {
                            coordinator.startLevel(levelId, isInsane: isInsane)
                        }
                    },
                    onReturnHome: {
                        // Clear checkpoint since player gave up
                        campaignState.returnToHub(clearCheckpoint: true)
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

            case .helixAwakening:
                HelixAwakeningView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        coordinator.completeHelixAwakening()
                    }
                }
                .transition(.opacity)
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
        .environment(gameEngine)
        .environmentObject(campaignState)
        .environmentObject(cloudManager)
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentScreen)
        .animation(.easeInOut(duration: 0.3), value: coordinator.activeStoryMoment?.id)
        .onAppear {
            coordinator.campaignState = campaignState
            coordinator.loadStoryState()
            // Wire story state provider so CampaignState.save() uploads real story state
            campaignState.storyStateProvider = { [weak coordinator] in
                coordinator?.storyState ?? StoryState()
            }
            // Perform initial cloud sync only once per app session
            if !hasPerformedInitialSync {
                hasPerformedInitialSync = true
                Task {
                    await coordinator.performInitialCloudSync(campaignState: campaignState)
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Auto-save when app goes to background or becomes inactive
            if newPhase == .background || newPhase == .inactive {
                gameEngine.pause()  // pause() calls saveGame()
                campaignState.save()
                coordinator.saveStoryState()
                AmbientAudioManager.shared.pause()
            } else if newPhase == .active && oldPhase != .active {
                // Resume music and game when returning to foreground
                AmbientAudioManager.shared.resume()

                // Auto-resume the game engine if we're on a gameplay screen
                if case .gameplay = coordinator.currentScreen {
                    gameEngine.start()
                }

                // Sync from cloud in case another device updated while backgrounded
                Task {
                    await coordinator.performInitialCloudSync(campaignState: campaignState)
                }
            }
        }
    }
}

#Preview("Root Navigation") {
    RootNavigationView()
}

