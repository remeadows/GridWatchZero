// UnitShopView.swift
// ProjectPlague
// Unit shop for purchasing and equipping units

import SwiftUI

struct UnitShopView: View {
    @ObservedObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: UnitFactory.UnitCategory = .source
    @State private var selectedUnit: UnitFactory.UnitInfo?

    var body: some View {
        ZStack {
            // Background
            Color.terminalBlack
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                shopHeader

                // Category tabs
                categoryTabs

                // Unit list
                unitList

                // Bottom action area
                if let unit = selectedUnit {
                    unitActionBar(unit)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var shopHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("UNIT SHOP")
                    .font(.terminalLarge)
                    .foregroundColor(.neonGreen)
                    .glow(.neonGreen, radius: 4)

                Text("[ BLACK MARKET ACCESS ]")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }

            Spacer()

            // Credits display
            VStack(alignment: .trailing, spacing: 2) {
                Text("AVAILABLE")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)

                Text("¢\(engine.resources.credits.formatted)")
                    .font(.terminalTitle)
                    .foregroundColor(.neonAmber)
            }

            // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.terminalGray)
                    .frame(width: 32, height: 32)
                    .background(Color.terminalDarkGray)
                    .cornerRadius(4)
            }
            .padding(.leading, 12)
        }
        .padding()
        .background(Color.terminalDarkGray)
    }

    // MARK: - Category Tabs

    private var categoryTabs: some View {
        HStack(spacing: 0) {
            ForEach(UnitFactory.UnitCategory.allCases, id: \.self) { category in
                categoryTab(category)
            }
        }
        .background(Color.terminalBlack)
    }

    private func categoryTab(_ category: UnitFactory.UnitCategory) -> some View {
        let isSelected = selectedCategory == category
        let color = categoryColor(category)

        return Button(action: {
            selectedCategory = category
            selectedUnit = nil
        }) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))

                Text(category.rawValue)
                    .font(.terminalMicro)
            }
            .foregroundColor(isSelected ? color : .terminalGray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? color.opacity(0.1) : Color.clear)
            .overlay(
                Rectangle()
                    .fill(isSelected ? color : Color.clear)
                    .frame(height: 2),
                alignment: .bottom
            )
        }
    }

    private func categoryColor(_ category: UnitFactory.UnitCategory) -> Color {
        switch category {
        case .source: return .neonGreen
        case .link: return .neonCyan
        case .sink: return .neonAmber
        case .defense: return .neonRed
        }
    }

    // MARK: - Unit List

    private var unitList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(UnitFactory.units(for: selectedCategory)) { unit in
                    UnitRowView(
                        unit: unit,
                        isUnlocked: engine.unlockState.isUnlocked(unit.id),
                        isEquipped: isEquipped(unit),
                        isSelected: selectedUnit?.id == unit.id,
                        credits: engine.resources.credits,
                        tierGateReason: engine.tierGateReason(for: unit)
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedUnit = (selectedUnit?.id == unit.id) ? nil : unit
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func isEquipped(_ unit: UnitFactory.UnitInfo) -> Bool {
        switch unit.category {
        case .source:
            return engine.source.name == unit.name
        case .link:
            return engine.link.name == unit.name
        case .sink:
            return engine.sink.name == unit.name
        case .defense:
            return engine.firewall?.name == unit.name
        }
    }

    // MARK: - Action Bar

    private func unitActionBar(_ unit: UnitFactory.UnitInfo) -> some View {
        let isUnlocked = engine.unlockState.isUnlocked(unit.id)
        let isEquipped = isEquipped(unit)
        let canAfford = engine.resources.credits >= unit.unlockCost

        return VStack(spacing: 12) {
            Divider()
                .background(categoryColor(unit.category).opacity(0.3))

            HStack(spacing: 16) {
                // Unit info
                VStack(alignment: .leading, spacing: 4) {
                    Text(unit.name)
                        .font(.terminalBody)
                        .foregroundColor(categoryColor(unit.category))

                    Text(unit.tier.name.uppercased())
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                }

                Spacer()

                // Action button
                if isEquipped {
                    Text("EQUIPPED")
                        .font(.terminalSmall)
                        .foregroundColor(.neonGreen)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.dimGreen)
                        .cornerRadius(4)
                } else if isUnlocked {
                    Button(action: { equipUnit(unit) }) {
                        Text("EQUIP")
                            .font(.terminalSmall)
                            .foregroundColor(.terminalBlack)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.neonCyan)
                            .cornerRadius(4)
                    }
                } else {
                    Button(action: { purchaseUnit(unit) }) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.open.fill")
                            Text("UNLOCK")
                            Text("¢\(unit.unlockCost.formatted)")
                        }
                        .font(.terminalSmall)
                        .foregroundColor(canAfford ? .terminalBlack : .terminalGray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(canAfford ? Color.neonAmber : Color.terminalGray)
                        .cornerRadius(4)
                    }
                    .disabled(!canAfford)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.terminalDarkGray)
    }

    // MARK: - Actions

    private func purchaseUnit(_ unit: UnitFactory.UnitInfo) {
        if engine.unlockUnit(unit) {
            // Stay selected to allow immediate equip
        }
    }

    private func equipUnit(_ unit: UnitFactory.UnitInfo) {
        switch unit.category {
        case .source:
            _ = engine.setSource(unit.id)
        case .link:
            _ = engine.setLink(unit.id)
        case .sink:
            _ = engine.setSink(unit.id)
        case .defense:
            _ = engine.setFirewall(unit.id)
        }
        selectedUnit = nil
    }
}

