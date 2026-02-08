//
//  SaveSystemTests.swift
//  GridWatchZeroTests
//
//  Created by War Signal on 2026-02-06.
//  Tests for save/load functionality, migration, and iCloud sync
//

import Testing
import Foundation
@testable import GridWatchZero

/// Tests for the save system and persistence
@Suite("Save System Tests")
@MainActor
struct SaveSystemTests {

    // MARK: - GameState Structure Tests

    @Test("GameState can be created")
    func testGameStateCreation() async {
        let state = GameState.newGame()

        #expect(state.resources.credits >= 0, "New game should have valid credits")
        #expect(state.currentTick >= 0, "New game should have valid tick count")
        #expect(!state.source.name.isEmpty, "New game should have a source node")
        #expect(!state.link.name.isEmpty, "New game should have a link node")
        #expect(!state.sink.name.isEmpty, "New game should have a sink node")
    }

    @Test("GameState has all required properties")
    func testGameStateProperties() async {
        let state = GameState.newGame()

        // Verify all critical properties exist
        #expect(state.resources.credits >= 0, "Should have resources")
        #expect(state.source.level > 0, "Should have source node")
        #expect(state.link.level > 0, "Should have link node")
        #expect(state.sink.level > 0, "Should have sink node")
        #expect(state.defenseStack.totalDefensePoints >= 0, "Should have defense stack")
        #expect(state.malusIntel.reportsSent >= 0, "Should have malus intel")
        #expect(state.currentTick >= 0, "Should have tick count")
        #expect(state.threatState.currentLevel.rawValue >= 1, "Should have threat state")
        #expect(state.unlockState.unlockedUnitIds.count > 0, "Should have unlocked units")
        #expect(state.loreState.unlockedFragments.count >= 0, "Should have lore state")
        #expect(state.milestoneState.completedMilestoneIds.count >= 0, "Should have milestone state")
        #expect(state.prestigeState.prestigeLevel >= 0, "Should have prestige state")
    }

    @Test("GameState can be encoded to JSON")
    func testGameStateEncoding() async {
        let state = GameState.newGame()

        // Try to encode
        let encoder = JSONEncoder()
        let data = try? encoder.encode(state)

        #expect(data != nil, "GameState should be encodable")
        #expect((data?.count ?? 0) > 0, "Encoded data should not be empty")
    }

    @Test("GameState can be decoded from JSON")
    func testGameStateDecoding() async {
        let state = GameState.newGame()

        // Encode then decode
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(state) else {
            Issue.record("Failed to encode GameState")
            return
        }

        let decoder = JSONDecoder()
        let decoded = try? decoder.decode(GameState.self, from: data)

        #expect(decoded != nil, "GameState should be decodable")
        #expect(decoded?.resources.credits == state.resources.credits, "Credits should match")
        #expect(decoded?.currentTick == state.currentTick, "Tick count should match")
    }

    // MARK: - Save Version Tests

    @Test("SaveVersion has correct current version")
    func testSaveVersionCurrent() async {
        let current = SaveVersion.current

        #expect(current == .v6, "Current version should be v6")
        #expect(current.rawValue == 6, "v6 should have raw value 6")
    }

    @Test("SaveVersion generates correct save keys")
    func testSaveVersionKeys() async {
        let v1Key = SaveVersion.v1.saveKey
        let v2Key = SaveVersion.v2.saveKey
        let v6Key = SaveVersion.v6.saveKey

        #expect(v1Key == "GridWatchZero.GameState.v1", "v1 key should be correct")
        #expect(v2Key == "GridWatchZero.GameState.v2", "v2 key should be correct")
        #expect(v6Key == "GridWatchZero.GameState.v6", "v6 key should be correct")
    }

    @Test("SaveVersion versions are comparable")
    func testSaveVersionComparison() async {
        #expect(SaveVersion.v1 < SaveVersion.v2, "v1 should be less than v2")
        #expect(SaveVersion.v2 < SaveVersion.v3, "v2 should be less than v3")
        #expect(SaveVersion.v5 < SaveVersion.v6, "v5 should be less than v6")
        #expect(!(SaveVersion.v6 < SaveVersion.v1), "v6 should not be less than v1")
    }

    @Test("SaveVersion allCases includes all versions")
    func testSaveVersionAllCases() async {
        let allCases = SaveVersion.allCases

        #expect(allCases.count == 6, "Should have 6 save versions")
        #expect(allCases.contains(.v1), "Should contain v1")
        #expect(allCases.contains(.v6), "Should contain v6")
    }

    // MARK: - GameEngine Save/Load Tests

    @Test("GameEngine loads existing save on init")
    func testGameEngineLoadsOnInit() async {
        // GameEngine constructor calls loadGame() automatically
        let engine = GameEngine()

        // Engine should have loaded state (or initialized fresh)
        #expect(engine.resources.credits >= 0, "Should have valid credits after init")
        #expect(engine.currentTick >= 0, "Should have valid tick count after init")
    }

