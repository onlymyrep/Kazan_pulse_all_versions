import Foundation
import Combine


class RecommendationService {
    private let eventStore: EventStore
    
    init(eventStore: EventStore) {
        self.eventStore = eventStore
    }
    
    func recommendEvents(for user: User, from events: [Event]) -> [Event] {
        // Если у пользователя нет интересов, возвращаем популярные события
        guard !user.interests.isEmpty else {
            return getPopularEvents(from: events)
        }
        
        // Логика рекомендаций на основе категорий интересов
        let recommendedEvents = events.filter { event in
            // Проверяем совпадение категории события с интересами пользователя
            user.interests.contains(event.category)
        }
        
        // Сортируем по рейтингу и дате
        return recommendedEvents.sorted {
            // Сначала по рейтингу (если есть)
            let rating1 = $0.rating ?? 0
            let rating2 = $1.rating ?? 0
            if rating1 != rating2 {
                return rating1 > rating2
            }
            // Затем по дате (ближайшие первыми)
            return $0.date < $1.date
        }
    }
    
    // Рекомендации для бизнесов на основе интересов пользователя
    func recommendBusinesses(for user: User, from businesses: [Event]) -> [Event] {
        // Для бизнесов используем популярные, так как нет прямой связи с EventCategory
        return getPopularBusinesses(from: businesses)
    }
    
    // Получить популярные события (высокий рейтинг, бесплатные, ближайшие)
    private func getPopularEvents(from events: [Event]) -> [Event] {
        return events
            .filter {
                // Бесплатные события или с высоким рейтингом
                $0.isFree || ($0.rating ?? 0) > 4.0
            }
            .sorted {
                // Сначала бесплатные, затем по рейтингу, затем по дате
                if $0.isFree != $1.isFree {
                    return $0.isFree
                }
                
                let rating1 = $0.rating ?? 0
                let rating2 = $1.rating ?? 0
                if rating1 != rating2 {
                    return rating1 > rating2
                }
                
                return $0.date < $1.date
            }
    }
    
    // Получить популярные бизнесы (высокий рейтинг, много отзывов)
    private func getPopularBusinesses(from businesses: [Event]) -> [Event] {
        return businesses
            .filter {
                ($0.rating ?? 0) > 4.0 &&
                ($0.reviewCount ?? 0) > 10
            }
            .sorted {
                let rating1 = $0.rating ?? 0
                let rating2 = $1.rating ?? 0
                if rating1 != rating2 {
                    return rating1 > rating2
                }
                return ($0.reviewCount ?? 0) > ($1.reviewCount ?? 0)
            }
    }
    
    // Рекомендации на основе местоположения (ближайшие события)
    func recommendNearbyEvents(for user: User, from events: [Event], userLocation: EventLocation) -> [Event] {
        return events
            .sorted {
                distanceBetween($0.location, userLocation) <
                distanceBetween($1.location, userLocation)
            }
            .prefix(10)
            .map { $0 }
    }
    
    // Рекомендации на основе местоположения (ближайшие бизнесы)
    func recommendNearbyBusinesses(for user: User, from businesses: [Event], userLocation: EventLocation) -> [Event] {
        return businesses
            .sorted {
                distanceBetween($0.location, userLocation) <
                distanceBetween($1.location, userLocation)
            }
            .prefix(10)
            .map { $0 }
    }
    
 
    
    // Вспомогательная функция для расчета расстояния
    private func distanceBetween(_ location1: EventLocation, _ location2: EventLocation) -> Double {
        let coord1 = location1.coordinate
        let coord2 = location2.coordinate
        
        // Упрощенный расчет расстояния
        let latDiff = coord1.latitude - coord2.latitude
        let lonDiff = coord1.longitude - coord2.longitude
        return sqrt(latDiff * latDiff + lonDiff * lonDiff)
    }
    
    // Обновление интересов пользователя на основе его активности
    func updateUserInterests(user: inout User, basedOn events: [Event]) {
        var categoryCount: [EventCategory: Int] = [:]
        
        // Анализируем избранные события и события, куда пользователь идет
        let userEvents = events.filter { event in
            user.favoriteEvents.contains(event.id) || user.joinedEvents.contains(event.id)
        }
        
        // Считаем частоту категорий
        for event in userEvents {
            categoryCount[event.category, default: 0] += 1
        }
        
        // Обновляем интересы - берем топ-3 самые частые категории
        let topCategories = categoryCount
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
        
        if !topCategories.isEmpty {
            user.interests = topCategories
        }
    }
}
