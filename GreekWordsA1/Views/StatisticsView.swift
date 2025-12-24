import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query private var quizStats: [QuizStats]
    @Query private var words: [Word]
    @Query private var progress: [WordProgress]
    @Query private var groups: [GroupMeta]
    @EnvironmentObject var trainingAccess: TrainingAccessManager
    @Environment(\.horizontalSizeClass) var sizeClass
    private let wordDayService = WordDayService()

    private var cardHeight: CGFloat {
        sizeClass == .regular ? 90 : 70
    }

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 30 : 20
    }

    private var horizontalPadding: CGFloat {
        sizeClass == .regular ? 80 : 40
    }

    // quiz
    private var totalWords: Int { StatsService.totalWords(words) }
    private var seenWords: Int { StatsService.seenWords(progress) }
    private var learnedWords: Int { StatsService.learnedWords(progress) }
    private var completedQuizzes: Int { StatsService.completedQuizzes(quizStats) }
    private var averageScore: Int { StatsService.averageQuizScore(quizStats) }

    // training
    private var studyingCount: Int { StatsService.studyingWordsCount(words: words, groups: groups) }
    private var learnedCount: Int { StatsService.learnedWordsCount(progress) }
    private var weakWords: [WordProgress] { StatsService.weakWords(progress) }
    private var weakWordsCount: Int { weakWords.count }
    private var staleWords: [WordProgress] { StatsService.staleWords(progress, weak: weakWords) }
    private var staleWordsCount: Int { staleWords.count }
    private var wordDayStats: WordDayStats { wordDayService.wordDayStats() }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    Text(Texts.quiz)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        StatCard(title: Texts.allWords, value: "\(totalWords)")
                        StatCard(title: Texts.quizzesCompleted, value: "\(completedQuizzes)")
                        StatCard(title: Texts.wordsSeen, value: "\(seenWords)")
                        StatCard(title: Texts.averagePercentage, value: "\(averageScore)%")
                    }
                    .padding(.horizontal, horizontalPadding)

                    Text(Texts.training)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        StatCard(title: Texts.wordsLearn, value: "\(studyingCount)")
                        StatCard(title: Texts.wordsLearned, value: "\(learnedCount)")

                        if weakWordsCount > 0 {
                            if trainingAccess.hasAccess {
                                StatCardWithButton(
                                    title: Texts.weakWords,
                                    value: "\(weakWordsCount)",
                                    horizontalPadding: horizontalPadding
                                ) {
                                    NavigationLink(
                                        destination: TrainingSelectionView(wordsProgress: weakWords,
                                                                           title: Texts.wWords)
                                    ) {
                                        Text(Texts.studyWords)
                                            .foregroundColor(.primary)
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .glassCard(
                                                height: sizeClass == .regular ? 45 : 35,
                                                cornerRadius: sizeClass == .regular ? 18 : 12
                                            )
                                    }
                                }
                            } else {
                                StatCard(title: Texts.weakWords, value: "0")
                            }
                        } else {
                            StatCard(title: Texts.weakWords, value: "0")
                        }

                        if staleWordsCount > 0 {
                            if trainingAccess.hasAccess {
                                StatCardWithButton(
                                    title: Texts.staleWords,
                                    value: "\(staleWordsCount)",
                                    horizontalPadding: horizontalPadding
                                ) {
                                    NavigationLink(
                                        destination: TrainingSelectionView(wordsProgress: staleWords,
                                                                           title: Texts.staleWords)
                                    ) {
                                        Text(Texts.reviewWords)
                                            .foregroundColor(.primary)
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .glassCard(
                                                height: sizeClass == .regular ? 45 : 35,
                                                cornerRadius: sizeClass == .regular ? 18 : 12
                                            )
                                    }
                                }
                            } else {
                                StatCard(title: Texts.staleWords, value: "0")
                            }
                        } else {
                            StatCard(title: Texts.staleWords, value: "0")
                        }
                    }
                    .padding(.horizontal, horizontalPadding)

                    Text(Texts.wordDay)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        StatCard(title: Texts.wordDaySolvedTotal, value: "\(wordDayStats.totalSolved)")
                        StatCard(title: Texts.wordDayStreak, value: "\(wordDayStats.currentStreak)")
                    }
                    .padding(.horizontal, horizontalPadding)
                }
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.statistics)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    @Environment(\.horizontalSizeClass) var sizeClass

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 30 : 20
    }

    private var height: CGFloat {
        sizeClass == .regular ? 90 : 70
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .glassLabel(height: height, cornerRadius: cornerRadius)
    }
}

private struct StatCardWithButton<ButtonContent: View>: View {
    let title: String
    let value: String
    let horizontalPadding: CGFloat
    @ViewBuilder let button: () -> ButtonContent

    @Environment(\.horizontalSizeClass) var sizeClass

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 30 : 20
    }

    private var height: CGFloat {
        sizeClass == .regular ? 150 : 120
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.clear)
                .glassLabel(height: height, cornerRadius: cornerRadius)
                .allowsHitTesting(false)

            VStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(.primary)

                button()
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
    }
}
