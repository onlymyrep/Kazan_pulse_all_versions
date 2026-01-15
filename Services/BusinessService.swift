import Foundation
import MapKit

class BusinessService {
    
    // Временно используем мок данные вместо реального API 2ГИС
    func fetchMockBusinesses() async throws -> [Event] {
        // Имитация сетевого запроса
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
        
        return [
            Event(
                id: UUID().uuidString,
                title: "Барбершоп 'Old Boy'",
                description: "Мужская парикмахерская премиум-класса. Стрижки, бритье, уход за бородой.",
                date: Date().addingTimeInterval(86400 * 365),
                location: EventLocation(
                    address: "ул. Баумана, 35",
                    coordinate: CLLocationCoordinate2D(latitude: 55.794, longitude: 49.111)
                ),
                category: .other,
                price: "от 1200 руб",
                organizer: "Old Boy Network",
                isBusiness: true,
                businessCategory: .barbershop,
                businessHours: "10:00–22:00",
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
                description: "Уютная кофейня с домашней атмосферой. Свежая выпечка, авторский кофе.",
                date: Date().addingTimeInterval(86400 * 365),
                location: EventLocation(
                    address: "ул. Кремлевская, 15",
                    coordinate: CLLocationCoordinate2D(latitude: 55.791, longitude: 49.122)
                ),
                category: .food,
                price: "от 150 руб",
                organizer: "Кофейня Уют",
                isBusiness: true,
                businessCategory: .cafe,
                businessHours: "08:00–23:00",
                rating: 4.7,
                reviewCount: 156,
                contactInfo: "+7 (843) 245-67-89",
                accessibility: .wheelchairAccessible,
                chatRoomId: "business_cozy_cafe",
                imageUrl: nil,
                source: .twoGis
            )
        ]
    }
}
