import SwiftUI

struct ChatView: View {
    let event: Event
    let user: User
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(event: Event, user: User) {
        self.event = event
        self.user = user
        _viewModel = StateObject(wrappedValue: ChatViewModel(eventId: event.id, user: user))
    }
    
    private var chatTitle: String {
        if event.isBusiness {
            return "Чат с \(event.organizer)"
        }
        return "Чат события"
    }
    
    private var placeholderText: String {
        if event.isBusiness {
            return "Написать сообщение бизнесу..."
        }
        return "Написать сообщение..."
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primaryText)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(chatTitle)
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    Text(event.title)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Для симметрии
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.clear)
            }
            .padding()
            .background(Color.darkBackground)
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Приветственное сообщение для бизнеса
                        if event.isBusiness {
                            WelcomeBusinessMessage(event: event)
                        }
                        
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: viewModel.messages) { oldValue, newValue in
                    if let lastMessage = newValue.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input area
            VStack(spacing: 8) {
                if let error = viewModel.error {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.neonPink)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.neonPink)
                        Spacer()
                        Button("OK") {
                            viewModel.clearError()
                        }
                        .foregroundColor(.neonPink)
                    }
                    .padding(.horizontal)
                }
                
                HStack {
                    TextField(placeholderText, text: $viewModel.newMessageText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.cardBackground)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.neonBlue.opacity(0.3), lineWidth: 1)
                        )
                    
                    Button(action: { viewModel.sendMessage() }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.neonBlue)
                            .padding(8)
                    }
                    .disabled(viewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(Color.darkBackground)
        }
        .background(Color.darkBackground.ignoresSafeArea())
        .onAppear {
            viewModel.connectToEvent()
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
}

struct WelcomeBusinessMessage: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.neonBlue)
                Text("Информация о бизнесе")
                    .font(.headline)
                    .foregroundColor(.primaryText)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Вы пишете в \(event.title)")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                
                if let hours = event.businessHours {
                    Text("Часы работы: \(hours)")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                if let contact = event.contactInfo {
                    Text("Телефон: \(contact)")
                        .font(.caption)
                        .foregroundColor(.neonBlue)
                }
                
                Text("Обычно отвечают в течение 15 минут")
                    .font(.caption)
                    .foregroundColor(.neonGreen)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.neonBlue.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neonBlue.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
