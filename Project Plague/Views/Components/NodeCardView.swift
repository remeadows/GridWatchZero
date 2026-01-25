// NodeCardView.swift
// ProjectPlague
// Reusable card component for displaying nodes

import SwiftUI

struct NodeCardView: View {
    let title: String
    let subtitle: String
    let level: Int
    let accentColor: Color

    let stats: [(label: String, value: String)]
    let upgradeCost: Double
    let canAfford: Bool
    let onUpgrade: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.terminalLarge)
                        .foregroundColor(accentColor)
                        .glow(accentColor, radius: 4)

                    Text(subtitle)
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                }

                Spacer()

                // Level badge
                Text("LVL \(level)")
                    .font(.terminalBody)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(accentColor)
                    .cornerRadius(2)
            }

            Divider()
                .background(accentColor.opacity(0.3))

            // Stats grid
            ForEach(stats.indices, id: \.self) { index in
                HStack {
                    Text(stats[index].label)
                        .font(.terminalBody)
                        .foregroundColor(.terminalGray)

                    Spacer()

                    Text(stats[index].value)
                        .font(.terminalReadable)
                        .foregroundColor(accentColor)
                }
            }

            // Upgrade button
            Button(action: onUpgrade) {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("UPGRADE")
                    Spacer()
                    Text("¢\(upgradeCost.formatted)")
                }
                .terminalButton(isEnabled: canAfford)
            }
            .disabled(!canAfford)
        }
        .terminalCard(borderColor: accentColor)
    }
}

// MARK: - Specialized Node Cards

struct SourceCardView: View {
    let source: SourceNode
    let credits: Double
    let onUpgrade: () -> Void

    @State private var isPulsing = false

    private var nextLevelOutput: Double {
        source.baseProduction * Double(source.level + 1) * 1.5
    }

    private var outputGain: Double {
        nextLevelOutput - source.productionPerTick
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header - compact single line
            HStack {
                Text(source.name)
                    .font(.terminalTitle)
                    .foregroundColor(.neonGreen)
                    .glow(.neonGreen, radius: 3)
                    .lineLimit(1)

                Text("[ SOURCE ]")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Spacer()

                Text("LVL \(source.level)")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.neonGreen)
                    .cornerRadius(2)
            }

            // Output stat + Upgrade button on same row
            HStack {
                Text("Output:")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)
                Text("\(source.productionPerTick.formatted)/tick")
                    .font(.terminalBody)
                    .foregroundColor(.neonGreen)

                Spacer()

                // Upgrade button or MAX badge
                if source.isAtMaxLevel {
                    Text("MAX")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.neonGreen.opacity(0.8))
                        .cornerRadius(2)
                } else {
                    Button(action: onUpgrade) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 10))
                            Text("+\(outputGain.formatted)")
                                .font(.terminalMicro)
                            Text("¢\(source.upgradeCost.formatted)")
                                .font(.terminalSmall)
                        }
                        .foregroundColor(credits >= source.upgradeCost ? .terminalBlack : .terminalGray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(credits >= source.upgradeCost ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                        .cornerRadius(2)
                    }
                    .disabled(credits < source.upgradeCost)
                }
            }
        }
        .terminalCard(borderColor: .neonGreen)
        .shadow(color: .neonGreen.opacity(isPulsing ? 0.3 : 0.1), radius: isPulsing ? 8 : 3)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

struct LinkCardView: View {
    let link: TransportLink
    let credits: Double
    let onUpgrade: () -> Void

    @State private var isPulsing = false

    private var efficiencyColor: Color {
        if link.throughputEfficiency >= 0.9 {
            return .neonGreen
        } else if link.throughputEfficiency >= 0.5 {
            return .neonAmber
        } else {
            return .neonRed
        }
    }

    private var nextLevelBandwidth: Double {
        link.baseBandwidth * Double(link.level + 1) * 1.4
    }

    private var bandwidthGain: Double {
        nextLevelBandwidth - link.bandwidth
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header - compact single line
            HStack {
                Text(link.name)
                    .font(.terminalTitle)
                    .foregroundColor(.neonCyan)
                    .glow(.neonCyan, radius: 3)
                    .lineLimit(1)

                Text("[ LINK ]")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Spacer()

                Text("LVL \(link.level)")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.neonCyan)
                    .cornerRadius(2)
            }

