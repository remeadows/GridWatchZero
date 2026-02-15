// Theme.swift
// GridWatchZero
// Cyberpunk terminal aesthetic

import SwiftUI
import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Color Theme

extension Color {
    // Primary colors
    static let terminalBlack = Color(red: 0.05, green: 0.05, blue: 0.08)
    static let terminalDarkGray = Color(red: 0.12, green: 0.12, blue: 0.15)  // Lighter for better card contrast
    static let terminalGray = Color(red: 0.55, green: 0.55, blue: 0.6)  // Slightly brighter for readability

    // Accent colors
    static let neonGreen = Color(red: 0.2, green: 1.0, blue: 0.4)
    static let neonAmber = Color(red: 1.0, green: 0.75, blue: 0.2)
    static let neonRed = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let neonCyan = Color(red: 0.3, green: 0.9, blue: 1.0)

    // Dimmed variants
    static let dimGreen = Color(red: 0.1, green: 0.4, blue: 0.2)
    static let dimAmber = Color(red: 0.4, green: 0.3, blue: 0.1)
    static let dimRed = Color(red: 0.4, green: 0.15, blue: 0.15)

    // MARK: - Tier Colors (T7-25)

    // Transcendence colors (T7-10) - Purple shades
    static let transcendencePurple = Color(red: 0.6, green: 0.2, blue: 0.9)
    static let voidBlue = Color(red: 0.15, green: 0.1, blue: 0.4)

    // Dimensional colors (T11-15) - Purple/Gold
    static let dimensionalGold = Color(red: 1.0, green: 0.85, blue: 0.3)
    static let multiversePink = Color(red: 0.9, green: 0.3, blue: 0.6)
    static let akashicGold = Color(red: 1.0, green: 0.9, blue: 0.4)

    // Cosmic colors (T16-20) - White/Silver
    static let cosmicSilver = Color(red: 0.85, green: 0.85, blue: 0.92)
    static let darkMatterPurple = Color(red: 0.3, green: 0.1, blue: 0.4)
    static let singularityWhite = Color(red: 0.95, green: 0.95, blue: 1.0)

    // Infinite colors (T21-25) - Gold/Black
    static let infiniteGold = Color(red: 1.0, green: 0.9, blue: 0.5)
    static let omegaBlack = Color(red: 0.08, green: 0.02, blue: 0.12)

    /// Returns the appropriate SwiftUI Color for a tier color string
    static func tierColor(named colorName: String) -> Color {
        switch colorName {
        // Existing colors
        case "terminalGray": return .terminalGray
        case "neonGreen": return .neonGreen
        case "neonCyan": return .neonCyan
        case "neonAmber": return .neonAmber
        case "neonRed": return .neonRed
        // Transcendence (T7-10)
        case "transcendencePurple": return .transcendencePurple
        case "voidBlue": return .voidBlue
        // Dimensional (T11-15)
        case "dimensionalGold": return .dimensionalGold
        case "multiversePink": return .multiversePink
        case "akashicGold": return .akashicGold
        // Cosmic (T16-20)
        case "cosmicSilver": return .cosmicSilver
        case "darkMatterPurple": return .darkMatterPurple
        case "singularityWhite": return .singularityWhite
        // Infinite (T21-25)
        case "infiniteGold": return .infiniteGold
        case "omegaBlack": return .omegaBlack
        default: return .terminalGray
        }
    }
}

// MARK: - Font Theme
// Using relative text styles for Dynamic Type support while maintaining monospace design

extension Font {
    // Maps to .title2 (22pt base)
    static let terminalLarge = Font.system(.title2, design: .monospaced).weight(.bold)
    // Maps to .subheadline (15pt base)
    static let terminalTitle = Font.system(.subheadline, design: .monospaced).weight(.semibold)
    // Maps to .footnote (13pt base)
    static let terminalBody = Font.system(.footnote, design: .monospaced)
    // Maps to .footnote with medium weight (13pt base)
    static let terminalReadable = Font.system(.footnote, design: .monospaced).weight(.medium)
    // Maps to .caption2 (11pt base)
    static let terminalSmall = Font.system(.caption2, design: .monospaced)
    // Maps to .caption2 (11pt base) - smallest accessible size
    static let terminalMicro = Font.system(.caption2, design: .monospaced)
}

// MARK: - View Modifiers (Glass HUD Style)

enum RenderPerformanceProfile {
    static var reducedEffects: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return ProcessInfo.processInfo.environment["GWZ_REDUCED_EFFECTS"] == "1"
        #endif
    }
}

struct TerminalCardModifier: ViewModifier {
    var borderColor: Color = .neonGreen

    func body(content: Content) -> some View {
        Group {
            if RenderPerformanceProfile.reducedEffects {
                content
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.terminalDarkGray.opacity(0.92))
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(borderColor.opacity(0.35), lineWidth: 1)
                    )
            } else {
                content
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        // Frosted glass: translucent dark base with ultra-thin material
                        ZStack {
                            Color.terminalDarkGray.opacity(0.55)
                            Color.terminalBlack.opacity(0.15)
                        }
                    )
                    .background(.ultraThinMaterial.opacity(0.4))
                    .cornerRadius(4)
                    // Inner shadow for glass depth
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black.opacity(0.4), lineWidth: 1)
                            .blur(radius: 1)
                            .offset(x: 0, y: 1)
                            .mask(RoundedRectangle(cornerRadius: 4).fill())
                    )
                    // Neon rim glow
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(borderColor.opacity(0.5), lineWidth: 1)
                            .shadow(color: borderColor.opacity(0.25), radius: 3, x: 0, y: 0)
                    )
                    // Outer depth shadow
                    .shadow(color: borderColor.opacity(0.1), radius: 6, x: 0, y: 3)
            }
        }
    }
}

