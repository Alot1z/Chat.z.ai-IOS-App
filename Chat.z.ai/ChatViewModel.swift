import Combine
import Foundation

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()

    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isLoading else { return }

        messages.append(ChatMessage(text: trimmed, isFromUser: true))
        inputText = ""
        isLoading = true

        APIClient.shared.sendMessage(trimmed)
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
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
}
