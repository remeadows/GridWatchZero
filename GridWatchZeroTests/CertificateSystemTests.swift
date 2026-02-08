//
//  CertificateSystemTests.swift
//  GridWatchZeroTests
//
//  Created by War Signal on 2026-02-06.
//  Tests for certificate system, maturity timers, and bonus calculations
//

import Testing
import Foundation
@testable import GridWatchZero

/// Tests for the certificate system and maturity mechanics
@Suite("Certificate System Tests")
@MainActor
struct CertificateSystemTests {

    // MARK: - CertificateTier Tests

    @Test("CertificateTier has all six tiers")
    func testCertificateTierCount() async {
        let allTiers = CertificateTier.allCases

        #expect(allTiers.count == 6, "Should have 6 certificate tiers")
        #expect(allTiers.contains(.foundational), "Should have foundational tier")
        #expect(allTiers.contains(.practitioner), "Should have practitioner tier")
        #expect(allTiers.contains(.professional), "Should have professional tier")
        #expect(allTiers.contains(.expert), "Should have expert tier")
        #expect(allTiers.contains(.master), "Should have master tier")
        #expect(allTiers.contains(.architect), "Should have architect tier")
    }

    @Test("CertificateTier maps levels correctly")
    func testCertificateTierLevelMapping() async {
        #expect(CertificateTier.forLevel(1) == .foundational, "Level 1 should be foundational")
        #expect(CertificateTier.forLevel(4) == .foundational, "Level 4 should be foundational")
        #expect(CertificateTier.forLevel(5) == .practitioner, "Level 5 should be practitioner")
        #expect(CertificateTier.forLevel(7) == .practitioner, "Level 7 should be practitioner")
        #expect(CertificateTier.forLevel(8) == .professional, "Level 8 should be professional")
        #expect(CertificateTier.forLevel(10) == .professional, "Level 10 should be professional")
        #expect(CertificateTier.forLevel(11) == .expert, "Level 11 should be expert")
        #expect(CertificateTier.forLevel(14) == .expert, "Level 14 should be expert")
        #expect(CertificateTier.forLevel(15) == .master, "Level 15 should be master")
        #expect(CertificateTier.forLevel(17) == .master, "Level 17 should be master")
        #expect(CertificateTier.forLevel(18) == .architect, "Level 18 should be architect")
        #expect(CertificateTier.forLevel(20) == .architect, "Level 20 should be architect")
    }

    @Test("CertificateTier has display properties")
    func testCertificateTierDisplayProperties() async {
        let foundational = CertificateTier.foundational

        #expect(!foundational.color.isEmpty, "Should have color")
        #expect(!foundational.borderColor.isEmpty, "Should have border color")
        #expect(!foundational.icon.isEmpty, "Should have icon")
        #expect(foundational.rawValue == "Foundational", "Should have raw value")
    }

    // MARK: - Certificate Structure Tests

    @Test("Certificate has required properties")
    func testCertificateProperties() async {
        let cert = Certificate(
            id: "test_cert",
            levelId: 1,
            name: "Test Certificate",
            fullName: "Test Certificate Full Name",
            abbreviation: "TEST",
            description: "Test description",
            tier: .foundational,
            issuingBody: "Test Authority",
            creditHours: 10,
            isInsane: false
        )

        #expect(cert.id == "test_cert", "Should have ID")
        #expect(cert.levelId == 1, "Should have level ID")
        #expect(!cert.name.isEmpty, "Should have name")
        #expect(!cert.fullName.isEmpty, "Should have full name")
        #expect(!cert.abbreviation.isEmpty, "Should have abbreviation")
        #expect(!cert.description.isEmpty, "Should have description")
        #expect(cert.tier == .foundational, "Should have tier")
        #expect(!cert.issuingBody.isEmpty, "Should have issuing body")
        #expect(cert.creditHours == 10, "Should have credit hours")
        #expect(cert.isInsane == false, "Should have insane flag")
    }

    @Test("Certificate maturity hours differ by mode")
    func testCertificateMaturityHours() async {
        let normalCert = Certificate(
            id: "normal",
            levelId: 1,
            name: "Normal",
            fullName: "Normal",
            abbreviation: "NRM",
            description: "Test",
            tier: .foundational,
            issuingBody: "Test",
            creditHours: 10,
            isInsane: false
        )

        let insaneCert = Certificate(
            id: "insane",
            levelId: 1,
            name: "Insane",
            fullName: "Insane",
            abbreviation: "INS",
            description: "Test",
            tier: .foundational,
            issuingBody: "Test",
            creditHours: 10,
            isInsane: true
        )

        #expect(normalCert.maturityHours == 40.0, "Normal cert should have 40h maturity")
        #expect(insaneCert.maturityHours == 60.0, "Insane cert should have 60h maturity")
    }

