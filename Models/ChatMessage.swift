import Foundation

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: String
    let eventId: String
    let userId: String
    let userDisplayName: String
    let text: String
    let timestamp: Date
    let isModerated: Bool
    let moderationReason: String?
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
    
    var isFromCurrentUser: Bool {
        // В реальном приложении сравнивать с ID текущего пользователя
        return userId == "current_user"
    }
    
    init(
        id: String = UUID().uuidString,
        eventId: String,
        userId: String,
        userDisplayName: String,
        text: String,
        timestamp: Date = Date(),
        isModerated: Bool = false,
        moderationReason: String? = nil
    ) {
        self.id = id
        self.eventId = eventId
        self.userId = userId
        self.userDisplayName = userDisplayName
        self.text = text
        self.timestamp = timestamp
        self.isModerated = isModerated
        self.moderationReason = moderationReason
    }
}
