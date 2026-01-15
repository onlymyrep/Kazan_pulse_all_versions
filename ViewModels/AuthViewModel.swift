import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthService) {
        self.authService = authService
        print("🔄 AuthViewModel: Initialized")
        setupBindings()
    }
    
    private func setupBindings() {
        authService.$authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (authState: UserAuthState) in
                print("🔄 AuthViewModel: Received authState - \(authState)")
                
                switch authState {
                case .authenticated(let user):
                    self?.isAuthenticated = true
                    self?.currentUser = user
                    self?.isLoading = false
                    self?.error = nil
                    print("✅ AuthViewModel: User authenticated - \(user.name)")
                    
                case .guest:
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                    self?.isLoading = false
                    self?.error = nil
                    print("🔐 AuthViewModel: User is guest")
                    
                case .loading:
                    self?.isLoading = true
                    print("⏳ AuthViewModel: Loading...")
                }
            }
            .store(in: &cancellables)
        
        authService.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.error = errorMessage
                if let error = errorMessage {
                    print("❌ AuthViewModel Error: \(error)")
                }
            }
            .store(in: &cancellables)
    }
    
    func signInWithGoogle(completion: @escaping (Bool) -> Void = { _ in }) {
        isLoading = true
        error = nil
        print("🔄 AuthViewModel: Starting Google Sign-In")
        
        authService.signInWithGoogle { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoading = false
                print("🔄 AuthViewModel: Google Sign-In completed - success: \(success)")
                completion(success)
            }
        }
    }
    
    func signOut() {
        print("🔄 AuthViewModel: Signing out")
        authService.signOut()
    }
}

