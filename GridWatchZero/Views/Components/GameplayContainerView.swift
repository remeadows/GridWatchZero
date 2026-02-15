import SwiftUI

// MARK: - Gameplay Container

/// Wrapper that adds campaign UI elements around DashboardView
struct GameplayContainerView: View {
    var gameEngine: GameEngine
    @ObservedObject var campaignState: CampaignState
    let levelId: Int?
    let isInsane: Bool
    var onExit: () -> Void
    var onLevelComplete: (LevelCompletionStats) -> Void
    var onLevelFailed: (Int, FailureReason) -> Void

    @State private var showExitConfirm = false
    @State private var showVictoryProgress = false
    @State private var setupKey: String?

    var body: some View {
        ZStack {
            // Main gameplay (existing DashboardView)
            DashboardView(onCampaignExit: levelId != nil ? { showExitConfirm = true } : nil)
                .environment(gameEngine)
                .environmentObject(campaignState)
                .environmentObject(CloudSaveManager.shared)
                // Add bottom padding for mission objectives bar
                .safeAreaInset(edge: .bottom) {
                    if levelId != nil, let progress = gameEngine.victoryProgress {
                        VictoryProgressBar(progress: progress)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                            .background(Color.terminalBlack.opacity(0.95))
                    }
                }

            // Endless mode overlay - only show exit button
            if levelId == nil {
                VStack {
                    endlessTopBar
                    Spacer()
                }
            }
        }
        .alert("Exit Mission?", isPresented: $showExitConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Exit") {
                // Force checkpoint save before exiting to prevent progress loss
                gameEngine.saveCampaignCheckpoint()
                gameEngine.pause()
                onExit()
            }
        } message: {
            Text("Progress is auto-saved every 30 seconds. You can resume this mission anytime.")
        }
        .onAppear {
            setupLevelIfNeeded()
        }
        .onChange(of: levelId) { _, _ in
            setupLevelIfNeeded()
        }
        .onChange(of: isInsane) { _, _ in
            setupLevelIfNeeded()
        }
    }

    private var currentSetupKey: String {
        "level:\(levelId ?? -1)-insane:\(isInsane)"
    }

    private func setupLevelIfNeeded() {
        guard setupKey != currentSetupKey else { return }
        setupKey = currentSetupKey
        setupLevel()
    }

    private func setupLevel() {
        // Enter gameplay mode - stops music and prevents it from restarting
        AmbientAudioManager.shared.enterGameplayMode()
        print("[GameplayContainer] Entered gameplay mode - music stopped and locked")

        if let levelId = levelId {
            // Campaign mode - configure and start level
            if let level = LevelDatabase.shared.level(forId: levelId) {
                // CRITICAL: Set up CampaignState tracking FIRST
                // This sets currentLevel so completeCurrentLevel() works properly
                campaignState.startLevel(levelId, isInsane: isInsane)

                let config = LevelConfiguration(level: level, isInsane: isInsane)

                // Unit unlocks do NOT persist across campaign levels
                // Each level is a fresh economic challenge - players must re-unlock units
                // Only base T1 units are available at the start of each level

                // Check if we have a valid checkpoint to resume from
                if let checkpoint = campaignState.validCheckpoint(for: levelId, isInsane: isInsane) {
                    // Resume from saved checkpoint (checkpoint stores unlocks earned THIS level)
                    gameEngine.resumeFromCheckpoint(checkpoint, config: config, persistedUnlocks: [])
                } else {
                    // Start fresh with no persisted unlocks
                    gameEngine.startCampaignLevel(config, persistedUnlocks: [])
                }

                // Unit unlocks are no longer persisted across campaign levels
                gameEngine.onUnitUnlocked = nil

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
            gameEngine.onUnitUnlocked = nil  // No persistence needed in endless mode
            gameEngine.start()
        }
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
