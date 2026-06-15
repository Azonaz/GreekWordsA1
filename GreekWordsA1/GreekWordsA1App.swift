import SwiftUI
import SwiftData

@main
struct GreekWordsA1App: App {
    @State private var showLaunchScreen = true
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject private var trainingAccess = TrainingAccessManager()
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showLaunchScreen = false
                            }
                        }
                    }
            } else {
                ContentView()
                    .environmentObject(trainingAccess)
                    .environmentObject(purchaseManager)
                    .modelContainer(for: [Word.self, GroupMeta.self, WordProgress.self, QuizStats.self])
                    .fullScreenCover(isPresented: onboardingBinding) {
                        OnboardingView {
                            hasSeenOnboarding = true
                        }
                    }
            }
        }
    }

    private var onboardingBinding: Binding<Bool> {
        Binding {
            !hasSeenOnboarding
        } set: { isPresented in
            if !isPresented {
                hasSeenOnboarding = true
            }
        }
    }
}
