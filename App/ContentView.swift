import SwiftUI
import Foundation

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var eventStore = EventStore()
    @StateObject private var authService = AuthService()
    @State private var showingLogin = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.darkBackground, Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                EventsOffersView()
                    .tabItem {
                        Image(systemName: "sparkles")
                        Text("Предложения")
                    }
                    .tag(0)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Профиль")
                    }
                    .tag(1)
            }
            .accentColor(.neonBlue)
        }
        .environmentObject(eventStore)
        .environmentObject(authService)
        .onAppear {
            eventStore.loadEvents()
        }
        .onChange(of: authService.authState) { oldValue, newValue in
            if case .guest = newValue {
                showingLogin = true
            }
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
    }
}
