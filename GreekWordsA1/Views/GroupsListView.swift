import SwiftUI
import SwiftData

struct GroupsListView: View {
    let mode: QuizMode
    @Query(sort: [SortDescriptor(\GroupMeta.id, order: .forward)]) private var groups: [GroupMeta]
    @Query private var words: [Word]
    @Query private var progresses: [WordProgress]
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private var cardHeight: CGFloat {
        sizeClass == .regular ? 100 : 70
    }

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 40 : 30
    }

    private var paddingHorizontal: CGFloat {
        sizeClass == .regular ? 48 : 24
    }

    private var isEnglish: Bool {
        Locale.preferredLanguages.first?.hasPrefix("en") == true
    }

    init(mode: QuizMode = .direct) {
        self.mode = mode
    }

    var body: some View {
        let wordsByGroup = Dictionary(grouping: words, by: \.groupID)
        let seenIDs = Set(progresses.filter { $0.seen }.map(\.compositeID))

        ZStack {
            Color.gray.opacity(0.05)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(groups) { group in
                        NavigationLink(destination: destination(for: group)) {
                            let counts = countForGroup(group, wordsByGroup: wordsByGroup, seenIDs: seenIDs)
                            let counterText = "\(counts.seen)/\(counts.total)"

                            HStack(alignment: .center) {
                                Text(isEnglish ? group.nameEn : group.nameRu)
                                    .font(sizeClass == .regular ? .title2 : .title3)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(counterText)
                                    .font(sizeClass == .regular ? .title2 : .title3)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .frame(height: cardHeight)
                            .glassCard(height: cardHeight, cornerRadius: cornerRadius)
                            .padding(.horizontal, paddingHorizontal)
                        }
                    }
                }
                .padding(.top, sizeClass == .regular ? 60 : 40)
            }
        }
        .background(
            Image(.pillar)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.2)
        )
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.categories)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }

    private func countForGroup(_ group: GroupMeta, wordsByGroup: [Int: [Word]],
                               seenIDs: Set<String>) -> (seen: Int, total: Int) {
        let groupWords = wordsByGroup[group.id] ?? []
        let seen = groupWords.reduce(into: 0) { result, word in
            if seenIDs.contains(word.compositeID) {
                result += 1
            }
        }

        return (seen, groupWords.count)
    }

    @ViewBuilder
    private func destination(for group: GroupMeta) -> some View {
        QuizView(group: group, mode: mode)
    }
}
