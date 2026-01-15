import Foundation
import Combine

class ChatService: ObservableObject {
    @Published var eventChats: [String: EventChat] = [:] // eventId: Chat
    @Published var activeChats: [EventChat] = []
    @Published var messages: [ChatMessage] = []
    @Published var error: String?
    
    private var cleanupTimer: Timer?
    
    init() {
        startCleanupTimer()
    }
    
    // MARK: - Chat Management
    
    func joinEventChat(event: Event, user: User) {
        let chatId = "chat_\(event.id)"
        
        Task { @MainActor in
            if var existingChat = eventChats[chatId] {
                if !existingChat.participants.contains(where: { $0.id == user.id }) {
                    existingChat.participants.append(user)
                    existingChat.lastActivity = Date()
                    existingChat.isActive = true
                    eventChats[chatId] = existingChat
                }
            } else {
                let newChat = EventChat(
                    id: chatId,
                    eventId: event.id,
                    participants: [user],
                    messages: [],
                    createdAt: Date(),
                    lastActivity: Date(),
                    isActive: true
                )
                eventChats[chatId] = newChat
            }
            
            updateActiveChats()
        }
    }
    
    func leaveEventChat(event: Event, user: User) {
        let chatId = "chat_\(event.id)"
        
        Task { @MainActor in
            if var chat = eventChats[chatId] {
                chat.participants.removeAll { $0.id == user.id }
                chat.lastActivity = Date()
                
                // Проверяем, пуст ли чат и уничтожаем его если да
                if chat.participants.isEmpty {
                    eventChats.removeValue(forKey: chatId)
                } else {
                    eventChats[chatId] = chat
                }
                
                updateActiveChats()
            }
        }
    }
    
    // MARK: - Message Management
    
    func connectToEvent(_ eventId: String) {
        print("Connected to event chat: \(eventId)")
    }
    
    func disconnect() {
        print("Disconnected from chats")
    }
    
    func sendMessage(_ text: String, for eventId: String, user: User) -> Bool {
        guard moderateMessage(text) else {
            error = "Сообщение не прошло модерацию"
            return false
        }
        
        let chatId = "chat_\(eventId)"
        guard var chat = eventChats[chatId] else {
            error = "Чат не найден"
            return false
        }
        
        // ИСПРАВЛЕНО: используем правильный инициализатор ChatMessage
        let newMessage = ChatMessage(
            eventId: eventId,
            userId: user.id,
            userDisplayName: user.name,
            text: text
        )
        
        chat.messages.append(newMessage)
        chat.lastActivity = Date()
        eventChats[chatId] = chat
        
        Task { @MainActor in
            updateActiveChats()
            messages = getAllMessages()
        }
        
        return true
    }
    
    func getChat(for event: Event) -> EventChat? {
        let chatId = "chat_\(event.id)"
        return eventChats[chatId]
    }
    
    func clearError() {
        error = nil
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func updateActiveChats() {
        activeChats = Array(eventChats.values)
            .filter { $0.isActive && !$0.isEmpty }
            .sorted { $0.lastActivity > $1.lastActivity }
    }
    
    private func getAllMessages() -> [ChatMessage] {
        return activeChats.flatMap { $0.messages }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    private func startCleanupTimer() {
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.cleanupEmptyChats()
        }
    }
    
    private func cleanupEmptyChats() {
        Task { @MainActor in
            let emptyChats = eventChats.filter { $0.value.isEmpty }
            for chatId in emptyChats.keys {
                eventChats.removeValue(forKey: chatId)
            }
            updateActiveChats()
        }
    }
    
    private func moderateMessage(_ text: String) -> Bool {
        let bannedWords = ["оскорбление", "спам", "реклама"]
        let lowercasedText = text.lowercased()
        
        guard text.count <= 500 else { return false }
        guard !text.isEmpty else { return false }
        
        for word in bannedWords {
            if lowercasedText.contains(word) {
                return false
            }
        }
        
        return true
    }
    
    deinit {
        cleanupTimer?.invalidate()
    }
}
