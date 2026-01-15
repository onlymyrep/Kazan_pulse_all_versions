import SwiftUI

struct EventsOffersView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @State private var selectedOfferType: OfferType = .yandexEvent
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedCategory: EventCategory?
    @State private var selectedBusinessCategory: BusinessCategory?
    
    var filteredEvents: [Event] {
        let baseEvents = selectedOfferType == .yandexEvent ? eventViewModel.events : eventViewModel.businesses
        
        var filtered = baseEvents
        
        // Фильтр по категориям в зависимости от типа
        if selectedOfferType == .yandexEvent, let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        } else if selectedOfferType == .localBusiness, let category = selectedBusinessCategory {
            filtered = filtered.filter { $0.businessCategory == category }
        }
        
        // Поиск
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.location.address.localizedCaseInsensitiveContains(searchText) ||
                $0.organizer.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Kazan Pulse")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primaryText)
                                
                                Text("Найди интересные предложения")
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryText)
                            }
                            
                            Spacer()
                            
                            Button(action: { showingFilters.toggle() }) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.title2)
                                    .foregroundColor(.neonBlue)
                                    .padding(8)
                                    .background(Color.neonBlue.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                        
                        // Переключатель событий/бизнесов
                        Picker("Тип предложений", selection: $selectedOfferType) {
                            Text("События с Афиши").tag(OfferType.yandexEvent)
                            Text("Местные бизнесы").tag(OfferType.localBusiness)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.darkBackground, Color.darkBackground.opacity(0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Категории
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if selectedOfferType == .yandexEvent {
                                ForEach(EventCategory.allCases, id: \.self) { category in
                                    CategoryChip(
                                        title: category.rawValue,
                                        icon: category.icon,
                                        isSelected: selectedCategory == category,
                                        color: .neonBlue
                                    ) {
                                        selectedCategory = selectedCategory == category ? nil : category
                                    }
                                }
                            } else {
                                ForEach(BusinessCategory.allCases, id: \.self) { category in
                                    CategoryChip(
                                        title: category.rawValue,
                                        icon: category.icon,
                                        isSelected: selectedBusinessCategory == category,
                                        color: .neonPurple
                                    ) {
                                        selectedBusinessCategory = selectedBusinessCategory == category ? nil : category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                    
                    if eventViewModel.isLoading {
                        Spacer()
                        LoadingView()
                    } else if let error = eventViewModel.error {
                        Spacer()
                        ErrorView(error: error, retryAction: {
                            Task {
                                await eventViewModel.fetchAllEvents()
                            }
                        })
                    } else if filteredEvents.isEmpty {
                        Spacer()
                        EmptyStateView(offerType: selectedOfferType)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredEvents) { event in
                                    NavigationLink(destination: EventDetailView(event: event)) {
                                        EventCardView(event: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .searchable(text: $searchText, prompt: "Поиск предложений...")
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    selectedEventCategory: $selectedCategory,
                    selectedBusinessCategory: $selectedBusinessCategory,
                    offerType: selectedOfferType
                )
            }
        }
    }
}

// Вспомогательные структуры
struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.3) : Color.cardBackground)
            .foregroundColor(isSelected ? color : .secondaryText)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct EmptyStateView: View {
    let offerType: OfferType
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: offerType == .yandexEvent ? "calendar.badge.exclamationmark" : "building.2")
                .font(.system(size: 60))
                .foregroundColor(.secondaryText)
            
            Text(offerType == .yandexEvent ? "Нет событий" : "Нет бизнесов")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            Text(offerType == .yandexEvent ?
                 "Попробуйте изменить фильтры или зайти позже" :
                 "В этой категории пока нет бизнесов")
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}


// FilterView остается как был
struct FilterView: View {
    @Binding var selectedEventCategory: EventCategory?
    @Binding var selectedBusinessCategory: BusinessCategory?
    let offerType: OfferType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                
                List {
                    if offerType == .yandexEvent {
                        eventCategoriesSection
                    } else {
                        businessCategoriesSection
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color.darkBackground)
            }
            .navigationTitle("Фильтры по категориям")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(.neonBlue)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Сбросить") {
                        selectedEventCategory = nil
                        selectedBusinessCategory = nil
                    }
                    .foregroundColor(.neonPink)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var eventCategoriesSection: some View {
        Section(header: Text("Категории событий")
            .foregroundColor(.primaryText)
            .font(.headline)) {
            ForEach(EventCategory.allCases, id: \.self) { category in
                Button(action: {
                    selectedEventCategory = selectedEventCategory == category ? nil : category
                }) {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(.neonBlue)
                            .frame(width: 30)
                        Text(category.rawValue)
                            .foregroundColor(.primaryText)
                        Spacer()
                        if selectedEventCategory == category {
                            Image(systemName: "checkmark")
                                .foregroundColor(.neonBlue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.cardBackground)
            }
        }
    }
    
    private var businessCategoriesSection: some View {
        Section(header: Text("Категории бизнесов")
            .foregroundColor(.primaryText)
            .font(.headline)) {
            ForEach(BusinessCategory.allCases, id: \.self) { category in
                Button(action: {
                    selectedBusinessCategory = selectedBusinessCategory == category ? nil : category
                }) {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(.neonPurple)
                            .frame(width: 30)
                        Text(category.rawValue)
                            .foregroundColor(.primaryText)
                        Spacer()
                        if selectedBusinessCategory == category {
                            Image(systemName: "checkmark")
                                .foregroundColor(.neonPurple)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.cardBackground)
            }
        }
    }
}
