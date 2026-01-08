import Foundation
@testable import GreekWordsB1
import FSRS

extension WordProgress {
    static func make(
        id: String = UUID().uuidString,
        state: CardState,
        due: Date = .distantPast,
        assigned: Date? = nil,
        reps: Int = 0
    ) -> WordProgress {
        let progress = WordProgress(
            compositeID: id,
            learned: state == .review,
            correctAnswers: reps,
            seen: false
        )
        progress.state = state
        progress.due = due
        progress.assignedDate = assigned
        progress.lastReview = nil
        return progress
    }
}