    @Test("Certificate display name is formatted correctly")
    func testCertificateDisplayName() async {
        let cert = Certificate(
            id: "test",
            levelId: 1,
            name: "Network Fundamentals",
            fullName: "Full",
            abbreviation: "CDO-NET",
            description: "Test",
            tier: .foundational,
            issuingBody: "Test",
            creditHours: 10,
            isInsane: false
        )

        #expect(cert.displayName == "CDO-NET - Network Fundamentals", "Display name should be formatted")
    }

    // MARK: - CertificateDatabase Tests

    @Test("CertificateDatabase has 20 normal certificates")
    func testCertificateDatabaseCount() async {
        let allCerts = CertificateDatabase.allCertificates

        // 20 levels × 1 normal cert per level = 20 certs
        let normalCerts = allCerts.filter { !$0.isInsane }
        #expect(normalCerts.count == 20, "Should have 20 normal mode certificates")
    }

    @Test("CertificateDatabase can find certificate by ID")
    func testCertificateDatabaseLookup() async {
        let cert = CertificateDatabase.certificate(byId: "cert_level_1")

        #expect(cert != nil, "Should find cert_level_1")
        #expect(cert?.levelId == 1, "Should have level ID 1")
    }

    @Test("CertificateDatabase calculates total credit hours")
    func testCertificateDatabaseTotalCreditHours() async {
        let earnedCerts: Set<String> = ["cert_level_1", "cert_level_2"]
        let totalHours = CertificateDatabase.totalCreditHours(for: earnedCerts)

        #expect(totalHours > 0, "Should have positive credit hours")
    }

    // MARK: - CertificateState Tests

    @Test("CertificateState initializes empty")
    func testCertificateStateInitialization() async {
        let state = CertificateState()

        #expect(state.earnedCertificates.isEmpty, "Should start with no certificates")
        #expect(state.certificateEarnedDates.isEmpty, "Should have no earned dates")
        #expect(state.newlyEarnedCertificateId == nil, "Should have no newly earned cert")
    }

    @Test("CertificateState can earn certificates")
    func testCertificateStateEarnCertificate() async {
        var state = CertificateState()

        state.earnCertificate("cert_level_1")

        #expect(state.hasEarned("cert_level_1"), "Should have earned cert")
        #expect(state.earnedDate(for: "cert_level_1") != nil, "Should have earned date")
        #expect(state.newlyEarnedCertificateId == "cert_level_1", "Should set newly earned")
    }

    @Test("CertificateState prevents duplicate earning")
    func testCertificateStatePreventsDuplicates() async {
        var state = CertificateState()

        state.earnCertificate("cert_level_1")
        let firstDate = state.earnedDate(for: "cert_level_1")

        state.earnCertificate("cert_level_1")  // Try to earn again
        let secondDate = state.earnedDate(for: "cert_level_1")

        #expect(state.totalCertificates == 1, "Should only have 1 certificate")
        #expect(firstDate == secondDate, "Earned date should not change")
    }

    @Test("CertificateState tracks total certificates")
    func testCertificateStateTotalCount() async {
        var state = CertificateState()

        state.earnCertificate("cert_level_1")
        state.earnCertificate("cert_level_2")
        state.earnCertificate("cert_level_3")

        #expect(state.totalCertificates == 3, "Should have 3 certificates")
    }

    @Test("CertificateState clears newly earned flag")
    func testCertificateStateClearNewlyEarned() async {
        var state = CertificateState()

        state.earnCertificate("cert_level_1")
        #expect(state.newlyEarnedCertificateId == "cert_level_1", "Should have newly earned")

        state.clearNewlyEarned()
        #expect(state.newlyEarnedCertificateId == nil, "Should clear newly earned")
    }

    // MARK: - Maturity Calculation Tests

    @Test("CertificateState calculates hours elapsed")
    func testCertificateStateHoursElapsed() async {
        var state = CertificateState()

        // Manually set earned date to 2 hours ago
        let twoHoursAgo = Date().addingTimeInterval(-2 * 3600)
        state.earnCertificate("cert_level_1")
        state.certificateEarnedDates["cert_level_1"] = twoHoursAgo

        let elapsed = state.hoursElapsed(for: "cert_level_1")

        // Should be approximately 2 hours
        #expect(elapsed >= 1.9 && elapsed <= 2.1, "Should be approximately 2 hours")
    }

