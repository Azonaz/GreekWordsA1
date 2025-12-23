import SwiftUI

let baseURL = "https://azonaz.github.io/words-gr-a1new.json"
let appRate = "https://apps.apple.com/cy/app/greek-words-a1/id6474042509?action=write-review"

enum Texts {
    static let quiz: LocalizedStringKey = "quiz"
    static let training: LocalizedStringKey = "training"
    static let soon: LocalizedStringKey = "soon"
    static let categories: LocalizedStringKey = "categories"
    static let settings: LocalizedStringKey = "settings"
    static let statistics: LocalizedStringKey = "statistics"
    static let language: LocalizedStringKey = "language"
    static let restart: LocalizedStringKey = "restart"
    static let back: LocalizedStringKey = "back"
    static let result: LocalizedStringKey = "result"
    static let information: LocalizedStringKey = "information"
    static let quizInfo: LocalizedStringKey = "quizInfo"
    static let quizHelp: LocalizedStringKey = "quizHelp"
    static let trainingInfo: LocalizedStringKey = "trainingInfo"
    static let trainingHelp: LocalizedStringKey = "trainingHelp"
    static let showTranslation: LocalizedStringKey = "showTranslation"
    static let wordsDone: LocalizedStringKey = "wordsDone"
    static let noOpenGroups: LocalizedStringKey = "noOpenGroups"
    static let wordsToday: LocalizedStringKey = "wordsToday"
    static let new: LocalizedStringKey = "new"
    static let learning: LocalizedStringKey = "learning"
    static let review: LocalizedStringKey = "review"
    static let studyWords: LocalizedStringKey = "studyWords"
    static let reviewWords: LocalizedStringKey = "reviewWords"
    static let done: LocalizedStringKey = "done"
    static let wordsLeft: LocalizedStringKey = "wordsLeft"
    static let newWordsNumber: LocalizedStringKey = "newWordsNumber"
    static let trainingAccess: LocalizedStringKey = "trainingAccess"
    static let accessExpired: LocalizedStringKey = "accessExpired"
    static let unlockAccess: LocalizedStringKey = "unlockAccess"
    static let unlockFor: LocalizedStringKey = "unlockFor"
    static let loadPrice: LocalizedStringKey = "loadPrice"
    static let restore: LocalizedStringKey = "restore"
    static let rateApp: LocalizedStringKey = "rateApp"
    static let reverseQuiz: LocalizedStringKey = "reverseQuiz"
    static let reverseQuizInfo: LocalizedStringKey = "reverseQuizInfo"
    static let reverseQuizHelp: LocalizedStringKey = "reverseQuizHelp"
    static let randomQuiz: LocalizedStringKey = "randomQuiz"
    static let randomSelection: LocalizedStringKey = "randomSelection"
    static let levels: LocalizedStringKey = "levels"
    static let here: LocalizedStringKey = "here"
    static let otherLevels: LocalizedStringKey = "otherLevels"

    static var allWords: String {
        NSLocalizedString("allWords", comment: "")
    }

    static var quizzesCompleted: String {
        NSLocalizedString("quizzesCompleted", comment: "")
    }

    static var wordsSeen: String {
        NSLocalizedString("wordsSeen", comment: "")
    }

    static var averagePercentage: String {
        NSLocalizedString("averagePercentage", comment: "")
    }

    static var blurOn: String {
        NSLocalizedString("blurOn", comment: "")
    }

    static var blurOff: String {
        NSLocalizedString("blurOff", comment: "")
    }

    static var wordsLearn: String {
        NSLocalizedString("wordsLearn", comment: "")
    }

    static var wordsLearned: String {
        NSLocalizedString("wordsLearned", comment: "")
    }

    static var weakWords: String {
        NSLocalizedString("weakWords", comment: "")
    }

    static var wWords: String {
        NSLocalizedString("wWords", comment: "")
    }

    static var staleWords: String {
        NSLocalizedString("staleWords", comment: "")
    }

    static var errorPurchase: String {
        NSLocalizedString("errorPurchase", comment: "")
    }

    static var purchaseRestored: String {
        NSLocalizedString("purchaseRestored", comment: "")
    }

    static var noPurchase: String {
        NSLocalizedString("noPurchase", comment: "")
    }

    static var a1Level: String {
        NSLocalizedString("a1", comment: "")
    }

    static var a2Level: String {
        NSLocalizedString("a2", comment: "")
    }

    static var b1Level: String {
        NSLocalizedString("b1", comment: "")
    }
}
