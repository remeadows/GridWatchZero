//
//  InsaneModeRunwayTests.swift
//  GridWatchZeroTests
//
//  Regression coverage for Insane-mode startup upgrade runway.
//

import Testing
import Foundation
@testable import GridWatchZero

@Suite("Insane Mode Runway Tests", .serialized)
@MainActor
struct InsaneModeRunwayTests {

    private func startLevel(_ levelId: Int, isInsane: Bool) -> GameEngine {
        let engine = GameEngine()
        engine.resetGame()

        guard let level = LevelDatabase.shared.level(forId: levelId) else {
            Issue.record("Missing level \(levelId)")
            return engine
        }

        let config = LevelConfiguration(level: level, isInsane: isInsane)
        engine.startCampaignLevel(config)
        engine.pause() // Freeze deterministic startup state for assertions.
        return engine
    }

    private func startInsaneLevel(_ levelId: Int) -> GameEngine {
        startLevel(levelId, isInsane: true)
    }

    @Test("Insane mode starts with credits runway and starter firewall")
    func testInsaneStartHasRunway() async {
        let engine = startInsaneLevel(1)
        #expect(engine.resources.credits >= 120, "Insane startup should provide bootstrap credits")
        #expect(engine.firewall != nil, "Insane startup should provide a starter firewall")
    }

    @Test("Insane startup credits can afford first node/firewall upgrades")
    func testInsaneStartAffordsFirstUpgrades() async {
        let engine = startInsaneLevel(1)
        let credits = engine.resources.credits

        #expect(credits >= engine.source.upgradeCost, "Should afford first SOURCE upgrade")
        #expect(credits >= engine.link.upgradeCost, "Should afford first LINK upgrade")
        #expect(credits >= engine.sink.upgradeCost, "Should afford first SINK upgrade")

        guard let firewall = engine.firewall else {
            Issue.record("Expected starter firewall in insane mode")
            return
        }
        #expect(credits >= firewall.upgradeCost, "Should afford first FW upgrade")
    }

    @Test("Insane attack grace period guarantees startup runway")
    func testInsaneGraceIsGuaranteed() async {
        guard let level1 = LevelDatabase.shared.level(forId: 1),
              let level3 = LevelDatabase.shared.level(forId: 3) else {
            Issue.record("Missing expected campaign levels")
            return
        }

        let level1Insane = LevelConfiguration(level: level1, isInsane: true)
        let level3Insane = LevelConfiguration(level: level3, isInsane: true)

        #expect(level1Insane.attackGracePeriod >= 60, "L1 insane should have at least 60 ticks grace")
        #expect(level3Insane.attackGracePeriod >= 45, "Insane grace should never drop below 45 ticks")
    }

