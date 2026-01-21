// CriticalAlarmView.swift
// ProjectPlague
// Full-screen alarm overlay when threat is critical

import SwiftUI

struct CriticalAlarmView: View {
    let threatLevel: ThreatLevel
    let riskLevel: ThreatLevel
    let activeAttack: Attack?
    let defenseStack: DefenseStack
    let onAcknowledge: () -> Void
    let onBoostDefenses: () -> Void

    @State private var isPulsing = false
    @State private var glitchOffset: CGFloat = 0
    @State private var showDetails = false

    var body: some View {
        ZStack {
            // Dark overlay with red tint
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            // Glitch/static effect
            GlitchOverlay(intensity: isPulsing ? 1.0 : 0.5)
                .ignoresSafeArea()

            // Red pulsing vignette
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.neonRed.opacity(isPulsing ? 0.4 : 0.2)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Warning icon with pulse
                ZStack {
                    // Outer pulse ring
                    Circle()
                        .stroke(Color.neonRed.opacity(isPulsing ? 0.3 : 0), lineWidth: 3)
                        .frame(width: 150, height: 150)
                        .scaleEffect(isPulsing ? 1.5 : 1.0)

                    // Inner ring
                    Circle()
                        .stroke(Color.neonRed, lineWidth: 2)
                        .frame(width: 100, height: 100)

                    // Icon
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.neonRed)
                        .glow(.neonRed, radius: isPulsing ? 20 : 10)
                        .offset(x: glitchOffset)
                }

                // CRITICAL text with glitch effect
                VStack(spacing: 8) {
                    Text("CRITICAL THREAT")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(.neonRed)
                        .glow(.neonRed, radius: 8)
                        .offset(x: glitchOffset)

                    Text("ACTION REQUIRED")
                        .font(.terminalTitle)
                        .foregroundColor(.white)
                        .opacity(isPulsing ? 1 : 0.7)
                }

                // Threat info box
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("THREAT LEVEL")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                            Text(threatLevel.name)
                                .font(.terminalTitle)
                                .foregroundColor(.neonRed)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("RISK LEVEL")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                            Text(riskLevel.name)
                                .font(.terminalTitle)
                                .foregroundColor(.neonRed)
                        }
                    }

                    if let attack = activeAttack {
                        Divider()
                            .background(Color.neonRed.opacity(0.5))

                        HStack {
                            Image(systemName: attack.type.icon)
                                .font(.system(size: 20))
                                .foregroundColor(.neonRed)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(attack.type.displayName)
                                    .font(.terminalBody)
                                    .foregroundColor(.white)
                                Text(attack.type.description)
                                    .font(.terminalMicro)
                                    .foregroundColor(.terminalGray)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("SEVERITY")
                                    .font(.terminalMicro)
                                    .foregroundColor(.terminalGray)
                                Text(String(format: "%.1fx", attack.severity))
                                    .font(.terminalBody)
                                    .foregroundColor(.neonRed)
                            }
                        }
                    }

                    Divider()
                        .background(Color.neonRed.opacity(0.5))

                    // Defense status
                    HStack {
                        Text("DEFENSE STATUS:")
                            .font(.terminalSmall)
                            .foregroundColor(.terminalGray)

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: defenseStack.overallStatus.icon)
                                .font(.system(size: 12))
                            Text(defenseStack.overallStatus.rawValue)
                                .font(.terminalSmall)
                        }
                        .foregroundColor(defenseStatusColor)
                    }

                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("DEPLOYED")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                            Text("\(defenseStack.deployedCount)/6")
                                .font(.terminalSmall)
                                .foregroundColor(.neonCyan)
                        }

                        VStack(spacing: 2) {
                            Text("DEF PTS")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                            Text(defenseStack.totalDefensePoints.formatted)
                                .font(.terminalSmall)
                                .foregroundColor(.neonGreen)
                        }

                        VStack(spacing: 2) {
                            Text("DAMAGE RED")
                                .font(.terminalMicro)
                                .foregroundColor(.terminalGray)
                            Text(defenseStack.totalDamageReduction.percentFormatted)
                                .font(.terminalSmall)
                                .foregroundColor(.neonRed)
                        }
                    }
                }
                .padding()
                .background(Color.terminalDarkGray.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.neonRed, lineWidth: 2)
                )
                .cornerRadius(4)
                .padding(.horizontal)

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    // Boost defenses button
                    if defenseStack.deployedCount < 6 {
                        Button(action: onBoostDefenses) {
                            HStack {
                                Image(systemName: "shield.fill")
                                Text("BOOST DEFENSES")
                            }
                            .font(.terminalTitle)
                            .foregroundColor(.terminalBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.neonCyan)
                            .cornerRadius(4)
                            .glow(.neonCyan, radius: 8)
                        }
                    }

                    // Acknowledge button
                    Button(action: onAcknowledge) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("ACKNOWLEDGE")
                        }
                        .font(.terminalBody)
                        .foregroundColor(.neonRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.terminalDarkGray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.neonRed, lineWidth: 1)
                        )
                        .cornerRadius(4)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Start animations
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }

            // Glitch effect
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if Bool.random() {
                    glitchOffset = CGFloat.random(in: -3...3)
                } else {
                    glitchOffset = 0
                }
            }

            // Play alarm sound
            AudioManager.shared.playSound(.attackIncoming)
        }
    }

    private var defenseStatusColor: Color {
        switch defenseStack.overallStatus {
        case .nominal: return .neonGreen
        case .degraded, .alert: return .neonAmber
        case .critical, .offline: return .neonRed
        }
    }
}

