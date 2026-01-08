import SwiftUI

struct GlassCard: ViewModifier {
    var height: CGFloat
    var cornerRadius: CGFloat
    var highlightColors: [Color]?
    var expand: Bool = true

    @State private var glowStrength: CGFloat = 0
    @State private var phase: CGFloat = 0

    private let sweepDuration: Double = 1.4
    private let lineW: CGFloat = 3
    private let segment: CGFloat = 0.5

    private var glowColor: Color {
        highlightColors?.first ?? .clear
    }

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .frame(height: height)
            .frame(maxWidth: expand ? .infinity : nil)
            .font(.title)
            .foregroundStyle(.primary)
            .background(.ultraThinMaterial, in: shape)
            .contentShape(shape)

        // baselines
            .overlay(
                shape.stroke(.white.opacity(0.25), lineWidth: 2)
                    .allowsHitTesting(false)
            )

        // base top glow
            .overlay(
                shape.fill(
                    LinearGradient(
                        colors: [.white.opacity(0.25), .clear],
                        startPoint: .top, endPoint: .center
                    )
                )
                .blendMode(.plusLighter)
                .opacity(0.7)
                .allowsHitTesting(false)
            )

        // base shadow
            .shadow(radius: 3)

        // running outline
            .overlay(
                runningOutlineOverlay(shape)
            )
            .onAppear {
                phase = 0
                withAnimation(.linear(duration: sweepDuration).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }

        // colour shadow when displaying results
            .shadow(color: glowColor.opacity(glowStrength * 0.45), radius: 10, x: 0, y: 6)
            .shadow(color: glowColor.opacity(glowStrength * 0.25), radius: 18, x: 0, y: 10)

            .onChange(of: highlightColors) {
                if highlightColors != nil {
                    withAnimation(.easeOut(duration: 0.25)) { glowStrength = 1 }
                } else {
                    withAnimation(.easeInOut(duration: 0.5)) { glowStrength = 0 }
                }
            }
    }

    private func runningOutlineOverlay(_ shape: RoundedRectangle) -> some View {
        return ZStack {
            let baseColors = highlightColors?.map { $0.opacity(0.4) } ?? [.clear, .clear]

            shape
                .trim(from: phase, to: min(phase + segment, 1))
                .stroke(
                    LinearGradient(colors: baseColors,
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineW, lineCap: .round)
                )

            if phase + segment > 1 {
                shape
                    .trim(from: 0, to: (phase + segment).truncatingRemainder(dividingBy: 1))
                    .stroke(
                        LinearGradient(colors: baseColors,
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: lineW, lineCap: .round)
                    )
            }
        }
        .opacity(highlightColors == nil ? 0 : 1)
        .allowsHitTesting(false)
    }
}

extension View {
    func glassCard(height: CGFloat, cornerRadius: CGFloat, highlightColors: [Color]? = nil,
                   expand: Bool = true) -> some View {
        modifier(GlassCard(height: height, cornerRadius: cornerRadius,
                           highlightColors: highlightColors, expand: expand))
    }
}
