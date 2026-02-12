import SwiftUI

// MARK: - iPad Compact Source Card

struct IPadCompactSourceCard: View {
    let source: SourceNode
    let credits: Double
    let onUpgrade: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header row
            HStack {
                Text(source.name)
                    .font(.terminalSmall)
                    .foregroundColor(.neonGreen)
                    .lineLimit(1)
                Spacer()
                Text("L\(source.level)")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.neonGreen)
                    .cornerRadius(2)
            }

            // Stats
            HStack(spacing: 4) {
                Text("OUT:")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
                Text("\(source.productionPerTick.formatted)/t")
                    .font(.terminalSmall)
                    .foregroundColor(.neonGreen)
            }

            // Upgrade button
            if source.isAtMaxLevel {
                Text("MAX")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.neonGreen.opacity(0.8))
                    .cornerRadius(2)
            } else {
                Button(action: onUpgrade) {
                    HStack {
                        Text("+\((source.baseProduction * Double(source.level + 1) * 1.5 - source.productionPerTick).formatted)")
                            .font(.terminalMicro)
                        Spacer()
                        Text("¢\(source.upgradeCost.formatted)")
                            .font(.terminalMicro)
                    }
                    .foregroundColor(credits >= source.upgradeCost ? .terminalBlack : .terminalGray)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(credits >= source.upgradeCost ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                    .cornerRadius(2)
                }
                .disabled(credits < source.upgradeCost)
            }
        }
        .padding(10)
        .background(Color.terminalDarkGray)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.neonGreen.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - iPad Compact Link Card

struct IPadCompactLinkCard: View {
    let link: TransportLink
    let credits: Double
    let activeAttack: Attack?
    let onUpgrade: () -> Void

    private var efficiencyColor: Color {
        link.throughputEfficiency >= 0.9 ? .neonGreen :
            (link.throughputEfficiency >= 0.5 ? .neonAmber : .neonRed)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header row
            HStack {
                Text(link.name)
                    .font(.terminalSmall)
                    .foregroundColor(.neonCyan)
                    .lineLimit(1)
                Spacer()
                Text("L\(link.level)")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.neonCyan)
                    .cornerRadius(2)
            }

            // Stats - two rows
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("BW:")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text("\(link.bandwidth.formatted)/t")
                        .font(.terminalSmall)
                        .foregroundColor(.neonCyan)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("EFF:")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text(link.throughputEfficiency.percentFormatted)
                        .font(.terminalSmall)
                        .foregroundColor(efficiencyColor)
                }
            }

            // Upgrade button
            if link.isAtMaxLevel {
                Text("MAX")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.neonCyan.opacity(0.8))
                    .cornerRadius(2)
            } else {
                Button(action: onUpgrade) {
                    HStack {
                        Text("+\((link.baseBandwidth * Double(link.level + 1) * 1.4 - link.bandwidth).formatted)")
                            .font(.terminalMicro)
                        Spacer()
                        Text("¢\(link.upgradeCost.formatted)")
                            .font(.terminalMicro)
                    }
                    .foregroundColor(credits >= link.upgradeCost ? .terminalBlack : .terminalGray)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(credits >= link.upgradeCost ? Color.neonCyan : Color.terminalGray.opacity(0.3))
                    .cornerRadius(2)
                }
                .disabled(credits < link.upgradeCost)
            }

            // DDoS overlay indicator
            if let attack = activeAttack, attack.type == .ddos && attack.isActive {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                    Text("DDOS ATTACK")
                        .font(.terminalMicro)
                }
                .foregroundColor(.neonRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(Color.neonRed.opacity(0.2))
                .cornerRadius(2)
            }
        }
        .padding(10)
        .background(Color.terminalDarkGray)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.neonCyan.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - iPad Compact Sink Card

struct IPadCompactSinkCard: View {
    let sink: SinkNode
    let credits: Double
    let onUpgrade: () -> Void

    private var bufferColor: Color {
        sink.loadPercentage >= 0.9 ? .neonRed :
            (sink.loadPercentage >= 0.6 ? .neonAmber : .neonAmber)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header row
            HStack {
                Text(sink.name)
                    .font(.terminalSmall)
                    .foregroundColor(.neonAmber)
                    .lineLimit(1)
                Spacer()
                Text("L\(sink.level)")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.neonAmber)
                    .cornerRadius(2)
            }

