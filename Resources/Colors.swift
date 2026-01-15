import SwiftUI

extension Color {
    // Основные цвета приложения
    static let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let cardBackground = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let elevatedCard = Color(red: 0.2, green: 0.2, blue: 0.2) // Добавьте этот цвет
    static let primaryText = Color.white
    static let secondaryText = Color.gray
    
    // Неоновая палитра
    static let neonBlue = Color(red: 0.0, green: 0.8, blue: 1.0)
    static let neonPink = Color(red: 1.0, green: 0.2, blue: 0.8)
    static let neonPurple = Color(red: 0.6, green: 0.2, blue: 1.0)
    static let neonGreen = Color(red: 0.2, green: 1.0, blue: 0.4)
    
    // Дополнительные цвета
    static let successGreen = Color.green
    static let warningOrange = Color.orange
    static let errorRed = Color.red
}