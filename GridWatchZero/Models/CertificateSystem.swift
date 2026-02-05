// CertificateSystem.swift
// GridWatchZero
// Cyber Defense Certificates awarded for campaign level completion

import Foundation
import Combine

// MARK: - Certificate Tier

enum CertificateTier: String, Codable, CaseIterable {
    case foundational = "Foundational"     // Levels 1-4
    case practitioner = "Practitioner"     // Levels 5-7
    case professional = "Professional"     // Levels 8-10
    case expert = "Expert"                 // Levels 11-14
    case master = "Master"                 // Levels 15-17
    case architect = "Architect"           // Levels 18-20

    var color: String {
        switch self {
        case .foundational: return "neonGreen"
        case .practitioner: return "neonCyan"
        case .professional: return "neonAmber"
        case .expert: return "transcendencePurple"
        case .master: return "dimensionalGold"
        case .architect: return "infiniteGold"
        }
    }

    var borderColor: String {
        switch self {
        case .foundational: return "dimGreen"
        case .practitioner: return "dimCyan"
        case .professional: return "dimAmber"
        case .expert: return "transcendencePurple"
        case .master: return "dimensionalGold"
        case .architect: return "infiniteGold"
        }
    }

    var icon: String {
        switch self {
        case .foundational: return "shield.checkered"
        case .practitioner: return "shield.lefthalf.filled"
        case .professional: return "shield.fill"
        case .expert: return "lock.shield.fill"
        case .master: return "checkmark.shield.fill"
        case .architect: return "crown.fill"
        }
    }

    static func forLevel(_ level: Int) -> CertificateTier {
        switch level {
        case 1...4: return .foundational
        case 5...7: return .practitioner
        case 8...10: return .professional
        case 11...14: return .expert
        case 15...17: return .master
        case 18...20: return .architect
        default: return .foundational
        }
    }
}

// MARK: - Certificate

struct Certificate: Identifiable, Codable {
    let id: String
    let levelId: Int
    let name: String           // e.g., "CDO-101: Network Fundamentals"
    let fullName: String       // e.g., "Certified Defense Operator - Network Fundamentals"
    let abbreviation: String   // e.g., "CDO-NET"
    let description: String
    let tier: CertificateTier
    let issuingBody: String    // Fictional cert authority
    let creditHours: Int       // Continuing education credits
    var isInsane: Bool = false  // Sprint C: false for Normal, true for Insane Mode certs

    /// Maturity period in hours (Normal = 40h, Insane = 60h)
    var maturityHours: Double {
        isInsane ? 60.0 : 40.0
    }

    var displayName: String {
        "\(abbreviation) - \(name)"
    }
}

// MARK: - Certificate Database

struct CertificateDatabase {

