import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var eventStore: EventStore
    @State private var showingLogin = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                
                if case .loading = authService.authState {
                    LoadingView()
                } else if case .authenticated(let user) = authService.authState {
                    authenticatedProfileView(user: user)
                } else {
                    guestProfileView
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var guestProfileView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 80))
                    .foregroundColor(.secondaryText)
                
                VStack(spacing: 8) {
                    Text("Вы не вошли в аккаунт")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                    
                    Text("Войдите, чтобы общаться с бизнесами и участвовать в событиях")
                        .font(.body)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            Button("Войти в аккаунт") {
                showingLogin = true
            }
            .buttonStyle(NeonButtonStyle())
            .padding(.horizontal)
            
            Spacer()
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
    }
    
    private func authenticatedProfileView(user: User) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.neonBlue)
                    
                    VStack(spacing: 4) {
                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryText)
                        
                        Text("Участник Kazan Pulse")
                            .font(.body)
                            .foregroundColor(.secondaryText)
                        
                        Text("Общается с \(user.joinedEvents.count) бизнесами")
                            .font(.caption)
                            .foregroundColor(.neonBlue)
                            .padding(.top, 4)
                    }
                }
                .padding(.top, 20)
                
                // Мои активности
                VStack(alignment: .leading, spacing: 16) {
                    Text("Мои активности")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                        .padding(.horizontal)
                    
                    if user.joinedEvents.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 40))
                                .foregroundColor(.secondaryText)
                            
                            Text("У вас нет активных чатов")
                                .font(.body)
                                .foregroundColor(.secondaryText)
                            
                            Text("Нажимайте 'Написать' на бизнесах или 'Пойду' на событиях")
                                .font(.caption)
                                .foregroundColor(.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(user.joinedEvents.prefix(5), id: \.self) { eventId in
                                if let event = eventStore.events.first(where: { $0.id == eventId }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(event.title)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primaryText)
                                            
                                            Text(event.isBusiness ? "Чат с бизнесом" : "Участвую в событии")
                                                .font(.caption)
                                                .foregroundColor(.secondaryText)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: event.isBusiness ? "message" : "calendar")
                                            .foregroundColor(event.isBusiness ? .neonPurple : .neonBlue)
                                    }
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Настройки
                VStack(spacing: 0) {
                    ForEach([
                        ("Уведомления", "bell"),
                        ("Конфиденциальность", "lock"),
                        ("Помощь", "questionmark.circle")
                    ], id: \.0) { setting, icon in
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: icon)
                                    .foregroundColor(.neonBlue)
                                Text(setting)
                                    .foregroundColor(.primaryText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondaryText)
                            }
                            .padding()
                            
                            if setting != "Помощь" {
                                Divider()
                                    .background(Color.secondaryText.opacity(0.3))
                                    .padding(.leading)
                            }
                        }
                    }
                }
                .background(Color.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Logout
                Button("Выйти из аккаунта") {
                    authService.logout()
                }
                .foregroundColor(.neonPink)
                .padding()
            }
        }
    }
}