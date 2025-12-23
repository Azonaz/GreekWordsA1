import XCTest
@testable import GreekWordsA1
import FSRS

final class TrainingSchedulerWordsForTodayTests: XCTestCase {

    private var scheduler: TrainingScheduler!

    override func setUp() {
        super.setUp()
        scheduler = TrainingScheduler()
        // Given: daily limit of new words is 2
        UserDefaults.standard.set(2, forKey: "dailyNewWordsLimit")
    }

    func test_returnsOnlyDueAndNewWords() {
        // Given: new word, due review word, and future review word
        let now = Date()
        let newWord = WordProgress.make(state: .new)
        let dueReview = WordProgress.make(state: .review, due: now)
        let futureReview = WordProgress.make(
            state: .review,
            due: now.addingTimeInterval(86400)
        )

        // When: selecting words for today
        let result = scheduler.wordsForToday(from: [
            newWord, dueReview, futureReview
        ])

        // Then: only new and due review words are returned
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.state == .new })
        XCTAssertTrue(result.contains { $0.state == .review })
    }

    func test_assignsNewWordsUpToLimit() {
        // Given: more new words than the daily limit
        let today = Calendar.current.startOfDay(for: .now)
        let new1 = WordProgress.make(state: .new)
        let new2 = WordProgress.make(state: .new)
        let new3 = WordProgress.make(state: .new)

        // When: selecting words for today
        let result = scheduler.wordsForToday(from: [new1, new2, new3])

        // Then: only up to the daily limit of new words are assigned today
        XCTAssertEqual(result.filter { $0.state == .new }.count, 2)
        XCTAssertTrue(result.allSatisfy {
            $0.assignedDate == nil ||
            Calendar.current.isDate($0.assignedDate!, inSameDayAs: today)
        })
    }

    func test_learningAlwaysIncluded() {
        // Given: a learning card
        let learning = WordProgress.make(state: .learning)

        // When: selecting words for today
        let result = scheduler.wordsForToday(from: [learning])

        // Then: learning cards are always included
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.state, .learning)
    }
}

final class TrainingSchedulerTrimTests: XCTestCase {

    private var scheduler: TrainingScheduler!

    override func setUp() {
        super.setUp()
        scheduler = TrainingScheduler()
        // Given: daily limit of new words is 1
        UserDefaults.standard.set(1, forKey: "dailyNewWordsLimit")
    }

    func test_trimsExtraAssignedNewWords() {
        // Given: two new words assigned today exceeding the limit
        let today = Calendar.current.startOfDay(for: .now)
        let pr1 = WordProgress.make(state: .new, assigned: today)
        let pr2 = WordProgress.make(state: .new, assigned: today)

        // When: trimming assigned new words
        scheduler.trimAssignedNewWordsIfNeeded([pr1, pr2])

        // Then: only one new word remains assigned
        let assignedCount = [pr1, pr2].filter { $0.assignedDate != nil }.count
        XCTAssertEqual(assignedCount, 1)
    }

    func test_doesNotTouchLearningOrReview() {
        // Given: learning and review cards assigned today
        let today = Calendar.current.startOfDay(for: .now)
        let learning = WordProgress.make(state: .learning, assigned: today)
        let review = WordProgress.make(state: .review, assigned: today)

        // When: trimming assigned new words
        scheduler.trimAssignedNewWordsIfNeeded([learning, review])

        // Then: non-new cards are not modified
        XCTAssertNotNil(learning.assignedDate)
        XCTAssertNotNil(review.assignedDate)
    }
}

final class TrainingSchedulerNextReviewTests: XCTestCase {

    private var scheduler: TrainingScheduler!

    override func setUp() {
        super.setUp()
        scheduler = TrainingScheduler()
    }

    func test_againMovesToLearningOrRelearning() {
        // Given: a review card
        let progress = WordProgress.make(
            state: .review,
            reps: 5
        )

        // When: rating the card as `.again`
        let updated = scheduler.nextReview(for: progress, rating: .again)

        // Then: the card leaves the review state and is marked as seen
        XCTAssertNotEqual(updated.state, .review)
        XCTAssertTrue(updated.seen)
    }

    func test_easyIncreasesInterval() {
        // Given: a review card with a short interval
        let progress = WordProgress.make(
            state: .review,
            reps: 3
        )
        progress.scheduledDays = 2

        // When: rating the card as `.easy`
        let updated = scheduler.nextReview(for: progress, rating: .easy)

        // Then: the interval increases and the card stays in review
        XCTAssertGreaterThan(updated.scheduledDays, progress.scheduledDays)
        XCTAssertEqual(updated.state, .review)
    }

    func test_doesNotMutateOriginalProgress() {
        // Given: an original WordProgress instance
        let progress = WordProgress.make(state: .new)
        let originalState = progress.state

        // When: calculating the next review
        _ = scheduler.nextReview(for: progress, rating: .good)

        // Then: the original instance is not mutated
        XCTAssertEqual(progress.state, originalState)
    }
}

final class QuizStatsTests: XCTestCase {

    func test_averageScore() {
        // Given: completed quizzes with total score
        let stats = QuizStats(completedCount: 4, totalScore: 10)

        // When: calculating average score
        let average = stats.averageScore

        // Then: average score is computed correctly
        XCTAssertEqual(average, 2.5)
    }

    func test_averageScoreZeroSafe() {
        // Given: zero completed quizzes
        let stats = QuizStats(completedCount: 0, totalScore: 10)

        // When: calculating average score
        let average = stats.averageScore

        // Then: division by zero is avoided
        XCTAssertEqual(average, 10)
    }
}
