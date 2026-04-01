import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()

    func sendMessage() {
        guard !inputText.isEmpty else { return }

        let userMessage = ChatMessage(text: inputText, isFromUser: true)
        messages.append(userMessage)
        let sentText = inputText
        inputText = ""
        isLoading = true

        APIClient.shared.sendMessage(sentText)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        self?.messages.append(ChatMessage(text: "Error: \(error.localizedDescription)", isFromUser: false))
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
