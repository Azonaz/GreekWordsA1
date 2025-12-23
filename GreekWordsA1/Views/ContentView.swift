import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var trainingAccess: TrainingAccessManager
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @State private var goTraining = false
    @State private var goPaywall = false
    @State private var isLandscapeDevice = UIScreen.main.bounds.width > UIScreen.main.bounds.height

    private var buttonHeight: CGFloat {
        if isHorizontalLayout {
            return sizeClass == .regular ? 100 : 65
        }

        return sizeClass == .regular ? 100 : 80
    }

    private var buttonPaddingHorizontal: CGFloat {
        sizeClass == .regular ? 100 : 60
    }

    private var topPadding: CGFloat {
        sizeClass == .regular ? 30 : 15
    }

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 40 : 30
    }

    private var isLandscapePhone: Bool {
        sizeClass == .compact && verticalSizeClass == .compact
    }

    private var isHorizontalLayout: Bool {
        isLandscapePhone || (UIDevice.current.userInterfaceIdiom == .pad && isLandscapeDevice)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.05)
                    .ignoresSafeArea()

                VStack(spacing: 10) {
                    Text("Greek Words A1")
                        .font(sizeClass == .regular ? .largeTitle : .title)
                        .fontWeight(.semibold)
                        .padding(.top, topPadding)

                    Spacer()

                    if isHorizontalLayout {
                        HStack(alignment: .center, spacing: sizeClass == .regular ? 48 : 24) {
                            VStack(spacing: sizeClass == .regular ? 30 : 12) {
                                NavigationLink(destination: GroupsListView()) {
                                    Text(Texts.quiz)
                                        .foregroundColor(.primary)
                                        .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                                }

                                NavigationLink(destination: QuizView()) {
                                    Text(Texts.randomQuiz)
                                        .foregroundColor(.primary)
                                        .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                                }

                                NavigationLink(destination: GroupsListView(mode: .reverse)) {
                                    Text(Texts.reverseQuiz)
                                        .foregroundColor(.primary)
                                        .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                                }
                            }
                            .frame(maxWidth: .infinity)

                            VStack(spacing: sizeClass == .regular ? 30 : 12) {
                                Spacer()

                                trainingButton

                                NavigationLink(destination: WordDayView()) {
                                    Text(Texts.wordDay)
                                        .foregroundColor(.primary)
                                        .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                                }

                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, buttonPaddingHorizontal)
                    } else {
                        NavigationLink(destination: GroupsListView()) {
                            Text(Texts.quiz)
                                .foregroundColor(.primary)
                                .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                        }
                        .padding(.horizontal, buttonPaddingHorizontal)

                        NavigationLink(destination: QuizView()) {
                            Text(Texts.randomQuiz)
                                .foregroundColor(.primary)
                                .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                        }
                        .padding(.top, topPadding)
                        .padding(.horizontal, buttonPaddingHorizontal)

                        NavigationLink(destination: GroupsListView(mode: .reverse)) {
                            Text(Texts.reverseQuiz)
                                .foregroundColor(.primary)
                                .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                        }
                        .padding(.top, topPadding)
                        .padding(.horizontal, buttonPaddingHorizontal)

                        trainingButton
                            .padding(.top, topPadding)
                            .padding(.horizontal, buttonPaddingHorizontal)

                        NavigationLink(destination: WordDayView()) {
                            Text(Texts.wordDay)
                                .foregroundColor(.primary)
                                .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                        }
                        .padding(.top, topPadding)
                        .padding(.horizontal, buttonPaddingHorizontal)
                    }

                    Spacer()

                    HStack(spacing: 24) {
                        NavigationLink {
                            InfoView()
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.system(size: 24, weight: .regular))
                                .frame(maxWidth: .infinity)
                                .glassCard(height: 55, cornerRadius: 25)
                        }

                        NavigationLink {
                            StatisticsView()
                        } label: {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 24, weight: .regular))
                                .frame(maxWidth: .infinity)
                                .glassCard(height: 55, cornerRadius: 25)
                        }

                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 24, weight: .regular))
                                .frame(maxWidth: .infinity)
                                .glassCard(height: 55, cornerRadius: 25)
                        }
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, buttonPaddingHorizontal)
                    .padding(.bottom, sizeClass == .regular ? 20 : 10)
                }
            }
            .background(
                Image(.pillar)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.2)
            )
            .task {
                await syncVocabulary()
                _ = try? context.fetch(FetchDescriptor<GroupMeta>())
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    Task { await syncVocabulary() }
                }
            }
            .navigationDestination(isPresented: $goTraining) {
                TrainingView()
            }
            .navigationDestination(isPresented: $goPaywall) {
                TrainingPaywallView()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                let orientation = UIDevice.current.orientation
                if orientation.isLandscape || orientation.isPortrait {
                    isLandscapeDevice = orientation.isLandscape
                }
            }
        }
    }

    func syncVocabulary() async {
        do {
            let url = URL(string: baseURL)!
            let service = VocabularySyncService(context: context, remoteURL: url)
            try await service.syncVocabulary()
        } catch {
            print("Synchronisation error: \(error)")
        }
    }

    private var trainingButton: some View {
        Button {
            trainingAccess.startTrialIfNeeded()
            trainingAccess.refreshState()

            if trainingAccess.hasAccess {
                goTraining = true
            } else {
                goPaywall = true
            }
        } label: {
            Text(Texts.training)
                .foregroundColor(.primary)
                .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
        }
    }
}
