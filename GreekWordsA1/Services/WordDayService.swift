import Foundation

final class WordDayService {
    private let remoteURL = URL(string: "https://azonaz.github.io/word-day-a1.json")!
    private let defaults = UserDefaults.standard
    private let cacheKey = "wordDayCache"
    private let solvedKey = "wordDaySolved"

    func loadWordOfDay() async throws -> WordDayState {
        let words = try await fetchWords()
        guard !words.isEmpty else { throw WordDayError.empty }

        let todayWord = wordForToday(from: words)

        if let solved = solvedWordForToday(), solved.gr == todayWord.gr {
            return WordDayState(word: solved, solved: true)
        }

        return WordDayState(word: todayWord, solved: false)
    }

    func markSolved(_ word: WordDayEntry) {
        let record = SolvedRecord(date: Date(), word: word)
        if let data = try? JSONEncoder().encode(record) {
            defaults.set(data, forKey: solvedKey)
        }
    }
}

private extension WordDayService {
    func fetchWords() async throws -> [WordDayEntry] {
        do {
            let (data, _) = try await URLSession.shared.data(from: remoteURL)
            let vocabulary = try JSONDecoder().decode(WordDayVocabularyFile.self, from: data)
            let trimmed = vocabulary.vocabulary.words.map { WordDayEntry(raw: $0) }

            cacheWords(trimmed)
            return trimmed
        } catch {
            if let cached = cachedWords() {
                return cached
            }
            throw error
        }
    }

    func wordForToday(from words: [WordDayEntry]) -> WordDayEntry {
        let day = Calendar.current.component(.day, from: Date())
        let index = max(0, (day - 1) % words.count)
        return words[index]
    }

    func cacheWords(_ words: [WordDayEntry]) {
        guard let data = try? JSONEncoder().encode(words) else { return }
        defaults.set(data, forKey: cacheKey)
    }

    func cachedWords() -> [WordDayEntry]? {
        guard let data = defaults.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode([WordDayEntry].self, from: data)
    }

    func solvedWordForToday() -> WordDayEntry? {
        guard let data = defaults.data(forKey: solvedKey),
              let record = try? JSONDecoder().decode(SolvedRecord.self, from: data) else { return nil }

        return Calendar.current.isDate(record.date, inSameDayAs: Date()) ? record.word : nil
    }
}

private struct SolvedRecord: Codable {
    let date: Date
    let word: WordDayEntry
}

enum WordDayError: LocalizedError {
    case empty

    var errorDescription: String? {
        switch self {
        case .empty:
            return "Word of the day list is empty."
        }
    }
}