// MARK: - Glitch Overlay

struct GlitchOverlay: View {
    let intensity: Double

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                // Random horizontal lines
                for _ in 0..<Int(intensity * 20) {
                    let y = CGFloat.random(in: 0..<size.height)
                    let height = CGFloat.random(in: 1...3)
                    let offset = CGFloat.random(in: -5...5)

                    let rect = CGRect(x: offset, y: y, width: size.width, height: height)
                    context.fill(
                        Path(rect),
                        with: .color(.neonRed.opacity(Double.random(in: 0.1...0.3)))
                    )
                }

                // Static noise
                for _ in 0..<Int(intensity * 50) {
                    let x = CGFloat.random(in: 0..<size.width)
                    let y = CGFloat.random(in: 0..<size.height)
                    let pixel = CGRect(x: x, y: y, width: 2, height: 2)
                    context.fill(
                        Path(pixel),
                        with: .color(.white.opacity(Double.random(in: 0...0.1)))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Malus Intel Panel

struct MalusIntelPanel: View {
    let intel: MalusIntelligence
    let onSendReport: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("[ MALUS INTELLIGENCE ]")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                Rectangle()
                    .fill(Color.terminalGray.opacity(0.3))
                    .frame(height: 1)
            }

            // Stats
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Footprint Data")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text(intel.footprintData.formatted)
                        .font(.terminalBody)
                        .foregroundColor(.neonCyan)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Patterns")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text("\(intel.patternsIdentified)")
                        .font(.terminalBody)
                        .foregroundColor(.neonAmber)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Reports Sent")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text("\(intel.reportsSent)")
                        .font(.terminalBody)
                        .foregroundColor(.neonGreen)
                }

                Spacer()
            }

            // Analysis progress
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Analysis Progress")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Spacer()
                    Text("\(Int(intel.analysisProgress))%")
                        .font(.terminalSmall)
                        .foregroundColor(.neonCyan)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.terminalGray.opacity(0.3))
                        Rectangle()
                            .fill(Color.neonCyan)
                            .frame(width: geo.size.width * (intel.analysisProgress / 100.0))
                    }
                }
                .frame(height: 6)
                .cornerRadius(3)
            }

            // Send report button
            Button(action: onSendReport) {
                HStack {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 10))
                    Text("SEND REPORT TO TEAM")
                        .font(.terminalSmall)
                    Spacer()
                    if intel.canSendReport {
                        Text("-250 data")
                            .font(.terminalMicro)
                            .foregroundColor(.neonAmber)
                    }
                }
                .foregroundColor(intel.canSendReport ? .terminalBlack : .terminalGray)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(intel.canSendReport ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                .cornerRadius(4)
            }
            .disabled(!intel.canSendReport)
        }
        .terminalCard(borderColor: .neonCyan)
    }
}

#Preview {
    CriticalAlarmView(
        threatLevel: .marked,
        riskLevel: .hunted,
        activeAttack: Attack(type: .malusStrike, severity: 2.5, startTick: 100),
        defenseStack: DefenseStack(),
        onAcknowledge: {},
        onBoostDefenses: {}
    )
}
