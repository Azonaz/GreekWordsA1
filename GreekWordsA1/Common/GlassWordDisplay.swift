import SwiftUI

struct GlassWordDisplay: ViewModifier {
    var height: CGFloat
    var cornerRadius: CGFloat
    @State private var shimmerPhase: CGFloat = 0

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                shape.fill(.ultraThinMaterial)
            )
            .overlay(
                shape.fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.25),
                            .white.opacity(0.08),
                            .clear
                        ],
                        center: .top,
                        startRadius: 10,
                        endRadius: height * 1.5
                    )
                )
                .blendMode(.overlay)
            )
            .overlay(
                shape.fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            .black.opacity(0.06)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            )
            .overlay(
                shape.stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.15),
                            .white.opacity(0.02)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.75
                )
            )
            .shadow(color: .black.opacity(0.08), radius: 6)
            .allowsHitTesting(false)
    }
}

extension View {
    func glassWordDisplay(height: CGFloat, cornerRadius: CGFloat) -> some View {
        modifier(GlassWordDisplay(height: height, cornerRadius: cornerRadius))
    }
}
