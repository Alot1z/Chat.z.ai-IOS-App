import Foundation
import Combine

class APIClient {
    static let shared = APIClient()

    private let baseURL = "https://chat.z.ai"
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }

    func sendMessage(_ message: String) -> AnyPublisher<String, Error> {
        guard let url = URL(string: "\(baseURL)/api/chat") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")

        let payload: [String: Any] = [
            "message": message,
            "model": "kimi-k2-5",
            "stream": false
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                if !(200 ... 299).contains(httpResponse.statusCode) {
                    throw APIError.httpError(statusCode: httpResponse.statusCode)
                }

                return data
            }
            .tryMap { data -> String in
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw APIError.decodingError
                }

                if let reply = json["reply"] as? String {
                    return reply
                } else if let message = json["message"] as? String {
                    return message
                } else if let content = json["content"] as? String {
                    return content
                } else if let choices = json["choices"] as? [[String: Any]],
                          let first = choices.first,
                          let text = first["text"] as? String {
                    return text
                } else {
                    return String(data: data, encoding: .utf8) ?? "Unknown response"
                }
            }
            .eraseToAnyPublisher()
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case let .httpError(code):
            return "HTTP Error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
