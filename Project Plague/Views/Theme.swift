// Theme.swift
// ProjectPlague
// Cyberpunk terminal aesthetic

import SwiftUI

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

// MARK: - View Modifiers

struct TerminalCardModifier: ViewModifier {
    var borderColor: Color = .neonGreen

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.terminalDarkGray)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(borderColor.opacity(0.7), lineWidth: 1.5)  // Brighter, thicker border
            )
            .shadow(color: borderColor.opacity(0.15), radius: 4, x: 0, y: 2)  // Subtle glow
    }
}

struct GlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius)
    }
}

struct TerminalButtonModifier: ViewModifier {
    var isEnabled: Bool = true

    func body(content: Content) -> some View {
        content
            .font(.terminalSmall)
            .foregroundColor(isEnabled ? .terminalBlack : .terminalGray)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isEnabled ? Color.neonGreen : Color.terminalGray)
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(isEnabled ? Color.neonGreen : Color.terminalGray, lineWidth: 1)
            )
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
}

// MARK: - Number Formatting

extension Double {
    var formatted: String {
        if self >= 1_000_000 {
            return String(format: "%.1fM", self / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.1fK", self / 1_000)
        } else if self == floor(self) {
            return String(format: "%.0f", self)
        } else {
            return String(format: "%.1f", self)
        }
    }

    var percentFormatted: String {
        String(format: "%.0f%%", self * 100)
    }
}