            // Stats - two rows
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("PROC:")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text("\(sink.processingPerTick.formatted)/t")
                        .font(.terminalSmall)
                        .foregroundColor(.neonAmber)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("¢")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                    Text(sink.conversionRate.formatted)
                        .font(.terminalSmall)
                        .foregroundColor(.neonGreen)
                }
            }

            // Buffer bar
            HStack(spacing: 4) {
                Text("BUF:")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.terminalGray.opacity(0.3))
                        Rectangle()
                            .fill(bufferColor)
                            .frame(width: geo.size.width * sink.loadPercentage)
                    }
                }
                .frame(height: 6)
                .cornerRadius(2)
                Text(sink.loadPercentage.percentFormatted)
                    .font(.terminalMicro)
                    .foregroundColor(bufferColor)
            }

            // Upgrade button
            if sink.isAtMaxLevel {
                Text("MAX")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.neonAmber.opacity(0.8))
                    .cornerRadius(2)
            } else {
                Button(action: onUpgrade) {
                    HStack {
                        Text("+\((sink.baseProcessingRate * Double(sink.level + 1) * 1.3 - sink.processingPerTick).formatted)")
                            .font(.terminalMicro)
                        Spacer()
                        Text("¢\(sink.upgradeCost.formatted)")
                            .font(.terminalMicro)
                    }
                    .foregroundColor(credits >= sink.upgradeCost ? .terminalBlack : .terminalGray)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(credits >= sink.upgradeCost ? Color.neonAmber : Color.terminalGray.opacity(0.3))
                    .cornerRadius(2)
                }
                .disabled(credits < sink.upgradeCost)
            }
        }
        .padding(10)
        .background(Color.terminalDarkGray)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.neonAmber.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - iPad Compact Firewall Card

struct IPadCompactFirewallCard: View {
    let firewall: FirewallNode?
    let credits: Double
    let onRepair: () -> Void
    let onUpgrade: () -> Void
    let onPurchase: () -> Void

    var body: some View {
        if let fw = firewall {
            let healthColor: Color = fw.healthPercentage >= 0.6 ? .neonGreen :
                (fw.healthPercentage >= 0.3 ? .neonAmber : .neonRed)

            VStack(alignment: .leading, spacing: 6) {
                // Header row
                HStack {
                    Text(fw.name)
                        .font(.terminalSmall)
                        .foregroundColor(.neonRed)
                        .lineLimit(1)
                    Spacer()
                    Text("L\(fw.level)")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.neonRed)
                        .cornerRadius(2)
                }

                // Health bar row
                HStack(spacing: 4) {
                    Text("HP \(fw.currentHealth.formatted)/\(fw.maxHealth.formatted)")
                        .font(.terminalMicro)
                        .foregroundColor(healthColor)
                    Spacer()
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.terminalGray.opacity(0.3))
                            Rectangle()
                                .fill(healthColor)
                                .frame(width: geo.size.width * fw.healthPercentage)
                        }
                    }
                    .frame(width: 60, height: 6)
                    .cornerRadius(2)
                }

                // Stats row: DR + Regen
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Text("DR")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text(fw.damageReduction.percentFormatted)
                            .font(.terminalSmall)
                            .foregroundColor(.neonRed)
                    }
                    HStack(spacing: 4) {
                        Text("REGEN")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                        Text("+\(fw.regenPerTick.formatted)")
                            .font(.terminalSmall)
                            .foregroundColor(.neonGreen)
                    }
                    Spacer()
                }

                // Buttons row
                HStack(spacing: 6) {
                    // Repair button (if damaged)
                    if fw.currentHealth < fw.maxHealth {
                        let repairCost = (fw.maxHealth - fw.currentHealth) * 0.5
                        Button(action: onRepair) {
                            HStack(spacing: 2) {
                                Image(systemName: "wrench.fill")
                                    .font(.system(size: 9))
                                Text("¢\(repairCost.formatted)")
                                    .font(.terminalMicro)
                            }
                            .foregroundColor(credits >= repairCost ? .terminalBlack : .terminalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(credits >= repairCost ? Color.neonAmber : Color.terminalGray.opacity(0.3))
                            .cornerRadius(2)
                        }
                        .disabled(credits < repairCost)
                    }

                    // Upgrade button or MAX badge
                    if fw.isAtMaxLevel {
                        Text("MAX")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color.neonGreen.opacity(0.8))
                            .cornerRadius(2)
                    } else {
                        Button(action: onUpgrade) {
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 9))
                                Text("¢\(fw.upgradeCost.formatted)")
                                    .font(.terminalMicro)
                            }
                            .foregroundColor(credits >= fw.upgradeCost ? .terminalBlack : .terminalGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(credits >= fw.upgradeCost ? Color.neonGreen : Color.terminalGray.opacity(0.3))
                            .cornerRadius(2)
                        }
                        .disabled(credits < fw.upgradeCost)
                    }
                }
            }
            .padding(10)
            .background(Color.terminalDarkGray)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.neonRed.opacity(0.5), lineWidth: 1)
            )
        } else {
            // No firewall - purchase prompt
            HStack(spacing: 8) {
                Image(systemName: "shield.slash")
                    .font(.system(size: 14))
                    .foregroundColor(.terminalGray)

                VStack(alignment: .leading, spacing: 2) {
                    Text("NO FIREWALL")
                        .font(.terminalSmall)
                        .foregroundColor(.terminalGray)
                    Text("Unprotected")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                }

                Spacer()

                let cost: Double = 500
                Button(action: onPurchase) {
                    HStack(spacing: 4) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 10))
                        Text("¢\(cost.formatted)")
                            .font(.terminalMicro)
                    }
                    .foregroundColor(credits >= cost ? .terminalBlack : .terminalGray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(credits >= cost ? Color.neonRed : Color.terminalGray.opacity(0.3))
                    .cornerRadius(2)
                }
                .disabled(credits < cost)
            }
            .padding(10)
            .background(Color.terminalDarkGray)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.terminalGray.opacity(0.5), lineWidth: 1)
            )
        }
    }
}
