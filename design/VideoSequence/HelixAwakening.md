import SwiftUI

struct HelixAwakeningView: View {
    @State private var glowIntensity: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var eyeGlowOpacity: Double = 0.0
    @State private var environmentShift: Double = 0.0
    @State private var awakened: Bool = false

    var body: some View {
        ZStack {
            // Environment
            LinearGradient(
                colors: [
                    Color.white.opacity(0.9 - environmentShift),
                    Color.blue.opacity(0.2 + environmentShift)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 3.0), value: environmentShift)

            // Helix Core
            VStack {
                ZStack {
                    // Power Aura
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.cyan.opacity(glowIntensity),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 160
                            )
                        )
                        .scaleEffect(pulseScale)
                        .blur(radius: 30)

                    // Helix Silhouette (placeholder)
                    Image("helix") // Use your Helix image asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240)
                        .overlay(
                            // Eye Glow
                            Color.cyan
                                .opacity(eyeGlowOpacity)
                                .mask(
                                    Image("helixEyesMask") // Optional eye mask
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 240)
                                )
                        )
                }
            }
        }
        .onAppear {
            awakenHelix()
        }
    }

    private func awakenHelix() {
        // Phase 1 — dormant
        glowIntensity = 0.0
        eyeGlowOpacity = 0.0

        // Phase 2 — internal power builds
        withAnimation(.easeIn(duration: 3.0)) {
            glowIntensity = 0.6
            pulseScale = 1.08
            environmentShift = 0.2
        }

        // Phase 3 — pulse loop
        withAnimation(
            .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.15
        }

        // Phase 4 — awakening moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation(.easeOut(duration: 1.2)) {
                eyeGlowOpacity = 0.9
                environmentShift = 0.35
                awakened = true
            }
        }
    }
}