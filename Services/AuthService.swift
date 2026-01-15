import Foundation
import Combine
import GoogleSignIn
import SwiftUI

enum UserAuthState: Equatable {
    case authenticated(User)
    case guest
    case loading
    
    static func == (lhs: UserAuthState, rhs: UserAuthState) -> Bool {
        switch (lhs, rhs) {
        case (.authenticated(let lhsUser), .authenticated(let rhsUser)):
            return lhsUser.id == rhsUser.id
        case (.guest, .guest):
            return true
        case (.loading, .loading):
            return true
        default:
            return false
        }
    }
}

class AuthService: ObservableObject {
    @Published var authState: UserAuthState = .loading
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false  // Add this
    
    var isAuthenticated: Bool {
        if case .authenticated = authState {
            return true
        }
        return false
    }
    
    var error: String? {  // Add this computed property for compatibility
        return errorMessage
    }
    
    private let userDefaultsKey = "currentUser"
    
    init() {
        // Не восстанавливаем сессию автоматически - показываем логин
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.authState = .guest
        }
    }
    
    // MARK: - Public Methods
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        isLoading = true  // Set loading state
        errorMessage = nil
        
        guard let clientID = loadGoogleClientID() else {
            handleError("Не удалось загрузить конфигурацию Google Sign-In")
            isLoading = false
            completion(false)
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let rootViewController = getRootViewController() else {
            handleError("Не удалось получить root view controller")
            isLoading = false
            completion(false)
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false  // Reset loading state
                
                if let error = error {
                    self?.handleError("Ошибка входа: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let user = result?.user else {
                    self?.handleError("Не удалось получить данные пользователя")
                    completion(false)
                    return
                }
                
                self?.handleSuccessfulGoogleSignIn(user)
                completion(true)
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        authState = .guest
        currentUser = nil
        errorMessage = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        print("✅ User signed out")
    }
    
    // MARK: - Event Methods (для EventDetailView)
    func isGoingToEvent(_ eventId: String) -> Bool {
        guard case .authenticated(let user) = authState else { return false }
        return user.joinedEvents.contains(eventId)
    }
    
    func joinEvent(_ eventId: String) {
        guard case .authenticated(var user) = authState else { return }
        if !user.joinedEvents.contains(eventId) {
            user.joinedEvents.append(eventId)
            // Обновляем пользователя
            authState = .authenticated(user)
            currentUser = user
            saveUserToDefaults(user)
        }
    }
    
    func leaveEvent(_ eventId: String) {
        guard case .authenticated(var user) = authState else { return }
        user.joinedEvents.removeAll { $0 == eventId }
        authState = .authenticated(user)
        currentUser = user
        saveUserToDefaults(user)
    }
    
    func logout() {
        signOut()
    }
    
    // MARK: - Private Methods
    private func handleSuccessfulGoogleSignIn(_ user: GIDGoogleUser) {
        let email = user.profile?.email
        let fullName = user.profile?.name
        let profileImageURL = user.profile?.imageURL(withDimension: 120)
        
        let displayName = fullName ?? email ?? "Google User"
        
        let newUser = User(
            id: user.userID ?? UUID().uuidString,
            name: displayName,
            email: email,
            profileImageURL: profileImageURL?.absoluteString,
            favoriteEvents: [],
            joinedEvents: [],
            interests: [],
            isStudent: false
        )
        
        authState = .authenticated(newUser)
        currentUser = newUser
        saveUserToDefaults(newUser)
        errorMessage = nil
        
        print("✅ User signed in: \(displayName)")
    }
    
    private func saveUserToDefaults(_ user: User) {
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
        }
    }
    
    private func loadGoogleClientID() -> String? {
        // Загружаем реальный CLIENT_ID из GoogleService-Info.plist
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let clientID = dict["CLIENT_ID"] as? String else {
            print("❌ Failed to load GoogleService-Info.plist or CLIENT_ID not found")
            return nil
        }
        return clientID
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootViewController
    }
    
    private func handleError(_ error: String) {
        errorMessage = error
        authState = .guest
        print("❌ AuthService Error: \(error)")
    }
}