// MARK: - Unit Row View

struct UnitRowView: View {
    let unit: UnitFactory.UnitInfo
    let isUnlocked: Bool
    let isEquipped: Bool
    let isSelected: Bool
    let credits: Double
    let tierGateReason: String?
    let onTap: () -> Void

    private var tierColor: Color {
        switch unit.tier {
        case .tier1: return .terminalGray
        case .tier2: return .neonGreen
        case .tier3: return .neonCyan
        case .tier4: return .neonAmber
        case .tier5: return .neonRed
        case .tier6: return .neonRed
        }
    }

    private var categoryColor: Color {
        switch unit.category {
        case .source: return .neonGreen
        case .link: return .neonCyan
        case .sink: return .neonAmber
        case .defense: return .neonRed
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Header row
                HStack {
                    // Tier badge
                    Text("T\(unit.tier.rawValue)")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(tierColor)
                        .cornerRadius(2)

                    // Name
                    Text(unit.name)
                        .font(.terminalBody)
                        .foregroundColor(isUnlocked ? categoryColor : .terminalGray)

                    Spacer()

                    // Status indicator
                    if isEquipped {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.neonGreen)
                                .frame(width: 6, height: 6)
                            Text("ACTIVE")
                                .font(.terminalMicro)
                                .foregroundColor(.neonGreen)
                        }
                    } else if isUnlocked {
                        // Unlocked but not equipped - show owned status
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                            Text("OWNED")
                                .font(.terminalMicro)
                        }
                        .foregroundColor(.neonCyan)
                    } else {
                        // Locked - show cost
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                            Text("¢\(unit.unlockCost.formatted)")
                                .font(.terminalSmall)
                        }
                        .foregroundColor(credits >= unit.unlockCost ? .neonAmber : .terminalGray)
                    }
                }

                // Description (shown when selected or always for locked)
                if isSelected || !isUnlocked {
                    Text(unit.description)
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray)
                        .lineLimit(isSelected ? nil : 2)

                    if !isUnlocked {
                        Text("Requirement: \(unit.unlockRequirement)")
                            .font(.terminalMicro)
                            .foregroundColor(.dimAmber)

                        // Show tier gate reason proactively
                        if let gateReason = tierGateReason {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                Text(gateReason)
                            }
                            .font(.terminalMicro)
                            .foregroundColor(.neonRed)
                        }
                    }
                }

                // Stats preview
                if isSelected {
                    unitStats
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? categoryColor.opacity(0.1) : Color.terminalDarkGray)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        isSelected ? categoryColor : (isEquipped ? Color.neonGreen.opacity(0.5) : Color.terminalGray.opacity(0.3)),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var unitStats: some View {
        HStack(spacing: 16) {
            switch unit.category {
            case .source:
                statPill("Output", value: sourceOutput(unit))
            case .link:
                statPill("Bandwidth", value: linkBandwidth(unit))
            case .sink:
                statPill("Processing", value: sinkProcessing(unit))
                statPill("Conversion", value: sinkConversion(unit))
            case .defense:
                statPill("Health", value: defenseHealth(unit))
                statPill("Reduction", value: defenseReduction(unit))
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    private func statPill(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.terminalMicro)
                .foregroundColor(.terminalGray)
            Text(value)
                .font(.terminalSmall)
                .foregroundColor(categoryColor)
        }
    }

    // Stat calculations
    private func sourceOutput(_ unit: UnitFactory.UnitInfo) -> String {
        switch unit.id {
        case "source_t1_mesh_sniffer": return "12/tick"
        case "source_t2_corp_leech": return "30/tick"
        case "source_t3_zero_day": return "75/tick"
        case "source_t4_helix_scanner": return "150/tick"
        case "source_t5_neural_tap": return "300/tick"
        case "source_t6_helix_collector": return "750/tick"
        default: return "?/tick"
        }
    }

    private func linkBandwidth(_ unit: UnitFactory.UnitInfo) -> String {
        switch unit.id {
        case "link_t1_copper_vpn": return "7/tick"
        case "link_t2_fiber_relay": return "21/tick"
        case "link_t3_quantum_bridge": return "56/tick"
        case "link_t4_helix_conduit": return "140/tick"
        case "link_t5_neural_backbone": return "375/tick"
        case "link_t6_helix_channel": return "900/tick"
        default: return "?/tick"
        }
    }

    private func sinkProcessing(_ unit: UnitFactory.UnitInfo) -> String {
        switch unit.id {
        case "sink_t1_data_broker": return "7.8/tick"
        case "sink_t2_shadow_market": return "23.4/tick"
        case "sink_t3_corp_backdoor": return "58.5/tick"
        case "sink_t4_helix_decoder": return "104/tick"
        case "sink_t5_neural_exchange": return "270/tick"
        case "sink_t6_helix_core": return "600/tick"
        default: return "?/tick"
        }
    }

    private func sinkConversion(_ unit: UnitFactory.UnitInfo) -> String {
        switch unit.id {
        case "sink_t1_data_broker": return "1.5x"
        case "sink_t2_shadow_market": return "2.0x"
        case "sink_t3_corp_backdoor": return "2.5x"
        case "sink_t4_helix_decoder": return "3.0x"
        case "sink_t5_neural_exchange": return "3.5x"
        case "sink_t6_helix_core": return "4.5x"
        default: return "?x"
        }
    }

    private func defenseHealth(_ unit: UnitFactory.UnitInfo) -> String {
        switch unit.id {
        case "defense_t1_basic_firewall": return "150 HP"
        case "defense_t2_adaptive_ids": return "300 HP"
        case "defense_t3_neural_counter": return "400 HP"
        case "defense_t4_quantum_shield": return "600 HP"
        case "defense_t5_neural_mesh": return "1000 HP"
        case "defense_t5_predictive": return "800 HP"
        case "defense_t6_helix_guardian": return "2000 HP"
        default: return "? HP"
        }
    }

    private func defenseReduction(_ unit: UnitFactory.UnitInfo) -> String {
        switch unit.id {
        case "defense_t1_basic_firewall": return "25%"
        case "defense_t2_adaptive_ids": return "35%"
        case "defense_t3_neural_counter": return "40%"
        case "defense_t4_quantum_shield": return "50%"
        case "defense_t5_neural_mesh": return "60%"
        case "defense_t5_predictive": return "55%"
        case "defense_t6_helix_guardian": return "70%"
        default: return "?%"
        }
    }
}

#Preview {
    UnitShopView(engine: GameEngine())
}
