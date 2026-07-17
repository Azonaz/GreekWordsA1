import Foundation

enum AnalyticsEventCode: String {
    case wordDaySolved = "word-day-solved"
    case statsOpen = "stats-open"
    case appLanguage = "app-language"
    case blurOn = "blur-on"
    case quizNormal = "quiz-normal"
    case quizReverse = "quiz-reverse"
    case quizRandom = "quiz-random"
    case trainingOpen = "training-open"
}

struct AnalyticsService {
    static let shared = AnalyticsService()

    func track(_ code: AnalyticsEventCode, value: Int? = nil) {
        let event = AnalyticsEvent(app: appKey, code: code.rawValue, value: value)

        Task {
            await send(event)
        }
    }

    private func send(_ event: AnalyticsEvent) async {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        do {
            request.httpBody = try JSONEncoder().encode(event)
            _ = try await URLSession.shared.data(for: request)
        } catch {
#if DEBUG
            print("Analytics event failed: \(event.code)")
#endif
        }
    }
}

private struct AnalyticsEvent: Encodable {
    let app: String
    let code: String
    let value: Int?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(app, forKey: .app)
        try container.encode(code, forKey: .code)
        try container.encodeIfPresent(value, forKey: .value)
    }

    private enum CodingKeys: String, CodingKey {
        case app
        case code
        case value
    }
}
