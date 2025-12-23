import Foundation
import FSRS

final class StatsService {
    // Quiz stats
    static func totalWords(_ words: [Word]) -> Int {
        words.count
    }

    static func seenWords(_ progress: [WordProgress]) -> Int {
        progress.filter { $0.seen }.count
    }

    static func learnedWords(_ progress: [WordProgress]) -> Int {
        progress.filter { $0.learned }.count
    }

    static func completedQuizzes(_ stats: [QuizStats]) -> Int {
        stats.first?.completedCount ?? 0
    }

    static func averageQuizScore(_ stats: [QuizStats]) -> Int {
        Int(stats.first?.averageScore ?? 0)
    }

    // Training stats
    static func studyingWordsCount(words: [Word], groups: [GroupMeta]) -> Int {
        let openIDs = groups.filter { $0.opened }.map(\.id)
        return words.filter { openIDs.contains($0.groupID) }.count
    }

    static func learnedWordsCount(_ progress: [WordProgress]) -> Int {
        progress.filter { $0.learned }.count
    }

    // words that are difficult to remember
    static func weakWords(_ allProgress: [WordProgress], thresholdLapses: Int = 7,
                          stabilityThreshold: Double = 3.0) -> [WordProgress] {
        allProgress
            .filter { progress in
                progress.lapses >= thresholdLapses &&
                progress.stability < stabilityThreshold
            }
            .sorted { lhs, rhs in
                // lower stability first
                if lhs.stability != rhs.stability {
                    return lhs.stability < rhs.stability
                }
                // more lapses — worse
                if lhs.lapses != rhs.lapses {
                    return lhs.lapses > rhs.lapses
                }
                // higher difficulty — worse
                return lhs.difficulty > rhs.difficulty
            }
    }

    static func weakWordsCount(_ allProgress: [WordProgress]) -> Int {
        weakWords(allProgress).count
    }

    // words that haven't been repeated in a long time
    static func staleWords(_ allProgress: [WordProgress], weak: [WordProgress], days: Int = 80) -> [WordProgress] {
        let weakIDs = Set(weak.map(\.compositeID))
        let threshold = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? .distantPast

        return allProgress
            .filter { progress in
                // there was at least one repetition
                guard let last = progress.lastReview else { return false }

                // haven't repeated in a long time
                guard last < threshold else { return false }

                // is not a weak word
                return !weakIDs.contains(progress.compositeID)
            }
            .sorted { $0.lastReview ?? .distantPast < $1.lastReview ?? .distantPast }
    }

    static func staleWordsCount(_ allProgress: [WordProgress], weak: [WordProgress], days: Int = 80) -> Int {
        staleWords(allProgress, weak: weak, days: days).count
    }
}