    @Test("Level 1 insane allows Tier 2 unit progression")
    func testInsaneLevel1AllowsTier2Unlocks() async {
        guard let tier2Source = UnitFactory.unit(withId: "source_t2_corp_leech"),
              let tier2Link = UnitFactory.unit(withId: "link_t2_fiber_relay"),
              let tier2Sink = UnitFactory.unit(withId: "sink_t2_shadow_market"),
              let tier2Firewall = UnitFactory.unit(withId: "defense_t2_adaptive_ids") else {
            Issue.record("Missing expected Tier 2 units")
            return
        }

        let insaneEngine = startLevel(1, isInsane: true)
        insaneEngine.resources.credits = 1_000_000
        insaneEngine.source.level = insaneEngine.source.maxLevel
        insaneEngine.link.level = insaneEngine.link.maxLevel
        insaneEngine.sink.level = insaneEngine.sink.maxLevel
        if var firewall = insaneEngine.firewall {
            firewall.level = firewall.maxLevel
            insaneEngine.firewall = firewall
        }

        #expect(insaneEngine.maxTierAvailable >= 2, "Insane Level 1 should expose Tier 2 progression")
        #expect(insaneEngine.canUnlock(tier2Source))
        #expect(insaneEngine.canUnlock(tier2Link))
        #expect(insaneEngine.canUnlock(tier2Sink))
        #expect(insaneEngine.canUnlock(tier2Firewall))

        let normalEngine = startLevel(1, isInsane: false)
        normalEngine.resources.credits = 1_000_000
        normalEngine.source.level = normalEngine.source.maxLevel
        normalEngine.link.level = normalEngine.link.maxLevel
        normalEngine.sink.level = normalEngine.sink.maxLevel
        normalEngine.firewall = UnitFactory.createBasicFirewall()
        if var firewall = normalEngine.firewall {
            firewall.level = firewall.maxLevel
            normalEngine.firewall = firewall
        }

        #expect(normalEngine.maxTierAvailable == 1, "Normal Level 1 mission config remains Tier 1")
        #expect(normalEngine.canUnlock(tier2Source), "Normal Level 1 should still expose Tier 2 runway")
        #expect(normalEngine.canUnlock(tier2Link), "Normal Level 1 should still expose Tier 2 runway")
        #expect(normalEngine.canUnlock(tier2Sink), "Normal Level 1 should still expose Tier 2 runway")
        #expect(normalEngine.canUnlock(tier2Firewall), "Normal Level 1 should still expose Tier 2 runway")
    }

    @Test("Level 1 insane allows Tier 3 once Tier 2 is equipped and maxed")
    func testInsaneLevel1AllowsTier3UnlocksAfterTier2Maxed() async {
        guard let t2SourceInfo = UnitFactory.unit(withId: "source_t2_corp_leech"),
              let t2LinkInfo = UnitFactory.unit(withId: "link_t2_fiber_relay"),
              let t2SinkInfo = UnitFactory.unit(withId: "sink_t2_shadow_market"),
              let t2DefenseInfo = UnitFactory.unit(withId: "defense_t2_adaptive_ids"),
              let t3Source = UnitFactory.unit(withId: "source_t3_zero_day"),
              let t3Link = UnitFactory.unit(withId: "link_t3_quantum_bridge"),
              let t3Sink = UnitFactory.unit(withId: "sink_t3_corp_backdoor"),
              let t3Defense = UnitFactory.unit(withId: "defense_t3_neural_counter") else {
            Issue.record("Missing expected Tier 2/3 units")
            return
        }

        let insane = startLevel(1, isInsane: true)
        insane.resources.credits = 1_000_000_000

        guard let sourceT2 = UnitFactory.createSource(fromId: t2SourceInfo.id),
              let linkT2 = UnitFactory.createLink(fromId: t2LinkInfo.id),
              let sinkT2 = UnitFactory.createSink(fromId: t2SinkInfo.id),
              let defenseT2 = UnitFactory.createFirewall(fromId: t2DefenseInfo.id) else {
            Issue.record("Missing Tier 2 constructors")
            return
        }

        insane.source = sourceT2
        insane.link = linkT2
        insane.sink = sinkT2
        insane.firewall = defenseT2

        insane.source.level = insane.source.maxLevel
        insane.link.level = insane.link.maxLevel
        insane.sink.level = insane.sink.maxLevel
        if var fw = insane.firewall {
            fw.level = fw.maxLevel
            insane.firewall = fw
        }

        #expect(insane.campaignTierGateReason(for: t3Source) == nil)
        #expect(insane.campaignTierGateReason(for: t3Link) == nil)
        #expect(insane.campaignTierGateReason(for: t3Sink) == nil)
        #expect(insane.campaignTierGateReason(for: t3Defense) == nil)

        #expect(insane.canUnlock(t3Source), "Insane mode should allow T3 Source after T2 max")
        #expect(insane.canUnlock(t3Link), "Insane mode should allow T3 Link after T2 max")
        #expect(insane.canUnlock(t3Sink), "Insane mode should allow T3 Sink after T2 max")
        #expect(insane.canUnlock(t3Defense), "Insane mode should allow T3 Defense after T2 max")

        let normal = startLevel(1, isInsane: false)
        normal.resources.credits = 1_000_000_000
        normal.source = sourceT2
        normal.link = linkT2
        normal.sink = sinkT2
        normal.firewall = defenseT2

        normal.source.level = normal.source.maxLevel
        normal.link.level = normal.link.maxLevel
        normal.sink.level = normal.sink.maxLevel
        if var fw = normal.firewall {
            fw.level = fw.maxLevel
            normal.firewall = fw
        }

        #expect(normal.canUnlock(t3Source) == false, "Normal L1 should still gate T3 by mission cap")
        #expect(normal.campaignTierGateReason(for: t3Source) == "Mission tier cap is T2")
    }

