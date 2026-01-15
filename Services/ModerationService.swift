import Foundation

class ModerationService {
    private let bannedWords = [
        "оскорбление1", "оскорбление2", "спам", "реклама", "мошенник"
    ] // В реальном приложении этот список будет больше и храниться на сервере
    
    private let suspiciousPatterns = [
        try! NSRegularExpression(pattern: "http[s]?://", options: .caseInsensitive),
        try! NSRegularExpression(pattern: "\\d{10,}", options: .caseInsensitive) // Длинные цифровые последовательности
    ]
    
    func moderateMessage(_ text: String) -> Bool {
        let lowercasedText = text.lowercased()
        
        // Проверка на запрещенные слова
        for word in bannedWords {
            if lowercasedText.contains(word) {
                return false
            }
        }
        
        // Проверка на подозрительные паттерны
        for pattern in suspiciousPatterns {
            let range = NSRange(location: 0, length: text.utf16.count)
            if pattern.firstMatch(in: text, options: [], range: range) != nil {
                return false
            }
        }
        
        // Проверка длины сообщения
        if text.count > 500 {
            return false
        }
        
        // Проверка на повторяющиеся символы (возможный спам)
        if hasRepeatingCharacters(text) {
            return false
        }
        
        return true
    }
    
    private func hasRepeatingCharacters(_ text: String) -> Bool {
        let repeatingPatterns = ["!!!", "???", "...", "000", "111"]
        return repeatingPatterns.contains { text.contains($0) }
    }
    
    // AI-модерация (в реальном приложении здесь будет вызов ML модели)
    func moderateWithAI(_ text: String, completion: @escaping (Bool) -> Void) {
        // Эмуляция AI-модерации
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            // Простая эвристика для демо
            let toxicWords = ["ненависть", "угроза", "экстремизм"]
            let isToxic = toxicWords.contains { text.lowercased().contains($0) }
            completion(!isToxic)
        }
    }
}
