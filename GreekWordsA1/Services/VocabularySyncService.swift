import Foundation
import SwiftData

final class VocabularySyncService {
    private let modelContainer: ModelContainer
    private let remoteURL: URL

    init(modelContainer: ModelContainer, remoteURL: URL) {
        self.modelContainer = modelContainer
        self.remoteURL = remoteURL
    }

    /// Basic sync logic
    func syncVocabulary() async throws {
        let (data, _) = try await URLSession.shared.data(from: remoteURL)
        let vocabularyFile = try JSONDecoder().decode(VocabularyFile.self, from: data)
        try syncVocabularyFile(vocabularyFile)
    }
}

extension VocabularySyncService {
    func syncVocabularyFile(_ vocabularyFile: VocabularyFile) throws {
        let context = ModelContext(modelContainer)
        var existingProgressIDs = Set(
            try context.fetch(FetchDescriptor<WordProgress>()).map(\.compositeID)
        )

        for group in vocabularyFile.vocabulary.groups {
            try syncGroup(group, in: context, existingProgressIDs: &existingProgressIDs)
        }

        if context.hasChanges {
            try context.save()
        }
    }
}

private extension VocabularySyncService {
    func syncGroup(_ group: WordGroup, in context: ModelContext,
                   existingProgressIDs: inout Set<String>) throws {
        // Check group version
        let existingMeta = try context.fetch(
            FetchDescriptor<GroupMeta>(predicate: #Predicate { $0.id == group.id })
        ).first

        if let existingMeta, existingMeta.version >= group.version {
            return
        }

        // Replace meta
        let meta: GroupMeta
        if let existingMeta {
            meta = existingMeta
        } else {
            meta = GroupMeta(
                id: group.id,
                version: group.version,
                nameEn: group.name.en,
                nameRu: group.name.ru
            )
            context.insert(meta)
        }

        meta.version = group.version
        meta.nameEn = group.name.en
        meta.nameRu = group.name.ru

        let existingWords = try context.fetch(
            FetchDescriptor<Word>(predicate: #Predicate { $0.groupID == group.id })
        )
        let wordsByLocalID = Dictionary(uniqueKeysWithValues: existingWords.map { ($0.localID, $0) })

        for word in group.words {
            if let existingWord = wordsByLocalID[word.id] {
                existingWord.gr = word.gr
                existingWord.en = word.en
                existingWord.ru = word.ru
            } else {
                let newWord = Word(
                    localID: word.id,
                    groupID: group.id,
                    gr: word.gr,
                    en: word.en,
                    ru: word.ru
                )
                context.insert(newWord)
                insertProgressIfNeeded(
                    for: newWord.compositeID,
                    in: context,
                    existingProgressIDs: &existingProgressIDs
                )
            }
        }
    }

    func insertProgressIfNeeded(for compositeID: String, in context: ModelContext,
                                existingProgressIDs: inout Set<String>) {
        guard !existingProgressIDs.contains(compositeID) else { return }

        let progress = WordProgress(
            compositeID: compositeID,
            learned: false,
            correctAnswers: 0,
            seen: false,
        )
        context.insert(progress)
        existingProgressIDs.insert(compositeID)
    }
}