    @Test("Level 1 never reports mission cap T1 for Tier 2 units")
    func testLevel1NeverCapsTier2AtT1() async {
        guard let tier2Source = UnitFactory.unit(withId: "source_t2_corp_leech"),
              let tier2Link = UnitFactory.unit(withId: "link_t2_fiber_relay"),
              let tier2Sink = UnitFactory.unit(withId: "sink_t2_shadow_market"),
              let tier2Firewall = UnitFactory.unit(withId: "defense_t2_adaptive_ids") else {
            Issue.record("Missing expected Tier 2 units")
            return
        }

        let normalEngine = startLevel(1, isInsane: false)
        let insaneEngine = startLevel(1, isInsane: true)
        let tier2Units = [tier2Source, tier2Link, tier2Sink, tier2Firewall]

        for unit in tier2Units {
            let normalCampaignReason = normalEngine.campaignTierGateReason(for: unit) ?? ""
            #expect(
                !normalCampaignReason.contains("Mission tier cap is T1"),
                "Normal L1 should not campaign-cap \(unit.id) at T1"
            )

            let insaneCampaignReason = insaneEngine.campaignTierGateReason(for: unit) ?? ""
            #expect(
                !insaneCampaignReason.contains("Mission tier cap is T1"),
                "Insane L1 should not campaign-cap \(unit.id) at T1"
            )

