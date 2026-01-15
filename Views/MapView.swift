import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var eventStore: EventStore
    // 1. Use MapCameraPosition for the region
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.796127, longitude: 49.106414),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))
    
    var body: some View {
        NavigationView {
            ZStack {
                // 2. Use the new Map initializer with 'position'
                Map(position: $cameraPosition) {
                    // 3. Add annotations directly to the Map's content builder
                    ForEach(eventStore.events) { event in
                        Annotation(event.title, coordinate: event.location.coordinate) {
                            EventMapAnnotation(event: event)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .ignoresSafeArea()
                
                // Кнопка возврата к центру с неоновым стилем
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: centerOnKazan) {
                            Image(systemName: "location.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.neonBlue)
                                        .shadow(color: .neonBlue.opacity(0.6), radius: 8)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Карта событий")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            eventStore.loadEvents()
        }
    }
    
    private func centerOnKazan() {
        withAnimation(.easeInOut(duration: 0.5)) {
            // 4. Update the region by setting cameraPosition
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 55.796127, longitude: 49.106414),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }
}

// Аннотация с неоновыми цветами
struct EventMapAnnotation: View {
    let event: Event
    @State private var showingDetail = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(getCategoryColor(event.category))
                    .frame(width: 44, height: 44)
                    .shadow(color: getCategoryColor(event.category).opacity(0.6), radius: 4)
                
                Image(systemName: getCategoryIcon(event.category))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(event.title)
                .font(.system(size: 10, weight: .semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.cardBackground)
                .foregroundColor(.primaryText)
                .cornerRadius(6)
                .frame(maxWidth: 80)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(getCategoryColor(event.category), lineWidth: 1)
                )
        }
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            NavigationView {
                EventDetailView(event: event)
            }
        }
    }
    
    private func getCategoryIcon(_ category: EventCategory) -> String {
        switch category {
        case .music: return "music.note"
        case .sport: return "sportscourt"
        case .art: return "paintpalette"
        case .food: return "fork.knife"
        case .education: return "book"
        case .technology: return "laptopcomputer"
        case .festival: return "party.popper"
        case .exhibition: return "photo"
        case .conference: return "person.3"
        case .volunteer: return "heart"
        case .other: return "star"
        }
    }
    
    private func getCategoryColor(_ category: EventCategory) -> Color {
        switch category {
        case .music: return .neonPink
        case .sport: return .neonGreen
        case .art: return .neonPurple
        case .food: return .neonBlue
        case .education: return .neonGreen
        case .technology: return .neonBlue
        case .festival: return .neonPink
        case .exhibition: return .neonPurple
        case .conference: return .neonBlue
        case .volunteer: return .neonGreen
        case .other: return .neonGreen
        }
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        let eventStore = EventStore()
//        eventStore.events = Event.sampleEvents
//        
//        return MapView()
//            .environmentObject(eventStore)
//    }
//}
