// UnitShopView.swift
// GridWatchZero
// Unit shop for purchasing and equipping units

import SwiftUI

struct UnitShopView: View {
    @Bindable var engine: GameEngine
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: UnitFactory.UnitCategory = .source
    @State private var selectedUnit: UnitFactory.UnitInfo?
    private let reducedEffects = RenderPerformanceProfile.reducedEffects

    var body: some View {
        ZStack {
            // Background
            GlassDashboardBackground()

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
        .onAppear {
            selectInitialUnitIfNeeded(for: selectedCategory)
        }
        .onChange(of: selectedCategory) { _, newCategory in
            selectedUnit = nil
            selectInitialUnitIfNeeded(for: newCategory)
        }
        .transaction { transaction in
            if reducedEffects {
                transaction.disablesAnimations = true
                transaction.animation = nil
            }
        }
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
                ForEach(displayedUnits(for: selectedCategory)) { unit in
                    UnitRowView(
                        unit: unit,
                        isUnlocked: engine.unlockState.isUnlocked(unit.id),
                        isEquipped: isEquipped(unit),
                        isSelected: selectedUnit?.id == unit.id,
                        canUnlock: engine.canUnlock(unit),
                        unlockBlockReason: engine.unlockBlockReason(for: unit),
                        onQuickUnlock: {
                            purchaseUnit(unit)
                        },
                        onQuickEquip: {
                            equipUnit(unit)
                        }
                    ) {
                        if reducedEffects {
                            selectedUnit = unit
                        } else {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedUnit = unit
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func displayedUnits(for category: UnitFactory.UnitCategory) -> [UnitFactory.UnitInfo] {
        UnitFactory.units(for: category)
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
        let canUnlockUnit = engine.canUnlock(unit)
        let unlockBlockReason = engine.unlockBlockReason(for: unit)

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
                            Image(systemName: canUnlockUnit ? "lock.open.fill" : "lock.fill")
                            Text("UNLOCK")
                            Text("¢\(unit.unlockCost.formatted)")
                        }
                        .font(.terminalSmall)
                        .foregroundColor(canUnlockUnit ? .terminalBlack : .terminalBlack.opacity(0.72))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(canUnlockUnit ? Color.neonAmber : Color.terminalGray.opacity(0.8))
                        .cornerRadius(4)
                    }
                    .disabled(!canUnlockUnit)
                }
            }
            .padding(.horizontal)

            if !isUnlocked, let unlockBlockReason {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                    Text(unlockBlockReason)
                        .font(.terminalMicro)
                }
                .foregroundColor(.neonRed)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 2)
            }

        }
        .padding(.bottom)
        .background(Color.terminalDarkGray)
    }

    // MARK: - Actions

    private func purchaseUnit(_ unit: UnitFactory.UnitInfo) {
        if engine.unlockUnit(unit) {
            // Keep selected so action bar immediately shows EQUIP.
            selectedUnit = unit
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
        selectedUnit = unit
    }

    private func selectInitialUnitIfNeeded(for category: UnitFactory.UnitCategory) {
        guard selectedUnit == nil else { return }
        var units = displayedUnits(for: category)
        if units.isEmpty {
            units = UnitFactory.units(for: category)
        }
        if let firstUnlockable = units.first(where: { engine.canUnlock($0) }) {
            selectedUnit = firstUnlockable
            return
        }
        if let firstLocked = units.first(where: { !engine.unlockState.isUnlocked($0.id) }) {
            selectedUnit = firstLocked
            return
        }
        selectedUnit = units.first
    }
}

// MARK: - Unit Row View

struct UnitRowView: View {
    let unit: UnitFactory.UnitInfo
    let isUnlocked: Bool
    let isEquipped: Bool
    let isSelected: Bool
    let canUnlock: Bool
    let unlockBlockReason: String?
    let onQuickUnlock: () -> Void
    let onQuickEquip: () -> Void
    let onTap: () -> Void

    private var tierColor: Color {
        Color.tierColor(named: unit.tier.color)
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

                // Status indicator / quick actions
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
                    Button(action: onQuickEquip) {
                        Text("EQUIP")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalBlack)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.neonCyan)
                            .cornerRadius(3)
                    }
                    .buttonStyle(.plain)
                } else if canUnlock {
                    Button(action: onQuickUnlock) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 10))
                            Text("UNLOCK")
                            Text("¢\(unit.unlockCost.formatted)")
                        }
                        .font(.terminalMicro)
                        .foregroundColor(.terminalBlack)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.neonAmber)
                        .cornerRadius(3)
                    }
                    .buttonStyle(.plain)
                } else {
                    // Locked - show cost
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("¢\(unit.unlockCost.formatted)")
                            .font(.terminalSmall)
                    }
                    .foregroundColor(.terminalGray)
                }
            }

            // Keep collapsed rows lightweight to avoid list scroll stalls on simulator.
            if isSelected {
                Text(unit.description)
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
                    .lineLimit(nil)
            }

            if !isUnlocked {
                Text("Requirement: \(unit.unlockRequirement)")
                    .font(.terminalMicro)
                    .foregroundColor(.dimAmber)
                    .lineLimit(isSelected ? nil : 1)

                if let gateReason = unlockBlockReason {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                        Text(gateReason)
                            .lineLimit(isSelected ? nil : 1)
                    }
                    .font(.terminalMicro)
                    .foregroundColor(.neonRed)
                }
            }

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
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
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

    // Stat calculations - use UnitFactory to get accurate stats
    private func sourceOutput(_ unit: UnitFactory.UnitInfo) -> String {
        // Create the unit and get its actual production value
        if let source = UnitFactory.createSource(fromId: unit.id) {
            return "\(source.baseProduction.formatted)/tick"
        }
        return "?/tick"
    }

    private func linkBandwidth(_ unit: UnitFactory.UnitInfo) -> String {
        if let link = UnitFactory.createLink(fromId: unit.id) {
            return "\(link.baseBandwidth.formatted)/tick"
        }
        return "?/tick"
    }

    private func sinkProcessing(_ unit: UnitFactory.UnitInfo) -> String {
        if let sink = UnitFactory.createSink(fromId: unit.id) {
            return "\(sink.baseProcessingRate.formatted)/tick"
        }
        return "?/tick"
    }

    private func sinkConversion(_ unit: UnitFactory.UnitInfo) -> String {
        if let sink = UnitFactory.createSink(fromId: unit.id) {
            return String(format: "%.1fx", sink.conversionRate)
        }
        return "?x"
    }

    private func defenseHealth(_ unit: UnitFactory.UnitInfo) -> String {
        if let firewall = UnitFactory.createFirewall(fromId: unit.id) {
            return "\(Int(firewall.maxHealth)) HP"
        }
        return "? HP"
    }

    private func defenseReduction(_ unit: UnitFactory.UnitInfo) -> String {
        if let firewall = UnitFactory.createFirewall(fromId: unit.id) {
            return "\(Int(firewall.damageReduction * 100))%"
        }
        return "?%"
    }
}

#Preview {
    UnitShopView(engine: GameEngine())
}
