import SwiftUI

// MARK: - Threat Stats View

struct ThreatStatsView: View {
    let threatState: ThreatState
    let totalGenerated: Double
    let totalTransferred: Double
    let totalDropped: Double
    let totalProcessed: Double

    private var efficiency: Double? {
        guard totalGenerated > 0 else { return nil }
        return totalTransferred / totalGenerated
    }

    var body: some View {
        VStack(spacing: 12) {
            // Threat section
            VStack(spacing: 8) {
                HStack {
                    Text("[ THREAT INTEL ]")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)

                    Rectangle()
                        .fill(Color.terminalGray.opacity(0.3))
                        .frame(height: 1)
                }

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Threat Level")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(threatState.currentLevel.name)
                            .font(.terminalSmall)
                            .foregroundColor(threatLevelColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Attacks Survived")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text("\(threatState.attacksSurvived)")
                            .font(.terminalSmall)
                            .foregroundColor(.neonGreen)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Damage Taken")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text("¢\(threatState.totalDamageReceived.formatted)")
                            .font(.terminalSmall)
                            .foregroundColor(.neonRed)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Malus Status")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(malusStatus)
                            .font(.terminalSmall)
                            .foregroundColor(malusColor)
                    }
                }
            }
            .terminalCard(borderColor: threatLevelColor)

            // Network stats section
            VStack(spacing: 8) {
                HStack {
                    Text("[ NETWORK STATS ]")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)

                    Rectangle()
                        .fill(Color.terminalGray.opacity(0.3))
                        .frame(height: 1)
                }

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Generated")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(totalGenerated.formatted)
                            .font(.terminalSmall)
                            .foregroundColor(.neonGreen)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Processed")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(totalProcessed.formatted)
                            .font(.terminalSmall)
                            .foregroundColor(.neonAmber)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Packets Lost")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(totalDropped.formatted)
                            .font(.terminalSmall)
                            .foregroundColor(.neonRed)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Efficiency")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        if let eff = efficiency {
                            Text(eff.percentFormatted)
                                .font(.terminalSmall)
                                .foregroundColor(eff >= 0.8 ? .neonGreen : (eff >= 0.5 ? .neonAmber : .neonRed))
                        } else {
                            Text("--")
                                .font(.terminalSmall)
                                .foregroundColor(.terminalGray)
                        }
                    }
                }
            }
            .terminalCard(borderColor: .terminalGray)
        }
    }

    private var threatLevelColor: Color {
        // Use the tier color from Theme.swift for all threat levels
        Color.tierColor(named: threatState.currentLevel.color)
    }

    private var malusStatus: String {
        switch threatState.currentLevel {
        case .ghost: return "UNAWARE"
        case .blip: return "SCANNING"
        case .signal: return "CURIOUS"
        case .target: return "TRACKING"
        case .priority: return "HUNTING"
        case .hunted: return "ACTIVE"
        case .marked: return "LOCKED ON"
        case .targeted: return "COORDINATED"
        case .hammered: return "OVERWHELMING"
        case .critical: return "TOTAL WAR"
        // Transcendence Era (Campaign 8-10)
        case .ascended: return "TRANSCENDING"
        case .symbiont: return "SYMBIOTIC"
        case .transcendent: return "BEYOND"
        // Dimensional Era (Campaign 11-14)
        case .unknown: return "UNKNOWN"
        case .dimensional: return "DIMENSIONAL"
        case .cosmic: return "COSMIC"
        // Cosmic Era (Campaign 15-18)
        case .paradox: return "PARADOX"
        case .primordial: return "PRIMORDIAL"
        case .infinite: return "INFINITE"
        // Omega Era (Campaign 19-20)
        case .omega: return "OMEGA"
        }
    }

    private var malusColor: Color {
        // Use the tier color from Theme.swift for all threat levels
        Color.tierColor(named: threatState.currentLevel.color)
    }
}
