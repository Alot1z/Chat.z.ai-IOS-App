import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    guard let last = viewModel.messages.last else { return }
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack(spacing: 10) {
                TextField("Type a message...", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)

                Button(action: viewModel.sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(viewModel.canSend ? .blue : .gray)
                        .font(.title3)
                }
                .disabled(!viewModel.canSend)
            }
            .padding(12)
        }
        .navigationTitle("Chat.z.ai")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser { Spacer(minLength: 28) }

            Text(message.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .foregroundStyle(message.isFromUser ? Color.white : Color.primary)
                .background(message.isFromUser ? Color.blue : Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if !message.isFromUser { Spacer(minLength: 28) }
        }
        .id(message.id)
    }
}
