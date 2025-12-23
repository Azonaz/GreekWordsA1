import SwiftUI
import Combine

struct WordDayVocabularyFile: Codable {
    let vocabulary: WordDayVocabulary
}

struct WordDayVocabulary: Codable {
    let words: [WordDayRawEntry]
}

// swiftlint:disable identifier_name
struct WordDayRawEntry: Codable {
    let gr: String
    let en: String
}

struct WordDayEntry: Codable, Equatable {
    let gr: String
    let en: String
    let fullGr: String

    init(gr: String, en: String, fullGr: String) {
        self.gr = gr
        self.en = en
        self.fullGr = fullGr
    }

    init(raw: WordDayRawEntry) {
        self.init(
            gr: WordDayEntry.trimGreek(raw.gr),
            en: raw.en,
            fullGr: raw.gr
        )
    }

    private static func trimGreek(_ value: String) -> String {
        let components = value.split(separator: " ", omittingEmptySubsequences: true)
        guard components.count > 1 else {
            return value.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return components.dropFirst().joined(separator: " ")
    }
}
// swiftlint:enable identifier_name

struct WordDayState {
    let word: WordDayEntry
    let solved: Bool
}

struct WordDayLetter: Identifiable {
    let id = UUID()
    let value: String
    var isUsed: Bool = false
}

enum WordDayResult: Equatable {
    case success
    case failure
}

@MainActor
final class WordDayModel: ObservableObject {
    @Published var word: WordDayEntry?
    @Published var isSolved = false
    @Published var letters: [WordDayLetter] = []
    @Published var slots: [String?] = []
    @Published var showHelp = false
    @Published var result: WordDayResult?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isChecking = false

    private let service = WordDayService()

    var isOKEnabled: Bool {
        guard !isSolved else { return false }
        return !isChecking && word != nil && slots.allSatisfy { $0 != nil }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        result = nil
        showHelp = false
        isChecking = false

        do {
            let state = try await service.loadWordOfDay()
            word = state.word
            isSolved = state.solved

            if state.solved {
                letters = []
                slots = []
            } else {
                prepareGame(with: state.word)
            }
        } catch {
            errorMessage = NSLocalizedString("wordDayError", comment: "")
        }

        isLoading = false
    }

    func prepareGame(with entry: WordDayEntry) {
        let characters = entry.gr.map { String($0) }
        slots = Array(repeating: nil, count: characters.count)
        letters = characters.map { WordDayLetter(value: $0) }.shuffled()
        showHelp = false
        result = nil
    }

    func placeLetter(_ letter: WordDayLetter) {
        guard !isSolved, let slotIndex = slots.firstIndex(where: { $0 == nil }) else { return }
        guard let letterIndex = letters.firstIndex(where: { $0.id == letter.id }),
              !letters[letterIndex].isUsed else { return }

        slots[slotIndex] = letter.value
        letters[letterIndex].isUsed = true
        result = nil
    }

    func deleteLastLetter() {
        guard !isSolved else { return }

        guard let lastIndex = slots.lastIndex(where: { $0 != nil }) else { return }
        let value = slots[lastIndex]
        slots[lastIndex] = nil

        if let value, let letterIndex = letters.firstIndex(where: { $0.isUsed && $0.value == value }) {
            letters[letterIndex].isUsed = false
        }

        result = nil
    }

    func toggleHelp() {
        showHelp.toggle()
    }

    func checkAnswer() {
        guard isOKEnabled, let word else { return }
        isChecking = true

        let attempt = slots.compactMap { $0 }.joined()
        let isCorrect = attempt == word.gr
        result = isCorrect ? .success : .failure

        if isCorrect {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                service.markSolved(word)
                isSolved = true
                result = nil
                isChecking = false
            }
        } else {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 800_000_000)
                resetInput()
                result = nil
                isChecking = false
            }
        }
    }

    private func resetInput() {
        slots = slots.map { _ in nil }
        letters = letters.map { letter in
            var updated = letter
            updated.isUsed = false
            return updated
        }
    }
}
