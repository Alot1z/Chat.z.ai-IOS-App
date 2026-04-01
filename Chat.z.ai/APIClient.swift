import Combine
import Foundation

final class APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: "https://chat.z.ai")!
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 180
        session = URLSession(configuration: config)
    }

    func sendMessage(_ message: String) -> AnyPublisher<String, Error> {
        let endpoint = baseURL.appendingPathComponent("api/chat")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")

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
            .tryMap(validateHTTP)
            .tryMap(parseResponse)
            .eraseToAnyPublisher()
    }

    private func validateHTTP(data: Data, response: URLResponse) throws -> Data {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200 ... 299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode)
        }
        return data
    }

    private func parseResponse(_ data: Data) throws -> String {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            if let fallback = String(data: data, encoding: .utf8), !fallback.isEmpty {
                return fallback
            }
            throw APIError.decodingError
        }

        if let direct = root["reply"] as? String ?? root["message"] as? String ?? root["content"] as? String {
            return direct
        }

        if let choices = root["choices"] as? [[String: Any]],
           let first = choices.first {
            if let text = first["text"] as? String {
                return text
            }

            if let message = first["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            }
        }

        if let dataText = String(data: data, encoding: .utf8), !dataText.isEmpty {
            return dataText
        }

        throw APIError.decodingError
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
            return "HTTP error: \(statusCode)"
        case .decodingError:
            return "Could not parse server response"
        }
    }
}
