// DossierManager.swift
// GridWatchZero
// Manages unlocked character dossiers

import Foundation
import Combine

// MARK: - Dossier State

struct DossierState: Codable {
    var unlockedDossierIds: Set<String> = []
    var viewedDossierIds: Set<String> = []  // Track which have been read

    var unreadCount: Int {
        unlockedDossierIds.subtracting(viewedDossierIds).count
    }

    func isUnlocked(_ dossierId: String) -> Bool {
        unlockedDossierIds.contains(dossierId)
    }

    func isViewed(_ dossierId: String) -> Bool {
        viewedDossierIds.contains(dossierId)
    }

    mutating func unlock(_ dossierId: String) {
        unlockedDossierIds.insert(dossierId)
    }

    mutating func markViewed(_ dossierId: String) {
        viewedDossierIds.insert(dossierId)
    }
}

// MARK: - Dossier Manager

@MainActor
class DossierManager: ObservableObject {
    static let shared = DossierManager()

    @Published var state = DossierState()
    @Published var recentlyUnlocked: CharacterDossier?

    private let saveKey = "GridWatchZero.DossierState.v1"

    private init() {
        load()
    }

    // MARK: - Persistence

    func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let loaded = try? JSONDecoder().decode(DossierState.self, from: data) {
            state = loaded
        }
    }

    // MARK: - Unlocking

    func unlockDossier(for character: StoryCharacter) {
        guard let dossier = DossierDatabase.dossier(for: character) else { return }
        unlockDossier(withId: dossier.id)
    }

    func unlockDossier(withId id: String) {
        guard !state.isUnlocked(id) else { return }
        guard let dossier = DossierDatabase.dossier(withId: id) else { return }

        state.unlock(id)
        recentlyUnlocked = dossier
        save()

        // Clear recently unlocked after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            if self?.recentlyUnlocked?.id == id {
                self?.recentlyUnlocked = nil
            }
        }
    }

    func markViewed(_ dossierId: String) {
        guard state.isUnlocked(dossierId) else { return }
        state.markViewed(dossierId)
        save()
    }

    // MARK: - Level-Based Unlocking

    func unlockDossiersForLevel(_ levelId: Int) {
        // Unlock dossiers based on level completion
        switch levelId {
        case 1:
            unlockDossier(for: .rusty)
        case 2:
            unlockDossier(for: .tish)
        case 3:
            unlockDossier(for: .flex)
        case 5:
            unlockDossier(for: .helix)
        case 8:
            unlockDossier(for: .ronin)
        case 10:
            unlockDossier(for: .tee)
        case 12:
            unlockDossier(for: .vexis)
        case 14:
            unlockDossier(for: .kron)
        case 16:
            unlockDossier(for: .axiom)
        case 18:
            unlockDossier(for: .zero)
        case 20:
            unlockDossier(for: .architect)
        default:
            break
        }
    }

    func unlockMalusDossier() {
        unlockDossier(for: .malus)
    }

    /// Unlock Insane Mode exclusive dossiers based on Insane level completion
    func unlockDossiersForInsaneLevel(_ levelId: Int) {
        switch levelId {
        case 5:
            unlockDossier(withId: "dossier_flex_insane")
        case 10:
            unlockDossier(withId: "dossier_malus_insane")
        case 13:
            unlockDossier(withId: "dossier_prometheus_classified")
        case 15:
            unlockDossier(withId: "dossier_helix_prime")
        case 18:
            unlockDossier(withId: "dossier_architect_journal")
        case 20:
            unlockDossier(withId: "dossier_zero_protocol")
        default:
            break
        }
    }

    // MARK: - Queries

    var unlockedDossiers: [CharacterDossier] {
        DossierDatabase.allDossiers.filter { state.isUnlocked($0.id) }
    }

    var lockedDossiers: [CharacterDossier] {
        DossierDatabase.allDossiers.filter { !state.isUnlocked($0.id) }
    }

    func unlockedDossiers(for faction: CharacterFaction) -> [CharacterDossier] {
        DossierDatabase.dossiers(for: faction).filter { state.isUnlocked($0.id) }
    }

    var unreadCount: Int {
        state.unreadCount
    }

    var totalCount: Int {
        DossierDatabase.allDossiers.count
    }

    var unlockedCount: Int {
        state.unlockedDossierIds.count
    }

    // MARK: - Reset

    func reset() {
        state = DossierState()
        save()
    }
}

// MARK: - Story Character Extension

extension StoryCharacter {
    var dossier: CharacterDossier? {
        DossierDatabase.dossier(for: self)
    }
}
