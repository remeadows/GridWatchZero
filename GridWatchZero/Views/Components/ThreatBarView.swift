import SwiftUI

// MARK: - Threat Bar View

struct ThreatBarView: View {
    let threatState: ThreatState
    let activeAttack: Attack?
    let attacksSurvived: Int
    var earlyWarning: EarlyWarning? = nil

    var body: some View {
        HStack(spacing: 12) {
            // Threat / Defense / Risk indicator
            ThreatIndicatorView(
                threatState: threatState,
                activeAttack: activeAttack,
                earlyWarning: earlyWarning
            )

            Spacer()

            // Attacks survived counter
            if attacksSurvived > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.neonGreen)

                    Text("\(attacksSurvived)")
                        .font(.terminalSmall)
                        .foregroundColor(.neonGreen)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color.terminalDarkGray.opacity(0.8))
    }
}