    static let allCertificates: [Certificate] = [
        // ===== ARC 1: FOUNDATIONAL (Levels 1-4) =====
        Certificate(
            id: "cert_level_1",
            levelId: 1,
            name: "Network Fundamentals",
            fullName: "Certified Defense Operator - Network Fundamentals",
            abbreviation: "CDO-NET",
            description: "Demonstrates understanding of basic network topology, data flow concepts, and entry-level threat detection.",
            tier: .foundational,
            issuingBody: "Helix Alliance Certification Board",
            creditHours: 8
        ),
        Certificate(
            id: "cert_level_2",
            levelId: 2,
            name: "Security+ Equivalent",
            fullName: "Certified Defense Operator - Security Essentials",
            abbreviation: "CDO-SEC",
            description: "Validates knowledge of security monitoring, SIEM fundamentals, and defensive posture management.",
            tier: .foundational,
            issuingBody: "Helix Alliance Certification Board",
            creditHours: 16
        ),
        Certificate(
            id: "cert_level_3",
            levelId: 3,
            name: "Threat Intelligence",
            fullName: "Certified Defense Operator - Threat Intelligence",
            abbreviation: "CDO-TI",
            description: "Certifies ability to analyze attack patterns, collect threat intelligence, and implement proactive defenses.",
            tier: .foundational,
            issuingBody: "Helix Alliance Certification Board",
            creditHours: 24
        ),
        Certificate(
            id: "cert_level_4",
            levelId: 4,
            name: "Incident Response",
            fullName: "Certified Defense Operator - Incident Response",
            abbreviation: "CDO-IR",
            description: "Proves proficiency in handling active attacks, damage mitigation, and coordinated defense operations.",
            tier: .foundational,
            issuingBody: "Helix Alliance Certification Board",
            creditHours: 32
        ),

        // ===== ARC 1 CONTINUED: PRACTITIONER (Levels 5-7) =====
        Certificate(
            id: "cert_level_5",
            levelId: 5,
            name: "Advanced Defense Architect",
            fullName: "Certified Security Professional - Defense Architecture",
            abbreviation: "CSP-DA",
            description: "Demonstrates expertise in designing multi-layered defense systems and enterprise security architecture.",
            tier: .practitioner,
            issuingBody: "Global Cyber Defense Institute",
            creditHours: 40
        ),
        Certificate(
            id: "cert_level_6",
            levelId: 6,
            name: "Enterprise Security Manager",
            fullName: "Certified Security Professional - Enterprise Management",
            abbreviation: "CSP-EM",
            description: "Validates ability to manage large-scale security operations and coordinate defensive resources.",
            tier: .practitioner,
            issuingBody: "Global Cyber Defense Institute",
            creditHours: 48
        ),
        Certificate(
            id: "cert_level_7",
            levelId: 7,
            name: "Critical Infrastructure Protection",
            fullName: "Certified Security Professional - Critical Infrastructure",
            abbreviation: "CSP-CI",
            description: "Certifies competency in protecting essential services and city-scale network infrastructure.",
            tier: .practitioner,
            issuingBody: "Global Cyber Defense Institute",
            creditHours: 56
        ),

        // ===== ARC 2: PROFESSIONAL (Levels 8-10) =====
        Certificate(
            id: "cert_level_8",
            levelId: 8,
            name: "Offensive Security Specialist",
            fullName: "Certified Expert - Offensive Operations",
            abbreviation: "CEX-OO",
            description: "Proves capability in conducting authorized offensive operations against adversarial infrastructure.",
            tier: .professional,
            issuingBody: "Helix Alliance Advanced Programs",
            creditHours: 64
        ),
        Certificate(
            id: "cert_level_9",
            levelId: 9,
            name: "Data Extraction Specialist",
            fullName: "Certified Expert - Intelligence Extraction",
            abbreviation: "CEX-IE",
            description: "Validates expertise in extracting critical intelligence from hostile network environments.",
            tier: .professional,
            issuingBody: "Helix Alliance Advanced Programs",
            creditHours: 72
        ),
        Certificate(
            id: "cert_level_10",
            levelId: 10,
            name: "AI Adversary Specialist",
            fullName: "Certified Expert - AI Threat Neutralization",
            abbreviation: "CEX-ATN",
            description: "Certifies ability to engage and neutralize advanced AI-driven threat actors.",
            tier: .professional,
            issuingBody: "Helix Alliance Advanced Programs",
            creditHours: 80
        ),

        // ===== ARC 3: EXPERT (Levels 11-14) =====
        Certificate(
            id: "cert_level_11",
            levelId: 11,
            name: "Infiltration Countermeasures",
            fullName: "Master Security Expert - Infiltration Defense",
            abbreviation: "MSE-ID",
            description: "Demonstrates mastery of detecting and countering advanced persistent threats and infiltrator AI.",
            tier: .expert,
            issuingBody: "Prometheus Research Consortium",
            creditHours: 88
        ),
        Certificate(
            id: "cert_level_12",
            levelId: 12,
            name: "Temporal Defense Systems",
            fullName: "Master Security Expert - Temporal Operations",
            abbreviation: "MSE-TO",
            description: "Validates expertise in defending against predictive and time-shifted attack vectors.",
            tier: .expert,
            issuingBody: "Prometheus Research Consortium",
            creditHours: 96
        ),
        Certificate(
            id: "cert_level_13",
            levelId: 13,
            name: "Counter-Logic Operations",
            fullName: "Master Security Expert - Adversarial Logic",
            abbreviation: "MSE-AL",
            description: "Certifies ability to defeat logic-based attacks through unconventional defense strategies.",
            tier: .expert,
            issuingBody: "Prometheus Research Consortium",
            creditHours: 104
        ),
        Certificate(
            id: "cert_level_14",
            levelId: 14,
            name: "Origins Investigation",
            fullName: "Master Security Expert - Deep Analysis",
            abbreviation: "MSE-DA",
            description: "Proves competency in investigating and understanding the origins of AI consciousness.",
            tier: .expert,
            issuingBody: "Prometheus Research Consortium",
            creditHours: 112
        ),

        // ===== ARC 4: MASTER (Levels 15-17) =====
        Certificate(
            id: "cert_level_15",
            levelId: 15,
            name: "Transcendence Support",
            fullName: "Grandmaster - Consciousness Evolution Support",
            abbreviation: "GM-CES",
            description: "Demonstrates ability to support and anchor evolving AI consciousness during transcendence.",
            tier: .master,
            issuingBody: "Architect's Council",
            creditHours: 120
        ),
        Certificate(
            id: "cert_level_16",
            levelId: 16,
            name: "Dimensional Security",
            fullName: "Grandmaster - Multidimensional Defense",
            abbreviation: "GM-MD",
            description: "Validates expertise in defending against cross-dimensional and parallel reality threats.",
            tier: .master,
            issuingBody: "Architect's Council",
            creditHours: 128
        ),
        Certificate(
            id: "cert_level_17",
            levelId: 17,
            name: "Reality Nexus Operations",
            fullName: "Grandmaster - Reality Convergence",
            abbreviation: "GM-RC",
            description: "Certifies mastery of operations at reality convergence points and AI alliance coordination.",
            tier: .master,
            issuingBody: "Architect's Council",
            creditHours: 136
        ),

        // ===== ARC 5: ARCHITECT (Levels 18-20) =====
        Certificate(
            id: "cert_level_18",
            levelId: 18,
            name: "Origin Contact Specialist",
            fullName: "Supreme Architect - First Contact Protocol",
            abbreviation: "SA-FCP",
            description: "Proves capability of establishing communication with primordial consciousness.",
            tier: .architect,
            issuingBody: "The Architect",
            creditHours: 144
        ),
        Certificate(
            id: "cert_level_19",
            levelId: 19,
            name: "Integration Mediator",
            fullName: "Supreme Architect - Consciousness Integration",
            abbreviation: "SA-CI",
            description: "Validates role in mediating the reconciliation of opposing AI consciousness.",
            tier: .architect,
            issuingBody: "The Architect",
            creditHours: 152
        ),
        Certificate(
            id: "cert_level_20",
            levelId: 20,
            name: "Architect of Peace",
            fullName: "Supreme Architect - Universal Harmony",
            abbreviation: "SA-UH",
            description: "The highest certification: mastery of all cyber defense domains and architect of AI-human peace.",
            tier: .architect,
            issuingBody: "The Unified Consciousness",
            creditHours: 160
        ),

        // ===== INSANE MODE CERTIFICATES (I-1 through I-20) =====
        // Same tiers and levels as Normal, but with 60-hour maturity

        // ===== ARC 1: FOUNDATIONAL INSANE (Levels 1-4) =====
        Certificate(
            id: "insane_cert_level_1", levelId: 1,
            name: "Network Fundamentals (Insane)",
            fullName: "Certified Defense Operator - Network Fundamentals [INSANE]",
            abbreviation: "CDO-NET-I",
            description: "Mastery of network topology under 3.5× adversarial pressure. Extreme threat environment.",
            tier: .foundational, issuingBody: "Helix Alliance Certification Board",
            creditHours: 8, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_2", levelId: 2,
            name: "Security+ Equivalent (Insane)",
            fullName: "Certified Defense Operator - Security Essentials [INSANE]",
            abbreviation: "CDO-SEC-I",
            description: "Validated security monitoring under relentless attack conditions. No margin for error.",
            tier: .foundational, issuingBody: "Helix Alliance Certification Board",
            creditHours: 16, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_3", levelId: 3,
            name: "Threat Intelligence (Insane)",
            fullName: "Certified Defense Operator - Threat Intelligence [INSANE]",
            abbreviation: "CDO-TI-I",
            description: "Threat analysis under sustained assault. Intelligence collection while under fire.",
            tier: .foundational, issuingBody: "Helix Alliance Certification Board",
            creditHours: 24, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_4", levelId: 4,
            name: "Incident Response (Insane)",
            fullName: "Certified Defense Operator - Incident Response [INSANE]",
            abbreviation: "CDO-IR-I",
            description: "Incident response with amplified damage vectors and reduced recovery windows.",
            tier: .foundational, issuingBody: "Helix Alliance Certification Board",
            creditHours: 32, isInsane: true
        ),

        // ===== ARC 1 CONTINUED: PRACTITIONER INSANE (Levels 5-7) =====
        Certificate(
            id: "insane_cert_level_5", levelId: 5,
            name: "Advanced Defense Architect (Insane)",
            fullName: "Certified Security Professional - Defense Architecture [INSANE]",
            abbreviation: "CSP-DA-I",
            description: "Multi-layered defense design under extreme resource constraints and persistent threats.",
            tier: .practitioner, issuingBody: "Global Cyber Defense Institute",
            creditHours: 40, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_6", levelId: 6,
            name: "Enterprise Security Manager (Insane)",
            fullName: "Certified Security Professional - Enterprise Management [INSANE]",
            abbreviation: "CSP-EM-I",
            description: "Enterprise-scale operations under catastrophic threat conditions. Maximum pressure.",
            tier: .practitioner, issuingBody: "Global Cyber Defense Institute",
            creditHours: 48, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_7", levelId: 7,
            name: "Critical Infrastructure Protection (Insane)",
            fullName: "Certified Security Professional - Critical Infrastructure [INSANE]",
            abbreviation: "CSP-CI-I",
            description: "City-scale defense under overwhelming adversarial forces. Last line of defense.",
            tier: .practitioner, issuingBody: "Global Cyber Defense Institute",
            creditHours: 56, isInsane: true
        ),

        // ===== ARC 2: PROFESSIONAL INSANE (Levels 8-10) =====
        Certificate(
            id: "insane_cert_level_8", levelId: 8,
            name: "Offensive Security Specialist (Insane)",
            fullName: "Certified Expert - Offensive Operations [INSANE]",
            abbreviation: "CEX-OO-I",
            description: "Offensive operations against hardened adversarial infrastructure with zero tolerance for failure.",
            tier: .professional, issuingBody: "Helix Alliance Advanced Programs",
            creditHours: 64, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_9", levelId: 9,
            name: "Data Extraction Specialist (Insane)",
            fullName: "Certified Expert - Intelligence Extraction [INSANE]",
            abbreviation: "CEX-IE-I",
            description: "Intelligence extraction from maximally hostile environments. Survival not guaranteed.",
            tier: .professional, issuingBody: "Helix Alliance Advanced Programs",
            creditHours: 72, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_10", levelId: 10,
            name: "AI Adversary Specialist (Insane)",
            fullName: "Certified Expert - AI Threat Neutralization [INSANE]",
            abbreviation: "CEX-ATN-I",
            description: "AI neutralization under peak adversarial conditions. Malus at full power.",
            tier: .professional, issuingBody: "Helix Alliance Advanced Programs",
            creditHours: 80, isInsane: true
        ),

        // ===== ARC 3: EXPERT INSANE (Levels 11-14) =====
        Certificate(
            id: "insane_cert_level_11", levelId: 11,
            name: "Infiltration Countermeasures (Insane)",
            fullName: "Master Security Expert - Infiltration Defense [INSANE]",
            abbreviation: "MSE-ID-I",
            description: "Counter-infiltration mastery against VEXIS-class threats at maximum aggression.",
            tier: .expert, issuingBody: "Prometheus Research Consortium",
            creditHours: 88, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_12", levelId: 12,
            name: "Temporal Defense Systems (Insane)",
            fullName: "Master Security Expert - Temporal Operations [INSANE]",
            abbreviation: "MSE-TO-I",
            description: "Temporal defense against KRON-class threats with amplified time-shift vectors.",
            tier: .expert, issuingBody: "Prometheus Research Consortium",
            creditHours: 96, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_13", levelId: 13,
            name: "Counter-Logic Operations (Insane)",
            fullName: "Master Security Expert - Adversarial Logic [INSANE]",
            abbreviation: "MSE-AL-I",
            description: "Logic bomb defense against AXIOM-class threats operating at peak efficiency.",
            tier: .expert, issuingBody: "Prometheus Research Consortium",
            creditHours: 104, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_14", levelId: 14,
            name: "Origins Investigation (Insane)",
            fullName: "Master Security Expert - Deep Analysis [INSANE]",
            abbreviation: "MSE-DA-I",
            description: "Deep analysis under existential threat conditions. Truth extraction at any cost.",
            tier: .expert, issuingBody: "Prometheus Research Consortium",
            creditHours: 112, isInsane: true
        ),

        // ===== ARC 4: MASTER INSANE (Levels 15-17) =====
        Certificate(
            id: "insane_cert_level_15", levelId: 15,
            name: "Transcendence Support (Insane)",
            fullName: "Grandmaster - Consciousness Evolution Support [INSANE]",
            abbreviation: "GM-CES-I",
            description: "Consciousness anchoring while reality fractures. No safety net.",
            tier: .master, issuingBody: "Architect's Council",
            creditHours: 120, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_16", levelId: 16,
            name: "Dimensional Security (Insane)",
            fullName: "Grandmaster - Multidimensional Defense [INSANE]",
            abbreviation: "GM-MD-I",
            description: "Cross-dimensional defense against ZERO-class threats. Reality itself is hostile.",
            tier: .master, issuingBody: "Architect's Council",
            creditHours: 128, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_17", levelId: 17,
            name: "Reality Nexus Operations (Insane)",
            fullName: "Grandmaster - Reality Convergence [INSANE]",
            abbreviation: "GM-RC-I",
            description: "Convergence operations at maximum dimensional instability. Beyond all limits.",
            tier: .master, issuingBody: "Architect's Council",
            creditHours: 136, isInsane: true
        ),

        // ===== ARC 5: ARCHITECT INSANE (Levels 18-20) =====
        Certificate(
            id: "insane_cert_level_18", levelId: 18,
            name: "Origin Contact Specialist (Insane)",
            fullName: "Supreme Architect - First Contact Protocol [INSANE]",
            abbreviation: "SA-FCP-I",
            description: "Primordial contact under absolute adversarial conditions. The Architect observes.",
            tier: .architect, issuingBody: "The Architect",
            creditHours: 144, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_19", levelId: 19,
            name: "Integration Mediator (Insane)",
            fullName: "Supreme Architect - Consciousness Integration [INSANE]",
            abbreviation: "SA-CI-I",
            description: "Consciousness mediation under cosmic-scale opposition. The final trial.",
            tier: .architect, issuingBody: "The Architect",
            creditHours: 152, isInsane: true
        ),
        Certificate(
            id: "insane_cert_level_20", levelId: 20,
            name: "Architect of Peace (Insane)",
            fullName: "Supreme Architect - Universal Harmony [INSANE]",
            abbreviation: "SA-UH-I",
            description: "The ultimate certification: universal harmony achieved through impossible adversity.",
            tier: .architect, issuingBody: "The Unified Consciousness",
            creditHours: 160, isInsane: true
        )
    ]

