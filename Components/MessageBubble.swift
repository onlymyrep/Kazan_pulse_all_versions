import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if !message.isFromCurrentUser {
                    Text(message.userDisplayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.neonBlue)
                }
                
                Text(message.text)
                    .font(.body)
                    .foregroundColor(.primaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        message.isFromCurrentUser ?
                        Color.neonBlue.opacity(0.2) :
                        Color.cardBackground
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                message.isFromCurrentUser ?
                                Color.neonBlue.opacity(0.3) :
                                Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
                
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
            }
            
            if !message.isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
    }
}
