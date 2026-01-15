import Foundation
import UIKit
import CoreLocation
import MapKit

class NavigationService: ObservableObject {
    
    func openNavigationToEvent(_ event: Event) {
        let location = event.location
        
        // Сначала пробуем Яндекс Карты
        if let url = location.yandexMapsURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        
        // Затем 2ГИС
        if let url = location.twoGisURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        
        // Fallback: Apple Maps
        if let url = location.appleMapsURL {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func getNavigationOptions(for location: EventLocation) -> [NavigationApp] {
        var options: [NavigationApp] = []
        
        // Яндекс Карты
        if let url = location.yandexMapsURL, UIApplication.shared.canOpenURL(url) {
            options.append(NavigationApp(name: "Яндекс Карты", type: .yandex))
        }
        
        // 2ГИС
        if let url = location.twoGisURL, UIApplication.shared.canOpenURL(url) {
            options.append(NavigationApp(name: "2GIS", type: .dgis))
        }
        
        // Apple Maps как запасной вариант
        options.append(NavigationApp(name: "Карты Apple", type: .apple))
        
        return options
    }
}

struct NavigationApp: Identifiable {
    let id = UUID()
    let name: String
    let type: NavigationAppType
}

enum NavigationAppType {
    case yandex
    case dgis
    case apple
}

extension NavigationService {
    func openInYandexMaps(_ location: EventLocation) {
        if let url = location.yandexMapsURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func openIn2GIS(_ location: EventLocation) {
        if let url = location.twoGisURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func openInAppleMaps(_ location: EventLocation) {
        if let url = location.appleMapsURL {
            UIApplication.shared.open(url)
        }
    }
}

// Добавьте это расширение в ваш файл с моделью EventLocation
extension EventLocation {
    var yandexMapsURL: URL? {
        let coordinate = self.coordinate
        let urlString = "yandexmaps://maps.yandex.ru/?pt=\(coordinate.longitude),\(coordinate.latitude)&z=15"
        return URL(string: urlString)
    }
    
    var twoGisURL: URL? {
        let coordinate = self.coordinate
        let urlString = "dgis://2gis.ru/geo/\(coordinate.longitude),\(coordinate.latitude)"
        return URL(string: urlString)
    }
    
    var appleMapsURL: URL? {
        let coordinate = self.coordinate
        let urlString = "http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)&q=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        return URL(string: urlString)
    }
}
