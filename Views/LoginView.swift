import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authService: AuthService  // Change this line
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.neonBlue)
                        
                        Text("Вход в KazanPulse")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                        
                        Text("Войдите, чтобы сохранять избранные события и общаться с участниками")
                            .font(.body)
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Sign In Button
                    VStack(spacing: 16) {
                        if authService.isLoading {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Выполняется вход...")
                                    .font(.caption)
                                    .foregroundColor(.secondaryText)
                            }
                            .padding()
                        } else {
                            Button(action: handleSignIn) {
                                HStack {
                                    Image(systemName: "person.fill")
                                    Text("Войти через Google")
                                }
                                .font(.headline)
                                .foregroundColor(.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.neonBlue.opacity(0.2))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.neonBlue, lineWidth: 1)
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        if let error = authService.errorMessage {  // Use errorMessage from AuthService
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.secondaryText)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            print("🔐 LoginView: Appeared, isAuthenticated = \(authService.isAuthenticated)")
        }
        .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
            print("🔄 LoginView: Auth state changed to \(isAuthenticated)")
            if isAuthenticated {
                print("✅ LoginView: User authenticated, dismissing...")
                dismiss()
            }
        }
    }
    
    private func handleSignIn() {
        print("🔄 LoginView: Starting Google Sign-In")
        authService.signInWithGoogle { success in
            print("🔄 LoginView: Google Sign-In callback - success: \(success)")
            if success {
                print("✅ LoginView: Sign-In successful, will dismiss")
            } else {
                print("❌ LoginView: Sign-In failed")
            }
        }
    }
}
