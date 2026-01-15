import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var email: String?
    var profileImageURL: String?
    var favoriteEvents: [String]
    var joinedEvents: [String] // Добавляем события, куда пользователь идет
    var interests: [EventCategory] // Добавляем интересы для рекомендаций
    var isStudent: Bool
    var createdAt: Date
    var lastActive: Date
    
    // Вычисляемое свойство для инициалов
    var initials: String {
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.prefix(1) ?? ""
        let lastInitial = components.count > 1 ? components.last?.prefix(1) ?? "" : ""
        return String(firstInitial + lastInitial).uppercased()
    }
    
    // Вычисляемое свойство для проверки наличия изображения профиля
    var hasProfileImage: Bool {
        return profileImageURL != nil
    }
    
    // Вычисляемое свойство для получения URL изображения профиля
    var profileImageURLValue: URL? {
        guard let urlString = profileImageURL else { return nil }
        return URL(string: urlString)
    }
    
    init(id: String, name: String, email: String? = nil, profileImageURL: String? = nil,
         favoriteEvents: [String] = [], joinedEvents: [String] = [],
         interests: [EventCategory] = [], isStudent: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageURL = profileImageURL
        self.favoriteEvents = favoriteEvents
        self.joinedEvents = joinedEvents
        self.interests = interests
        self.isStudent = isStudent
        self.createdAt = Date()
        self.lastActive = Date()
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

// Добавьте в Models/User.swift
extension User {
    // Проверка, интересуется ли пользователь категорией
    func isInterestedIn(_ category: EventCategory) -> Bool {
        return interests.contains(category)
    }
    
    // Добавление интереса
    mutating func addInterest(_ category: EventCategory) {
        if !interests.contains(category) {
            interests.append(category)
        }
    }
    
    // Удаление интереса
    mutating func removeInterest(_ category: EventCategory) {
        interests.removeAll { $0 == category }
    }
    
    // Обновление времени последней активности
    mutating func updateLastActive() {
        lastActive = Date()
    }
}
