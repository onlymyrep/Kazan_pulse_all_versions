import Foundation
import Combine

class FavoriteManager: ObservableObject {
    @Published var favoriteEvents: [Event] = []
    @Published var goingEvents: [Event] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadFromUserDefaults()
    }
    
    // MARK: - Favorite Management
    
    func toggleFavorite(event: Event) {
        if isFavorite(event: event) {
            favoriteEvents.removeAll { $0.id == event.id }
        } else {
            favoriteEvents.append(event)
        }
        saveToUserDefaults()
    }
    
    func isFavorite(event: Event) -> Bool {
        favoriteEvents.contains { $0.id == event.id }
    }
    
    // MARK: - Going Events Management
    
    func addToGoingEvents(_ event: Event) {
        if !isGoing(event: event) {
            goingEvents.append(event)
            saveToUserDefaults()
        }
    }
    
    func removeFromGoingEvents(_ event: Event) {
        goingEvents.removeAll { $0.id == event.id }
        saveToUserDefaults()
    }
    
    func isGoing(event: Event) -> Bool {
        goingEvents.contains { $0.id == event.id }
    }
    
    // MARK: - Persistence
    
    private func saveToUserDefaults() {
        let favoriteIds = favoriteEvents.map { $0.id }
        let goingIds = goingEvents.map { $0.id }
        
        UserDefaults.standard.set(favoriteIds, forKey: "favoriteEvents")
        UserDefaults.standard.set(goingIds, forKey: "goingEvents")
    }
    
    // Исправьте метод loadFromUserDefaults:
    func loadFromUserDefaults() {
        let favoriteIds = UserDefaults.standard.stringArray(forKey: "favoriteEvents") ?? []
        let goingIds = UserDefaults.standard.stringArray(forKey: "goingEvents") ?? []
        
        // Пока оставляем пустыми, будут заполняться при загрузке событий
        favoriteEvents = []
        goingEvents = []
    }
    
    // Обновить события из eventStore
    func updateEvents(from eventStore: EventStore) {
        let favoriteIds = favoriteEvents.map { $0.id }
        let goingIds = goingEvents.map { $0.id }
        
        favoriteEvents = eventStore.events.filter { favoriteIds.contains($0.id) }
        goingEvents = eventStore.events.filter { goingIds.contains($0.id) }
    }
}