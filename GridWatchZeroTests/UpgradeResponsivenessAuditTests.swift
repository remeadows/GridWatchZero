//
//  UpgradeResponsivenessAuditTests.swift
//  GridWatchZeroTests
//
//  Focused audit for upgrade responsiveness and Insane-mode progression.
//

import Testing
import Foundation
@testable import GridWatchZero

@Suite("Upgrade Responsiveness Audit")
@MainActor
struct UpgradeResponsivenessAuditTests {

    private struct BurstStats {
        let count: Int
        let totalMs: Double
        let p50Ms: Double
        let p95Ms: Double
        let maxMs: Double

        var meanMs: Double { count > 0 ? totalMs / Double(count) : 0 }
    }

    private func nowStamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }

    private func percentile(_ values: [Double], p: Double) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let index = min(sorted.count - 1, max(0, Int(Double(sorted.count - 1) * p)))
        return sorted[index]
    }

    private func runUpgradeBurst(
        engine: GameEngine,
        iterations: Int,
        emulateLegacyImmediateSaves: Bool
    ) -> BurstStats {
        var samples: [Double] = []
        samples.reserveCapacity(iterations)
        let burstStart = ContinuousClock.now

        for _ in 0..<iterations {
            engine.source.level = 1
            engine.resources.credits = 10_000_000
            if emulateLegacyImmediateSaves {
                // Legacy behavior effectively played feedback and wrote state on every tap.
                engine.lastUpgradeFeedbackTimestamp = 0
            }

            let opStart = ContinuousClock.now
            _ = engine.upgradeSource()
            if emulateLegacyImmediateSaves {
                EngagementManager.shared.save(immediate: true)
                engine.saveGame(immediate: true)
            }
            let opDuration = opStart.duration(to: ContinuousClock.now)
            let opMs = Double(opDuration.components.seconds) * 1000
                + Double(opDuration.components.attoseconds) / 1_000_000_000_000_000
            samples.append(opMs)
        }

        let burstDuration = burstStart.duration(to: ContinuousClock.now)
        let burstMs = Double(burstDuration.components.seconds) * 1000
            + Double(burstDuration.components.attoseconds) / 1_000_000_000_000_000

        return BurstStats(
            count: samples.count,
            totalMs: burstMs,
            p50Ms: percentile(samples, p: 0.50),
            p95Ms: percentile(samples, p: 0.95),
            maxMs: samples.max() ?? 0
        )
    }

    @Test("Upgrade tap/hold responsiveness audit")
    func testUpgradeResponsivenessAudit() async {
        let engine = GameEngine()
        engine.resetGame()
        engine.pause()

        let timestamp = nowStamp()
        let current = runUpgradeBurst(
            engine: engine,
            iterations: 250,
            emulateLegacyImmediateSaves: false
        )
        let legacyEmulated = runUpgradeBurst(
            engine: engine,
            iterations: 250,
            emulateLegacyImmediateSaves: true
        )

        NSLog("""
        [AUDIT][\(timestamp)] Upgrade burst timing:
          current-path: total=\(String(format: "%.2f", current.totalMs))ms mean=\(String(format: "%.4f", current.meanMs))ms p50=\(String(format: "%.4f", current.p50Ms))ms p95=\(String(format: "%.4f", current.p95Ms))ms max=\(String(format: "%.4f", current.maxMs))ms
          legacy-emulated: total=\(String(format: "%.2f", legacyEmulated.totalMs))ms mean=\(String(format: "%.4f", legacyEmulated.meanMs))ms p50=\(String(format: "%.4f", legacyEmulated.p50Ms))ms p95=\(String(format: "%.4f", legacyEmulated.p95Ms))ms max=\(String(format: "%.4f", legacyEmulated.maxMs))ms
        """)

        #expect(current.p95Ms <= legacyEmulated.p95Ms, "Current upgrade path should not be slower than legacy-emulated immediate-save path")
    }

    @Test("Insane L1 end-to-end unlock/equip/upgrade audit")
    func testInsaneL1UnlockEquipUpgradeAudit() async {
        guard let level = LevelDatabase.shared.level(forId: 1),
              let t2Source = UnitFactory.unit(withId: "source_t2_corp_leech"),
              let t2Link = UnitFactory.unit(withId: "link_t2_fiber_relay"),
              let t2Sink = UnitFactory.unit(withId: "sink_t2_shadow_market"),
              let t2Defense = UnitFactory.unit(withId: "defense_t2_adaptive_ids") else {
            Issue.record("Missing required level or unit definitions")
            return
        }

        let engine = GameEngine()
        engine.resetGame()
        engine.startCampaignLevel(LevelConfiguration(level: level, isInsane: true))
        engine.pause()

        engine.resources.credits = 50_000_000
        engine.source.level = engine.source.maxLevel
        engine.link.level = engine.link.maxLevel
        engine.sink.level = engine.sink.maxLevel
        if var fw = engine.firewall {
            fw.level = fw.maxLevel
            engine.firewall = fw
        } else {
            engine.firewall = UnitFactory.createBasicFirewall()
            engine.firewall?.level = engine.firewall?.maxLevel ?? 1
        }

        #expect(engine.maxTierAvailable >= 2, "Insane L1 must expose Tier 2")
        #expect(engine.canUnlock(t2Source))
        #expect(engine.canUnlock(t2Link))
        #expect(engine.canUnlock(t2Sink))
        #expect(engine.canUnlock(t2Defense))

        #expect(engine.unlockUnit(t2Source))
        #expect(engine.unlockUnit(t2Link))
        #expect(engine.unlockUnit(t2Sink))
        #expect(engine.unlockUnit(t2Defense))

        #expect(engine.setSource(t2Source.id))
        #expect(engine.setLink(t2Link.id))
        #expect(engine.setSink(t2Sink.id))
        #expect(engine.setFirewall(t2Defense.id))

        let sourceBefore = engine.source.level
        let linkBefore = engine.link.level
        let sinkBefore = engine.sink.level
        let firewallBefore = engine.firewall?.level ?? 0

        #expect(engine.upgradeSource())
        #expect(engine.upgradeLink())
        #expect(engine.upgradeSink())
        #expect(engine.upgradeFirewall())

        #expect(engine.source.level == sourceBefore + 1)
        #expect(engine.link.level == linkBefore + 1)
        #expect(engine.sink.level == sinkBefore + 1)
        #expect(engine.firewall?.level == firewallBefore + 1)

        NSLog("[AUDIT][\(nowStamp())] Insane L1 unlock/equip/upgrade path validated for SOURCE/LINK/SINK/FW")
    }
}