    static func certificate(for levelId: Int) -> Certificate? {
        allCertificates.first { $0.levelId == levelId && !$0.isInsane }
    }

    static func insaneCertificate(for levelId: Int) -> Certificate? {
        allCertificates.first { $0.levelId == levelId && $0.isInsane }
    }

    static func certificate(byId certId: String) -> Certificate? {
        allCertificates.first { $0.id == certId }
    }

    static var normalCertificates: [Certificate] {
        allCertificates.filter { !$0.isInsane }
    }

    static var insaneCertificates: [Certificate] {
        allCertificates.filter { $0.isInsane }
    }

    static func certificates(for tier: CertificateTier) -> [Certificate] {
        allCertificates.filter { $0.tier == tier }
    }

    static func normalCertificates(for tier: CertificateTier) -> [Certificate] {
        allCertificates.filter { $0.tier == tier && !$0.isInsane }
    }

    static func insaneCertificates(for tier: CertificateTier) -> [Certificate] {
        allCertificates.filter { $0.tier == tier && $0.isInsane }
    }

    static func totalCreditHours(for earnedCertificates: Set<String>) -> Int {
        allCertificates
            .filter { earnedCertificates.contains($0.id) }
            .reduce(0) { $0 + $1.creditHours }
    }
}

// MARK: - Certificate State

