// swiftlint:disable identifier_name
nonisolated struct VocabularyFile: Codable, Sendable {
    let vocabulary: Vocabulary
}

nonisolated struct Vocabulary: Codable, Sendable {
    let groups: [WordGroup]
}

nonisolated struct WordGroup: Codable, Sendable {
    let id: Int
    let name: LocalizedString
    let version: Int
    let words: [WordItem]
}

nonisolated struct LocalizedString: Codable, Sendable {
    let en: String
    let ru: String
}

nonisolated struct WordItem: Codable, Sendable {
    let id: Int
    let gr: String
    let en: String
    let ru: String
}
// swiftlint:enable identifier_name
