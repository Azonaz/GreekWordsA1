import SwiftUI
import SwiftData

struct QuizView: View {
    let group: GroupMeta?
    let mode: QuizMode
    @Query var words: [Word]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.verticalSizeClass) var vSizeClass

    @State private var quizWords: [Word] = []
    @State private var currentIndex = 0
    @State private var options: [Word] = []
    @State private var selectedWord: Word?
    @State private var isCorrect: Bool?
    @State private var correctCount = 0
    @State private var showResult = false
    @State private var isEnglish: Bool = Locale.preferredLanguages.first?.hasPrefix("en") == true
    @AppStorage("isBlurEnabled") private var isBlurEnabled = false
    @State private var answersBlurred = false
    @State private var haptic = UISelectionFeedbackGenerator()
    @State private var shakeOffset: CGFloat = 0
    @State private var answeredCount = 0
    @State private var isInteractionDisabled = false

    private var currentWord: Word? {
        quizWords.isEmpty ? nil : quizWords[currentIndex]
    }

    private var paddingHorizontal: CGFloat {
        sizeClass == .regular ? 48 : 24
    }

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 40 : 30
    }

    init(group: GroupMeta? = nil, mode: QuizMode = .direct) {
        self.group = group
        self.mode = mode
        if let group {
            let groupID = group.id
            _words = Query(filter: #Predicate<Word> { $0.groupID == groupID })
        } else {
            _words = Query()
        }
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).ignoresSafeArea()

            VStack(spacing: vSizeClass == .compact ? 20 : 100) {
                quizContent
                GlassProgressBar(progress: Double(answeredCount) / Double(max(quizWords.count, 1)))
            }

            if answersBlurred {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.3)) {
                            answersBlurred = false
                        }
                    }
            }
        }
        .onAppear {
            context.autosaveEnabled = true
            haptic.prepare()
            markGroupAsOpened()
            startQuiz()
        }
        .alert(isPresented: $showResult) {
            Alert(
                title: Text(Texts.result),
                message: Text("\(correctCount)/\(quizWords.count)"),
                primaryButton: .default(Text(Texts.restart)) { startQuiz() },
                secondaryButton: .cancel(Text(Texts.back)) { dismiss() }
            )
        }
        .onChange(of: showResult) { if showResult { saveQuizResult() } }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let group {
                    Text(isEnglish ? group.nameEn : group.nameRu)
                        .font(sizeClass == .regular ? .largeTitle : .title2)
                        .foregroundColor(.primary)
                } else {
                    Text(Texts.randomSelection)
                        .font(sizeClass == .regular ? .largeTitle : .title2)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

private extension QuizView {
    @ViewBuilder
    var quizContent: some View {
        if let currentWord {
            let isSingleWord = !promptText(for: currentWord).contains(" ")

            if sizeClass == .compact && vSizeClass == .compact {
                GeometryReader { geo in
                    HStack(spacing: 16) {
                        Text(promptText(for: currentWord))
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                            .lineLimit(isSingleWord ? 1 : nil)
                            .minimumScaleFactor(isSingleWord ? 0.4 : 1)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .glassWordDisplay(height: 120, cornerRadius: cornerRadius)
                            .frame(width: geo.size.width * 0.4)

                        VStack(spacing: 16) {
                            ForEach(options, id: \.compositeID) { word in
                                answerView(for: word, height: 60)
                                    .frame(width: geo.size.width * 0.6)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 16)
                }
                .frame(height: 220)
            } else {
                VStack(spacing: 20) {
                    Text(promptText(for: currentWord))
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .lineLimit(isSingleWord ? 1 : nil)
                        .minimumScaleFactor(isSingleWord ? 0.4 : 1)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .glassWordDisplay(height: sizeClass == .regular ? 140 : 120, cornerRadius: cornerRadius)
                        .padding(.horizontal, paddingHorizontal)
                        .padding(.bottom, sizeClass == .regular ? 100 : 80)

                    ForEach(options, id: \.compositeID) { word in
                        answerView(for: word, height: sizeClass == .regular ? 80 : 60)
                    }
                }
            }
        } else {
            ProgressView()
        }
    }

    @ViewBuilder
    func answerView(for word: Word, height: CGFloat) -> some View {
        Text(optionText(for: word))
            .offset(x: (isCorrect == false && word.compositeID == selectedWord?.compositeID) ? shakeOffset : 0)
            .font(.title3)
            .foregroundColor(.primary)
            .blur(radius: answersBlurred ? 8 : 0)
            .opacity(answersBlurred ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.3), value: answersBlurred)
            .glassCard(
                height: height,
                cornerRadius: cornerRadius,
                highlightColors: highlightColors(for: word)
            )
            .padding(.horizontal, paddingHorizontal)
            .onTapGesture {
                if !isInteractionDisabled {
                    handleTap(word)
                }
            }
    }

    func markGroupAsOpened() {
        guard let group else { return }

        if !group.opened {
            group.opened = true
            do {
                try context.save()
            } catch {
                print("Error when saving the opened-flag: \(error)")
            }
        }
    }

    func startQuiz() {
        guard words.count >= 10 else { return }
        quizWords = Array(words.shuffled().prefix(10))
        currentIndex = 0
        correctCount = 0
        answeredCount = 0
        selectedWord = nil
        isCorrect = nil
        showResult = false
        setupRound()
    }

    func setupRound() {
        guard let currentWord else { return }
        let others = words.filter { $0.compositeID != currentWord.compositeID }.shuffled()
        let newOptions = ([currentWord] + others.prefix(2)).shuffled()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            options = newOptions
            answersBlurred = isBlurEnabled
        }
    }

    func handleTap(_ word: Word) {
        guard selectedWord == nil else { return }
        isInteractionDisabled = true

        if let currentWord {
            let id = currentWord.compositeID
            let descriptor = FetchDescriptor<WordProgress>(
                predicate: #Predicate { $0.compositeID == id }
            )

            if let progress = try? context.fetch(descriptor).first {
                progress.seen = true
            } else {
                context.insert(WordProgress(compositeID: id, seen: true))
            }
        }

        selectedWord = word
        let correct = (word.compositeID == currentWord?.compositeID)
        isCorrect = correct
        if correct {
            correctCount += 1
        } else {
            shake()

            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                impact.impactOccurred(intensity: 0.5)
            }
        }

        haptic.selectionChanged()
        haptic.prepare()

        withAnimation(.easeInOut(duration: 0.35)) {
            answeredCount += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                selectedWord = nil
                isCorrect = nil

                if currentIndex + 1 < quizWords.count {
                    currentIndex += 1
                    setupRound()
                } else {
                    showResult = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isInteractionDisabled = false
            }
        }
    }

    func saveQuizResult() {
        let result = Int((Double(correctCount) / Double(quizWords.count)) * 100)

        if let stats = try? context.fetch(FetchDescriptor<QuizStats>()).first {
            stats.completedCount += 1
            stats.totalScore += result
        } else {
            context.insert(QuizStats(completedCount: 1, totalScore: result))
        }
    }

    func highlightColors(for word: Word) -> [Color]? {
        guard let currentWord else { return nil }

        if isCorrect == false, word.compositeID == currentWord.compositeID {
            return [.green.opacity(0.4), .green.opacity(0.7), .green.opacity(0.4)]
        }

        guard let selectedWord, word.compositeID == selectedWord.compositeID else {
            return nil
        }

        return isCorrect == true
            ? [.green.opacity(0.4), .green.opacity(0.7), .green.opacity(0.4)]
            : [.red.opacity(0.4), .red.opacity(0.8), .red.opacity(0.4)]
    }

    func shake() {
        let amplitude: CGFloat = 8
        withAnimation(.default.speed(3)) {
            shakeOffset = amplitude
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.default.speed(3)) { shakeOffset = -amplitude }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.default.speed(3)) { shakeOffset = amplitude / 2 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.default.speed(3)) { shakeOffset = 0 }
        }
    }

    func promptText(for word: Word) -> String {
        switch mode {
        case .direct:
            return word.gr
        case .reverse:
            return isEnglish ? word.en : word.ru
        }
    }

    func optionText(for word: Word) -> String {
        switch mode {
        case .direct:
            return isEnglish ? word.en : word.ru
        case .reverse:
            return word.gr
        }
    }
}