    @Test("CertificateState calculates maturity progress")
    func testCertificateStateMaturityProgress() async {
        var state = CertificateState()

        // Manually set earned date to 20 hours ago (50% of 40h)
        let twentyHoursAgo = Date().addingTimeInterval(-20 * 3600)
        state.earnCertificate("cert_level_1")
        state.certificateEarnedDates["cert_level_1"] = twentyHoursAgo

        let progress = state.maturityProgress(for: "cert_level_1")

        // Should be approximately 0.5 (50%)
        #expect(progress >= 0.48 && progress <= 0.52, "Should be approximately 50% mature")
    }

    @Test("CertificateState caps maturity progress at 1.0")
    func testCertificateStateMaturityCap() async {
        var state = CertificateState()

        // Manually set earned date to 80 hours ago (200% of 40h)
        let eightyHoursAgo = Date().addingTimeInterval(-80 * 3600)
        state.earnCertificate("cert_level_1")
        state.certificateEarnedDates["cert_level_1"] = eightyHoursAgo

        let progress = state.maturityProgress(for: "cert_level_1")

        #expect(progress == 1.0, "Progress should cap at 1.0")
    }

    @Test("CertificateState calculates per-cert bonus")
    func testCertificateStatePerCertBonus() async {
        var state = CertificateState()

        // Manually set earned date to 40 hours ago (100% mature)
        let fortyHoursAgo = Date().addingTimeInterval(-40 * 3600)
        state.earnCertificate("cert_level_1")
        state.certificateEarnedDates["cert_level_1"] = fortyHoursAgo

        let bonus = state.certBonus(for: "cert_level_1")

        // Should be 1.0 × 0.20 = 0.20
        #expect(bonus >= 0.19 && bonus <= 0.21, "Fully mature cert should give 0.20 bonus")
    }

    @Test("CertificateState detects mature certificates")
    func testCertificateStateIsMature() async {
        var state = CertificateState()

        // Fully mature cert
        let fortyHoursAgo = Date().addingTimeInterval(-40 * 3600)
        state.earnCertificate("cert_level_1")
        state.certificateEarnedDates["cert_level_1"] = fortyHoursAgo

        // Partially mature cert
        let tenHoursAgo = Date().addingTimeInterval(-10 * 3600)
        state.earnCertificate("cert_level_2")
        state.certificateEarnedDates["cert_level_2"] = tenHoursAgo

        #expect(state.isMature("cert_level_1") == true, "cert_level_1 should be mature")
        #expect(state.isMature("cert_level_2") == false, "cert_level_2 should not be mature")
    }

    @Test("CertificateState returns correct maturity state")
    func testCertificateStateMaturityState() async {
        var state = CertificateState()

        // Just earned (pending)
        state.earnCertificate("cert_level_1")

        // Maturing (10 hours ago)
        let tenHoursAgo = Date().addingTimeInterval(-10 * 3600)
        state.earnCertificate("cert_level_2")
        state.certificateEarnedDates["cert_level_2"] = tenHoursAgo

        // Mature (40 hours ago)
        let fortyHoursAgo = Date().addingTimeInterval(-40 * 3600)
        state.earnCertificate("cert_level_3")
        state.certificateEarnedDates["cert_level_3"] = fortyHoursAgo

        let state1 = state.maturityState(for: "cert_level_1")
        let state2 = state.maturityState(for: "cert_level_2")
        let state3 = state.maturityState(for: "cert_level_3")

        #expect(state1 == .pending, "Just earned should be pending")
        #expect(state2 == .maturing, "Partially mature should be maturing")
        #expect(state3 == .mature, "Fully mature should be mature")
    }

    // MARK: - Total Multiplier Tests

    @Test("CertificateState calculates total multiplier")
    func testCertificateStateTotalMultiplier() async {
        var state = CertificateState()

        // Earn 3 fully mature certs
        let fortyHoursAgo = Date().addingTimeInterval(-40 * 3600)
        state.earnCertificate("cert_level_1")
        state.earnCertificate("cert_level_2")
        state.earnCertificate("cert_level_3")
        state.certificateEarnedDates["cert_level_1"] = fortyHoursAgo
        state.certificateEarnedDates["cert_level_2"] = fortyHoursAgo
        state.certificateEarnedDates["cert_level_3"] = fortyHoursAgo

        let multiplier = state.totalCertificationMultiplier

        // 1.0 + (3 × 0.20) = 1.6
        #expect(multiplier >= 1.58 && multiplier <= 1.62, "3 mature certs should give 1.6× multiplier")
    }

