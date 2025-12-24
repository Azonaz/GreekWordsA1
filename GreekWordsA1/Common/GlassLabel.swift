import SwiftUI

struct GlassLabel: ViewModifier {
    var height: CGFloat
    var cornerRadius: CGFloat
    var expand: Bool = true

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            .multilineTextAlignment(.center)
            .frame(height: height)
            .frame(maxWidth: expand ? .infinity : nil)
            .foregroundStyle(.primary)
            .background(.ultraThinMaterial, in: shape)
            .overlay(
                shape.stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .overlay(
                shape.fill(
                    LinearGradient(
                        colors: [.white.opacity(0.1), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            )
            .clipShape(shape)
            .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
            .allowsHitTesting(false)
    }
}

extension View {
    func glassLabel(height: CGFloat, cornerRadius: CGFloat, expand: Bool = true) -> some View {
        modifier(GlassLabel(height: height, cornerRadius: cornerRadius, expand: expand))
    }
}
