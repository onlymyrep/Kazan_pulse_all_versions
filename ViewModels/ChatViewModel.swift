import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var newMessageText = ""
    @Published var error: String?
    
    private let chatService = ChatService()
    private var cancellables = Set<AnyCancellable>()
    private let eventId: String
    private let user: User // Добавляем пользователя
    
    init(eventId: String, user: User) { // Добавляем user в инициализатор
        self.eventId = eventId
        self.user = user
        setupObservers()
    }
    
    private func setupObservers() {
        chatService.$messages
            .assign(to: \.messages, on: self)
            .store(in: &cancellables)
        
        chatService.$error
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
    }
    
    func connectToEvent() {
        chatService.connectToEvent(eventId)
    }
    
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        // ИСПРАВЛЕНО: передаем пользователя
        _ = chatService.sendMessage(newMessageText, for: eventId, user: user)
        newMessageText = ""
    }
    
    func disconnect() {
        chatService.disconnect()
    }
    
    func clearError() {
        chatService.clearError()
    }
}
