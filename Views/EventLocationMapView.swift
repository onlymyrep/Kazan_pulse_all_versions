import SwiftUI
import MapKit

struct EventLocationMapView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    private let kazanCenter = CLLocationCoordinate2D(latitude: 55.796127, longitude: 49.106414)
    
    private var eventCoordinate: CLLocationCoordinate2D {
        return coordinateForEvent(event)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                
                Map(position: $cameraPosition) {
                    Annotation(event.title, coordinate: eventCoordinate) {
                        VStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.neonPink)
                                .background(
                                    Circle()
                                        .fill(Color.darkBackground)
                                        .frame(width: 30, height: 30)
                                )
                            
                            Text(event.title)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.darkBackground.opacity(0.9))
                                .cornerRadius(8)
                                .foregroundColor(.primaryText)
                        }
                    }
                }
                .mapStyle(.standard)
                .ignoresSafeArea()
                
                // Информационная панель
                VStack {
                    VStack(alignment: .leading, spacing: 8) {
                        // Исправлено: используем address вместо location
                        Text(event.location.address)
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        Text(event.title)
                            .font(.body)
                            .foregroundColor(.secondaryText)
                        
                        HStack {
                            Image(systemName: getCategoryIcon(event.category))
                                .foregroundColor(getCategoryColor(event.category))
                            
                            Text(event.category.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondaryText)
                            
                            Spacer()
                            
                            Button("Открыть в картах") {
                                openInMaps()
                            }
                            .font(.caption)
                            .foregroundColor(.neonBlue)
                        }
                    }
                    .padding()
                    .background(Color.cardBackground.opacity(0.9))
                    .cornerRadius(12)
                    .padding()
                    
                    Spacer()
                    
                    // Кнопки действий
                    VStack(spacing: 12) {
                        Button("Построить маршрут") {
                            openRoute()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.neonBlue)
                        .cornerRadius(12)
                        
                        Button("Закрыть") {
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.neonBlue.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Местоположение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(.neonBlue)
                }
            }
            .onAppear {
                centerMapOnEvent()
            }
        }
    }
    
    private func centerMapOnEvent() {
        let region = MKCoordinateRegion(
            center: eventCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        cameraPosition = .region(region)
    }
    
    private func coordinateForEvent(_ event: Event) -> CLLocationCoordinate2D {
        // Исправлено: сравниваем address вместо location
        switch event.location.address {
        case "Центральный парк": return CLLocationCoordinate2D(latitude: 55.791, longitude: 49.122)
        case "Площадь Свободы": return CLLocationCoordinate2D(latitude: 55.794, longitude: 49.111)
        case "Стадион Ак Барс": return CLLocationCoordinate2D(latitude: 55.820, longitude: 49.160)
        case "Художественная галерея": return CLLocationCoordinate2D(latitude: 55.787, longitude: 49.134)
        case "IT-парк": return CLLocationCoordinate2D(latitude: 55.796127, longitude: 49.106414)
        case "Казанский Кремль": return CLLocationCoordinate2D(latitude: 55.798098, longitude: 49.105208)
        case "Парк Горького": return CLLocationCoordinate2D(latitude: 55.787, longitude: 49.134)
        case "КФУ": return CLLocationCoordinate2D(latitude: 55.7919, longitude: 49.1221)
        default: return kazanCenter
        }
    }
    
    // Исправлено: добавили обработку всех случаев EventCategory
    private func getCategoryIcon(_ category: EventCategory) -> String {
        switch category {
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
    
    // Исправлено: добавили обработку всех случаев EventCategory
    private func getCategoryColor(_ category: EventCategory) -> Color {
        switch category {
        case .music: return .neonPurple
        case .sport: return .neonGreen
        case .art: return .neonPurple
        case .food: return .neonBlue
        case .education: return .neonGreen
        case .technology: return .neonBlue
        case .festival: return .neonPink
        case .exhibition: return .neonPurple
        case .conference: return .neonBlue
        case .volunteer: return .neonGreen
        case .other: return .neonBlue
        }
    }
    
    private func openInMaps() {
        let coordinate = eventCoordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        // Исправлено: используем address вместо location
        mapItem.name = event.location.address
        mapItem.openInMaps()
    }
    
    private func openRoute() {
        let coordinate = eventCoordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        // Исправлено: используем address вместо location
        mapItem.name = event.location.address
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: options)
    }
}
