import SwiftUI

// MARK: - Level Complete View

struct LevelCompleteView: View {
    let levelId: Int
    let isInsane: Bool
    let stats: LevelCompletionStats?
    var onNextLevel: () -> Void
    var onReturnHome: () -> Void

    @State private var showContent = false
    @State private var showCertificatePopup = false

    private var accentColor: Color {
        isInsane ? .neonRed : .neonGreen
    }

    private var earnedCertificate: Certificate? {
        // Show certificate for both Normal and Insane completions
        if isInsane {
            return CertificateDatabase.insaneCertificate(for: levelId)
        } else {
            return CertificateDatabase.certificate(for: levelId)
        }
    }

    var body: some View {
        ZStack {
            GlassDashboardBackground()

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

                // Certificate earned (normal mode only)
                if let cert = earnedCertificate {
                    Button {
                        showCertificatePopup = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title2)
                                .foregroundColor(Color.tierColor(named: cert.tier.color))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("CERTIFICATE EARNED")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.tierColor(named: cert.tier.color))

                                Text(cert.abbreviation)
                                    .font(.terminalTitle)
                                    .foregroundColor(.white)

                                Text(cert.name)
                                    .font(.terminalSmall)
                                    .foregroundColor(.terminalGray)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.terminalGray)
                        }
                        .padding(16)
                        .background(Color.terminalDarkGray)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.tierColor(named: cert.tier.color).opacity(0.5), lineWidth: 1)
                        )
                    }
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    if levelId < 20 {
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
                        Text("CAMPAIGN COMPLETE!")
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

            // Certificate popup overlay
            if showCertificatePopup, let cert = earnedCertificate {
                CertificateUnlockPopupView(certificate: cert) {
                    showCertificatePopup = false
                }
                .transition(.opacity)
                .zIndex(100)
            }
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

// MARK: - Stat Display Row

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

// MARK: - Previews

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
            intelReportsSent: 5,
            completionDate: Date()
        ),
        onNextLevel: {},
        onReturnHome: {}
    )
}
