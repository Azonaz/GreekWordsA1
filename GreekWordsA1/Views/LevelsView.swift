import SwiftUI

struct LevelsView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    private var cardHeight: CGFloat {
        sizeClass == .regular ? 120 : 95
    }

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 28 : 22
    }

    private var paddingHorizontal: CGFloat {
        sizeClass == .regular ? 36 : 22
    }

    private var topPadding: CGFloat {
        sizeClass == .regular ? 40 : 26
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {

                    LevelCard(
                        level: "A1",
                        title: "Greek Words — A1",
                        subtitle: Texts.a1Level,
                        appIconName: "a1",
                        appStoreURL: nil,
                        isCurrent: true,
                        height: cardHeight,
                        cornerRadius: cornerRadius
                    )

                    LevelCard(
                        level: "A2",
                        title: "Greek Words — A2",
                        subtitle: Texts.a2Level,
                        appIconName: "a2",
                        appStoreURL: "https://apps.apple.com/cy/app/greek-words-a2/id6736978135",
                        isCurrent: false,
                        height: cardHeight,
                        cornerRadius: cornerRadius
                    )

                    LevelCard(
                        level: "B1",
                        title: "Greek Words — B1",
                        subtitle: Texts.b1Level,
                        appIconName: "b1",
                        appStoreURL: "https://apps.apple.com/cy/app/greek-words-b1/id6754924042",
                        isCurrent: false,
                        height: cardHeight,
                        cornerRadius: cornerRadius
                    )
                }
                .padding(.horizontal, paddingHorizontal)
                .padding(.top, topPadding)
                .padding(.bottom, 24)
            }
        }
        .background(
            Image(.pillar)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.2)
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.levels)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct LevelCard: View {
    let level: String
    let title: String
    let subtitle: String
    let appIconName: String
    let appStoreURL: String?
    let isCurrent: Bool
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        Button {
            guard !isCurrent,
                  let appStoreURL,
                  let url = URL(string: appStoreURL) else { return }
            UIApplication.shared.open(url)
        } label: {
            HStack(spacing: 16) {

                Image(appIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                Color.black.opacity(isCurrent ? 0.1 : 0.2),
                                lineWidth: 1
                            )
                    )
                    .opacity(isCurrent ? 0.5 : 1.0)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .layoutPriority(1)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .layoutPriority(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    if isCurrent {
                        Text(Texts.here)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(Color.gray.opacity(0.2))
                            )
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                    Image(systemName: isCurrent ? "checkmark.circle" : "arrow.up.right.square")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isCurrent ? .seaBlue : .secondary)
                }
            }
            .padding(.horizontal, 18)
            .glassCard(
                height: height,
                cornerRadius: cornerRadius,
                highlightColors: nil
            )
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(!isCurrent)
    }
}
