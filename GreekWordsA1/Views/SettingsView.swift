import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    @Environment(\.horizontalSizeClass) var sizeClass
    @AppStorage("isBlurEnabled") private var isBlurEnabled = false
    @AppStorage("dailyNewWordsLimit") private var dailyNewWordsLimit: Int = 20
    @AppStorage("shouldShowRateButton") private var shouldShowRateButton = false

    @EnvironmentObject var trainingAccess: TrainingAccessManager
    @EnvironmentObject var purchaseManager: PurchaseManager

    @State private var restoring = false
    @State private var restoreMessage: String?
    @State private var showLevels = false

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 25 : 20
    }

    private var buttonHeight: CGFloat {
        sizeClass == .regular ? 55 : 50
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).ignoresSafeArea()

            List {
                // Selecting the application language
                Button {
                    openAppSettings()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "globe")
                            .font(.body)
                            .imageScale(.large)
                            .foregroundColor(.primary)

                        Text(Texts.language)
                            .font(.body)
                            .foregroundColor(.primary)

                        Spacer()

                        Text(displayName(for: currentLanguage))
                            .font(.body)
                            .foregroundColor(.secondary)

                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                }

                // Enable blur - hide answers until tapped
                GlassToggle(
                    isOn: $isBlurEnabled,
                    label: isBlurEnabled ? Texts.blurOn : Texts.blurOff
                )

                // Set the number of new words per day in training
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        Image(systemName: "character.book.closed")
                            .font(.body)
                            .imageScale(.large)
                            .foregroundColor(.primary)

                        Text(Texts.newWordsNumber)
                            .font(.body)
                            .foregroundColor(.primary)
                    }

                    GlassSegmentedControl(
                        items: [10, 20, 30],
                        label: { "\($0)" },
                        selection: $dailyNewWordsLimit
                    )
                }
                .padding(.vertical, 8)

                // Purchase recovery
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 14) {
                        Image(systemName: "lock.open")
                            .font(.body)
                            .imageScale(.large)
                            .foregroundColor(.primary)

                        Text(Texts.restore)
                            .font(.body)
                            .foregroundColor(.primary)

                        Spacer()

                        if restoring {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else if restoreMessage == Texts.purchaseRestored {
                            Image(systemName: "checkmark")
                                .font(.body)
                                .imageScale(.large)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            restoring = true
                            restoreMessage = nil

                            let restored = await restorePurchases()

                            restoring = false
                            restoreMessage = restored
                                ? Texts.purchaseRestored
                            : Texts.noPurchase
                        }
                    }

                    if let restoreMessage {
                        Text(restoreMessage)
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }

                // Other levels
                Button {
                    showLevels = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "graduationcap")
                            .font(.body)
                            .imageScale(.large)
                            .foregroundColor(.primary)

                        Text(Texts.otherLevels)
                            .font(.body)
                            .foregroundColor(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                }

                // Rate the app
                if shouldShowRateButton {
                    HStack(spacing: 14) {
                        Image(systemName: "star.fill")
                            .font(.body)
                            .imageScale(.large)
                            .foregroundColor(.primary)

                        Text(Texts.rateApp)
                            .font(.body)
                            .foregroundColor(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let url = URL(string: appRate) {
                            UIApplication.shared.open(url)
                        }
                        shouldShowRateButton = false
                    }
                }
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.settings)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
        .scrollContentBackground(.hidden)
        .onAppear {
            updateLanguage()
        }
        .navigationDestination(isPresented: $showLevels) {
            LevelsView()
        }
    }

    private func restorePurchases() async -> Bool {
        var restored = false

        for await result in Transaction.currentEntitlements {
            if let transaction = try? result.payloadValue {
                purchaseManager.purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
                trainingAccess.setUnlocked()
                restored = true
            }
        }

        return restored
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    private func updateLanguage() {
        currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    }

    private func displayName(for code: String) -> String {
        switch code {
        case "ru": return "Русский"
        case "en": return "English"
        default: return code.uppercased()
        }
    }
}