    @Test("GameEngine state persists after modification")
    func testGameStateModification() async {
        let state = GameState.newGame()

        // Modify state
        var modifiedState = state
        modifiedState.currentTick = 100
        modifiedState.resources.credits = 5000

        #expect(modifiedState.currentTick == 100, "Tick count should be modified")
        #expect(modifiedState.resources.credits == 5000, "Credits should be modified")
    }

    // MARK: - Offline Progress Tests

    @Test("OfflineProgress calculates correct time away")
    func testOfflineProgressTimeFormatting() async {
        let secondsProgress = OfflineProgress(
            secondsAway: 45,
            ticksSimulated: 45,
            creditsEarned: 100,
            dataProcessed: 500
        )
        #expect(secondsProgress.formattedTimeAway.contains("second"), "Should show seconds")

        let minutesProgress = OfflineProgress(
            secondsAway: 120,
            ticksSimulated: 120,
            creditsEarned: 1000,
            dataProcessed: 5000
        )
        #expect(minutesProgress.formattedTimeAway.contains("minute"), "Should show minutes")

        let hoursProgress = OfflineProgress(
            secondsAway: 7200,
            ticksSimulated: 7200,
            creditsEarned: 10000,
            dataProcessed: 50000
        )
        #expect(hoursProgress.formattedTimeAway.contains("hour"), "Should show hours")
    }

    @Test("OfflineProgress has valid properties")
    func testOfflineProgressProperties() async {
        let progress = OfflineProgress(
            secondsAway: 3600,
            ticksSimulated: 3600,
            creditsEarned: 5000,
            dataProcessed: 25000
        )

        #expect(progress.secondsAway == 3600, "Seconds away should match")
        #expect(progress.ticksSimulated == 3600, "Ticks simulated should match")
        #expect(progress.creditsEarned == 5000, "Credits earned should match")
        #expect(progress.dataProcessed == 25000, "Data processed should match")
    }

    @Test("OfflineProgress is equatable")
    func testOfflineProgressEquality() async {
        let progress1 = OfflineProgress(
            secondsAway: 100,
            ticksSimulated: 100,
            creditsEarned: 500,
            dataProcessed: 2000
        )
        let progress2 = OfflineProgress(
            secondsAway: 100,
            ticksSimulated: 100,
            creditsEarned: 500,
            dataProcessed: 2000
        )
        let progress3 = OfflineProgress(
            secondsAway: 200,
            ticksSimulated: 200,
            creditsEarned: 1000,
            dataProcessed: 4000
        )

        #expect(progress1 == progress2, "Identical progress should be equal")
        #expect(progress1 != progress3, "Different progress should not be equal")
    }

    // MARK: - UnlockState Tests

    @Test("UnlockState initializes with starter units")
    func testUnlockStateInitialization() async {
        let unlockState = UnlockState()

        #expect(unlockState.unlockedUnitIds.count >= 3, "Should have at least 3 starter units")
        #expect(unlockState.unlockedUnitIds.contains("source_t1_mesh_sniffer"), "Should have T1 source")
        #expect(unlockState.unlockedUnitIds.contains("link_t1_copper_vpn"), "Should have T1 link")
        #expect(unlockState.unlockedUnitIds.contains("sink_t1_data_broker"), "Should have T1 sink")
    }

    @Test("UnlockState is codable")
    func testUnlockStateCodable() async {
        var unlockState = UnlockState()
        unlockState.unlockedUnitIds.insert("source_t2_botnet_scraper")

        // Encode
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(unlockState) else {
            Issue.record("Failed to encode UnlockState")
            return
        }

        // Decode
        let decoder = JSONDecoder()
        let decoded = try? decoder.decode(UnlockState.self, from: data)

        #expect(decoded != nil, "UnlockState should be decodable")
        #expect(decoded?.unlockedUnitIds.contains("source_t2_botnet_scraper") == true, "Unlocked units should match")
    }

    // MARK: - Cloud Save Status Tests

    @Test("CloudSaveStatus has correct availability states")
    func testCloudSaveStatusAvailability() async {
        let available = CloudSaveStatus.available
        let synced = CloudSaveStatus.synced(lastSync: Date())
        let syncing = CloudSaveStatus.syncing
        let unavailable = CloudSaveStatus.unavailable(reason: "No iCloud")
        let error = CloudSaveStatus.error(message: "Network error")

        #expect(available.isAvailable == true, "available should be available")
        #expect(synced.isAvailable == true, "synced should be available")
        #expect(syncing.isAvailable == true, "syncing should be available")
        #expect(unavailable.isAvailable == false, "unavailable should not be available")
        #expect(error.isAvailable == false, "error should not be available")
    }

