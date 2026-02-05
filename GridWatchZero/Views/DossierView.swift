// DossierView.swift
// GridWatchZero
// Character dossier collection view

import SwiftUI

// MARK: - Dossier Collection View

struct DossierCollectionView: View {
    @StateObject private var dossierManager = DossierManager.shared
    @State private var selectedDossier: CharacterDossier?
    @State private var selectedFaction: CharacterFaction?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        ZStack {
            GlassDashboardBackground()

            VStack(spacing: 0) {
                // Header
                headerView

                // Faction filter
                factionFilter
                    .padding(.horizontal)
                    .padding(.top, 12)

                // Dossier grid
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(filteredDossiers) { dossier in
                            DossierCardView(
                                dossier: dossier,
                                isUnlocked: dossierManager.state.isUnlocked(dossier.id),
                                isNew: !dossierManager.state.isViewed(dossier.id) && dossierManager.state.isUnlocked(dossier.id)
                            )
                            .onTapGesture {
                                if dossierManager.state.isUnlocked(dossier.id) {
                                    selectedDossier = dossier
                                    dossierManager.markViewed(dossier.id)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedDossier) { dossier in
            DossierDetailView(dossier: dossier)
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("BACK")
                }
                .font(.terminalSmall)
                .foregroundColor(.neonCyan)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("DOSSIERS")
                    .font(.terminalLarge)
                    .foregroundColor(.neonCyan)

                Text("\(dossierManager.unlockedCount)/\(dossierManager.totalCount) PROFILES UNLOCKED")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }

            Spacer()

            // Balance the back button
            Color.clear
                .frame(width: 60)
        }
        .padding()
        .background(Color.terminalDarkGray.opacity(0.5))
    }

    private var factionFilter: some View {
        HStack(spacing: 12) {
            FilterButton(title: "ALL", isSelected: selectedFaction == nil) {
                selectedFaction = nil
            }

            ForEach(CharacterFaction.allCases, id: \.self) { faction in
                FilterButton(
                    title: faction.rawValue,
                    isSelected: selectedFaction == faction,
                    color: Color.tierColor(named: faction.color)
                ) {
                    selectedFaction = faction
                }
            }
        }
    }

    private var filteredDossiers: [CharacterDossier] {
        if let faction = selectedFaction {
            return DossierDatabase.dossiers(for: faction)
        }
        return DossierDatabase.allDossiers
    }

    private var gridColumns: [GridItem] {
        if isIPad {
            return [
                GridItem(.adaptive(minimum: 200, maximum: 250), spacing: 16)
            ]
        } else {
            return [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]
        }
    }
}

// MARK: - Filter Button

private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    var color: Color = .neonCyan
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.terminalMicro)
                .foregroundColor(isSelected ? .terminalBlack : color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isSelected ? color : Color.clear)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        }
    }
}

// MARK: - Dossier Card View

struct DossierCardView: View {
    let dossier: CharacterDossier
    let isUnlocked: Bool
    let isNew: Bool

    private var themeColor: Color {
        Color.tierColor(named: dossier.themeColor)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Portrait
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.terminalDarkGray)
                    .frame(height: 120)

                if isUnlocked {
                    if let imageName = dossier.imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(themeColor)
                    }

                    // New badge
                    if isNew {
                        VStack {
                            HStack {
                                Spacer()
                                Text("NEW")
                                    .font(.terminalMicro)
                                    .foregroundColor(.terminalBlack)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.neonAmber)
                                    .cornerRadius(4)
                                    .padding(4)
                            }
                            Spacer()
                        }
                    }
                } else {
                    // Locked state
                    VStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.terminalGray)

                        Text("CLASSIFIED")
                            .font(.terminalMicro)
                            .foregroundColor(.terminalGray)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isUnlocked ? themeColor.opacity(0.6) : Color.terminalGray.opacity(0.3), lineWidth: 1)
            )

            // Name
            Text(isUnlocked ? dossier.codename : "???")
                .font(.terminalSmall)
                .foregroundColor(isUnlocked ? themeColor : .terminalGray)

            // Classification
            Text(isUnlocked ? dossier.classification.prefix(20) + "..." : "UNKNOWN")
                .font(.terminalMicro)
                .foregroundColor(.terminalGray)
                .lineLimit(1)
        }
        .padding(8)
        .background(Color.terminalDarkGray.opacity(0.5))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isUnlocked ? themeColor.opacity(0.3) : Color.terminalGray.opacity(0.2), lineWidth: 1)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Dossier Detail View

struct DossierDetailView: View {
    let dossier: CharacterDossier
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab = 0

    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    private var themeColor: Color {
        Color.tierColor(named: dossier.themeColor)
    }