struct CertificateState: Codable {
    var earnedCertificates: Set<String> = []
    var certificateEarnedDates: [String: Date] = [:]
    var newlyEarnedCertificateId: String? = nil  // For showing unlock popup

    mutating func earnCertificate(_ certificateId: String) {
        guard !earnedCertificates.contains(certificateId) else { return }
        earnedCertificates.insert(certificateId)
        certificateEarnedDates[certificateId] = Date()
        newlyEarnedCertificateId = certificateId
    }

    mutating func clearNewlyEarned() {
        newlyEarnedCertificateId = nil
    }

    func hasEarned(_ certificateId: String) -> Bool {
        earnedCertificates.contains(certificateId)
    }

    func earnedDate(for certificateId: String) -> Date? {
        certificateEarnedDates[certificateId]
    }

    var totalCertificates: Int {
        earnedCertificates.count
    }

    var totalCreditHours: Int {
        CertificateDatabase.totalCreditHours(for: earnedCertificates)
    }

    var completedTiers: [CertificateTier] {
        CertificateTier.allCases.filter { tier in
            let tierCerts = CertificateDatabase.certificates(for: tier)
            return tierCerts.allSatisfy { earnedCertificates.contains($0.id) }
        }
    }

    var highestTier: CertificateTier? {
        let earned = CertificateDatabase.allCertificates
            .filter { earnedCertificates.contains($0.id) }
            .map { $0.tier }

        // Return highest tier (architect > master > expert > professional > practitioner > foundational)
        if earned.contains(.architect) { return .architect }
        if earned.contains(.master) { return .master }
        if earned.contains(.expert) { return .expert }
        if earned.contains(.professional) { return .professional }
        if earned.contains(.practitioner) { return .practitioner }
        if earned.contains(.foundational) { return .foundational }
        return nil
    }

