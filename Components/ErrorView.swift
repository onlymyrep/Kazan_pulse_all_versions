import SwiftUI

struct ErrorView: View {
    let error: String
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.neonPink)
            
            Text("Ошибка")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            Text(error)
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction = retryAction {
                Button("Попробовать снова", action: retryAction)
                    .buttonStyle(NeonButtonStyle())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.darkBackground)
    }
}
