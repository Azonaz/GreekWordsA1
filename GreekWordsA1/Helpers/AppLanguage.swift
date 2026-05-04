import SwiftUI

enum AppLanguage {
    private static let supportedCodes = ["en", "ru"]

    static func code(for locale: Locale) -> String {
        if let localeCode = normalizedCode(from: locale.language.languageCode?.identifier) {
            return localeCode
        }

        if let bundleCode = normalizedCode(from: Bundle.main.preferredLocalizations.first) {
            return bundleCode
        }

        return "en"
    }

    static func isEnglish(for locale: Locale) -> Bool {
        code(for: locale) == "en"
    }

    private static func normalizedCode(from rawCode: String?) -> String? {
        guard let rawCode else { return nil }

        let separator = rawCode.contains("-") ? "-" : "_"
        let baseCode = rawCode.components(separatedBy: separator).first?.lowercased() ?? rawCode.lowercased()

        guard supportedCodes.contains(baseCode) else { return nil }
        return baseCode
    }
}

extension GroupMeta {
    func localizedName(for locale: Locale) -> String {
        AppLanguage.isEnglish(for: locale) ? nameEn : nameRu
    }
}

extension Word {
    func localizedTranslation(for locale: Locale) -> String {
        AppLanguage.isEnglish(for: locale) ? en : ru
    }
}
