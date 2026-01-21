// SaveMigration.swift
// ProjectPlague
// Handles migration of save data between versions

import Foundation

// MARK: - Save Version

enum SaveVersion: Int, Comparable, CaseIterable {
    case v1 = 1  // Initial release
    case v2 = 2  // Added UnlockState
    case v3 = 3  // Added FirewallNode, DefenseStack
    case v4 = 4  // Added LoreState, MilestoneState
    case v5 = 5  // Added PrestigeState, MalusIntelligence, criticalAlarmAcknowledged

    static let current: SaveVersion = .v5

    var saveKey: String {
        "ProjectPlague.GameState.v\(rawValue)"
    }

    static func < (lhs: SaveVersion, rhs: SaveVersion) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Save Migration Manager

@MainActor
final class SaveMigrationManager {

    /// Attempts to load and migrate save data to the current version
    /// Returns the migrated GameState, or nil if no save exists
    static func loadAndMigrate() -> GameState? {
        // Try current version first (most common case)
        if let state = loadVersion(.current) {
            return state
        }

        // Check older versions in descending order
        for version in SaveVersion.allCases.reversed() where version < .current {
            if let data = UserDefaults.standard.data(forKey: version.saveKey) {
                print("[SaveMigration] Found save at version \(version.rawValue), migrating to v\(SaveVersion.current.rawValue)")

                if let migratedState = migrate(from: version, data: data) {
                    // Save migrated state to current version
                    saveToCurrentVersion(migratedState)

                    // Clean up old save key
                    UserDefaults.standard.removeObject(forKey: version.saveKey)

                    return migratedState
                } else {
                    print("[SaveMigration] Failed to migrate from v\(version.rawValue)")
                }
            }
        }

        return nil
    }

    /// Load GameState from a specific version
    private static func loadVersion(_ version: SaveVersion) -> GameState? {
        guard let data = UserDefaults.standard.data(forKey: version.saveKey) else {
            return nil
        }

        if version == .current {
            return try? JSONDecoder().decode(GameState.self, from: data)
        }

        return migrate(from: version, data: data)
    }

    /// Migrate save data from an older version to current
    private static func migrate(from version: SaveVersion, data: Data) -> GameState? {
        switch version {
        case .v1:
            return migrateFromV1(data)
        case .v2:
            return migrateFromV2(data)
        case .v3:
            return migrateFromV3(data)
        case .v4:
            return migrateFromV4(data)
        case .v5:
            return try? JSONDecoder().decode(GameState.self, from: data)
        }
    }

    private static func saveToCurrentVersion(_ state: GameState) {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: SaveVersion.current.saveKey)
        }
    }
}

// MARK: - Legacy Game States

/// V1: Basic resources, nodes, tick count
private struct GameStateV1: Codable {
    var resources: PlayerResources
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var currentTick: Int
    var totalPlayTime: TimeInterval
}

/// V2: Added UnlockState, ThreatState
private struct GameStateV2: Codable {
    var resources: PlayerResources
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var currentTick: Int
    var totalPlayTime: TimeInterval
    var threatState: ThreatState
    var unlockState: UnlockState
}

/// V3: Added FirewallNode
private struct GameStateV3: Codable {
    var resources: PlayerResources
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var firewall: FirewallNode?
    var currentTick: Int
    var totalPlayTime: TimeInterval
    var threatState: ThreatState
    var unlockState: UnlockState
    var lastSaveTimestamp: Date?
}

/// V4: Added LoreState, MilestoneState
private struct GameStateV4: Codable {
    var resources: PlayerResources
    var source: SourceNode
    var link: TransportLink
    var sink: SinkNode
    var firewall: FirewallNode?
    var currentTick: Int
    var totalPlayTime: TimeInterval
    var threatState: ThreatState
    var unlockState: UnlockState
    var loreState: LoreState
    var milestoneState: MilestoneState
    var lastSaveTimestamp: Date?
}

// MARK: - Migration Functions

extension SaveMigrationManager {

