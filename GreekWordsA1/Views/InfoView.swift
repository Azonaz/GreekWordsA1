import SwiftUI

struct InfoView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).ignoresSafeArea()

            List {
                Section(header:
                    Text(Texts.quizInfo)
                        .font(sizeClass == .regular ? .title2 : .headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                ) {
                    Text(Texts.quizHelp)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 4)
                }

                Section(header:
                    Text(Texts.reverseQuizInfo)
                        .font(sizeClass == .regular ? .title2 : .headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                ) {
                    Text(Texts.reverseQuizHelp)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 4)
                }

                Section(header:
                    Text(Texts.trainingInfo)
                        .font(sizeClass == .regular ? .title2 : .headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                ) {
                    Text(Texts.trainingHelp)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.information)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }
}
