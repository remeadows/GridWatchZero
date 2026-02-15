import SwiftUI

// MARK: - Offline Progress View

struct OfflineProgressView: View {
    let progress: OfflineProgress
    let onDismiss: () -> Void

    @State private var showContent = false
    private let reducedEffects = RenderPerformanceProfile.reducedEffects

    var body: some View {
        ZStack {
            GlassDashboardBackground()

            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.neonCyan)
                        .glow(.neonCyan, radius: 10)

                    Text("OFFLINE PROGRESS")
                        .font(.terminalLarge)
                        .foregroundColor(.neonCyan)
                        .glow(.neonCyan, radius: 4)

                    Text("Your network kept running while you were away")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Stats
                VStack(spacing: 16) {
                    HStack {
                        Text("Time Away:")
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                        Spacer()
                        Text(progress.formattedTimeAway)
                            .font(.terminalReadable)
                            .foregroundColor(.neonCyan)
                    }

                    Divider()
                        .background(Color.neonCyan.opacity(0.3))

                    HStack {
                        Text("Ticks Processed:")
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                        Spacer()
                        Text("\(progress.ticksSimulated.formatted())")
                            .font(.terminalReadable)
                            .foregroundColor(.neonGreen)
                    }

                    HStack {
                        Text("Data Processed:")
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                        Spacer()
                        Text("\(progress.dataProcessed.formatted)")
                            .font(.terminalReadable)
                            .foregroundColor(.neonAmber)
                    }

                    Divider()
                        .background(Color.neonCyan.opacity(0.3))

                    HStack {
                        Text("Credits Earned:")
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                        Spacer()
                        Text("¢\(progress.creditsEarned.formatted)")
                            .font(.terminalLarge)
                            .foregroundColor(.neonAmber)
                            .glow(.neonAmber, radius: 4)
                    }
                }
                .padding()
                .terminalCard(borderColor: .neonCyan)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Note about efficiency
                Text("(50% efficiency while offline)")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
                    .opacity(showContent ? 1 : 0)

                Spacer()

                // Dismiss button
                Button(action: onDismiss) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("COLLECT")
                    }
                    .font(.terminalTitle)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.neonGreen)
                    .cornerRadius(4)
                    .glow(.neonGreen, radius: 8)
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)
            }
            .padding()
            .padding(.top, 40)
        }
        .onAppear {
            if reducedEffects {
                showContent = true
            } else {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                    showContent = true
                }
            }
            AudioManager.shared.playSound(.milestone)
        }
        .transaction { transaction in
            if reducedEffects {
                transaction.disablesAnimations = true
                transaction.animation = nil
            }
        }
    }
}