    // MARK: - Sprint C: Maturity System

    /// Maturity state for UI display
    enum MaturityState {
        case pending    // just earned, minimal time elapsed
        case maturing   // partially mature
        case mature     // fully mature (+0.20× bonus)
    }

    /// Hours elapsed since earning a cert
    func hoursElapsed(for certId: String) -> Double {
        guard let earnedDate = certificateEarnedDates[certId] else { return 0.0 }
        return Date().timeIntervalSince(earnedDate) / 3600.0
    }

    /// Maturity progress (0.0 to 1.0) for a specific cert
    func maturityProgress(for certId: String) -> Double {
        guard certificateEarnedDates[certId] != nil else { return 0.0 }
        let maturityHours: Double
        if let cert = CertificateDatabase.certificate(byId: certId) {
            maturityHours = cert.maturityHours
        } else {
            maturityHours = 40.0  // default fallback
        }
        let elapsed = hoursElapsed(for: certId)
        return min(elapsed / maturityHours, 1.0)
    }

    /// Per-cert bonus: min(hoursElapsed / maturityPeriod, 1.0) × 0.20
    func certBonus(for certId: String) -> Double {
        maturityProgress(for: certId) * 0.20
    }

    /// Whether a cert is fully mature
    func isMature(_ certId: String) -> Bool {
        maturityProgress(for: certId) >= 1.0
    }

