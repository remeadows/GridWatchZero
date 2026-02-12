import SwiftUI

// MARK: - Level Failed View

struct LevelFailedView: View {
    let levelId: Int
    let reason: FailureReason
    var onRetry: () -> Void
    var onReturnHome: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            GlassDashboardBackground()

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

// MARK: - Previews

#Preview("Level Failed") {
    LevelFailedView(
        levelId: 1,
        reason: .creditsZero,
        onRetry: {},
        onReturnHome: {}
    )
}