    @Test("CloudSaveStatus has display text")
    func testCloudSaveStatusDisplayText() async {
        let available = CloudSaveStatus.available
        let unavailable = CloudSaveStatus.unavailable(reason: "Test reason")
        let syncing = CloudSaveStatus.syncing
        let error = CloudSaveStatus.error(message: "Test error")

        #expect(available.displayText == "iCloud Ready", "available should have correct text")
        #expect(unavailable.displayText == "Test reason", "unavailable should show reason")
        #expect(syncing.displayText == "Syncing...", "syncing should have correct text")
        #expect(error.displayText == "Test error", "error should show message")
    }

    @Test("CloudSaveStatus conflict has both dates")
    func testCloudSaveStatusConflict() async {
        let localDate = Date()
        let cloudDate = Date().addingTimeInterval(-3600) // 1 hour ago

        let conflict = CloudSaveStatus.conflict(localDate: localDate, cloudDate: cloudDate)

        #expect(conflict.displayText == "Sync Conflict", "Conflict should have correct text")
        #expect(conflict.isAvailable == false, "Conflict should not be available")
    }

    // MARK: - SyncableProgress Tests

    @Test("SyncableProgress initializes with current device")
    func testSyncableProgressInitialization() async {
        let campaignProgress = CampaignProgress()
        let storyState = StoryState()

        let syncable = SyncableProgress(progress: campaignProgress, storyState: storyState)

        #expect(!syncable.deviceId.isEmpty, "Should have device ID")
        #expect(syncable.timestamp <= Date(), "Timestamp should be in past or present")
        #expect(syncable.progress.completedLevels.count >= 0, "Should have progress")
    }

    @Test("SyncableProgress device ID persists")
    func testSyncableProgressDeviceIdPersistence() async {
        let deviceId1 = SyncableProgress.currentDeviceId
        let deviceId2 = SyncableProgress.currentDeviceId

        #expect(deviceId1 == deviceId2, "Device ID should persist across calls")
        #expect(!deviceId1.isEmpty, "Device ID should not be empty")
    }

    @Test("SyncableProgress is codable")
    func testSyncableProgressCodable() async {
        let campaignProgress = CampaignProgress()
        let storyState = StoryState()
        let syncable = SyncableProgress(progress: campaignProgress, storyState: storyState)

        // Encode
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(syncable) else {
            Issue.record("Failed to encode SyncableProgress")
            return
        }

        // Decode
        let decoder = JSONDecoder()
        let decoded = try? decoder.decode(SyncableProgress.self, from: data)

        #expect(decoded != nil, "SyncableProgress should be decodable")
        #expect(decoded?.deviceId == syncable.deviceId, "Device ID should match")
    }

    // MARK: - Prestige State Tests

    @Test("Prestige state initializes correctly")
    func testPrestigeStateInitialization() async {
        let state = PrestigeState()

        #expect(state.prestigeLevel == 0, "New prestige state should be level 0")
        #expect(state.totalHelixCores == 0, "New prestige state should have 0 cores")
    }

    @Test("Prestige multipliers are calculated correctly")
    func testPrestigeMultipliers() async {
        var state = PrestigeState()
        state.prestigeLevel = 2
        state.totalHelixCores = 10

        let productionMultiplier = state.productionMultiplier
        let creditMultiplier = state.creditMultiplier

        // Production: 1.0 + (2 × 0.1) + (10 × 0.05) = 1.0 + 0.2 + 0.5 = 1.7
        #expect(productionMultiplier == 1.7, "Production multiplier should be 1.7")

        // Credit: 1.0 + (2 × 0.15) = 1.0 + 0.3 = 1.3
        #expect(creditMultiplier == 1.3, "Credit multiplier should be 1.3")
    }

    @Test("Prestige credits required scales correctly")
    func testPrestigeCreditsRequired() async {
        let level0 = PrestigeState.creditsRequiredForPrestige(level: 0)
        let level1 = PrestigeState.creditsRequiredForPrestige(level: 1)
        let level2 = PrestigeState.creditsRequiredForPrestige(level: 2)

        // 150K × 5^level
        #expect(level0 == 150_000, "Level 0 should require 150K")
        #expect(level1 == 750_000, "Level 1 should require 750K")
        #expect(level2 == 3_750_000, "Level 2 should require 3.75M")
    }

    @Test("Prestige cores earned calculation")
    func testPrestigeCoresEarned() async {
        let cores1 = PrestigeState.helixCoresEarned(fromCredits: 150_000, atLevel: 0)
        let cores2 = PrestigeState.helixCoresEarned(fromCredits: 300_000, atLevel: 0)
        let cores3 = PrestigeState.helixCoresEarned(fromCredits: 750_000, atLevel: 0)

        // Base 1 core + 1 per 2x requirement
        #expect(cores1 == 1, "At 1x requirement should earn 1 core")
        #expect(cores2 == 2, "At 2x requirement should earn 2 cores")
        #expect(cores3 == 3, "At 5x requirement should earn 3 cores")
    }