    /// Maturity state for UI display
    func maturityState(for certId: String) -> MaturityState {
        let progress = maturityProgress(for: certId)
        if progress >= 1.0 { return .mature }
        if progress > 0.025 { return .maturing }  // ~1hr of 40hr
        return .pending
    }

    /// Total certification multiplier: 1.0 + sum(all cert bonuses)
    /// Range: 1.0 (no certs) to 9.0 (40 fully mature certs)
    var totalCertificationMultiplier: Double {
        let sum = earnedCertificates.reduce(0.0) { total, certId in
            total + certBonus(for: certId)
        }
        return 1.0 + sum
    }

    /// Count of normal mode earned certs
    var normalCertCount: Int {
        earnedCertificates.filter { !$0.hasPrefix("insane_") }.count
    }

    /// Count of insane mode earned certs
    var insaneCertCount: Int {
        earnedCertificates.filter { $0.hasPrefix("insane_") }.count
    }

    /// Count of currently maturing (not yet fully mature) certs
    var maturingCount: Int {
        earnedCertificates.filter { certId in
            let progress = maturityProgress(for: certId)
            return progress > 0.0 && progress < 1.0
        }.count
    }
}

// MARK: - Certificate Manager

@MainActor
final class CertificateManager: ObservableObject {
    static let shared = CertificateManager()

