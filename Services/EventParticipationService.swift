import Foundation
import Combine

class EventParticipationService: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    
    private let authService: AuthService
    private let eventStore: EventStore
    private let chatService: ChatService
    private let favoriteManager: FavoriteManager
    
    init(authService: AuthService, eventStore: EventStore, chatService: ChatService, favoriteManager: FavoriteManager) {
        self.authService = authService
        self.eventStore = eventStore
        self.chatService = chatService
        self.favoriteManager = favoriteManager
    }
    
    func joinEvent(_ event: Event) async -> Bool {
        guard !isLoading else { return false }
        
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        // 1. Проверка авторизации
        guard let user = authService.currentUser else {
            await MainActor.run {
                error = "Для записи на событие необходимо авторизоваться"
            }
            print("❌ EventParticipationService: User not authenticated")
            return false
        }
        
        print("🔄 EventParticipationService: User \(user.name) trying to join event '\(event.title)'")
        
        // 2. Проверка доступности мест
        if event.isFull {
            await MainActor.run {
                error = "К сожалению, все места заняты"
            }
            print("❌ EventParticipationService: Event is full")
            return false
        }
        
        // 3. Проверка, не прошел ли уже ивент
        if event.date < Date() {
            await MainActor.run {
                error = "Это событие уже прошло"
            }
            print("❌ EventParticipationService: Event has already passed")
            return false
        }
        
        // 4. Добавляем пользователя в список участников
        let success = await eventStore.addParticipant(to: event.id, userId: user.id)
        
        if success {
            await MainActor.run {
                // 5. Добавляем в события "Я иду"
                favoriteManager.addToGoingEvents(event)
                
                // 6. Добавляем в чат события
                chatService.joinEventChat(event: event, user: user)
                
                // 7. Показываем уведомление
                showSuccessNotification(for: event)
            }
            print("✅ EventParticipationService: Successfully joined event '\(event.title)'")
            return true
        }
        
        await MainActor.run {
            error = "Не удалось записаться на событие"
        }
        print("❌ EventParticipationService: Failed to join event")
        return false
    }
    
    func leaveEvent(_ event: Event) async -> Bool {
        guard let user = authService.currentUser else {
            print("❌ EventParticipationService: User not authenticated for leaving event")
            return false
        }
        
        print("🔄 EventParticipationService: User \(user.name) leaving event '\(event.title)'")
        
        let success = await eventStore.removeParticipant(from: event.id, userId: user.id)
        
        if success {
            await MainActor.run {
                // Удаляем из событий "Я иду"
                favoriteManager.removeFromGoingEvents(event)
                
                // Удаляем из чата события
                chatService.leaveEventChat(event: event, user: user)
            }
            print("✅ EventParticipationService: Successfully left event")
            return true
        }
        
        print("❌ EventParticipationService: Failed to leave event")
        return false
    }
    
    func isUserJoined(_ event: Event) -> Bool {
        return favoriteManager.isGoing(event: event)
    }
    
    private func showSuccessNotification(for event: Event) {
        NotificationCenter.default.post(
            name: .eventJoinSuccess,
            object: nil,
            userInfo: ["eventTitle": event.title]
        )
        
        print("✅ EventParticipationService: Success notification for '\(event.title)'")
    }
    
    func clearError() {
        error = nil
    }
}

extension Notification.Name {
    static let eventJoinSuccess = Notification.Name("eventJoinSuccess")
}
