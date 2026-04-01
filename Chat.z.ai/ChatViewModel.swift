import Combine
import Foundation

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var selectedModel: ChatModel = .kimiK25

    private var cancellables = Set<AnyCancellable>()

    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isLoading else { return }

        messages.append(ChatMessage(text: trimmed, isFromUser: true))
        inputText = ""
        isLoading = true

        APIClient.shared.sendMessage(trimmed, model: selectedModel.apiValue)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.isLoading = false
                    if case let .failure(error) = completion {
                        self.messages.append(ChatMessage(text: "Error: \(error.localizedDescription)", isFromUser: false))
                    }
                },
                receiveValue: { [weak self] reply in
                    self?.messages.append(ChatMessage(text: reply, isFromUser: false))
                }
            )
            .store(in: &cancellables)
    }

    func clearConversation() {
        messages.removeAll()
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
}

enum ChatModel: String, CaseIterable, Identifiable {
    case kimiK25 = "Kimi K2.5"
    case gpt4oMini = "GPT-4o mini"
    case deepSeekV3 = "DeepSeek V3"

    var id: String { rawValue }

    var apiValue: String {
        switch self {
        case .kimiK25:
            return "kimi-k2-5"
        case .gpt4oMini:
            return "gpt-4o-mini"
        case .deepSeekV3:
            return "deepseek-v3"
        }
    }
}
