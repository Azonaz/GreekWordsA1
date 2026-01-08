import SwiftUI
import FSRS
import SwiftData

struct TrainingSelectionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass

    let wordsProgress: [WordProgress]
    let title: String

    @State private var weakWords: [Word] = []
    @State private var currentIndex: Int = 0
    @State private var showTranslation = false
    @State private var finished = false
    @State private var isEnglish: Bool = Locale.preferredLanguages.first?.hasPrefix("en") == true

    private var currentWord: Word? {
        weakWords[safe: currentIndex]
    }

    private var buttonHeight: CGFloat {
        hSizeClass == .regular ? 100 : 80
    }

    private var cornerRadius: CGFloat {
        hSizeClass == .regular ? 40 : 30
    }

    private var isPhoneLandscape: Bool {
        UIDevice.current.userInterfaceIdiom == .phone && vSizeClass == .compact
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).ignoresSafeArea()

            VStack {
                if finished {
                    Text(Texts.done)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .glassLabel(height: hSizeClass == .regular ? 90 : 70,
                                    cornerRadius: hSizeClass == .regular ? 30 : 20)
                        .padding(.horizontal, 16)

                } else if let word = currentWord {
                    if isPhoneLandscape {
                        landscapeLayout(word)
                    } else {
                        portraitLayout(word)
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .task {
            await loadWords()
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(hSizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }

    @ViewBuilder
    private func portraitLayout(_ word: Word) -> some View {
        VStack(spacing: 40) {
            wordsLeftView(
                height: hSizeClass == .regular ? 70 : 50,
                cornerRadius: cornerRadius,
                horizontalPadding: 16
            )
                .padding(.top, 12)

            wordCard(word, height: hSizeClass == .regular ? 140 : 120)
                .padding(.top, 40)

            translationView(for: word)
                .padding(.horizontal, 16)

            Spacer()

            portraitActions(for: word)
        }
        .padding()
    }

    private func landscapeLayout(_ word: Word) -> some View {
        VStack {
            wordsLeftView(height: 55, cornerRadius: 20, horizontalPadding: 0)
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
                    if showTranslation {
                        ratingButtons(for: word)
                    } else {
                        showTranslationButton(height: 100)
                    }
                }
                .padding(.trailing, 24)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private func ratingButtons(for word: Word) -> some View {
        HStack(spacing: 12) {
            ForEach(Rating.allCases.filter { $0 != .manual }, id: \.self) { rating in
                Button {
                    Task { await handleRating(rating, for: word) }
                } label: {
                    Text(rating.localized)
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .glassCard(height: hSizeClass == .regular ? 55 : 35,
                                   cornerRadius: hSizeClass == .regular ? 25 : 15)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 40)
    }

    private func wordCard(_ word: Word, height: CGFloat) -> some View {
        let isSingleWord = !word.gr.contains(" ")

        return Text(word.gr)
            .font(.largeTitle.bold())
            .multilineTextAlignment(.center)
            .lineLimit(isSingleWord ? 1 : nil)
            .minimumScaleFactor(isSingleWord ? 0.4 : 1)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .glassWordDisplay(height: height, cornerRadius: cornerRadius)
            .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func translationView(for word: Word) -> some View {
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

    private func wordsLeftView(height: CGFloat, cornerRadius: CGFloat, horizontalPadding: CGFloat) -> some View {
        HStack(spacing: 0) {
            Text(Texts.wordsLeft)
            Text(" \(weakWords.count - currentIndex)")
        }
        .font(.headline)
        .frame(maxWidth: .infinity)
        .glassLabel(height: height, cornerRadius: cornerRadius)
        .padding(.horizontal, horizontalPadding)
    }

    private func portraitActions(for word: Word) -> some View {
        Group {
            if showTranslation {
                ratingButtons(for: word)
            } else {
                showTranslationButton(height: buttonHeight)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
            }
        }
    }

    private func showTranslationButton(height: CGFloat) -> some View {
        Button {
            withAnimation { showTranslation = true }
        } label: {
            Text(Texts.showTranslation)
                .font(hSizeClass == .regular ? .title : .title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding()
                .frame(maxWidth: .infinity)
                .glassCard(height: height, cornerRadius: cornerRadius)
        }
    }

    private func loadWords() async {
        do {
            let allWords = try context.fetch(FetchDescriptor<Word>())

            // match WordProgress → Word
            let ids = Set(wordsProgress.map(\.compositeID))
            self.weakWords = allWords.filter { ids.contains($0.compositeID) }

            await MainActor.run {
                currentIndex = 0
                showTranslation = false
                finished = weakWords.isEmpty
            }

        } catch {
            print("TrainingSelectionView loadWords error:", error)
        }
    }

    private func handleRating(_ rating: Rating, for word: Word) async {
        do {
            // load fresh WordProgress
            guard let wProgress = try context
                .fetch(FetchDescriptor<WordProgress>())
                .first(where: { $0.compositeID == word.compositeID })
            else {
                print("ERROR: Progress not found for", word.compositeID)
                return
            }

            // FSRS call
            let scheduler = TrainingScheduler()
            let updated = scheduler.nextReview(for: wProgress, rating: rating)

            // Applying changes
            wProgress.apply(from: updated)
            try context.save()

            withAnimation {
                if currentIndex + 1 < weakWords.count {
                    currentIndex += 1
                    showTranslation = false
                } else {
                    finished = true
                }
            }

        } catch {
            print("TrainingSelectionView handleRating error:", error)
        }
    }
}
