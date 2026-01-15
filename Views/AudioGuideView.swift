import SwiftUI

struct AudioGuideView: View {
    @StateObject private var audioService = AudioGuideService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ConnectionStatusView(audioService: audioService)
                
                if audioService.isHeadphonesConnected {
                    if audioService.availableTrailers.isEmpty {
                        EmptyTrailersView()
                    } else {
                        TrailersListView(audioService: audioService)
                    }
                } else {
                    BluetoothPromptView()
                }
            }
            .navigationTitle("🎧 Аудиогид")
            .padding()
            // Убрали onAppear с вызовом несуществующего метода
        }
    }
}

struct ConnectionStatusView: View {
    @ObservedObject var audioService: AudioGuideService
    
    var body: some View {
        HStack {
            Image(systemName: audioService.isHeadphonesConnected ?
                  "headphones.circle.fill" : "headphones.circle")
                .font(.title2)
                .foregroundColor(audioService.isHeadphonesConnected ? .green : .gray)
            
            VStack(alignment: .leading) {
                Text(audioService.isHeadphonesConnected ?
                     "Наушники подключены" : "Подключите наушники")
                    .font(.headline)
                Text(audioService.isHeadphonesConnected ?
                     "Доступны аудиотрейлеры" : "Для прослушивания трейлеров")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TrailersListView: View {
    @ObservedObject var audioService: AudioGuideService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(audioService.availableTrailers) { trailer in
                    TrailerCard(trailer: trailer, audioService: audioService)
                }
            }
        }
    }
}

struct TrailerCard: View {
    let trailer: EventTrailer
    @ObservedObject var audioService: AudioGuideService
    
    var isCurrentPlaying: Bool {
        audioService.currentPlayingTrailer?.id == trailer.id && audioService.isPlaying
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trailer.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(Int(trailer.duration)) секунд")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    if isCurrentPlaying {
                        audioService.stopPlayback()
                    } else {
                        audioService.playTrailer(trailer)
                    }
                }) {
                    Image(systemName: isCurrentPlaying ?
                          "stop.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(isCurrentPlaying ? .red : .blue)
                }
            }
            
            // Прогресс воспроизведения
            if isCurrentPlaying {
                ProgressView(value: audioService.playbackProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .accentColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 2)
    }
}

struct EmptyTrailersView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Аудиотрейлеры появятся скоро")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Мы готовим аудиогиды для предстоящих событий")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct BluetoothPromptView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "headphones")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Подключите Bluetooth-наушники")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text("Для прослушивания аудиотрейлеров событий подключите беспроводные наушники")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Открыть настройки Bluetooth") {
                if let url = URL(string: "App-Prefs:Bluetooth") {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
