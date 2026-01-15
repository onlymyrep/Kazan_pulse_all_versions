import Foundation

struct EventChat: Identifiable, Codable {
    let id: String
    let eventId: String
    var participants: [User]
    var messages: [ChatMessage]
    let createdAt: Date
    var lastActivity: Date
    var isActive: Bool
    
    // Добавляем вычисляемое свойство isEmpty
    var isEmpty: Bool {
        participants.isEmpty
    }
    
    init(id: String, eventId: String, participants: [User] = [], messages: [ChatMessage] = [],
         createdAt: Date = Date(), lastActivity: Date = Date(), isActive: Bool = true) {
        self.id = id
        self.eventId = eventId
        self.participants = participants
        self.messages = messages
        self.createdAt = createdAt
        self.lastActivity = lastActivity
        self.isActive = isActive
    }
}
