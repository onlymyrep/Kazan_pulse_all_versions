import Foundation
import SwiftUI
import AVFoundation
import CoreBluetooth
import Combine

class AudioGuideService: NSObject, ObservableObject {
    @Published var isHeadphonesConnected = false
    @Published var availableTrailers: [EventTrailer] = []
    @Published var isPlaying = false
    @Published var currentPlayingTrailer: EventTrailer?
    @Published var playbackProgress: Double = 0
    
    private var centralManager: CBCentralManager!
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        setupAudioSession()
        loadDemoTrailers()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    private func loadDemoTrailers() {
        // Создаем демо-трейлеры
        availableTrailers = [
            EventTrailer(
                eventId: "demo_1",
                title: "Экскурсия по Казанскому Кремлю",
                audioURL: "kazan_kremlin_tour",
                duration: 45
            ),
            EventTrailer(
                eventId: "demo_2", 
                title: "Концерт в Центральном парке",
                audioURL: "central_park_concert",
                duration: 30
            ),
            EventTrailer(
                eventId: "demo_3",
                title: "IT-конференция в IT-парке",
                audioURL: "it_conference",
                duration: 60
            )
        ]
    }
    
    func playTrailer(_ trailer: EventTrailer) {
        stopPlayback()
        
        // В реальном приложении здесь будет загрузка из сети
        // Сейчас используем демо-воспроизведение
        print("Воспроизведение аудиотрейлера: \(trailer.title)")
        isPlaying = true
        currentPlayingTrailer = trailer
        startProgressTimer()
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        playbackTimer?.invalidate()
        isPlaying = false
        currentPlayingTrailer = nil
        playbackProgress = 0
    }
    
    private func startProgressTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.isPlaying {
                // Для демо-аудио без реального плеера
                self.playbackProgress += 0.1 / (self.currentPlayingTrailer?.duration ?? 30)
                if self.playbackProgress >= 1.0 {
                    self.stopPlayback()
                }
            }
        }
    }
}

extension AudioGuideService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Для демо просто устанавливаем подключение
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isHeadphonesConnected = true
            }
        }
    }
}

struct EventTrailer: Identifiable {
    let id = UUID()
    let eventId: String
    let title: String
    let audioURL: String
    let duration: TimeInterval
}