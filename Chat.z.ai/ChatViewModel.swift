import Combine
import Foundation

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published private(set) var isLoading = false

    private var cancellables = Set<AnyCancellable>()

    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(ChatMessage(text: text, isFromUser: true))
        inputText = ""
        isLoading = true

        APIClient.shared.sendMessage(text)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    guard case let .failure(error) = completion else { return }
                    self?.messages.append(ChatMessage(text: "Error: \(error.localizedDescription)", isFromUser: false))
                },
                receiveValue: { [weak self] reply in
                    self?.messages.append(ChatMessage(text: reply, isFromUser: false))
                }
            )
            .store(in: &cancellables)
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
}
