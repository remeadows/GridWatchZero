// BrandIntroView.swift
// GridWatchZero
// War Signal Labs brand intro with video and thunderstorm audio

import SwiftUI
import AVKit
import AVFoundation

// MARK: - Full Screen Video Player

struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> VideoPlayerUIView {
        let view = VideoPlayerUIView()
        view.player = player
        return view
    }
    
    func updateUIView(_ uiView: VideoPlayerUIView, context: Context) {
        // No updates needed
    }
}

class VideoPlayerUIView: UIView {
    var player: AVPlayer? {
        didSet {
            setupPlayerLayer()
        }
    }

    private var playerLayer: AVPlayerLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPlayerLayer() {
        guard let player = player else { return }

        // Mute video audio (storm audio plays instead)
        player.isMuted = true

        // Replace any existing layer to avoid stacked AVPlayerLayers.
        playerLayer?.removeFromSuperlayer()

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds

        self.layer.addSublayer(layer)
        self.playerLayer = layer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}

// MARK: - Brand Intro View

struct BrandIntroView: View {
    var onComplete: () -> Void

    @State private var player: AVPlayer?
    @State private var isVideoComplete = false
    @State private var opacity: Double = 0
    @State private var videoObserver: NSObjectProtocol?
    @State private var playerItemStatusObserver: NSKeyValueObservation?
    @State private var stormAudioPlayer: AVAudioPlayer?
    private let reducedEffects = RenderPerformanceProfile.reducedEffects

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)

            if reducedEffects {
                VStack(spacing: 12) {
                    Text("WAR SIGNAL LABS")
                        .font(.terminalLarge)
                        .foregroundColor(.neonGreen)
                    Text("GRID WATCH ZERO")
                        .font(.terminalTitle)
                        .foregroundColor(.neonAmber)
                }
                .opacity(opacity)
            } else if let player = player {
                // Full-screen video player
                VideoPlayerView(player: player)
                    .ignoresSafeArea(.all)
                    .opacity(opacity)
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            if reducedEffects {
                opacity = 1.0
                AmbientAudioManager.shared.startAmbient()
                onComplete()
                return
            }

            setupVideoPlayer()
            playStormAudio()
            
            // Fade in
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1.0
            }
        }
        .onDisappear {
            cleanupPlayers()
        }
    }

    // MARK: - Setup Video

    private func setupVideoPlayer() {
        guard let videoURL = Bundle.main.url(forResource: "WarSignalLabs_9_16_5", withExtension: "mp4") else {
            print("[BrandIntro] ❌ Video file not found")
            // Skip to next screen if video not found
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete()
            }
            return
        }

        let playerItem = AVPlayerItem(url: videoURL)
        playerItem.preferredForwardBufferDuration = 1.5
        let avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.automaticallyWaitsToMinimizeStalling = true

        // Observe when video finishes
        videoObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            handleVideoComplete()
        }

        self.player = avPlayer

        // Start playback when AVPlayerItem is actually ready to avoid first-frame stalls.
        playerItemStatusObserver = playerItem.observe(\.status, options: [.initial, .new]) { item, _ in
            DispatchQueue.main.async {
                guard self.player === avPlayer, !self.isVideoComplete else { return }
                switch item.status {
                case .readyToPlay:
                    avPlayer.play()
                case .failed:
                    cleanupPlayers()
                    onComplete()
                default:
                    break
                }
            }
        }
    }

    // MARK: - Storm Audio Setup
    
    private func playStormAudio() {
        guard let stormURL = Bundle.main.url(forResource: "storm", withExtension: "wav") else {
            print("[BrandIntro] ⚠️ Storm audio file not found")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: stormURL)
            player.volume = 0.3  // Quieter for atmospheric effect
            player.numberOfLoops = 0  // Play once
            player.prepareToPlay()
            player.play()
            
            self.stormAudioPlayer = player
            print("[BrandIntro] ⛈️ Storm audio started")
        } catch {
            print("[BrandIntro] ❌ Failed to play storm audio: \(error)")
        }
    }

    // MARK: - Video Complete Handler

    private func handleVideoComplete() {
        guard !isVideoComplete else { return }
        isVideoComplete = true

        // Start music BEFORE video fades out (overlap for smooth transition)
        // startAmbient() will start at 0 volume and fade in automatically
        AmbientAudioManager.shared.startAmbient()
        
        // Fade out storm audio
        stormAudioPlayer?.setVolume(0.0, fadeDuration: 0.5)

        // Fade out video
        withAnimation(.easeOut(duration: 0.5)) {
            opacity = 0
        }

        // Proceed to title screen (music already playing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            cleanupPlayers()
            onComplete()
        }
    }

    // MARK: - Cleanup

    private func cleanupPlayers() {
        player?.pause()
        player = nil
        playerItemStatusObserver?.invalidate()
        playerItemStatusObserver = nil
        
        // Stop storm audio
        stormAudioPlayer?.stop()
        stormAudioPlayer = nil

        // No background music during brand intro
        // Music starts on Title Screen

        if let observer = videoObserver {
            NotificationCenter.default.removeObserver(observer)
            videoObserver = nil
        }
    }
}

// MARK: - Preview

#Preview {
    BrandIntroView {
        print("Intro complete")
    }
}