    @Test("CertificateState multiplier with zero certs is 1.0")
    func testCertificateStateZeroCertsMultiplier() async {
        let state = CertificateState()

        let multiplier = state.totalCertificationMultiplier

        #expect(multiplier == 1.0, "No certs should give 1.0× multiplier")
    }

    @Test("CertificateState multiplier caps at 9.0 with 40 certs")
    func testCertificateStateMaxMultiplier() async {
        var state = CertificateState()

        // Earn 40 fully mature certs (20 normal + 20 insane)
        // Normal certs: 40h maturity, Insane certs: 60h maturity
        let fortyHoursAgo = Date().addingTimeInterval(-40 * 3600)
        let sixtyHoursAgo = Date().addingTimeInterval(-60 * 3600)
        
        for i in 1...20 {
            let certId = "cert_level_\(i)"
            state.earnCertificate(certId)
            state.certificateEarnedDates[certId] = fortyHoursAgo  // Normal: 40h
        }
        for i in 1...20 {
            let certId = "insane_cert_level_\(i)"
            state.earnCertificate(certId)
            state.certificateEarnedDates[certId] = sixtyHoursAgo  // Insane: 60h
        }

        let multiplier = state.totalCertificationMultiplier

        // 1.0 + (40 × 0.20) = 9.0
        #expect(multiplier >= 8.95 && multiplier <= 9.05, "40 mature certs should give 9.0× multiplier")
    }

    // MARK: - Normal vs Insane Mode Tests

    @Test("CertificateState counts normal mode certs")
    func testCertificateStateNormalCount() async {
        var state = CertificateState()

        state.earnCertificate("cert_level_1")
        state.earnCertificate("cert_level_2")
        state.earnCertificate("insane_cert_level_1")

        #expect(state.normalCertCount == 2, "Should have 2 normal certs")
    }

    @Test("CertificateState counts insane mode certs")
    func testCertificateStateInsaneCount() async {
        var state = CertificateState()

        state.earnCertificate("cert_level_1")
        state.earnCertificate("insane_cert_level_1")
        state.earnCertificate("insane_cert_level_2")

        #expect(state.insaneCertCount == 2, "Should have 2 insane certs")
    }

    @Test("CertificateState counts maturing certs")
    func testCertificateStateMaturingCount() async {
        var state = CertificateState()

        // Mature cert
        let fortyHoursAgo = Date().addingTimeInterval(-40 * 3600)
        state.earnCertificate("cert_level_1")
        state.certificateEarnedDates["cert_level_1"] = fortyHoursAgo

        // Maturing cert
        let tenHoursAgo = Date().addingTimeInterval(-10 * 3600)
        state.earnCertificate("cert_level_2")
        state.certificateEarnedDates["cert_level_2"] = tenHoursAgo

        // Maturing cert
        let twentyHoursAgo = Date().addingTimeInterval(-20 * 3600)
        state.earnCertificate("cert_level_3")
        state.certificateEarnedDates["cert_level_3"] = twentyHoursAgo

        #expect(state.maturingCount == 2, "Should have 2 maturing certs")
    }

    // MARK: - Tier Completion Tests

    @Test("CertificateState tracks completed tiers")
    func testCertificateStateCompletedTiers() async {
        var state = CertificateState()

        // Earn all foundational tier certs (levels 1-4, both normal AND insane)
        // completedTiers requires ALL certificates for a tier (normal + insane)
        state.earnCertificate("cert_level_1")
        state.earnCertificate("cert_level_2")
        state.earnCertificate("cert_level_3")
        state.earnCertificate("cert_level_4")
        state.earnCertificate("insane_cert_level_1")
        state.earnCertificate("insane_cert_level_2")
        state.earnCertificate("insane_cert_level_3")
        state.earnCertificate("insane_cert_level_4")

        let completedTiers = state.completedTiers

        #expect(completedTiers.contains(.foundational), "Should have completed foundational tier")
        #expect(!completedTiers.contains(.practitioner), "Should not have completed practitioner tier")
    }

    @Test("CertificateState tracks highest tier")
    func testCertificateStateHighestTier() async {
        var state = CertificateState()

        state.earnCertificate("cert_level_1")  // Foundational
        state.earnCertificate("cert_level_5")  // Practitioner
        state.earnCertificate("cert_level_11") // Expert

        let highestTier = state.highestTier

        #expect(highestTier == .expert, "Highest tier should be expert")
    }

    @Test("CertificateState highest tier with no certs is nil")
    func testCertificateStateNoHighestTier() async {
        let state = CertificateState()

        let highestTier = state.highestTier

        #expect(highestTier == nil, "Should have no highest tier with no certs")
    }
}