            let normalReason = normalEngine.unlockBlockReason(for: unit) ?? ""
            #expect(
                !normalReason.contains("Mission tier cap is T1"),
                "Normal L1 unlock reason should not show T1 mission cap for \(unit.id)"
            )

            let insaneReason = insaneEngine.unlockBlockReason(for: unit) ?? ""
            #expect(
                !insaneReason.contains("Mission tier cap is T1"),
                "Insane L1 unlock reason should not show T1 mission cap for \(unit.id)"
            )
        }
    }

    @Test("Insane mode allows top-tier unlocks when tier-gate is satisfied")
    func testInsaneTopTierUnlocksIgnoreMissionCap() async {
        guard let t24Source = UnitFactory.unit(withId: "source_t24_omega_stream"),
              let t24Link = UnitFactory.unit(withId: "link_t24_omega_bridge"),
              let t24Sink = UnitFactory.unit(withId: "sink_t24_omega_processor"),
              let t24Defense = UnitFactory.unit(withId: "defense_t24_omega_barrier"),
              let t25Source = UnitFactory.unit(withId: "source_t25_all_seeing"),
              let t25Link = UnitFactory.unit(withId: "link_t25_infinite_backbone"),
              let t25Sink = UnitFactory.unit(withId: "sink_t25_infinite_core"),
              let t25Defense = UnitFactory.unit(withId: "defense_t25_impenetrable") else {
            Issue.record("Missing expected Tier 24/25 units")
            return
        }

        let insane = startLevel(1, isInsane: true)
        insane.resources.credits = 1e30

        guard let source24 = UnitFactory.createSource(fromId: t24Source.id),
              let link24 = UnitFactory.createLink(fromId: t24Link.id),
              let sink24 = UnitFactory.createSink(fromId: t24Sink.id),
              let defense24 = UnitFactory.createFirewall(fromId: t24Defense.id) else {
            Issue.record("Missing Tier 24 unit constructors")
            return
        }

        insane.source = source24
        insane.link = link24
        insane.sink = sink24
        insane.firewall = defense24

        insane.source.level = insane.source.maxLevel
        insane.link.level = insane.link.maxLevel
        insane.sink.level = insane.sink.maxLevel
        if var fw = insane.firewall {
            fw.level = fw.maxLevel
            insane.firewall = fw
        }

        #expect(insane.campaignTierGateReason(for: t25Source) == nil)
        #expect(insane.campaignTierGateReason(for: t25Link) == nil)
        #expect(insane.campaignTierGateReason(for: t25Sink) == nil)
        #expect(insane.campaignTierGateReason(for: t25Defense) == nil)

        #expect(insane.canUnlock(t25Source), "Insane mode should allow Tier 25 source when Tier 24 is maxed")
        #expect(insane.canUnlock(t25Link), "Insane mode should allow Tier 25 link when Tier 24 is maxed")
        #expect(insane.canUnlock(t25Sink), "Insane mode should allow Tier 25 sink when Tier 24 is maxed")
        #expect(insane.canUnlock(t25Defense), "Insane mode should allow Tier 25 defense when Tier 24 is maxed")

        let normal = startLevel(1, isInsane: false)
        normal.resources.credits = 1e30
        #expect(normal.campaignTierGateReason(for: t25Source) != nil, "Normal mode should still enforce mission cap")
    }

    @Test("Insane checkpoint resume keeps Tier 2 progression available")
    func testInsaneResumeRetainsTier2Runway() async {
        CampaignSaveManager.shared.reset()

        guard let level = LevelDatabase.shared.level(forId: 1),
              let tier2Source = UnitFactory.unit(withId: "source_t2_corp_leech"),
              let tier2Link = UnitFactory.unit(withId: "link_t2_fiber_relay"),
              let tier2Sink = UnitFactory.unit(withId: "sink_t2_shadow_market"),
              let tier2Firewall = UnitFactory.unit(withId: "defense_t2_adaptive_ids") else {
            Issue.record("Missing expected level or Tier 2 units")
            return
        }

        let config = LevelConfiguration(level: level, isInsane: true)

        let engine = GameEngine()
        engine.resetGame()
        engine.startCampaignLevel(config)
        engine.pause()

        engine.resources.credits = 2_000_000
        engine.source.level = engine.source.maxLevel
        engine.link.level = engine.link.maxLevel
        engine.sink.level = engine.sink.maxLevel
        if var firewall = engine.firewall {
            firewall.level = firewall.maxLevel
            engine.firewall = firewall
        }
        engine.threatState.totalCreditsEarned = 1_200
        engine.threatState.currentLevel = .signal

        engine.saveCampaignCheckpoint()
        guard let checkpoint = CampaignSaveManager.shared.load().activeCheckpoint else {
            Issue.record("Expected active checkpoint after saveCampaignCheckpoint")
            return
        }

        let resumed = GameEngine()
        resumed.resetGame()
        resumed.resumeFromCheckpoint(checkpoint, config: config)
        resumed.pause()

        #expect(resumed.levelConfiguration?.isInsane == true, "Resumed config must remain Insane")
        #expect(resumed.maxTierAvailable >= 2, "Resumed Insane L1 should expose Tier 2")
        #expect(resumed.threatState.totalCreditsEarned >= 1_200, "Resume should preserve earned-credit threat progression")
        #expect(resumed.threatState.currentLevel.rawValue >= ThreatLevel.signal.rawValue, "Resume should not regress threat level below saved state")
        #expect(resumed.canUnlock(tier2Source))
        #expect(resumed.canUnlock(tier2Link))
        #expect(resumed.canUnlock(tier2Sink))
        #expect(resumed.canUnlock(tier2Firewall))

        CampaignSaveManager.shared.reset()
    }

    @Test("Insane runway unlocks next tier beyond mission cap when equipped tier advances")
    func testInsaneRunwayExpandsWithEquippedTier() async {
        CampaignSaveManager.shared.reset()
        defer { CampaignSaveManager.shared.reset() }

        guard let level = LevelDatabase.shared.level(forId: 1),
              let t2Source = UnitFactory.unit(withId: "source_t2_corp_leech"),
              let t2Link = UnitFactory.unit(withId: "link_t2_fiber_relay"),
              let t2Sink = UnitFactory.unit(withId: "sink_t2_shadow_market"),
              let t2Defense = UnitFactory.unit(withId: "defense_t2_adaptive_ids"),
              let t3Source = UnitFactory.unit(withId: "source_t3_zero_day"),
              let t3Link = UnitFactory.unit(withId: "link_t3_quantum_bridge"),
              let t3Sink = UnitFactory.unit(withId: "sink_t3_corp_backdoor"),
              let t3Defense = UnitFactory.unit(withId: "defense_t3_neural_counter") else {
            Issue.record("Missing expected level or tier definitions")
            return
        }

        let insane = GameEngine()
        insane.resetGame()
        insane.startCampaignLevel(LevelConfiguration(level: level, isInsane: true))
        insane.pause()
        insane.resources.credits = 100_000_000

        insane.source.level = insane.source.maxLevel
        #expect(insane.canUnlock(t2Source), "Insane L1 should allow Tier 2 source at T1 max")
        #expect(insane.unlockUnit(t2Source))
        #expect(insane.setSource(t2Source.id))

        insane.source.level = insane.source.maxLevel
        #expect(insane.source.tier.rawValue == 2)
        #expect(insane.canUnlock(t3Source), "Insane runway should allow Tier 3 source once Tier 2 is equipped and maxed")

        insane.link.level = insane.link.maxLevel
        #expect(insane.canUnlock(t2Link), "Insane L1 should allow Tier 2 link at T1 max")
        #expect(insane.unlockUnit(t2Link))
        #expect(insane.setLink(t2Link.id))
        insane.link.level = insane.link.maxLevel
        #expect(insane.link.tier.rawValue == 2)
        #expect(insane.canUnlock(t3Link), "Insane runway should allow Tier 3 link once Tier 2 is equipped and maxed")

        insane.sink.level = insane.sink.maxLevel
        #expect(insane.canUnlock(t2Sink), "Insane L1 should allow Tier 2 sink at T1 max")
        #expect(insane.unlockUnit(t2Sink))
        #expect(insane.setSink(t2Sink.id))
        insane.sink.level = insane.sink.maxLevel
        #expect(insane.sink.tier.rawValue == 2)
        #expect(insane.canUnlock(t3Sink), "Insane runway should allow Tier 3 sink once Tier 2 is equipped and maxed")

        if insane.firewall == nil {
            insane.firewall = UnitFactory.createBasicFirewall()
        }
        if var firewall = insane.firewall {
            firewall.level = firewall.maxLevel
            insane.firewall = firewall
        }
        #expect(insane.canUnlock(t2Defense), "Insane L1 should allow Tier 2 defense at T1 max")
        #expect(insane.unlockUnit(t2Defense))
        #expect(insane.setFirewall(t2Defense.id))
        if var firewall = insane.firewall {
            firewall.level = firewall.maxLevel
            insane.firewall = firewall
        }
        #expect(insane.firewall?.nodeTier.rawValue == 2)
        #expect(insane.canUnlock(t3Defense), "Insane runway should allow Tier 3 defense once Tier 2 is equipped and maxed")

        let normal = GameEngine()
        normal.resetGame()
        normal.startCampaignLevel(LevelConfiguration(level: level, isInsane: false))
        normal.pause()
        normal.resources.credits = 100_000_000
        normal.source.level = normal.source.maxLevel

        #expect(normal.canUnlock(t2Source), "Normal L1 should allow Tier 2 runway once T1 is maxed")
        #expect(!normal.canUnlock(t3Source), "Normal L1 runway should stop at Tier 2")
    }
}
