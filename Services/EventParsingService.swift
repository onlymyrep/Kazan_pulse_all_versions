import Foundation
import Combine
import MapKit

class EventParsingService: ObservableObject {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Упрощенный метод для MVP
    func parseEventsFromMultipleSources() async -> [Event] {
        print("🔄 Используем моковые данные для MVP...")
        
        // Возвращаем моковые данные вместо парсинга
        return await generateMockEvents()
    }
    
    private func generateMockEvents() async -> [Event] {
        // Имитируем загрузку
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let mockEvents = [
            // События (isBusiness: false)
            Event(
                id: UUID().uuidString,
                title: "Kazan Digital Week 2024",
                description: "Крупнейшая IT-конференция в Поволжье с участием ведущих экспертов",
                date: Date().addingTimeInterval(86400 * 7),
                location: EventLocation(
                    address: "ул. Петербургская, 52",
                    coordinate: CLLocationCoordinate2D(latitude: 55.796127, longitude: 49.106414)
                ),
                category: .technology,
                price: "Бесплатно",
                organizer: "Мэрия Казани",
                isBusiness: false,
                businessCategory: nil,
                businessHours: nil,
                rating: nil,
                reviewCount: nil,
                contactInfo: "digitalweek@kazan.ru",
                accessibility: .wheelchairAccessible,
                chatRoomId: "chat_1",
                imageUrl: nil,
                source: .yandexAfisha
            ),
            
            Event(
                id: UUID().uuidString,
                title: "Концерт татарской музыки",
                description: "Вечер традиционной татарской музыки в исполнении симфонического оркестра",
                date: Date().addingTimeInterval(86400 * 3),
                location: EventLocation(
                    address: "Кремль, центральная площадь",
                    coordinate: CLLocationCoordinate2D(latitude: 55.798098, longitude: 49.105208)
                ),
                category: .music,
                price: "1000 руб",
                organizer: "Министерство культуры РТ",
                isBusiness: false,
                businessCategory: nil,
                businessHours: nil,
                rating: nil,
                reviewCount: nil,
                contactInfo: "+7 (843) 123-45-67",
                accessibility: .hearingAssistance,
                chatRoomId: "chat_2",
                imageUrl: nil,
                source: .yandexAfisha
            ),
            
            // Бизнесы (isBusiness: true)
            Event(
                id: UUID().uuidString,
                title: "Барбершоп 'Old Boy'",
                description: "Мужская парикмахерская премиум-класса. Стрижки, бритье, уход за бородой",
                date: Date().addingTimeInterval(86400 * 365), // Дата далеко в будущем для бизнесов
                location: EventLocation(
                    address: "ул. Баумана, 35",
                    coordinate: CLLocationCoordinate2D(latitude: 55.787391, longitude: 49.123456)
                ),
                category: .other, // Категория по умолчанию для бизнесов
                price: "от 1200 руб",
                organizer: "Old Boy Network",
                isBusiness: true,
                businessCategory: .barbershop,
                businessHours: "10:00-22:00",
                rating: 4.8,
                reviewCount: 127,
                contactInfo: "+7 (843) 234-56-78",
                accessibility: .wheelchairAccessible,
                chatRoomId: "business_oldboy_chat",
                imageUrl: nil,
                source: .twoGis
            ),
            
            Event(
                id: UUID().uuidString,
                title: "Кофейня 'Уют'",
                description: "Уютная кофейня с домашней атмосферой. Свежая выпечка, авторский кофе",
                date: Date().addingTimeInterval(86400 * 365),
                location: EventLocation(
                    address: "ул. Декабристов, 28",
                    coordinate: CLLocationCoordinate2D(latitude: 55.789012, longitude: 49.128901)
                ),
                category: .food,
                price: "от 150 руб",
                organizer: "Кофейня Уют",
                isBusiness: true,
                businessCategory: .cafe,
                businessHours: "08:00-23:00",
                rating: 4.7,
                reviewCount: 156,
                contactInfo: "+7 (843) 567-89-01",
                accessibility: nil,
                chatRoomId: "business_cozy_cafe",
                imageUrl: nil,
                source: .twoGis
            )
        ]
        
        print("✅ Моковые данные созданы: \(mockEvents.count) событий")
        return mockEvents
    }
}
