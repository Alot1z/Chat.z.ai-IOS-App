import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showingClearConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            modelPicker

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        if viewModel.isLoading {
                            ProgressView("Thinking…")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    guard let last = viewModel.messages.last else { return }
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            Divider()
            HStack(spacing: 12) {
                TextField("Type a message…", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)

                Button(action: viewModel.sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                }
                .disabled(viewModel.isLoading || viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("Chat.z.ai")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Clear") {
                    showingClearConfirmation = true
                }
                .disabled(viewModel.messages.isEmpty || viewModel.isLoading)
            }
        }
        .alert("Clear conversation?", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                viewModel.clearConversation()
            }
        } message: {
            Text("This removes all messages in this chat on this device.")
        }
    }

    private var modelPicker: some View {
        Picker("Model", selection: $viewModel.selectedModel) {
            ForEach(ChatModel.allCases) { model in
                Text(model.rawValue).tag(model)
            }
        }
        .pickerStyle(.segmented)
        .padding([.horizontal, .top])
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser { Spacer(minLength: 40) }

            Text(message.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .foregroundStyle(message.isFromUser ? .white : .primary)
                .background(message.isFromUser ? Color.blue : Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if !message.isFromUser { Spacer(minLength: 40) }
        }
        .padding(.horizontal)
    }
}