    /// V1 → V5 (current)
    private static func migrateFromV1(_ data: Data) -> GameState? {
        guard let v1 = try? JSONDecoder().decode(GameStateV1.self, from: data) else {
            return nil
        }

        var loreState = LoreState()
        for fragment in LoreDatabase.starterFragments() {
            loreState.unlock(fragment.id)
        }

        return GameState(
            resources: v1.resources,
            source: v1.source,
            link: v1.link,
            sink: v1.sink,
            firewall: nil,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            currentTick: v1.currentTick,
            totalPlayTime: v1.totalPlayTime,
            threatState: ThreatState(),
            unlockState: UnlockState(),
            loreState: loreState,
            milestoneState: MilestoneState(),
            prestigeState: PrestigeState(),
            lastSaveTimestamp: nil,
            criticalAlarmAcknowledged: false
        )
    }

    /// V2 → V5 (current)
    private static func migrateFromV2(_ data: Data) -> GameState? {
        guard let v2 = try? JSONDecoder().decode(GameStateV2.self, from: data) else {
            return nil
        }

        var loreState = LoreState()
        for fragment in LoreDatabase.starterFragments() {
            loreState.unlock(fragment.id)
        }

        return GameState(
            resources: v2.resources,
            source: v2.source,
            link: v2.link,
            sink: v2.sink,
            firewall: nil,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            currentTick: v2.currentTick,
            totalPlayTime: v2.totalPlayTime,
            threatState: v2.threatState,
            unlockState: v2.unlockState,
            loreState: loreState,
            milestoneState: MilestoneState(),
            prestigeState: PrestigeState(),
            lastSaveTimestamp: nil,
            criticalAlarmAcknowledged: false
        )
    }

    /// V3 → V5 (current)
    private static func migrateFromV3(_ data: Data) -> GameState? {
        guard let v3 = try? JSONDecoder().decode(GameStateV3.self, from: data) else {
            return nil
        }

        var loreState = LoreState()
        for fragment in LoreDatabase.starterFragments() {
            loreState.unlock(fragment.id)
        }

        return GameState(
            resources: v3.resources,
            source: v3.source,
            link: v3.link,
            sink: v3.sink,
            firewall: v3.firewall,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            currentTick: v3.currentTick,
            totalPlayTime: v3.totalPlayTime,
            threatState: v3.threatState,
            unlockState: v3.unlockState,
            loreState: loreState,
            milestoneState: MilestoneState(),
            prestigeState: PrestigeState(),
            lastSaveTimestamp: v3.lastSaveTimestamp,
            criticalAlarmAcknowledged: false
        )
    }

    /// V4 → V5 (current)
    private static func migrateFromV4(_ data: Data) -> GameState? {
        guard let v4 = try? JSONDecoder().decode(GameStateV4.self, from: data) else {
            return nil
        }

        return GameState(
            resources: v4.resources,
            source: v4.source,
            link: v4.link,
            sink: v4.sink,
            firewall: v4.firewall,
            defenseStack: DefenseStack(),
            malusIntel: MalusIntelligence(),
            currentTick: v4.currentTick,
            totalPlayTime: v4.totalPlayTime,
            threatState: v4.threatState,
            unlockState: v4.unlockState,
            loreState: v4.loreState,
            milestoneState: v4.milestoneState,
            prestigeState: PrestigeState(),
            lastSaveTimestamp: v4.lastSaveTimestamp,
            criticalAlarmAcknowledged: false
        )
    }
}

// MARK: - Migration Result

struct MigrationResult {
    let fromVersion: SaveVersion
    let toVersion: SaveVersion
    let state: GameState

    var didMigrate: Bool {
        fromVersion != toVersion
    }

    var description: String {
        if didMigrate {
            return "Migrated save from v\(fromVersion.rawValue) to v\(toVersion.rawValue)"
        } else {
            return "Loaded save at v\(toVersion.rawValue)"
        }
    }
}

// MARK: - Save Utilities

extension SaveMigrationManager {

    /// Remove all save data (all versions)
    static func clearAllSaves() {
        for version in SaveVersion.allCases {
            UserDefaults.standard.removeObject(forKey: version.saveKey)
        }
    }

    /// Check if any save exists (any version)
    static func hasSave() -> Bool {
        for version in SaveVersion.allCases.reversed() {
            if UserDefaults.standard.data(forKey: version.saveKey) != nil {
                return true
            }
        }
        return false
    }

    /// Get the version of the existing save, if any
    static func existingSaveVersion() -> SaveVersion? {
        for version in SaveVersion.allCases.reversed() {
            if UserDefaults.standard.data(forKey: version.saveKey) != nil {
                return version
            }
        }
        return nil
    }
}
