import SwiftUI

struct EventsListView: View {
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var favoriteManager: FavoriteManager
    @State private var hasLoaded = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                
                if eventStore.isLoading {
                    LoadingView()
                } else if eventStore.events.isEmpty {
                    EmptyEventsView()
                } else {
                    EventsListContent()
                }
            }
            .navigationTitle("События Казани")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if !hasLoaded {
                Task {
                    await eventStore.loadEvents()
                    hasLoaded = true
                }
            }
        }
    }
}

struct EventsListContent: View {
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var favoriteManager: FavoriteManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(eventStore.events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventCardView(event: event)
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical)
        }
    }
}

struct EmptyEventsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.neonBlue)
            
            Text("Событий пока нет")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            Text("Проверьте позже или обновите список")
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
