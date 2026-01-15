import SwiftUI
import MapKit

struct EventDetailView: View {
    let event: Event
    @State private var isFavorite = false
    @State private var showingChat = false
    @State private var showingLogin = false
    @State private var showingNavigationOptions = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var eventViewModel: EventViewModel
    @StateObject private var navigationService = NavigationService()
    
    private var neonColor: Color {
        if event.isBusiness {
            return .neonPurple
        }
        
        switch event.category {
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
    
    private var isGoing: Bool {
        guard let currentUser = authService.currentUser else { return false }
        return currentUser.joinedEvents.contains(event.id)
    }
    
    private var isAuthenticated: Bool {
        authService.isAuthenticated
    }
    
    private var currentUser: User? {
        authService.currentUser
    }
    
    private var categoryText: String {
        if event.isBusiness, let businessCategory = event.businessCategory {
            return businessCategory.rawValue
        }
        return event.category.rawValue
    }
    
    private var categoryIcon: String {
        if event.isBusiness, let businessCategory = event.businessCategory {
            return businessCategory.icon
        }
        return event.category.icon
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header image
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [neonColor.opacity(0.3), neonColor.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: event.isBusiness ? "building.2" : "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.5))
                        )
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primaryText)
                            .padding(12)
                            .background(Color.darkBackground.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primaryText)
                                
                                Text(event.isBusiness ? "Местный бизнес" : "Событие с Яндекс Афиши")
                                    .font(.subheadline)
                                    .foregroundColor(neonColor)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring()) {
                                    isFavorite.toggle()
                                }
                            }) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(isFavorite ? .neonPink : .secondaryText)
                                    .padding(8)
                                    .background(Color.cardBackground)
                                    .clipShape(Circle())
                            }
                        }
                        
                        HStack {
                            if event.isBusiness, let hours = event.businessHours {
                                Image(systemName: "clock")
                                    .foregroundColor(neonColor)
                                Text("Часы: \(hours)")
                                    .foregroundColor(.secondaryText)
                            } else {
                                Image(systemName: "calendar")
                                    .foregroundColor(neonColor)
                                Text(event.formattedDate)
                                    .foregroundColor(.secondaryText)
                            }
                            
                            Spacer()
                            
                            Text(event.price)
                                .font(.headline)
                                .foregroundColor(neonColor)
                        }
                    }
                    
                    // Рейтинг для бизнесов
                    if event.isBusiness, let rating = event.rating, let reviewCount = event.reviewCount {
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.neonGreen)
                                Text(String(format: "%.1f", rating))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primaryText)
                            }
                            
                            Text("\(reviewCount) отзывов")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Badges
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], alignment: .leading, spacing: 8) {
                        // Категория
                        BadgeView(
                            text: categoryText,
                            color: neonColor,
                            icon: categoryIcon
                        )
                        
                        if event.isFree {
                            BadgeView(text: "Бесплатно", color: .neonGreen, icon: "tag")
                        }
                        
                        if event.isBusiness {
                            BadgeView(text: "Местный", color: .neonPurple, icon: "building.2")
                        }
                        
                        if let accessibility = event.accessibility {
                            BadgeView(text: accessibility.description, color: .neonBlue, icon: accessibility.icon)
                        }
                        
                        if !event.isBusiness {
                            BadgeView(text: event.timeUntilEvent, color: .neonPink, icon: "clock")
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        // Join/Contact button
                        Button(action: {
                            if isAuthenticated {
                                if isGoing {
                                    authService.leaveEvent(event.id)
                                } else {
                                    // СОЗДАЕМ ЧАТ ПРИ НАЖАТИИ "ПОЙДУ"
                                    if let userId = currentUser?.id {
                                        if let chatRoomId = eventViewModel.joinEvent(event.id, userId: userId) {
                                            print("✅ Чат создан: \(chatRoomId)")
                                        }
                                    }
                                    authService.joinEvent(event.id)
                                    // Показываем чат после присоединения к событию
                                    showingChat = true
                                }
                            } else {
                                showingLogin = true
                            }
                        }) {
                            HStack {
                                Image(systemName: isGoing ? "checkmark.circle.fill" :
                                      (event.isBusiness ? "message" : "person.badge.plus"))
                                Text(isGoing ? "Я иду!" :
                                     (event.isBusiness ? "Написать сообщение" : "Пойду на событие"))
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                isGoing ?
                                Color.neonGreen.opacity(0.2) :
                                Color.neonBlue.opacity(0.2)
                            )
                            .foregroundColor(
                                isGoing ? .neonGreen : .neonBlue
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isGoing ?
                                        Color.neonGreen.opacity(0.4) :
                                        Color.neonBlue.opacity(0.4),
                                        lineWidth: 1
                                    )
                            )
                        }
                        
                        // Chat button для событий
                        if !event.isBusiness {
                            Button(action: {
                                if isAuthenticated && isGoing {
                                    showingChat = true
                                } else if !isAuthenticated {
                                    showingLogin = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "message")
                                    Text("Чат события")
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    (isAuthenticated && isGoing) ?
                                    Color.neonPurple.opacity(0.2) :
                                    Color.cardBackground
                                )
                                .foregroundColor(
                                    (isAuthenticated && isGoing) ?
                                    .neonPurple : .secondaryText
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            (isAuthenticated && isGoing) ?
                                            Color.neonPurple.opacity(0.4) :
                                            Color.white.opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                            }
                            .disabled(!isAuthenticated || !isGoing)
                        }
                    }
                    
                    // Navigation button
                    Button(action: {
                        showingNavigationOptions = true
                    }) {
                        HStack {
                            Image(systemName: "location.circle")
                                .font(.system(size: 18))
                            Text("Построить маршрут к \(event.isBusiness ? "бизнесу" : "событию")")
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.neonGreen.opacity(0.1))
                        .foregroundColor(.neonGreen)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.neonGreen.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.isBusiness ? "О бизнесе" : "Описание события")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        Text(event.description)
                            .foregroundColor(.secondaryText)
                            .lineSpacing(4)
                    }
                    
                    // Организатор и контакты
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event.isBusiness ? "Владелец" : "Организатор")
                                .font(.headline)
                                .foregroundColor(.primaryText)
                            
                            Text(event.organizer)
                                .foregroundColor(.secondaryText)
                        }
                        
                        if let contactInfo = event.contactInfo {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Контакты для связи")
                                    .font(.headline)
                                    .foregroundColor(.primaryText)
                                
                                Text(contactInfo)
                                    .foregroundColor(.neonBlue)
                            }
                        }
                    }
                    
                    // Map
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Местоположение")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        Map {
                            Annotation(event.title, coordinate: event.location.coordinate) {
                                Image(systemName: event.isBusiness ? "building.2" : "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.neonPink)
                                    .background(Circle().fill(Color.darkBackground))
                            }
                        }
                        .mapStyle(.standard)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        
                        Text(event.location.address)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                }
                .padding()
            }
        }
        .background(Color.darkBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showingChat) {
            if let currentUser = currentUser {
                ChatView(event: event, user: currentUser)
            } else {
                Text("Ошибка: пользователь не найден")
                    .foregroundColor(.primaryText)
            }
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
        .actionSheet(isPresented: $showingNavigationOptions) {
            ActionSheet(
                title: Text("Выберите приложение для навигации"),
                buttons: navigationActionSheetButtons()
            )
        }
    }
    
    private func navigationActionSheetButtons() -> [ActionSheet.Button] {
        let navigationApps = navigationService.getNavigationOptions(for: event.location)
        var buttons: [ActionSheet.Button] = []
        
        for app in navigationApps {
            buttons.append(.default(Text(app.name)) {
                switch app.type {
                case .apple:
                    navigationService.openInAppleMaps(event.location)
                case .yandex:
                    navigationService.openInYandexMaps(event.location)

                case .dgis:
                    navigationService.openIn2GIS(event.location)
                }
            })
        }
        
        buttons.append(.cancel(Text("Отмена")))
        return buttons
    }
}
