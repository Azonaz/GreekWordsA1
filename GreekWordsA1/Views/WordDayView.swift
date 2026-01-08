import SwiftUI

struct WordDayView: View {
    @StateObject private var model = WordDayModel()
    @Environment(\.horizontalSizeClass) var sizeClass

    private var cornerRadius: CGFloat { sizeClass == .regular ? 20 : 16 }
    private var rowSpacing: CGFloat { sizeClass == .regular ? 15 : 8 }
    private var horizontalPadding: CGFloat { sizeClass == .regular ? 40 : 20 }
    private var landscapeItemWidth: CGFloat { sizeClass == .regular ? 60 : 50 }
    private var controlSpacing: CGFloat { sizeClass == .regular ? 40 : 24 }
    private var controlButtonWidth: CGFloat { sizeClass == .regular ? 170 : 130 }
    private var controlButtonHeight: CGFloat { sizeClass == .regular ? 70 : 50 }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05)
                .ignoresSafeArea()

            GeometryReader { geo in
                let availableWidth = max(geo.size.width - horizontalPadding * 2, 0)
                let isLandscape = geo.size.width > geo.size.height

                content(availableWidth: availableWidth, isLandscape: isLandscape)
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
    private func content(availableWidth: CGFloat, isLandscape: Bool) -> some View {
        if model.isLoading {
            ProgressView()
        } else if let errorMessage = model.errorMessage {
            errorView(message: errorMessage)
        } else if model.isSolved, let word = model.word {
            solvedView(word)
        } else if let word = model.word {
            gameView(word, availableWidth: availableWidth, isLandscape: isLandscape)
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

    func gameView(_ word: WordDayEntry, availableWidth: CGFloat, isLandscape: Bool) -> some View {
        let calculatedWidth = elementWidth(totalWidth: availableWidth, count: model.slots.count)
        let itemWidth = isLandscape ? landscapeItemWidth : min(calculatedWidth, landscapeItemWidth)
        let isPhoneLandscape = isLandscape && sizeClass != .regular

        return VStack(spacing: sizeClass == .regular ? 50 : 30) {
            slotsView(itemWidth: itemWidth, isLandscape: isLandscape)

            if model.showHelp {
                translationView(word.en)
            }

            if isPhoneLandscape == false {
                controlRow
            }

            lettersRow(itemWidth: itemWidth, isLandscape: isLandscape)

            if let result = model.result {
                resultView(result)
            }

            if isPhoneLandscape {
                phoneLandscapeControlRow
            } else {
                okButton
            }
        }
    }

    func slotsView(itemWidth: CGFloat, isLandscape: Bool) -> some View {
        HStack(spacing: rowSpacing) {
            ForEach(model.slots.indices, id: \.self) { index in
                let letter = model.slots[index] ?? ""

                Text(letter)
                    .font(.title2.weight(.medium))
                    .foregroundColor(.primary)
                    .frame(width: itemWidth, height: itemWidth)
                    .glassLabel(height: itemWidth, cornerRadius: sizeClass == .regular ? 16 : 8, expand: !isLandscape)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(strokeColor, lineWidth: 2)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    func translationView(_ translation: String) -> some View {
        Text(translation)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 12)
    }

    var controlRow: some View {
        HStack(spacing: controlSpacing) {
            Button {
                model.toggleHelp()
            } label: {
                Text(Texts.wordDayHelp)
                    .foregroundColor(.primary)
                    .frame(width: controlButtonWidth)
                    .glassCard(height: controlButtonHeight, cornerRadius: cornerRadius, expand: false)
            }

            Button {
                model.deleteLastLetter()
            } label: {
                Text(Texts.wordDayDelete)
                    .foregroundColor(.primary)
                    .frame(width: controlButtonWidth)
                    .glassCard(height: controlButtonHeight, cornerRadius: cornerRadius, expand: false)
            }
            .disabled(model.slots.allSatisfy { $0 == nil })
            .opacity(model.slots.allSatisfy { $0 == nil } ? 0.5 : 1)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    func lettersRow(itemWidth: CGFloat, isLandscape: Bool) -> some View {
        HStack(spacing: rowSpacing) {
            ForEach(model.letters) { letter in
                Button {
                    model.placeLetter(letter)
                } label: {
                    Text(letter.value)
                        .font(.title3)
                        .foregroundColor(.primary)
                        .frame(width: itemWidth, height: itemWidth)
                        .glassCard(height: itemWidth, cornerRadius: sizeClass == .regular ? 16 : 8,
                                   expand: !isLandscape)
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
            Button {
                model.checkAnswer()
            } label: {
                Text(Texts.wordDayOK)
                    .foregroundColor(.primary)
                    .frame(width: controlButtonWidth)
                    .glassCard(height: controlButtonHeight, cornerRadius: cornerRadius, expand: false)
            }
            .disabled(!model.isOKEnabled)
            .opacity(model.isOKEnabled ? 1 : 0.5)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    var phoneLandscapeControlRow: some View {
        HStack(spacing: controlSpacing) {
            Button {
                model.toggleHelp()
            } label: {
                Text(Texts.wordDayHelp)
                    .foregroundColor(.primary)
                    .frame(width: controlButtonWidth)
                    .glassCard(height: controlButtonHeight, cornerRadius: cornerRadius, expand: false)
            }

            Button {
                model.deleteLastLetter()
            } label: {
                Text(Texts.wordDayDelete)
                    .foregroundColor(.primary)
                    .frame(width: controlButtonWidth)
                    .glassCard(height: controlButtonHeight, cornerRadius: cornerRadius, expand: false)
            }
            .disabled(model.slots.allSatisfy { $0 == nil })
            .opacity(model.slots.allSatisfy { $0 == nil } ? 0.5 : 1)

            Button {
                model.checkAnswer()
            } label: {
                Text(Texts.wordDayOK)
                    .foregroundColor(.primary)
                    .frame(width: controlButtonWidth)
                    .glassCard(height: controlButtonHeight, cornerRadius: cornerRadius, expand: false)
            }
            .disabled(!model.isOKEnabled)
            .opacity(model.isOKEnabled ? 1 : 0.5)
        }
        .frame(maxWidth: .infinity, alignment: .center)
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
