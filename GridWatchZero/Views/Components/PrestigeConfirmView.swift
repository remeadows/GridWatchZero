import SwiftUI

// MARK: - Prestige Confirm View

struct PrestigeConfirmView: View {
    let prestigeState: PrestigeState
    let totalCredits: Double
    let creditsRequired: Double
    let helixCoresReward: Int
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            GlassDashboardBackground()

            VStack(spacing: 24) {
                // Warning icon
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.neonCyan)
                        .glow(.neonCyan, radius: 12)

                    Text("NETWORK WIPE")
                        .font(.terminalLarge)
                        .foregroundColor(.neonCyan)
                        .glow(.neonCyan, radius: 4)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Warning text
                VStack(spacing: 12) {
                    Text("This will reset your network:")
                        .font(.terminalBody)
                        .foregroundColor(.terminalGray)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("All credits will be lost", systemImage: "xmark.circle")
                            .foregroundColor(.neonRed)
                        Label("All units reset to Tier 1", systemImage: "xmark.circle")
                            .foregroundColor(.neonRed)
                        Label("Threat level returns to GHOST", systemImage: "xmark.circle")
                            .foregroundColor(.neonRed)
                        Label("Milestones and lore preserved", systemImage: "checkmark.circle")
                            .foregroundColor(.neonGreen)
                    }
                    .font(.terminalSmall)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.terminalDarkGray)
                    .cornerRadius(4)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                // Rewards
                VStack(spacing: 12) {
                    Text("You will receive:")
                        .font(.terminalBody)
                        .foregroundColor(.terminalGray)

                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Image(systemName: "hexagon.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.neonCyan)
                            Text("+\(helixCoresReward)")
                                .font(.terminalLarge)
                                .foregroundColor(.neonCyan)
                            Text("Helix Cores")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                        }

                        VStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.neonGreen)
                            Text("+10%")
                                .font(.terminalLarge)
                                .foregroundColor(.neonGreen)
                            Text("Production")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                        }

                        VStack(spacing: 4) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.neonAmber)
                            Text("+15%")
                                .font(.terminalLarge)
                                .foregroundColor(.neonAmber)
                            Text("Credits")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                        }
                    }
                    .padding()
                    .background(Color.terminalDarkGray)
                    .cornerRadius(4)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: onConfirm) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("CONFIRM WIPE")
                        }
                        .font(.terminalTitle)
                        .foregroundColor(.terminalBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.neonCyan)
                        .cornerRadius(4)
                        .glow(.neonCyan, radius: 8)
                    }

                    Button(action: onCancel) {
                        Text("CANCEL")
                            .font(.terminalBody)
                            .foregroundColor(.terminalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.terminalDarkGray)
                            .cornerRadius(4)
                    }
                }
                .opacity(showContent ? 1 : 0)
            }
            .padding()
            .padding(.top, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
        }
    }
}