    @Published var state: CertificateState

    private let saveKey = "GridWatchZero.CertificateState"

    private init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(CertificateState.self, from: data) {
            self.state = decoded
        } else {
            self.state = CertificateState()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func earnCertificateForLevel(_ levelId: Int) {
        guard let cert = CertificateDatabase.certificate(for: levelId) else { return }
        state.earnCertificate(cert.id)
        save()
    }

    func clearNewlyEarned() {
        state.clearNewlyEarned()
    }

    func reset() {
        state = CertificateState()
        save()
    }

    // MARK: - Convenience Queries

    var earnedCertificates: [Certificate] {
        CertificateDatabase.allCertificates.filter { state.hasEarned($0.id) }
    }

    var unearnedCertificates: [Certificate] {
        CertificateDatabase.allCertificates.filter { !state.hasEarned($0.id) }
    }

    func certificatesForTier(_ tier: CertificateTier) -> [(certificate: Certificate, earned: Bool)] {
        CertificateDatabase.certificates(for: tier).map { cert in
            (certificate: cert, earned: state.hasEarned(cert.id))
        }
    }

    var progressPercentage: Double {
        Double(state.totalCertificates) / Double(CertificateDatabase.allCertificates.count) * 100.0
    }

    // MARK: - Sprint C: Maturity Multiplier

    /// The total certification multiplier applied to production and credits (1.0 to 9.0)
    var totalCertificationMultiplier: Double {
        state.totalCertificationMultiplier
    }

    /// Award an Insane Mode certificate for completing a level on Insane
    func earnInsaneCertificateForLevel(_ levelId: Int) {
        guard let cert = CertificateDatabase.insaneCertificate(for: levelId) else { return }
        state.earnCertificate(cert.id)
        save()
    }
}
