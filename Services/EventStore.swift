import Foundation
import Combine
import CoreLocation

class EventStore: ObservableObject {
    @Published var events: [Event] = []
    @Published var businesses: [Event] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService()
    private let parsingService: EventParsingService
    
    init() {
        self.parsingService = EventParsingService(networkService: networkService)
        loadMockEvents()
    }
    
    func loadEvents() {
        isLoading = true
        error = nil
        
        // Используем моковые данные для MVP
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.loadMockEvents()
        }
    }
    
    
    func addParticipant(to eventId: String, userId: String) async -> Bool {
        await MainActor.run {
            if let index = events.firstIndex(where: { $0.id == eventId }) {
                // Проверяем максимальное количество участников
                if let maxParticipants = events[index].maxParticipants,
                   events[index].participantIds.count >= maxParticipants {
                    return false
                }
                
                // Добавляем пользователя если есть место
                if !events[index].participantIds.contains(userId) {
                    events[index].participantIds.append(userId)
                }
                return true
            }
            return false
        }
    }

    func removeParticipant(from eventId: String, userId: String) async -> Bool {
        await MainActor.run {
            if let index = events.firstIndex(where: { $0.id == eventId }) {
                events[index].participantIds.removeAll { $0 == userId }
                return true
            }
            return false
        }
    }
    
    private func loadMockEvents() {
        let mockEvents = [
            // События с Яндекс Афиши
            Event(
                id: "1",
                title: "Kazan Digital Week 2024",
                description: "Крупнейшая IT-конференция в Поволжье с участием ведущих экспертов в области технологий и цифровой трансформации.",
                date: Date().addingTimeInterval(86400),
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
                id: "2",
                title: "Концерт татарской музыки",
                description: "Вечер традиционной татарской музыки в исполнении симфонического оркестра Татарстана.",
                date: Date().addingTimeInterval(172800),
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
            
            // Местные бизнесы
            Event(
                id: "b1",
                title: "Барбершоп 'Old Boy'",
                description: "Мужская парикмахерская премиум-класса. Стрижки, бритье, уход за бородой.",
                date: Date().addingTimeInterval(86400 * 365), // Дата далеко в будущем для бизнесов
                location: EventLocation(
                    address: "ул. Баумана, 35",
                    coordinate: CLLocationCoordinate2D(latitude: 55.787391, longitude: 49.123456)
                ),
                category: .other,
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
                id: "b2",
                title: "Кофейня 'Уют'",
                description: "Уютная кофейня с домашней атмосферой. Свежая выпечка, авторский кофе.",
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
        
        self.events = mockEvents.filter { !$0.isBusiness }
        self.businesses = mockEvents.filter { $0.isBusiness }
        
        print("✅ Загружено событий: \(events.count)")
        print("✅ Загружено бизнесов: \(businesses.count)")
    }
    
    private func loadParsedEvents() async {
        do {
            let parsedEvents = await parsingService.parseEventsFromMultipleSources()
            await MainActor.run {
                self.events = parsedEvents.filter { !$0.isBusiness }
                self.businesses = parsedEvents.filter { $0.isBusiness }
                self.isLoading = false
            }
        }
    }
    
    // Получить все события и бизнесы вместе
    var allItems: [Event] {
        return events + businesses
    }
    
    // Получить события по категории
    func getEventsByCategory(_ category: EventCategory) -> [Event] {
        return events.filter { $0.category == category }
    }
    
    // Получить бизнесы по категории
    func getBusinessesByCategory(_ category: BusinessCategory) -> [Event] {
        return businesses.filter { $0.businessCategory == category }
    }
    
    // Поиск по всем элементам
    func searchItems(query: String) -> [Event] {
        let searchQuery = query.lowercased()
        return allItems.filter { event in
            event.title.lowercased().contains(searchQuery) ||
            event.description.lowercased().contains(searchQuery) ||
            event.location.address.lowercased().contains(searchQuery) ||
            event.organizer.lowercased().contains(searchQuery)
        }
    }
}

// Добавьте это расширение для удобства
extension Event {
    var isPromoted: Bool {
        // События с высоким рейтингом считаем промо
        return (rating ?? 0) > 4.5
    }
}

// В EventStore.swift добавьте:
extension EventStore {
    func refreshRecommendations(for user: User) -> [Event] {
        let recommendationService = RecommendationService(eventStore: self)
        return recommendationService.recommendEvents(for: user, from: events)
    }
    
    func refreshBusinessRecommendations(for user: User) -> [Event] {
        let recommendationService = RecommendationService(eventStore: self)
        return recommendationService.recommendBusinesses(for: user, from: businesses)
    }
    
    func getNearbyRecommendations(for user: User, userLocation: EventLocation) -> [Event] {
        let recommendationService = RecommendationService(eventStore: self)
        return recommendationService.recommendNearbyEvents(for: user, from: events, userLocation: userLocation)
    }
}
