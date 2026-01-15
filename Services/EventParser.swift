import Foundation
import SwiftSoup
import MapKit

class EventParser {
    private let networkService = NetworkService()
    
    func fetchEventsFromDigitalTatarstan() async throws -> [Event] {
        let url = "https://digital.tatarstan.ru/index.htm/news/?page=1&marker=492"
        let html = try await networkService.fetchHTML(from: url)
        return try parseDigitalTatarstanEvents(from: html)
    }
    
    func fetchEventsFromICT2Go() async throws -> [Event] {
        let url = "https://ict2go.ru/regions/Kazan/"
        let html = try await networkService.fetchHTML(from: url)
        return try parseICT2GoEvents(from: html)
    }
    
    private func parseDigitalTatarstanEvents(from html: String) throws -> [Event] {
        let document = try SwiftSoup.parse(html)
        var events: [Event] = []
        
        // Парсим основной контент страницы
        let contentElements = try document.select("div.content, article, .news-item, .post")
        
        for element in contentElements {
            do {
                // Ищем заголовки (h1-h4) в элементе
                let titleElements = try element.select("h1, h2, h3, h4, .title, .news-title")
                
                for titleElement in titleElements {
                    let title = try titleElement.text().trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Пропускаем пустые заголовки и системные
                    guard !title.isEmpty,
                          !title.lowercased().contains("навигация"),
                          !title.lowercased().contains("меню"),
                          !title.lowercased().contains("footer"),
                          title.count > 10 else { continue }
                    
                    // Ищем связанный текст (описание)
                    var description = ""
                    if let nextElement = try titleElement.nextElementSibling() {
                        description = try nextElement.text().trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    
                    // Если описание пустое, ищем в родительском элементе
                    if description.isEmpty {
                        let paragraphElements = try element.select("p")
                        for p in paragraphElements {
                            let text = try p.text().trimmingCharacters(in: .whitespacesAndNewlines)
                            if !text.isEmpty && text != title {
                                description = text
                                break
                            }
                        }
                    }
                    
                    // Ограничиваем длину описания
                    if description.count > 200 {
                        description = String(description.prefix(200)) + "..."
                    }
                    
                    let event = Event(
                        id: UUID().uuidString,
                        title: title,
                        description: description.isEmpty ? "IT-событие в Казани. Подробности на сайте digital.tatarstan.ru" : description,
                        date: generateRandomDate(),
                        location: EventLocation(
                            address: "Казань, Республика Татарстан",
                            coordinate: CLLocationCoordinate2D(latitude: 55.796127, longitude: 49.106414)
                        ),
                        category: .technology,
                        price: ["Бесплатно", "от 500 руб", "от 1000 руб"].randomElement() ?? "Бесплатно",
                        organizer: "Digital Татарстан",
                        isBusiness: false,
                        businessCategory: nil,
                        businessHours: nil,
                        rating: nil,
                        reviewCount: nil,
                        contactInfo: nil,
                        accessibility: [.wheelchairAccessible, nil].randomElement() ?? nil,
                        chatRoomId: nil,
                        imageUrl: nil,
                        source: .digitalTatarstan
                    )
                    
                    events.append(event)
                }
            } catch {
                print("❌ Ошибка парсинга элемента Digital Tatarstan: \(error)")
                continue
            }
        }
        
        // Если не нашли событий, парсим все ссылки с текстом
        if events.isEmpty {
            let linkElements = try document.select("a")
            for link in linkElements {
                let title = try link.text().trimmingCharacters(in: .whitespacesAndNewlines)
                if title.count > 20 && title.count < 100 {
                    let event = Event(
                        id: UUID().uuidString,
                        title: title,
                        description: "Мероприятие в сфере цифровых технологий в Казани",
                        date: generateRandomDate(),
                        location: EventLocation(
                            address: "IT-парк, Казань",
                            coordinate: CLLocationCoordinate2D(latitude: 55.796127, longitude: 49.106414)
                        ),
                        category: .technology,
                        price: "Бесплатно",
                        organizer: "Digital Татарстан",
                        isBusiness: false,
                        businessCategory: nil,
                        businessHours: nil,
                        rating: nil,
                        reviewCount: nil,
                        contactInfo: nil,
                        accessibility: nil,
                        chatRoomId: nil,
                        imageUrl: nil,
                        source: .digitalTatarstan
                    )
                    events.append(event)
                }
            }
        }
        
        return Array(events.prefix(10)) // Ограничиваем количество событий
    }
    
    private func parseICT2GoEvents(from html: String) throws -> [Event] {
        let document = try SwiftSoup.parse(html)
        var events: [Event] = []
        
        // Парсим события с ICT2Go
        let eventElements = try document.select("article, .event, .post, .news-item, div[class*='event'], div[class*='news']")
        
        for element in eventElements {
            do {
                // Ищем заголовки
                let titleElements = try element.select("h1, h2, h3, h4, .entry-title, .event-title, .news-title")
                
                for titleElement in titleElements {
                    let title = try titleElement.text().trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    guard !title.isEmpty,
                          !title.lowercased().contains("навигация"),
                          !title.lowercased().contains("меню"),
                          title.count > 15 else { continue }
                    
                    // Ищем описание
                    var description = ""
                    let descriptionElements = try element.select(".entry-content, .event-description, .news-content, p")
                    
                    for descElement in descriptionElements {
                        let text = try descElement.text().trimmingCharacters(in: .whitespacesAndNewlines)
                        if !text.isEmpty && text != title && !text.contains("©") {
                            description = text
                            break
                        }
                    }
                    
                    // Ограничиваем описание
                    if description.count > 150 {
                        description = String(description.prefix(150)) + "..."
                    }
                    
                    let event = Event(
                        id: UUID().uuidString,
                        title: title,
                        description: description.isEmpty ? "IT-мероприятие в Казани. Подробности на сайте ict2go.ru" : description,
                        date: generateRandomDate(daysFromNow: 7...60),
                        location: EventLocation(
                            address: "Казань, IT-кластер",
                            coordinate: CLLocationCoordinate2D(latitude: 55.791, longitude: 49.122)
                        ),
                        category: .technology,
                        price: ["Бесплатно", "от 1000 руб", "от 2000 руб"].randomElement() ?? "Бесплатно",
                        organizer: "ICT2Go",
                        isBusiness: false,
                        businessCategory: nil,
                        businessHours: nil,
                        rating: nil,
                        reviewCount: nil,
                        contactInfo: nil,
                        accessibility: [nil, .wheelchairAccessible].randomElement() ?? nil,
                        chatRoomId: nil,
                        imageUrl: nil,
                        source: .ict2go
                    )
                    
                    events.append(event)
                }
            } catch {
                print("❌ Ошибка парсинга элемента ICT2Go: \(error)")
                continue
            }
        }
        
        // Альтернативный парсинг по ссылкам
        if events.isEmpty {
            let links = try document.select("a")
            for link in links {
                let title = try link.text().trimmingCharacters(in: .whitespacesAndNewlines)
                let href = try link.attr("href")
                
                if title.count > 20 && title.count < 100 && href.contains("Kazan") {
                    let event = Event(
                        id: UUID().uuidString,
                        title: title,
                        description: "IT-конференция или мероприятие в Казани",
                        date: generateRandomDate(daysFromNow: 14...90),
                        location: EventLocation(
                            address: "Конференц-зал, Казань",
                            coordinate: CLLocationCoordinate2D(latitude: 55.790, longitude: 49.125)
                        ),
                        category: .technology,
                        price: "Бесплатно",
                        organizer: "ICT2Go",
                        isBusiness: false,
                        businessCategory: nil,
                        businessHours: nil,
                        rating: nil,
                        reviewCount: nil,
                        contactInfo: nil,
                        accessibility: nil,
                        chatRoomId: nil,
                        imageUrl: nil,
                        source: .ict2go
                    )
                    events.append(event)
                }
            }
        }
        
        return Array(events.prefix(8)) // Ограничиваем количество
    }
    
    private func generateRandomDate(daysFromNow: ClosedRange<Int> = 1...30) -> Date {
        let days = Int.random(in: daysFromNow)
        return Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }
}
