import SwiftUI

@main
struct KazanPulseApp: App {
    @StateObject var authService = AuthService()
    @StateObject var eventStore = EventStore()
    @StateObject var eventViewModel = EventViewModel()
    
    init() {
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(eventStore)
                .environmentObject(authService)
                .environmentObject(eventViewModel)
                .preferredColorScheme(.dark)
                .task {
                    await eventViewModel.fetchAllEvents()
                }
        }
    }
    
    private func setupAppearance() {
        // Настройка NavigationBar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(Color.darkBackground)
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.primaryText),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.primaryText),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        // Применяем настройки ко всем NavigationBar
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().tintColor = UIColor(Color.neonBlue)
        
        // Настройка TabBar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.darkBackground)
        
        // Внешний вид для выбранной вкладки
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.neonBlue)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.neonBlue),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Внешний вид для невыбранной вкладки
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.secondaryText)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.secondaryText),
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        
        // Применяем настройки ко всем TabBar
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Настройка SearchBar
        let searchBarAppearance = UISearchBar.appearance()
        searchBarAppearance.barTintColor = UIColor(Color.darkBackground)
        searchBarAppearance.tintColor = UIColor(Color.neonBlue)
        
        // Настройка UITableView (для списков)
        UITableView.appearance().backgroundColor = UIColor(Color.darkBackground)
        UITableViewCell.appearance().backgroundColor = UIColor(Color.cardBackground)
        
        // Настройка UISegmentedControl
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.neonBlue)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor(Color.primaryText)
        ], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor(Color.darkBackground)
        ], for: .selected)
        
        // Настройка UIRefreshControl (pull to refresh)
        UIRefreshControl.appearance().tintColor = UIColor(Color.neonBlue)
        
        print("✅ Appearance setup completed")
    }
}
