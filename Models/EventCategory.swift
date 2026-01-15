import Foundation

enum EventCategory: String, CaseIterable, Codable {
    case music = "Музыка"
    case sport = "Спорт"
    case art = "Искусство"
    case food = "Еда"
    case education = "Образование"
    case technology = "Технологии"
    case festival = "Фестиваль"
    case exhibition = "Выставка"
    case conference = "Конференция"
    case volunteer = "Волонтерство"
    case other = "Другое"
    
    var icon: String {
        switch self {
        case .music: return "music.note"
        case .sport: return "sportscourt"
        case .art: return "paintpalette"
        case .food: return "fork.knife"
        case .education: return "book"
        case .technology: return "laptopcomputer"
        case .festival: return "party.popper"
        case .exhibition: return "rectangle.3.group"
        case .conference: return "person.3"
        case .volunteer: return "heart"
        case .other: return "mappin"
        }
    }
}

enum BusinessCategory: String, CaseIterable, Codable {
    case cafe = "Кафе"
    case restaurant = "Ресторан"
    case bar = "Бар"
    case barbershop = "Парикмахерская"
    case spa = "Спа"
    case gym = "Фитнес"
    case shop = "Магазин"
    case entertainment = "Развлечения"
    
    var icon: String {
        switch self {
        case .cafe: return "cup.and.saucer"
        case .restaurant: return "fork.knife"
        case .bar: return "wineglass"
        case .barbershop: return "scissors"
        case .spa: return "sparkles"
        case .gym: return "dumbbell"
        case .shop: return "bag"
        case .entertainment: return "gamecontroller"
        }
    }
}

enum AccessibilityOption: String, Codable {
    case wheelchairAccessible = "Доступно для колясок"
    case hearingAssistance = "Помощь для слабослышащих"
    case visualAssistance = "Помощь для слабовидящих"
    
    var icon: String {
        switch self {
        case .wheelchairAccessible: return "figure.roll"
        case .hearingAssistance: return "ear"
        case .visualAssistance: return "eye"
        }
    }
    
    var description: String {
        return self.rawValue
    }
}
