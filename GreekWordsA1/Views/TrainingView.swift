import SwiftUI
import SwiftData
import FSRS

struct TrainingView: View {
    @Environment(\.modelContext) var context
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.verticalSizeClass) var vSizeClass

    @State var isEnglish: Bool = Locale.preferredLanguages.first?.hasPrefix("en") == true
    @State var dueWords: [Word] = []
    @State var currentIndex = 0
    @State var showTranslation = false
    @State var finished = false
    @State var noGroups = false
    @State var todayNew = 0
    @State var todayReview = 0
    @State var todayLearning = 0
    @State var wordStates: [String: ReviewState] = [:]

    @AppStorage("trainingCount") var trainingCount = 0
    @AppStorage("shouldShowRateButton") var shouldShowRateButton = false

    var todayTotal: Int {
        max(dueWords.count - currentIndex, 0)
    }

    var buttonHeight: CGFloat {
        sizeClass == .regular ? 100 : 80
    }

    var cornerRadius: CGFloat {
        sizeClass == .regular ? 40 : 30
    }

    var isPhoneLandscape: Bool {
        UIDevice.current.userInterfaceIdiom == .phone && vSizeClass == .compact
    }

    let scheduler = TrainingScheduler()

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).ignoresSafeArea()

            VStack {
                if noGroups {
                    Text(Texts.noOpenGroups)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .glassLabel(height: sizeClass == .regular ? 140 : 120,
                                    cornerRadius: cornerRadius)
                        .padding(.horizontal, 16)
                } else if finished {
                    Text(Texts.wordsDone)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .glassLabel(height: sizeClass == .regular ? 90 : 70,
                                    cornerRadius: sizeClass == .regular ? 30 : 20)
                        .padding(.horizontal, 16)
                } else if let word = dueWords[safe: currentIndex] {
                    if isPhoneLandscape {
                        landscapePhoneLayout(word)
                    } else {
                        portraitLayout(word)
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .task {
            await loadDueWords()
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.training)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }
}
