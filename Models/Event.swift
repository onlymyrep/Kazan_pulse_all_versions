import Foundation
import CoreLocation

struct Event: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let date: Date
    let location: EventLocation
    let category: EventCategory
    let price: String
    let organizer: String
    let isBusiness: Bool
    let businessCategory: BusinessCategory?
    let businessHours: String?
    let rating: Double?
    let reviewCount: Int?
    let contactInfo: String?
    let accessibility: AccessibilityOption?
    var chatRoomId: String? // Изменено на var
    let imageUrl: String?
    let source: EventSource?
    var maxParticipants: Int?
    var participantIds: [String] = []
    
    // Вычисляемое свойство для проверки заполненности
    var isFull: Bool {
        guard let max = maxParticipants else { return false }
        return participantIds.count >= max
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    var timeUntilEvent: String {
        let components = Calendar.current.dateComponents([.day, .hour], from: Date(), to: date)
        if let days = components.day, days > 0 {
            return "Через \(days) дн."
        } else if let hours = components.hour, hours > 0 {
            return "Через \(hours) ч"
        }
        return "Скоро"
    }
    
    var isFree: Bool {
        price.lowercased().contains("бесплатно") || price == "0"
    }
}

struct EventLocation: Codable {
    let address: String
    let coordinate: CLLocationCoordinate2D
    
    enum CodingKeys: String, CodingKey {
        case address
        case latitude
        case longitude
    }
    
    init(address: String, coordinate: CLLocationCoordinate2D) {
        self.address = address
        self.coordinate = coordinate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}

enum EventSource: String, Codable {
    case digitalTatarstan = "digital.tatarstan.ru"
    case ict2go = "ict2go.ru"
    case yandexAfisha = "yandex_afisha"
    case twoGis = "2gis"
}

enum OfferType {
    case yandexEvent
    case localBusiness
}

// Добавьте computed property в структуру Event
extension Event {
    var offerType: OfferType {
        return isBusiness ? .localBusiness : .yandexEvent
    }
}
