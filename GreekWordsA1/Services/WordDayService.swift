import Foundation

final class WordDayService {
    private let remoteURL = URL(string: "https://azonaz.github.io/word-day-a1.json")!
    private let defaults = UserDefaults.standard
    private let cacheKey = "wordDayCache"
    private let solvedKey = "wordDaySolved"
    private let historyKey = "wordDaySolvedHistory"

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
        save(record)
    }

    func wordDayStats() -> WordDayStats {
        let history = solvedHistory()
        return WordDayStats(
            totalSolved: history.count,
            currentStreak: currentStreak(from: history)
        )
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
        let today = Date()

        if let record = solvedHistory().last(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            return record.word
        }

        // fallback to legacy storage
        if let data = defaults.data(forKey: solvedKey),
           let record = try? JSONDecoder().decode(SolvedRecord.self, from: data),
           Calendar.current.isDate(record.date, inSameDayAs: today) {
            return record.word
        }

        return nil
    }

    func solvedHistory() -> [SolvedRecord] {
        if let data = defaults.data(forKey: historyKey),
           let records = try? JSONDecoder().decode([SolvedRecord].self, from: data) {
            return records
        }

        // migrate legacy single record
        if let data = defaults.data(forKey: solvedKey),
           let record = try? JSONDecoder().decode(SolvedRecord.self, from: data) {
            return [record]
        }

        return []
    }

    func save(_ record: SolvedRecord) {
        var history = solvedHistory()
        history.removeAll { Calendar.current.isDate($0.date, inSameDayAs: record.date) }
        history.append(record)
        history.sort { $0.date < $1.date }

        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: historyKey)
        }
    }

    func currentStreak(from history: [SolvedRecord]) -> Int {
        let calendar = Calendar.current
        let dates = Array(Set(history.map { calendar.startOfDay(for: $0.date) })).sorted()
        guard let lastDate = dates.last else { return 0 }

        var streak = 1
        var previousDate = lastDate

        for date in dates.reversed().dropFirst() {
            guard let expected = calendar.date(byAdding: .day, value: -1, to: previousDate) else { break }
            if calendar.isDate(date, inSameDayAs: expected) {
                streak += 1
                previousDate = date
            } else {
                break
            }
        }

        return streak
    }
}

private struct SolvedRecord: Codable {
    let date: Date
    let word: WordDayEntry
}

struct WordDayStats {
    let totalSolved: Int
    let currentStreak: Int

    static let zero = WordDayStats(totalSolved: 0, currentStreak: 0)
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
