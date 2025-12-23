import SwiftUI
import FSRS

extension TrainingView {
    func portraitLayout(_ word: Word) -> some View {
        VStack(spacing: 40) {
            statsHeaderPortrait()
                .padding(.top, 12)

            wordCard(word, height: sizeClass == .regular ? 140 : 120)
                .padding(.top, 40)

            translationView(for: word)
                .padding(.horizontal, 16)

            Spacer()

            portraitActions(for: word)
        }
        .padding()
    }

    func landscapePhoneLayout(_ word: Word) -> some View {
        VStack {
            statsHeaderLandscape()
                .padding(.horizontal, 120)
                .padding(.top, 1)

            Spacer()

            HStack(spacing: 20) {
                VStack(spacing: 12) {
                    wordCard(word, height: 100)
                    translationView(for: word)
                }
                .padding(.leading, 24)
                .frame(maxWidth: .infinity)

                VStack(spacing: 12) {
                    landscapeActions(for: word)
                }
                .padding(.trailing, 24)
            }

            Spacer()
        }
    }
}

private extension TrainingView {
    func statsHeaderPortrait() -> some View {
        Group {
            if !dueWords.isEmpty {
                VStack(spacing: 8) {
                    Text(Texts.wordsToday) + Text(" \(todayTotal)")
                        .font(.headline)

                    HStack(spacing: 12) {
                        Text(Texts.new) + Text(" \(todayNew)")
                        Text(Texts.learning) + Text(" \(todayLearning)")
                        Text(Texts.review) + Text(" \(todayReview)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .glassLabel(height: sizeClass == .regular ? 90 : 70,
                            cornerRadius: sizeClass == .regular ? 30 : 20)
                .padding(.horizontal, 16)
            }
        }
    }

    func statsHeaderLandscape() -> some View {
        Group {
            if !dueWords.isEmpty {
                HStack(spacing: 24) {
                    Text(Texts.wordsToday) + Text(" \(todayTotal)")
                        .font(.headline)

                    Text(Texts.new) + Text(" \(todayNew)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(Texts.learning) + Text(" \(todayLearning)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(Texts.review) + Text(" \(todayReview)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .glassLabel(height: 55, cornerRadius: 20)
            }
        }
    }

    func wordCard(_ word: Word, height: CGFloat) -> some View {
        let isSingleWord = !word.gr.contains(" ")

        return Text(word.gr)
            .font(.largeTitle.bold())
            .multilineTextAlignment(.center)
            .lineLimit(isSingleWord ? 1 : nil)
            .minimumScaleFactor(isSingleWord ? 0.4 : 1)
            .padding()
            .glassWordDisplay(height: height, cornerRadius: cornerRadius)
            .padding(.horizontal, 16)
    }

    @ViewBuilder
    func translationView(for word: Word) -> some View {
        if showTranslation {
            Text(isEnglish ? word.en : word.ru)
                .font(.largeTitle)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .transition(.opacity)
        }
    }

    @ViewBuilder
    func portraitActions(for word: Word) -> some View {
        if showTranslation {
            ratingButtons(
                for: word,
                height: sizeClass == .regular ? 55 : 35,
                cornerRadius: sizeClass == .regular ? 25 : 15
            )
                .padding(.horizontal, 8)
                .padding(.bottom, 40)
        } else {
            showTranslationButton(height: buttonHeight)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    func landscapeActions(for word: Word) -> some View {
        if showTranslation {
            ratingButtons(for: word, height: 45, cornerRadius: 20, direction: .vertical)
        } else {
            showTranslationButton(height: 100)
        }
    }

    func ratingButtons(for word: Word, height: CGFloat, cornerRadius: CGFloat,
                       direction: Axis.Set = .horizontal) -> some View {
        Group {
            if direction == .horizontal {
                HStack(spacing: 12) {
                    ratingButtonsContent(for: word, height: height, cornerRadius: cornerRadius)
                }
            } else {
                VStack(spacing: 12) {
                    ratingButtonsContent(for: word, height: height, cornerRadius: cornerRadius)
                }
            }
        }
    }

    func ratingButtonsContent(for word: Word, height: CGFloat, cornerRadius: CGFloat) -> some View {
        ForEach(Rating.allCases.filter { $0 != .manual }, id: \.self) { rating in
            Button {
                Task { await handleRating(rating, for: word) }
            } label: {
                Text(rating.localized)
                    .font(.body)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .glassCard(height: height, cornerRadius: cornerRadius)
            }
        }
    }

    func showTranslationButton(height: CGFloat) -> some View {
        Button {
            withAnimation { showTranslation = true }
        } label: {
            Text(Texts.showTranslation)
                .font(sizeClass == .regular ? .title : .title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding()
                .frame(maxWidth: .infinity)
                .glassCard(height: height, cornerRadius: cornerRadius)
        }
    }
}
