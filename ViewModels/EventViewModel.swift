import Foundation
import SwiftUI

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var businesses: [Event] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let eventParser = EventParser()
    private let businessService = BusinessService()
    
    @MainActor
    func fetchAllEvents() async {
        isLoading = true
        error = nil
        
        do {
            // Загружаем события с обоих источников параллельно
            async let digitalEvents = eventParser.fetchEventsFromDigitalTatarstan()
            async let ictEvents = eventParser.fetchEventsFromICT2Go()
            
            let (digitalEventsResult, ictEventsResult) = try await (digitalEvents, ictEvents)
            
            // Объединяем и перемешиваем события
            self.events = (digitalEventsResult + ictEventsResult).shuffled()
            
            // Загружаем бизнесы
            await fetchBusinesses()
            
            print("✅ Загружено событий: \(self.events.count)")
            print("✅ Загружено бизнесов: \(self.businesses.count)")
            
        } catch {
            self.error = "Ошибка загрузки событий: \(error.localizedDescription)"
            print("❌ Ошибка загрузки: \(error)")
        }
        
        isLoading = false
    }
    
    @MainActor
    func fetchBusinesses() async {
        do {
            let businessEvents = try await businessService.fetchMockBusinesses()
            self.businesses = businessEvents
        } catch {
            self.error = "Ошибка загрузки бизнесов: \(error.localizedDescription)"
        }
    }
    
    // Функция для создания чата при нажатии "Пойду"
    func joinEvent(_ eventId: String, userId: String) -> String? {
        guard let eventIndex = events.firstIndex(where: { $0.id == eventId }) else {
            return nil
        }
        
        // Создаем chatRoomId если его нет
        if events[eventIndex].chatRoomId == nil {
            let chatRoomId = "event_\(eventId)_\(UUID().uuidString.prefix(8))"
            
            // Создаем копию события с обновленным chatRoomId
            var updatedEvent = events[eventIndex]
            updatedEvent.chatRoomId = chatRoomId
            events[eventIndex] = updatedEvent
            
            print("✅ Создан чат для события '\(updatedEvent.title)': \(chatRoomId)")
            return chatRoomId
        }
        
        return events[eventIndex].chatRoomId
    }
}
