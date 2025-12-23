import SwiftUI

struct WordDayView: View {
    @StateObject private var model = WordDayModel()
    @Environment(\.horizontalSizeClass) var sizeClass

    private var cornerRadius: CGFloat { sizeClass == .regular ? 20 : 16 }
    private var rowSpacing: CGFloat { sizeClass == .regular ? 15 : 8 }
    private var horizontalPadding: CGFloat { sizeClass == .regular ? 40 : 20 }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05)
                .ignoresSafeArea()

            GeometryReader { geo in
                let availableWidth = max(geo.size.width - horizontalPadding * 2, 0)

                content(availableWidth: availableWidth)
                    .padding(.horizontal, horizontalPadding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.wordDay)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
        .task {
            await model.load()
        }
    }

    @ViewBuilder
    private func content(availableWidth: CGFloat) -> some View {
        if model.isLoading {
            ProgressView()
        } else if let errorMessage = model.errorMessage {
            errorView(message: errorMessage)
        } else if model.isSolved, let word = model.word {
            solvedView(word)
        } else if let word = model.word {
            gameView(word, availableWidth: availableWidth)
        } else {
            ProgressView()
        }
    }
}

private extension WordDayView {
    func solvedView(_ word: WordDayEntry) -> some View {
        VStack(spacing: 16) {
            Text(word.fullGr)
                .font(sizeClass == .regular ? .largeTitle : .title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)

            Text(word.en)
                .font(sizeClass == .regular ? .title2 : .title3)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
        }
        .padding(.horizontal, 12)
        .glassWordDisplay(height: sizeClass == .regular ? 150 : 130, cornerRadius: 24)
    }

    func gameView(_ word: WordDayEntry, availableWidth: CGFloat) -> some View {
        let itemWidth = elementWidth(totalWidth: availableWidth, count: model.slots.count)

        return VStack(spacing: sizeClass == .regular ? 50 : 30) {
            slotsView(itemWidth: itemWidth)

            if model.showHelp {
                translationView(word.en)
            }

            controlRow

            lettersRow(itemWidth: itemWidth)

            if let result = model.result {
                resultView(result)
            }

            okButton
        }
    }

    func slotsView(itemWidth: CGFloat) -> some View {
        HStack(spacing: rowSpacing) {
            ForEach(model.slots.indices, id: \.self) { index in
                let letter = model.slots[index] ?? ""

                Text(letter)
                    .font(.title2.weight(.medium))
                    .foregroundColor(.primary)
                    .frame(width: itemWidth, height: itemWidth)
                    .glassLabel(height: itemWidth, cornerRadius: cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(strokeColor, lineWidth: 2)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    func translationView(_ translation: String) -> some View {
        HStack(spacing: 8) {
            Text(Texts.wordDayTranslation)
                .fontWeight(.semibold)
            Text(translation)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .glassWordDisplay(height: sizeClass == .regular ? 70 : 60, cornerRadius: cornerRadius)
    }

    var controlRow: some View {
        HStack(spacing: sizeClass == .regular ? 20 : 30) {
            Button {
                model.toggleHelp()
            } label: {
                Text(Texts.wordDayHelp)
                    .foregroundColor(.primary)
                    .glassCard(height: 50, cornerRadius: cornerRadius)
            }

            Spacer()

            Button {
                model.deleteLastLetter()
            } label: {
                Text(Texts.wordDayDelete)
                    .foregroundColor(.primary)
                    .glassCard(height: 50, cornerRadius: cornerRadius)
            }
            .disabled(model.slots.allSatisfy { $0 == nil })
            .opacity(model.slots.allSatisfy { $0 == nil } ? 0.5 : 1)
        }
    }

    func lettersRow(itemWidth: CGFloat) -> some View {
        HStack(spacing: rowSpacing) {
            ForEach(model.letters) { letter in
                Button {
                    model.placeLetter(letter)
                } label: {
                    Text(letter.value)
                        .font(.title3)
                        .foregroundColor(.primary)
                        .frame(width: itemWidth, height: itemWidth)
                        .glassCard(height: itemWidth, cornerRadius: cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(strokeColor, lineWidth: 2)
                        )
                }
                .disabled(letter.isUsed || model.isSolved)
                .opacity(letter.isUsed ? 0.35 : 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    func resultView(_ result: WordDayResult) -> some View {
        let isSuccess = (result == .success)

        return Text(isSuccess ? Texts.wordDayCorrect : Texts.wordDayWrong)
            .font(.headline)
            .foregroundColor(isSuccess ? .green : .red)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    var okButton: some View {
        HStack {
            Spacer()

            Button {
                model.checkAnswer()
            } label: {
                Text(Texts.wordDayOK)
                    .foregroundColor(.primary)
                    .glassCard(height: 52, cornerRadius: cornerRadius)
            }
            .disabled(!model.isOKEnabled)
            .opacity(model.isOKEnabled ? 1 : 0.5)
        }
    }

    func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task { await model.load() }
            } label: {
                Text(Texts.retry)
                    .foregroundColor(.primary)
                    .glassCard(height: 50, cornerRadius: cornerRadius)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension WordDayView {
    func elementWidth(totalWidth: CGFloat, count: Int) -> CGFloat {
        guard count > 0 else { return totalWidth }
        let available = totalWidth - CGFloat(max(count - 1, 0)) * rowSpacing
        return max(available / CGFloat(count), 0)
    }

    var strokeColor: Color {
        switch model.result {
        case .some(.failure):
            return Color.red.opacity(0.45)
        case .some(.success):
            return Color.green.opacity(0.45)
        default:
            return .clear
        }
    }
}
