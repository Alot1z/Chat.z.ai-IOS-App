import Combine
import Foundation

final class APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: "https://chat.z.ai")!
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120
        session = URLSession(configuration: config)
    }

    func sendMessage(_ message: String) -> AnyPublisher<String, Error> {
        let url = baseURL.appendingPathComponent("api/chat")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Mozilla/5.0 (iPhone)", forHTTPHeaderField: "User-Agent")

        let body: [String: Any] = [
            "message": message,
            "model": "kimi-k2-5",
            "stream": false
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let http = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                guard (200...299).contains(http.statusCode) else {
                    throw APIError.httpError(statusCode: http.statusCode)
                }
                return data
            }
            .tryMap { data in
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw APIError.decodingError
                }

                for key in ["reply", "message", "content"] {
                    if let value = json[key] as? String, !value.isEmpty {
                        return value
                    }
                }

                if
                    let choices = json["choices"] as? [[String: Any]],
                    let first = choices.first,
                    let text = first["text"] as? String,
                    !text.isEmpty
                {
                    return text
                }

                return String(data: data, encoding: .utf8) ?? "Unknown response"
            }
            .eraseToAnyPublisher()
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case let .httpError(statusCode):
            return "HTTP Error: \(statusCode)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