            // Stats row: Bandwidth + Throughput + Efficiency
            HStack(spacing: 12) {
                // Bandwidth
                VStack(alignment: .leading, spacing: 2) {
                    Text("BW")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text("\(link.bandwidth.formatted)/t")
                        .font(.terminalBody)
                        .foregroundColor(.neonCyan)
                }

                // Last tick
                VStack(alignment: .leading, spacing: 2) {
                    Text("TX/DROP")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    HStack(spacing: 2) {
                        Text("\(link.lastTickTransferred.formatted)")
                            .font(.terminalBody)
                            .foregroundColor(.neonGreen)
                        Text("/")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text("\(link.lastTickDropped.formatted)")
                            .font(.terminalBody)
                            .foregroundColor(link.lastTickDropped > 0 ? .neonRed : .terminalGray)
                    }
                }

                // Efficiency bar
                VStack(alignment: .leading, spacing: 2) {
                    Text("EFF \(link.throughputEfficiency.percentFormatted)")
                        .font(.terminalMicro)
                        .foregroundColor(efficiencyColor)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.terminalGray.opacity(0.3))
                            Rectangle()
                                .fill(efficiencyColor)
                                .frame(width: geo.size.width * link.throughputEfficiency)
                        }
                    }
                    .frame(height: 4)
                    .cornerRadius(2)
                }
                .frame(width: 60)

                Spacer()

                // Upgrade button or MAX badge
                if link.isAtMaxLevel {
                    Text("MAX")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.neonCyan.opacity(0.8))
                        .cornerRadius(2)
                } else {
                    Button(action: onUpgrade) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 10))
                            Text("+\(bandwidthGain.formatted)")
                                .font(.terminalMicro)
                            Text("¢\(link.upgradeCost.formatted)")
                                .font(.terminalSmall)
                        }
                        .foregroundColor(credits >= link.upgradeCost ? .terminalBlack : .terminalGray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(credits >= link.upgradeCost ? Color.neonCyan : Color.terminalGray.opacity(0.3))
                        .cornerRadius(2)
                    }
                    .disabled(credits < link.upgradeCost)
                }
            }
        }
        .terminalCard(borderColor: .neonCyan)
        .shadow(color: .neonCyan.opacity(isPulsing ? 0.3 : 0.1), radius: isPulsing ? 8 : 3)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

struct SinkCardView: View {
    let sink: SinkNode
    let credits: Double
    let onUpgrade: () -> Void

    @State private var isPulsing = false

    private var bufferColor: Color {
        if sink.loadPercentage >= 0.9 {
            return .neonRed
        } else if sink.loadPercentage >= 0.6 {
            return .neonAmber
        } else {
            return .neonAmber
        }
    }

    private var nextLevelProcessing: Double {
        sink.baseProcessingRate * Double(sink.level + 1) * 1.3
    }

    private var processingGain: Double {
        nextLevelProcessing - sink.processingPerTick
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header - compact single line
            HStack {
                Text(sink.name)
                    .font(.terminalTitle)
                    .foregroundColor(.neonAmber)
                    .glow(.neonAmber, radius: 3)
                    .lineLimit(1)

                Text("[ SINK ]")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Spacer()

                Text("LVL \(sink.level)")
                    .font(.terminalSmall)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.neonAmber)
                    .cornerRadius(2)
            }

            // Stats row: Processing + Conversion + Buffer
            HStack(spacing: 12) {
                // Processing
                VStack(alignment: .leading, spacing: 2) {
                    Text("PROC")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text("\(sink.processingPerTick.formatted)/t")
                        .font(.terminalBody)
                        .foregroundColor(.neonAmber)
                }

                // Conversion
                VStack(alignment: .leading, spacing: 2) {
                    Text("RATE")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text("1→¢\(sink.conversionRate.formatted)")
                        .font(.terminalBody)
                        .foregroundColor(.neonGreen)
                }

                // Buffer bar
                VStack(alignment: .leading, spacing: 2) {
                    Text("BUF \(sink.inputBuffer.formatted)/\(sink.maxCapacity.formatted)")
                        .font(.terminalMicro)
                        .foregroundColor(bufferColor)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.terminalGray.opacity(0.3))
                            Rectangle()
                                .fill(bufferColor)
                                .frame(width: geo.size.width * sink.loadPercentage)
                        }
                    }
                    .frame(height: 4)
                    .cornerRadius(2)
                }
                .frame(width: 80)

                Spacer()

                // Upgrade button or MAX badge
                if sink.isAtMaxLevel {
                    Text("MAX")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.neonAmber.opacity(0.8))
                        .cornerRadius(2)
                } else {
                    Button(action: onUpgrade) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 10))
                            Text("+\(processingGain.formatted)")
                                .font(.terminalMicro)
                            Text("¢\(sink.upgradeCost.formatted)")
                                .font(.terminalSmall)
                        }
                        .foregroundColor(credits >= sink.upgradeCost ? .terminalBlack : .terminalGray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(credits >= sink.upgradeCost ? Color.neonAmber : Color.terminalGray.opacity(0.3))
                        .cornerRadius(2)
                    }
                    .disabled(credits < sink.upgradeCost)
                }
            }
        }
        .terminalCard(borderColor: .neonAmber)
        .shadow(color: .neonAmber.opacity(isPulsing ? 0.3 : 0.1), radius: isPulsing ? 8 : 3)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SourceCardView(
            source: UnitFactory.createPublicMeshSniffer(),
            credits: 100,
            onUpgrade: {}
        )

        LinkCardView(
            link: UnitFactory.createCopperVPNTunnel(),
            credits: 100,
            onUpgrade: {}
        )

        SinkCardView(
            sink: UnitFactory.createDataBroker(),
            credits: 100,
            onUpgrade: {}
        )
    }
    .padding()
    .background(Color.terminalBlack)
}
