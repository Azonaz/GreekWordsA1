import SwiftUI

struct OnboardingView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var page = 0

    let onClose: () -> Void

    private let pages = OnboardingPage.pages

    private var isCompactLandscape: Bool {
        sizeClass == .compact && verticalSizeClass == .compact
    }

    private var horizontalPadding: CGFloat {
        sizeClass == .regular ? 72 : 22
    }

    private var pageSpacing: CGFloat {
        isCompactLandscape ? 12 : 22
    }

    private var imageWidth: CGFloat {
        if isCompactLandscape {
            return 150
        }
        return sizeClass == .regular ? 300 : 205
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {
                Color.gray.opacity(0.05)
                    .ignoresSafeArea()

                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            horizontalPadding: horizontalPadding,
                            usesLandscapeLayout: isLandscape,
                            usesCompactLandscapeMetrics: isCompactLandscape,
                            spacing: pageSpacing,
                            imageWidth: imageWidth,
                            onClose: onClose
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .overlay(alignment: .bottom) {
                pageDots
                    .padding(.bottom, isCompactLandscape ? 6 : 16)
                    .allowsHitTesting(false)
            }
            .background(
                Image(.pillar)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.14)
            )
        }
    }

    private var pageDots: some View {
        HStack(spacing: 10) {
            ForEach(pages.indices, id: \.self) { index in
                Circle()
                    .fill(index == page ? Color.primary.opacity(0.82) : Color.clear)
                    .frame(width: 9, height: 9)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(index == page ? 0.45 : 0.25), lineWidth: 1)
                    )
                    .shadow(radius: index == page ? 2 : 0)
                    .animation(.easeInOut(duration: 0.2), value: page)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(.white.opacity(0.25), lineWidth: 1)
        )
    }

}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let horizontalPadding: CGFloat
    let usesLandscapeLayout: Bool
    let usesCompactLandscapeMetrics: Bool
    let spacing: CGFloat
    let imageWidth: CGFloat
    let onClose: () -> Void

    private var imageCornerRadius: CGFloat {
        usesCompactLandscapeMetrics ? 14 : 20
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if usesLandscapeLayout {
                landscapeContent
            } else {
                portraitContent
            }

            closeButton
                .padding(.top, 8)
                .padding(.trailing, horizontalPadding)
        }
    }

    private var landscapeContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                HStack(alignment: .center, spacing: 50) {
                    image

                    text
                        .frame(maxWidth: 360)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 14)

                Spacer(minLength: 0)
            }
            .containerRelativeFrame(.vertical)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var portraitContent: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(spacing: spacing) {
                image

                text
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, horizontalPadding)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var image: some View {
        Image(page.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: imageWidth)
            .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(radius: 4)
    }

    private var text: some View {
        VStack(spacing: 10) {
            Text(page.title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text(page.text)
                .font(.body)
                .lineSpacing(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private var closeButton: some View {
        Button(action: onClose) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 34, height: 34)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(radius: 2)

                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(0.45)
    }
}

private struct OnboardingPage {
    let imageName: ImageResource
    let title: LocalizedStringKey
    let text: LocalizedStringKey

    static let pages = [
        OnboardingPage(
            imageName: .q1,
            title: Texts.onboardingQuizTitle,
            text: Texts.onboardingQuizText
        ),
        OnboardingPage(
            imageName: .q3,
            title: Texts.onboardingRandomQuizTitle,
            text: Texts.onboardingRandomQuizText
        ),
        OnboardingPage(
            imageName: .q2,
            title: Texts.onboardingHiddenTitle,
            text: Texts.onboardingHiddenText
        ),
        OnboardingPage(
            imageName: .t1,
            title: Texts.onboardingTrainingTitle,
            text: Texts.onboardingTrainingText
        ),
        OnboardingPage(
            imageName: .t2,
            title: Texts.onboardingReviewTitle,
            text: Texts.onboardingReviewText
        ),
        OnboardingPage(
            imageName: .w,
            title: Texts.onboardingWordDayTitle,
            text: Texts.onboardingWordDayText
        ),
        OnboardingPage(
            imageName: .s,
            title: Texts.onboardingSettingsTitle,
            text: Texts.onboardingSettingsText
        )
    ]
}