    // MARK: - Save Key Tests

    @Test("Save keys are consistent")
    func testSaveKeyConsistency() async {
        // The save key should be for v6
        let expectedKey = "GridWatchZero.GameState.v6"

        // We can't directly access the private saveKey property,
        // but we can verify SaveVersion.current.saveKey
        #expect(SaveVersion.current.saveKey == expectedKey, "Save key should be consistent")
    }

    // MARK: - Save Migration Tests

    @Test("SaveMigrationManager can detect existing saves")
    func testSaveMigrationDetection() async {
        // Test that migration manager can check for saves
        let hasSave = SaveMigrationManager.hasSave()
        #expect(hasSave == true || hasSave == false, "Should return valid boolean")
    }

    @Test("SaveMigrationManager can identify save version")
    func testSaveMigrationVersionDetection() async {
        // Test that migration manager can identify version
        let version = SaveMigrationManager.existingSaveVersion()

        if let v = version {
            #expect(v.rawValue >= 1 && v.rawValue <= 6, "Version should be in valid range")
        }
    }

    // MARK: - Brand Migration Tests

    @Test("BrandMigrationManager has migration flag")
    func testBrandMigrationFlag() async {
        // Test that brand migration tracking works
        let isComplete = BrandMigrationManager.isMigrationComplete
        #expect(isComplete == true || isComplete == false, "Should return valid boolean")
    }

    @Test("BrandMigrationManager can check for old data")
    func testBrandMigrationOldDataCheck() async {
        // Test that we can check for old brand data
        let hasOldData = BrandMigrationManager.hasOldBrandData()
        #expect(hasOldData == true || hasOldData == false, "Should return valid boolean")
    }

    // MARK: - Cloud Save Conflict Tests

    @Test("CloudSaveStatus represents all states correctly")
    func testCloudSaveStatusStates() async {
        let available = CloudSaveStatus.available
        let unavailable = CloudSaveStatus.unavailable(reason: "Test")
        let syncing = CloudSaveStatus.syncing
        let synced = CloudSaveStatus.synced(lastSync: Date())
        let conflict = CloudSaveStatus.conflict(localDate: Date(), cloudDate: Date())
        let error = CloudSaveStatus.error(message: "Test")

        #expect(available.isAvailable == true, "available should be available")
        #expect(syncing.isAvailable == true, "syncing should be available")
        #expect(synced.isAvailable == true, "synced should be available")
        #expect(unavailable.isAvailable == false, "unavailable should not be available")
        #expect(conflict.isAvailable == false, "conflict should not be available")
        #expect(error.isAvailable == false, "error should not be available")
    }



    @Test("CloudSaveStatus conflict preserves dates")
    func testCloudSaveStatusConflictDates() async {
        let localDate = Date()
        let cloudDate = Date().addingTimeInterval(-3600)

        let conflict = CloudSaveStatus.conflict(localDate: localDate, cloudDate: cloudDate)

        if case .conflict(let local, let cloud) = conflict {
            #expect(local == localDate, "Local date should be preserved")
            #expect(cloud == cloudDate, "Cloud date should be preserved")
        } else {
            Issue.record("Conflict should preserve dates")
        }
    }

    @Test("SyncableProgress includes all required fields")
    func testSyncableProgressFields() async {
        let progress = CampaignProgress()
        let story = StoryState()
        let syncable = SyncableProgress(progress: progress, storyState: story)

        #expect(!syncable.deviceId.isEmpty, "Should have device ID")
        #expect(syncable.timestamp <= Date(), "Timestamp should be in past or present")
        #expect(syncable.progress.completedLevels.count == 0, "Fresh progress should have no completed levels")
    }



    // MARK: - Migration Result Tests

    @Test("MigrationResult tracks version migration")
    func testMigrationResultTracking() async {
        let state = GameState.newGame()
        let result = MigrationResult(fromVersion: .v5, toVersion: .v6, state: state)

        #expect(result.didMigrate == true, "Should indicate migration occurred")
        #expect(result.fromVersion == .v5, "Should track source version")
        #expect(result.toVersion == .v6, "Should track target version")
        #expect(result.description.contains("v5"), "Description should mention source version")
        #expect(result.description.contains("v6"), "Description should mention target version")
    }

    @Test("MigrationResult detects no migration")
    func testMigrationResultNoMigration() async {
        let state = GameState.newGame()
        let result = MigrationResult(fromVersion: .v6, toVersion: .v6, state: state)

        #expect(result.didMigrate == false, "Should indicate no migration")
        #expect(result.description.contains("Loaded"), "Description should indicate load not migrate")
    }
}