    var body: some View {
        ZStack {
            GlassDashboardBackground()

            ScrollView {
                VStack(spacing: 0) {
                    // Header with portrait
                    headerSection

                    // Tab selector
                    tabSelector
                        .padding(.top, 16)

                    // Content based on tab
                    switch selectedTab {
                    case 0:
                        bioSection
                    case 1:
                        combatSection
                    case 2:
                        secretSection
                    default:
                        bioSection
                    }
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.terminalGray)
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Portrait
            ZStack {
                if let imageName = dossier.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: isIPad ? 200 : 150, height: isIPad ? 200 : 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.terminalDarkGray)
                        .frame(width: isIPad ? 200 : 150, height: isIPad ? 200 : 150)

                    Image(systemName: "person.fill")
                        .font(.system(size: isIPad ? 60 : 50))
                        .foregroundColor(themeColor)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeColor, lineWidth: 2)
            )
            .shadow(color: themeColor.opacity(0.5), radius: 10)
            .padding(.top, 60)

            // Name and classification
            VStack(spacing: 4) {
                Text(dossier.codename)
                    .font(isIPad ? .system(size: 36, weight: .bold, design: .monospaced) : .terminalLarge)
                    .foregroundColor(themeColor)

                Text(dossier.classification)
                    .font(.terminalSmall)
                    .foregroundColor(.terminalGray)

                // Faction badge
                Text(dossier.faction.rawValue)
                    .font(.terminalMicro)
                    .foregroundColor(.terminalBlack)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.tierColor(named: dossier.faction.color))
                    .cornerRadius(4)
                    .padding(.top, 8)
            }

            // Visual description
            Text(dossier.visualDescription)
                .font(.terminalBody)
                .foregroundColor(.terminalGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, isIPad ? 60 : 24)
                .padding(.top, 8)
        }
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "BIO", isSelected: selectedTab == 0, color: themeColor) {
                selectedTab = 0
            }
            TabButton(title: "COMBAT", isSelected: selectedTab == 1, color: themeColor) {
                selectedTab = 1
            }
            TabButton(title: "SECRET", isSelected: selectedTab == 2, color: .neonAmber) {
                selectedTab = 2
            }
        }
        .padding(.horizontal)
    }

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("BACKGROUND")

            ForEach(Array(dossier.bio.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph)
                    .font(.terminalReadable)
                    .foregroundColor(.white)
                    .lineSpacing(4)
            }
        }
        .padding()
        .padding(.horizontal, isIPad ? 40 : 0)
    }

    private var combatSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Combat Style
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("COMBAT STYLE")

                Text(dossier.combatStyle)
                    .font(.terminalReadable)
                    .foregroundColor(.white)
                    .lineSpacing(4)
            }

            // Weakness
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.neonAmber)
                    Text("KNOWN WEAKNESS")
                        .font(.terminalSmall)
                        .foregroundColor(.neonAmber)
                }

                Text(dossier.weakness)
                    .font(.terminalReadable)
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .padding()
                    .background(Color.dimAmber.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.neonAmber.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
        .padding(.horizontal, isIPad ? 40 : 0)
    }

    private var secretSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "eye.slash.fill")
                    .foregroundColor(.neonRed)
                Text("CLASSIFIED INTELLIGENCE")
                    .font(.terminalSmall)
                    .foregroundColor(.neonRed)
            }

            Text(dossier.secret)
                .font(.terminalReadable)
                .foregroundColor(.white)
                .lineSpacing(4)
                .padding()
                .background(Color.dimRed.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.neonRed.opacity(0.3), lineWidth: 1)
                )

            // Unlock condition
            HStack(spacing: 8) {
                Image(systemName: "lock.open.fill")
                    .foregroundColor(.terminalGray)
                Text("Unlocked: \(dossier.unlockCondition)")
                    .font(.terminalMicro)
                    .foregroundColor(.terminalGray)
            }
            .padding(.top, 8)
        }
        .padding()
        .padding(.horizontal, isIPad ? 40 : 0)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text("[ \(title) ]")
                .font(.terminalSmall)
                .foregroundColor(themeColor)

            Rectangle()
                .fill(themeColor.opacity(0.3))
                .frame(height: 1)
        }
    }
}

// MARK: - Tab Button

private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.terminalSmall)
                .foregroundColor(isSelected ? .terminalBlack : color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? color : Color.clear)
        }
        .overlay(
            Rectangle()
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("Dossier Collection") {
    DossierCollectionView()
}

#Preview("Dossier Detail - Rusty") {
    if let dossier = DossierDatabase.dossier(for: .rusty) {
        DossierDetailView(dossier: dossier)
    }
}

#Preview("Dossier Detail - Malus") {
    if let dossier = DossierDatabase.dossier(for: .malus) {
        DossierDetailView(dossier: dossier)
    }
}
