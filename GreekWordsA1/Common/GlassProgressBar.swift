import SwiftUI

struct GlassProgressBar: View {
    var progress: Double
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) var sizeClass

    private var paddingHorizontal: CGFloat {
        sizeClass == .regular ? 48 : 24
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Color.glassBackground)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                    .shadow(color: .white.opacity(0.08), radius: 1, x: 0, y: -1)

                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: fillColors(for: colorScheme),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.25 : 0.6),
                                    lineWidth: 1)
                    )
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.2 : 0.5),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(Capsule())
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.black.opacity(colorScheme == .dark ? 0.2 : 0.1), lineWidth: 1)
                            .blur(radius: 1)
                            .offset(y: 1)
                            .mask(Capsule().fill(LinearGradient(colors: [.black, .clear],
                                                                startPoint: .bottom, endPoint: .top)))
                    )
                    .frame(width: geo.size.width * progress, height: 22)
                    .shadow(
                        color: colorScheme == .dark
                            ? .white.opacity(0.15)
                            : .black.opacity(0.15),
                        radius: 3, x: 0, y: 1
                    )
                    .animation(.easeInOut(duration: 0.35), value: progress)
            }
        }
        .frame(height: 22)
        .padding(.horizontal, paddingHorizontal)
        .padding(.top, 10)
    }

    private func fillColors(for scheme: ColorScheme) -> [Color] {
        if scheme == .dark {
            return [
                Color.white.opacity(0.25),
                Color.white.opacity(0.1)
            ]
        } else {
            return [
                Color(white: 0.9, opacity: 0.7),
                Color(white: 0.75, opacity: 0.5)
            ]
        }
    }
}
