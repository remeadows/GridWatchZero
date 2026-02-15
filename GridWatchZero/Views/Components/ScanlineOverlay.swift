import SwiftUI

// MARK: - Scanline Overlay

struct ScanlineOverlay: View {
    var body: some View {
        Group {
            if RenderPerformanceProfile.reducedEffects {
                EmptyView()
            } else {
                GeometryReader { _ in
                    Canvas { context, size in
                        for y in stride(from: 0, to: size.height, by: 3) {
                            let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                            context.fill(Path(rect), with: .color(.black.opacity(0.15)))
                        }
                    }
                    .drawingGroup()  // Rasterize to Metal texture — avoids per-frame Canvas re-render
                }
            }
        }
    }
}
