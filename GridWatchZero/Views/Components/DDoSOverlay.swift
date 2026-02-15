import SwiftUI

// MARK: - DDoS Attack Overlay

struct DDoSOverlay: View {
    @State private var isGlitching = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let reducedEffects = RenderPerformanceProfile.reducedEffects

    var body: some View {
        Rectangle()
            .fill(Color.neonRed.opacity(0.15))
            .overlay(
                // Glitch lines
                VStack(spacing: 0) {
                    ForEach(0..<10, id: \.self) { i in
                        Rectangle()
                            .fill(Color.neonRed.opacity((!reducedEffects && isGlitching) ? 0.3 : 0))
                            .frame(height: 2)
                            .offset(x: (!reducedEffects && isGlitching) ? CGFloat.random(in: -5...5) : 0)
                        Spacer()
                    }
                }
            )
            .cornerRadius(4)
            .allowsHitTesting(false)
            .onAppear {
                guard !reduceMotion && !reducedEffects else { return }
                withAnimation(
                    Animation.easeInOut(duration: 0.1)
                        .repeatForever(autoreverses: true)
                ) {
                    isGlitching = true
                }
            }
    }
}
