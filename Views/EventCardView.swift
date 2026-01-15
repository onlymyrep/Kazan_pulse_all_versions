import SwiftUI

struct EventCardView: View {
    let event: Event
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.headline)
                            .foregroundColor(.primaryText)
                            .lineLimit(2)
                        
                        Text(event.isBusiness ? "Местный бизнес" : "Событие с Яндекс Афиши")
                            .font(.caption)
                            .foregroundColor(neonColor)
                    }
                    
                    Spacer()
                    
                    if event.isBusiness, let rating = event.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.neonGreen)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primaryText)
                        }
                    }
                }
                
                Text(event.description)
                    .font(.body)
                    .foregroundColor(.secondaryText)
                    .lineLimit(2)
            }
            
            // Info row
            HStack {
                if event.isBusiness, let hours = event.businessHours {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(neonColor)
                        Text("Часы: \(hours)")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(neonColor)
                        Text(event.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                }
                
                Spacer()
                
                Text(event.price)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(neonColor)
            }
            
            // Location
            HStack {
                Image(systemName: "mappin.circle")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                Text(event.location.address)
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
