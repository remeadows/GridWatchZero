import SwiftUI

// MARK: - Victory Progress Bar

struct VictoryProgressBar: View {
    let progress: VictoryProgress
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Collapsed view - tap to expand
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    // Overall progress indicator
                    ZStack {
                        Circle()
                            .stroke(Color.terminalGray.opacity(0.3), lineWidth: 3)
                            .frame(width: 36, height: 36)
                        Circle()
                            .trim(from: 0, to: progress.overallProgress)
                            .stroke(progress.allConditionsMet ? Color.neonGreen : Color.neonCyan, lineWidth: 3)
                            .frame(width: 36, height: 36)
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(progress.overallProgress * 100))%")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(progress.allConditionsMet ? .neonGreen : .neonCyan)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(progress.allConditionsMet ? "VICTORY CONDITIONS MET!" : "MISSION OBJECTIVES")
                            .font(.terminalMicro)
                            .foregroundColor(progress.allConditionsMet ? .neonGreen : .terminalGray)

                        // Quick status
                        HStack(spacing: 8) {
                            // Clearer tier display: shows current → required when not met
                            ConditionPill(
                                label: progress.defenseTierCurrent == 0 ? "No App" :
                                       progress.defenseTierMet ? "T\(progress.defenseTierCurrent)+" :
                                       "T\(progress.defenseTierCurrent)→T\(progress.defenseTierRequired)",
                                met: progress.defenseTierMet
                            )
                            ConditionPill(label: "\(progress.defensePointsCurrent)/\(progress.defensePointsRequired)DP", met: progress.defensePointsMet)
                            ConditionPill(label: progress.riskLevelCurrent.name, met: progress.riskLevelMet)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                }
                .padding(12)
                .background(Color.terminalBlack.opacity(0.95))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)

            // Expanded details
            if isExpanded {
                VStack(spacing: 8) {
                    // Defense Application Tier (clarified label)
                    GoalRow(
                        icon: "shield.lefthalf.filled",
                        label: "Defense App Tier",
                        current: progress.defenseTierCurrent == 0 ? "None" : "T\(progress.defenseTierCurrent)",
                        target: "T\(progress.defenseTierRequired)+",
                        progress: Double(progress.defenseTierCurrent) / Double(progress.defenseTierRequired),
                        met: progress.defenseTierMet,
                        hint: progress.defenseTierCurrent == 0 ? "Install a defense app!" :
                              !progress.defenseTierMet ? "Upgrade an app to Tier \(progress.defenseTierRequired)!" : nil
                    )

                    // Defense Points
                    GoalRow(
                        icon: "chart.bar.fill",
                        label: "Defense Points",
                        current: "\(progress.defensePointsCurrent) DP",
                        target: "\(progress.defensePointsRequired) DP",
                        progress: Double(progress.defensePointsCurrent) / Double(progress.defensePointsRequired),
                        met: progress.defensePointsMet,
                        hint: nil
                    )

                    // Risk Level
                    GoalRow(
                        icon: "exclamationmark.triangle.fill",
                        label: "Risk Level",
                        current: progress.riskLevelCurrent.name,
                        target: "≤ \(progress.riskLevelRequired.name)",
                        progress: progress.riskLevelMet ? 1.0 : max(0, 1.0 - Double(progress.riskLevelCurrent.rawValue - progress.riskLevelRequired.rawValue) * 0.2),
                        met: progress.riskLevelMet,
                        hint: nil
                    )

                    // Credits (if required)
                    if let required = progress.creditsRequired {
                        GoalRow(
                            icon: "creditcard.fill",
                            label: "Credits Earned",
                            current: "₵\(progress.creditsCurrent.formatted)",
                            target: "₵\(required.formatted)",
                            progress: min(1.0, progress.creditsCurrent / required),
                            met: progress.creditsMet,
                            hint: nil
                        )
                    }

                    // Attacks Survived (if required)
                    if let required = progress.attacksRequired {
                        GoalRow(
                            icon: "shield.checkered",
                            label: "Attacks Survived",
                            current: "\(progress.attacksCurrent)",
                            target: "\(required)",
                            progress: min(1.0, Double(progress.attacksCurrent) / Double(required)),
                            met: progress.attacksMet,
                            hint: nil
                        )
                    }

                    // Intel Reports Sent (if required) - MAIN OBJECTIVE
                    if let required = progress.reportsRequired {
                        GoalRow(
                            icon: "doc.text.magnifyingglass",
                            label: "Intel Reports",
                            current: "\(progress.reportsCurrent)",
                            target: "\(required)",
                            progress: min(1.0, Double(progress.reportsCurrent) / Double(required)),
                            met: progress.reportsMet,
                            hint: progress.reportsCurrent == 0 ? "Send intel to help stop Malus!" : nil
                        )
                    }
                }
                .padding(12)
                .background(Color.terminalDarkGray.opacity(0.95))
                .cornerRadius(8)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
    }
}

// MARK: - Goal Row

struct GoalRow: View {
    let icon: String
    let label: String
    let current: String
    let target: String
    let progress: Double
    let met: Bool
    let hint: String?

    var body: some View {
        HStack(spacing: 10) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(met ? .neonGreen : .neonCyan)
                .frame(width: 20)

            // Label and progress
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(label)
                        .font(.terminalSmall)
                        .foregroundColor(.white)
                    Spacer()
                    Text(current)
                        .font(.terminalSmall)
                        .foregroundColor(met ? .neonGreen : .neonAmber)
                    Text("/")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text(target)
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.terminalGray.opacity(0.3))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(met ? Color.neonGreen : Color.neonCyan)
                            .frame(width: geo.size.width * min(1.0, progress))
                    }
                }
                .frame(height: 4)

                // Hint text when goal not met
                if let hint = hint, !met {
                    Text(hint)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.neonAmber)
                        .padding(.top, 2)
                }
            }

            // Checkmark
            if met {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.neonGreen)
            }
        }
    }
}

// MARK: - Condition Pill

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
