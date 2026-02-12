import SwiftUI

// MARK: - Prestige Card View

struct PrestigeCardView: View {
    let prestigeState: PrestigeState
    let totalCredits: Double
    let canPrestige: Bool
    let creditsRequired: Double
    let helixCoresReward: Int
    let onPrestige: () -> Void

    @State private var isPulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var progressToPrestige: Double {
        min(totalCredits / creditsRequired, 1.0)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("[ NETWORK WIPE ]")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)

                    if prestigeState.prestigeLevel > 0 {
                        HStack(spacing: 8) {
                            Text("Helix Level \(prestigeState.prestigeLevel)")
                                .font(.terminalBody)
                                .foregroundColor(.neonCyan)

                            Image(systemName: "hexagon.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.neonCyan)

                            Text("\(prestigeState.totalHelixCores) Cores")
                                .font(.terminalSmall)
                                .foregroundColor(.neonCyan)
                        }
                    }
                }

                Spacer()

                // Bonus indicators
                if prestigeState.prestigeLevel > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("+\(Int((prestigeState.productionMultiplier - 1) * 100))% Prod")
                            .font(.terminalMicro)
                            .foregroundColor(.neonGreen)
                        Text("+\(Int((prestigeState.creditMultiplier - 1) * 100))% Credits")
                            .font(.terminalMicro)
                            .foregroundColor(.neonAmber)
                    }
                }
            }

            // Progress to next prestige
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress to Wipe:")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                    Spacer()
                    Text("¢\(totalCredits.formatted) / ¢\(creditsRequired.formatted)")
                        .font(.terminalSmall)
                        .foregroundColor(canPrestige ? .neonCyan : .terminalGray)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.terminalGray.opacity(0.3))

                        Rectangle()
                            .fill(canPrestige ? Color.neonCyan : Color.neonCyan.opacity(0.5))
                            .frame(width: geo.size.width * progressToPrestige)
                    }
                }
                .frame(height: 8)
                .cornerRadius(4)
            }

            // Prestige button
            Button(action: onPrestige) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("INITIATE NETWORK WIPE")
                    Spacer()
                    if canPrestige {
                        Text("+\(helixCoresReward) Helix")
                            .foregroundColor(.neonCyan)
                    }
                }
                .font(.terminalSmall)
                .foregroundColor(canPrestige ? .terminalBlack : .terminalGray)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(canPrestige ? Color.neonCyan : Color.terminalGray.opacity(0.3))
                .cornerRadius(4)
            }
            .disabled(!canPrestige)
            .opacity(canPrestige && isPulsing ? 0.8 : 1.0)
        }
        .terminalCard(borderColor: canPrestige ? .neonCyan : .terminalGray)
        .shadow(color: canPrestige ? .neonCyan.opacity(isPulsing ? 0.5 : 0.2) : .clear, radius: canPrestige ? 10 : 0)
        .onAppear {
            if canPrestige && !reduceMotion {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
    }
}