struct GlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat = 8

    @ViewBuilder
    func body(content: Content) -> some View {
        if RenderPerformanceProfile.reducedEffects {
            content
        } else {
            content
                .shadow(color: color.opacity(0.6), radius: radius)
        }
    }
}

struct TerminalButtonModifier: ViewModifier {
    var isEnabled: Bool = true

    func body(content: Content) -> some View {
        let bgColor = isEnabled ? Color.neonGreen : Color.terminalGray
        content
            .font(.terminalSmall)
            .foregroundColor(isEnabled ? .terminalBlack : .terminalGray)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    bgColor.opacity(isEnabled ? 0.85 : 0.3)
                    // Specular highlight — top-light glass capsule
                    LinearGradient(
                        colors: [Color.white.opacity(isEnabled ? 0.2 : 0.05), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                }
            )
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(bgColor.opacity(isEnabled ? 0.6 : 0.2), lineWidth: 1)
            )
            // Subtle inner glow
            .shadow(color: bgColor.opacity(isEnabled ? 0.3 : 0), radius: 4, x: 0, y: 0)
    }
}

// MARK: - Glass Background Texture

/// Micro-noise texture overlay for dark matte depth (OLED-friendly)
struct NoiseTextureView: View {
    var body: some View {
        Group {
            if RenderPerformanceProfile.reducedEffects {
                EmptyView()
            } else {
                #if canImport(UIKit)
                Image(uiImage: NoiseTextureCache.tileImage)
                    .resizable(resizingMode: .tile)
                    .opacity(0.08)
                #else
                EmptyView()
                #endif
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#if canImport(UIKit)
private enum NoiseTextureCache {
    static let tileImage: UIImage = {
        let size = CGSize(width: 64, height: 64)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            var rng = StableRNG(seed: 42)
            for x in stride(from: 0, to: Int(size.width), by: 2) {
                for y in stride(from: 0, to: Int(size.height), by: 2) {
                    let alpha = CGFloat(rng.nextDouble() * 0.06)
                    UIColor.white.withAlphaComponent(alpha).setFill()
                    context.fill(CGRect(x: x, y: y, width: 2, height: 2))
                }
            }
        }
    }()
}

/// Simple deterministic RNG for cached texture generation
private struct StableRNG {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func nextDouble() -> Double {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return Double(state % 10000) / 10000.0
    }
}
#endif

/// Glass-style background for main dashboard
struct GlassDashboardBackground: View {
    var body: some View {
        ZStack {
            Color.terminalBlack
            NoiseTextureView()
        }
        .ignoresSafeArea()
    }
}

// MARK: - View Extensions

extension View {
    func terminalCard(borderColor: Color = .neonGreen) -> some View {
        modifier(TerminalCardModifier(borderColor: borderColor))
    }

    func glow(_ color: Color, radius: CGFloat = 8) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }

    func terminalButton(isEnabled: Bool = true) -> some View {
        modifier(TerminalButtonModifier(isEnabled: isEnabled))
    }

    /// Apply glass dashboard background with micro-noise texture
    func glassDashboardBackground() -> some View {
        self.background(GlassDashboardBackground())
    }
}

// MARK: - Number Formatting

extension Double {
    /// Formats large numbers with appropriate suffixes for T1-25 scale
    /// K = Thousand, M = Million, B = Billion, T = Trillion
    /// Q = Quadrillion, Qi = Quintillion, Sx = Sextillion, Sp = Septillion
    var formatted: String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""

        switch absValue {
        case 1e24...:  // Septillion+
            return sign + String(format: "%.1fSp", absValue / 1e24)
        case 1e21..<1e24:  // Sextillion
            return sign + String(format: "%.1fSx", absValue / 1e21)
        case 1e18..<1e21:  // Quintillion
            return sign + String(format: "%.1fQi", absValue / 1e18)
        case 1e15..<1e18:  // Quadrillion
            return sign + String(format: "%.1fQ", absValue / 1e15)
        case 1e12..<1e15:  // Trillion
            return sign + String(format: "%.1fT", absValue / 1e12)
        case 1e9..<1e12:  // Billion
            return sign + String(format: "%.1fB", absValue / 1e9)
        case 1e6..<1e9:  // Million
            return sign + String(format: "%.1fM", absValue / 1e6)
        case 1e3..<1e6:  // Thousand
            return sign + String(format: "%.1fK", absValue / 1e3)
        case _ where absValue == floor(absValue):
            return sign + String(format: "%.0f", absValue)
        default:
            return sign + String(format: "%.1f", absValue)
        }
    }

    var percentFormatted: String {
        String(format: "%.0f%%", self * 100)
    }
}
