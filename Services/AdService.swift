import Foundation
import Combine

class AdService: ObservableObject {
    @Published var promotedEvents: [Event] = []
    @Published var businessAds: [Event] = []
    
    private let eventViewModel: EventViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(eventViewModel: EventViewModel) {
        self.eventViewModel = eventViewModel
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        eventViewModel.$events
            .combineLatest(eventViewModel.$businesses)
            .sink { [weak self] events, businesses in
                self?.loadPromotedContent(events: events, businesses: businesses)
            }
            .store(in: &cancellables)
    }
    
    func loadPromotedContent(events: [Event], businesses: [Event]) {
        // Используем рейтинг и популярность для выделенных событий
        promotedEvents = events
            .filter {
                // Выбираем события с высоким рейтингом или бесплатные
                ($0.rating ?? 0) > 4.5 || $0.isFree
            }
            .prefix(3)
            .map { $0 }
        
        // Бизнес-реклама - это все бизнесы с хорошим рейтингом
        businessAds = businesses
            .filter { ($0.rating ?? 0) > 4.0 }
            .prefix(5)
            .map { $0 }
        
        print("✅ Загружено промо-событий: \(promotedEvents.count)")
        print("✅ Загружено бизнес-рекламы: \(businessAds.count)")
    }
    
    // Создание бизнес-рекламы - совместимая версия
    func createBusinessAd(
        businessName: String,
        description: String,
        category: BusinessCategory,
        location: EventLocation,
        price: String = "от 500 руб",
        contactInfo: String? = nil,
        rating: Double = 4.5
    ) -> Event {
        
        let newAd = Event(
            id: UUID().uuidString,
            title: businessName,
            description: description,
            date: Date().addingTimeInterval(86400 * 365), // Дата далеко в будущем для бизнесов
            location: location,
            category: .other, // Категория по умолчанию для бизнесов
            price: price,
            organizer: businessName,
            isBusiness: true,
            businessCategory: category,
            businessHours: "10:00-22:00",
            rating: rating,
            reviewCount: Int.random(in: 10...100),
            contactInfo: contactInfo,
            accessibility: [.wheelchairAccessible, nil].randomElement() ?? nil,
            chatRoomId: "business_\(UUID().uuidString)",
            imageUrl: nil,
            source: .twoGis
        )
        
        // Добавляем в список бизнес-рекламы
        businessAds.append(newAd)
        
        return newAd
    }
    
    // Очистка устаревшей рекламы
    func cleanupExpiredAds() {
        let now = Date()
        promotedEvents.removeAll { event in
            if event.isBusiness {
                return false // Бизнесы не имеют срока
            } else {
                return event.date < now
            }
        }
    }
    
    // Получить все активные рекламные кампании
    var activeCampaigns: [Event] {
        let now = Date()
        return promotedEvents.filter { event in
            if event.isBusiness {
                return true
            } else {
                return event.date > now
            }
        }
    }
    
    // Получить рекламу по категории бизнеса
    func getAdsForCategory(_ category: BusinessCategory) -> [Event] {
        return businessAds.filter { event in
            event.businessCategory == category
        }
    }
    
    // Получить рекламу по категории событий
    func getAdsForEventCategory(_ category: EventCategory) -> [Event] {
        return promotedEvents.filter { event in
            !event.isBusiness && event.category == category
        }
    }
    
    // Получить случайные промо-события
    func getRandomPromotedEvents(count: Int = 3) -> [Event] {
        return Array(promotedEvents.shuffled().prefix(count))
    }
    
    // Получить топ бизнесы по рейтингу
    func getTopRatedBusinesses(limit: Int = 5) -> [Event] {
        return businessAds
            .sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
            .prefix(limit)
            .map { $0 }
    }
}
