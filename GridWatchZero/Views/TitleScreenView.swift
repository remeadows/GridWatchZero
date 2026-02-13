// TitleScreenView.swift
// GridWatchZero
// Title screen with logo, version, and developer credit

import SwiftUI

struct TitleScreenView: View {
    @State private var showTitle = false
    @State private var showVersion = false
    @State private var showCredit = false
    @State private var glitchOffset: CGFloat = 0
    @State private var scanlineOffset: CGFloat = 0
    @State private var titleOpacity: Double = 0
    @State private var tapToContinue = false

    var onTap: () -> Void

    var body: some View {
        ZStack {
            // Background
            GlassDashboardBackground()

            // Scanline effect
            scanlineOverlay

            // Main content
            VStack(spacing: 0) {
                Spacer()

                // Logo / Title
                titleSection

                Spacer()

                // Version
                versionSection

                // Developer credit
                creditSection
                    .padding(.bottom, 60)

                // Tap to continue
                if tapToContinue {
                    Text("[ TAP TO CONTINUE ]")
                        .font(.terminalSmall)
                        .foregroundColor(.neonGreen.opacity(0.7))
                        .padding(.bottom, 40)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 40)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if tapToContinue {
                onTap()
            }
        }
        .onAppear {
            startAnimations()
            // Music already started during brand intro fade-out
            // Just ensure it's playing (in case we came from elsewhere)
            if !AmbientAudioManager.shared.isAmbientPlaying {
                AmbientAudioManager.shared.startAmbient()
                print("[TitleScreen] 🎵 Background music started")
            } else {
                print("[TitleScreen] 🎵 Background music already playing (from intro)")
            }
        }
    }

    // MARK: - Title Section

    // P1 FIX: .compositingGroup() flattens glow+glitch layers into single
    // rasterized composite. Without it, each glitch tick re-renders 3 text
    // layers + blur shadow = ~12 compositing passes at 10fps.
    private var titleSection: some View {
        VStack(spacing: 8) {
            // Glitch layers for "GRID WATCH"
            ZStack {
                // Red offset layer
                Text("GRID WATCH")
                    .font(.system(size: 42, weight: .black, design: .monospaced))
                    .foregroundColor(.neonRed.opacity(0.5))
                    .offset(x: glitchOffset, y: -1)

                // Cyan offset layer
                Text("GRID WATCH")
                    .font(.system(size: 42, weight: .black, design: .monospaced))
                    .foregroundColor(.neonCyan.opacity(0.5))
                    .offset(x: -glitchOffset, y: 1)

                // Main text
                Text("GRID WATCH")
                    .font(.system(size: 42, weight: .black, design: .monospaced))
                    .foregroundColor(.neonGreen)
            }
            .glow(.neonGreen, radius: 12)
            .compositingGroup()
            .opacity(titleOpacity)

            ZStack {
                // Red offset layer
                Text("ZERO")
                    .font(.system(size: 56, weight: .black, design: .monospaced))
                    .foregroundColor(.neonRed.opacity(0.5))
                    .offset(x: -glitchOffset, y: 1)

                // Cyan offset layer
                Text("ZERO")
                    .font(.system(size: 56, weight: .black, design: .monospaced))
                    .foregroundColor(.neonCyan.opacity(0.5))
                    .offset(x: glitchOffset, y: -1)

                // Main text
                Text("ZERO")
                    .font(.system(size: 56, weight: .black, design: .monospaced))
                    .foregroundColor(.neonAmber)
            }
            .glow(.neonAmber, radius: 15)
            .compositingGroup()
            .opacity(titleOpacity)

            // Subtitle
            if showTitle {
                Text("NEURAL GRID")
                    .font(.terminalTitle)
                    .foregroundColor(.terminalGray)
                    .tracking(8)
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }

    // MARK: - Version Section

    private var versionSection: some View {
        Group {
            if showVersion {
                HStack(spacing: 4) {
                    Text("v")
                        .foregroundColor(.terminalGray)
                    Text("1.0.0")
                        .foregroundColor(.neonCyan)
                }
                .font(.terminalBody)
                .padding(.bottom, 8)
                .transition(.opacity)
            }
        }
    }

    // MARK: - Credit Section

    private var creditSection: some View {
        Group {
            if showCredit {
                VStack(spacing: 4) {
                    Text("DEVELOPED BY")
                        .font(.terminalMicro)
                        .foregroundColor(.terminalGray.opacity(0.6))
                    Text("War Signal")
                        .font(.terminalBody)
                        .foregroundColor(.neonGreen)
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Scanline Overlay
    // P1 FIX: Replaced ForEach (~240 views) with single Canvas + drawingGroup.
    // Canvas rasterizes to Metal texture — zero per-frame view diffing cost.

    private var scanlineOverlay: some View {
        Canvas { context, size in
            for y in stride(from: scanlineOffset.truncatingRemainder(dividingBy: 4), to: size.height, by: 4) {
                let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                context.fill(Path(rect), with: .color(.black.opacity(0.15)))
            }
        }
        .drawingGroup()
        .allowsHitTesting(false)
    }

    // MARK: - Animations

    private func startAnimations() {
        // Glitch effect
        withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
            glitchOffset = 2
        }

        // Scanline scroll
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            scanlineOffset = 100
        }

        // Title fade in
        withAnimation(.easeOut(duration: 0.8)) {
            titleOpacity = 1
        }

        // Staggered reveals
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            showTitle = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
            showVersion = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(1.3)) {
            showCredit = true
        }

        withAnimation(.easeOut(duration: 0.5).delay(1.8)) {
            tapToContinue = true
        }
    }
}

#Preview {
    TitleScreenView {
        print("Tapped!")
    }
}
