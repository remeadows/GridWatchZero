// AudioManager.swift
// GridWatchZero
// AVAudioEngine-based audio system with Core Haptics integration

import AVFoundation
import UIKit
import SwiftUI
import CoreHaptics

// MARK: - Sound Types

enum SoundEffect: String, CaseIterable {
    case upgrade = "upgrade"
    case attackIncoming = "attack_incoming"
    case attackEnd = "attack_end"
    case malusMessage = "malus_message"
    case tick = "button_tap"  // Use button tap for tick
    case error = "error"
    case milestone = "milestone"
    case warning = "warning"

    /// File name for the sound effect (without extension)
    var fileName: String {
        return rawValue
    }
}

// MARK: - Audio Manager

/// Unified audio engine managing SFX, music, and ducking via AVAudioEngine
final class AudioManager: @unchecked Sendable {
    static let shared = AudioManager()

    private var isSoundEnabled: Bool = true
    private var isHapticsEnabled: Bool = true
    private var soundVolume: Float = 0.7

    // MARK: - AVAudioEngine

    private let engine = AVAudioEngine()
    private let sfxMixerNode = AVAudioMixerNode()
    private let musicMixerNode = AVAudioMixerNode()
    private let musicPlayerNode = AVAudioPlayerNode()

    // SFX player node pool (round-robin)
    private let maxSFXPlayers = 8
    private var sfxPlayerNodes: [AVAudioPlayerNode] = []
    private var nextPlayerIndex: Int = 0

    // Preloaded audio buffers
    private var sfxBuffers: [SoundEffect: AVAudioPCMBuffer] = [:]
    private var musicBuffer: AVAudioPCMBuffer?

    // Music state
    private var isMusicPlaying: Bool = false
    private var musicVolume: Float = 0.3

    // Ducking state
    private enum DuckState { case normal, ducked, restoring }
    private var duckState: DuckState = .normal
    private var preDuckMusicVolume: Float = 0.3
    private let duckRatio: Float = 0.3
    private var duckTimer: DispatchSourceTimer?

    private init() {
        setupAudioSession()
        setupNodeGraph()
        preloadSounds()
        startEngine()
        observeEngineNotifications()
        HapticManager.prepareEngine()
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    // MARK: - Node Graph Setup

    private func setupNodeGraph() {
        // Attach mixer nodes
        engine.attach(sfxMixerNode)
        engine.attach(musicMixerNode)
        engine.attach(musicPlayerNode)

        let mainMixer = engine.mainMixerNode

        // Standard stereo format for mixing
        let mixFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!

        // Connect mixers to main output
        engine.connect(sfxMixerNode, to: mainMixer, format: mixFormat)
        engine.connect(musicMixerNode, to: mainMixer, format: mixFormat)

        // Connect music player to music mixer
        engine.connect(musicPlayerNode, to: musicMixerNode, format: mixFormat)

        // Create SFX player node pool
        for _ in 0..<maxSFXPlayers {
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            engine.connect(playerNode, to: sfxMixerNode, format: mixFormat)
            sfxPlayerNodes.append(playerNode)
        }

        // Set initial volumes
        sfxMixerNode.volume = soundVolume
        musicMixerNode.volume = musicVolume
        mainMixer.outputVolume = 1.0
    }

    // MARK: - Engine Lifecycle

    private func startEngine() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            print("Audio engine start failed: \(error)")
        }
    }

    private func observeEngineNotifications() {
        NotificationCenter.default.addObserver(
            forName: .AVAudioEngineConfigurationChange,
            object: engine,
            queue: .main
        ) { [weak self] _ in
            self?.handleEngineConfigurationChange()
        }
    }

    private func handleEngineConfigurationChange() {
        // Engine was interrupted (phone call, Siri, etc.)
        // Restart the engine and resume music if it was playing
        let wasPlayingMusic = isMusicPlaying
        startEngine()
        if wasPlayingMusic {
            scheduleLoopingMusic()
            musicPlayerNode.play()
        }
    }

    // MARK: - Preload Sounds

    /// Preload all sound effects into AVAudioPCMBuffer for instant playback
    private func preloadSounds() {
        for sound in SoundEffect.allCases {
            guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "m4a") else {
                print("Sound file not found: \(sound.fileName).m4a")
                continue
            }
            do {
                let audioFile = try AVAudioFile(forReading: url)
                let format = audioFile.processingFormat
                let frameCount = AVAudioFrameCount(audioFile.length)
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                    print("Failed to create buffer for \(sound.fileName)")
                    continue
                }
                try audioFile.read(into: buffer)
                sfxBuffers[sound] = buffer
            } catch {
                print("Failed to preload sound \(sound.fileName): \(error)")
            }
        }
        print("Preloaded \(sfxBuffers.count) sound effects via AVAudioEngine")
    }

    // MARK: - SFX Playback

    func playSound(_ sound: SoundEffect) {
        guard isSoundEnabled else { return }

        // Respect user's device volume
        guard AVAudioSession.sharedInstance().outputVolume > 0 else { return }
        guard let buffer = sfxBuffers[sound] else { return }

        // Ensure engine is running
        startEngine()

        // Acquire a player node from the pool (round-robin)
        let playerNode = sfxPlayerNodes[nextPlayerIndex]
        if playerNode.isPlaying {
            playerNode.stop()
        }
        nextPlayerIndex = (nextPlayerIndex + 1) % maxSFXPlayers

        // Schedule and play the buffer
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        playerNode.play()

        // Trigger ducking for attack sounds
        if sound == .attackIncoming {
            duckMusic()
        } else if sound == .attackEnd {
            unduckMusic()
        }

        // Trigger haptic feedback
        guard isHapticsEnabled else { return }
        HapticManager.playPattern(for: sound)
    }

    /// Play button tap sound - lightweight for frequent use
    func playButtonTap() {
        playSound(.tick)
    }

    /// Speak text with distorted "AI" voice for Malus
    func speakMalusMessage(_ text: String) {
        guard isSoundEnabled else { return }
        playSound(.malusMessage)
    }

    // MARK: - Music Playback

    func startMusic() {
        guard !isMusicPlaying else { return }
        guard AVAudioSession.sharedInstance().outputVolume > 0 else { return }

        startEngine()

        // Load music buffer if needed
        if musicBuffer == nil {
            guard let url = Bundle.main.url(forResource: "background_music", withExtension: "m4a") else {
                print("Background music file not found in bundle")
                return
            }
            do {
                let audioFile = try AVAudioFile(forReading: url)
                let format = audioFile.processingFormat
                let frameCount = AVAudioFrameCount(audioFile.length)
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                    return
                }
                try audioFile.read(into: buffer)
                musicBuffer = buffer
            } catch {
                print("Failed to load background music: \(error)")
                return
            }
        }

        scheduleLoopingMusic()
        musicPlayerNode.play()
        isMusicPlaying = true
        print("Background music started playing via AVAudioEngine")
    }

    private func scheduleLoopingMusic() {
        guard let buffer = musicBuffer else { return }
        musicPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
    }

    func stopMusic() {
        musicPlayerNode.stop()
        isMusicPlaying = false
        print("Background music stopped")
    }

    /// Pause music (for when app goes to background)
    func pauseMusic() {
        musicPlayerNode.pause()
    }

    /// Resume music (for when app returns to foreground)
    func resumeMusic() {
        guard isMusicPlaying else { return }
        guard AVAudioSession.sharedInstance().outputVolume > 0 else { return }
        startEngine()
        musicPlayerNode.play()
    }

    func setMusicVolume(_ newVolume: Float) {
        musicVolume = max(0, min(1, newVolume))
        musicMixerNode.volume = musicVolume
    }

    var isMusicActive: Bool {
        isMusicPlaying
    }

    // MARK: - Audio Ducking

    /// Duck music volume during attacks for SFX clarity
    private func duckMusic() {
        guard duckState == .normal else { return }
        duckState = .ducked
        preDuckMusicVolume = musicMixerNode.volume
        let targetVolume = preDuckMusicVolume * duckRatio
        rampMusicVolume(to: targetVolume, duration: 0.5, completion: nil)
    }

    /// Restore music volume after attack ends
    private func unduckMusic() {
        guard duckState == .ducked else { return }
        duckState = .restoring
        rampMusicVolume(to: preDuckMusicVolume, duration: 1.0) { [weak self] in
            self?.duckState = .normal
        }
    }

    private func rampMusicVolume(to target: Float, duration: TimeInterval, completion: (() -> Void)?) {
        duckTimer?.cancel()

        let steps = 20
        let stepDuration = duration / Double(steps)
        let startVolume = musicMixerNode.volume
        let delta = (target - startVolume) / Float(steps)
        var currentStep = 0

        let timer = DispatchSource.makeTimerSource(queue: .global(qos: .userInteractive))
        timer.schedule(deadline: .now(), repeating: stepDuration)
        timer.setEventHandler { [weak self] in
            currentStep += 1
            let newVolume = startVolume + delta * Float(currentStep)
            self?.musicMixerNode.volume = newVolume
            if currentStep >= steps {
                self?.musicMixerNode.volume = target
                timer.cancel()
                completion?()
            }
        }
        timer.resume()
        duckTimer = timer
    }

    // MARK: - Settings

    func toggleSound() {
        isSoundEnabled.toggle()
    }

    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
    }

    func setHapticsEnabled(_ enabled: Bool) {
        isHapticsEnabled = enabled
    }

    func toggleHaptics() {
        isHapticsEnabled.toggle()
    }

    func setVolume(_ volume: Float) {
        soundVolume = max(0, min(1, volume))
        sfxMixerNode.volume = soundVolume
    }

    var isEnabled: Bool {
        isSoundEnabled
    }

    var hapticsEnabled: Bool {
        isHapticsEnabled
    }
}

// MARK: - Background Music Manager (Facade)

/// Thin facade delegating to AudioManager's unified AVAudioEngine.
/// Preserves existing call sites in NavigationCoordinator and AudioSettings.
final class AmbientAudioManager: @unchecked Sendable {
    static let shared = AmbientAudioManager()

    private init() {}

    func startAmbient() {
        AudioManager.shared.startMusic()
    }

    func stopAmbient() {
        AudioManager.shared.stopMusic()
    }

    func setVolume(_ newVolume: Float) {
        AudioManager.shared.setMusicVolume(newVolume)
    }

    func toggleAmbient() {
        if isAmbientPlaying {
            stopAmbient()
        } else {
            startAmbient()
        }
    }

    var isAmbientPlaying: Bool {
        AudioManager.shared.isMusicActive
    }

    /// Pause music (for when app goes to background)
    func pause() {
        AudioManager.shared.pauseMusic()
    }

    /// Resume music (for when app returns to foreground)
    func resume() {
        AudioManager.shared.resumeMusic()
    }
}

// MARK: - Haptic Manager (Core Haptics + UIKit Fallback)

struct HapticManager {
    private static var hapticEngine: CHHapticEngine?
    private static var engineNeedsRestart: Bool = true
    private static let supportsHaptics: Bool = CHHapticEngine.capabilitiesForHardware().supportsHaptics

    // Cached AHAP patterns
    private static var patterns: [SoundEffect: CHHapticPattern] = [:]

    // MARK: - Engine Setup

    /// Initialize Core Haptics engine and preload AHAP patterns
    static func prepareEngine() {
        guard supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.stoppedHandler = { _ in
                engineNeedsRestart = true
            }
            hapticEngine?.resetHandler = {
                do {
                    try hapticEngine?.start()
                    engineNeedsRestart = false
                } catch {
                    engineNeedsRestart = true
                }
            }
            try hapticEngine?.start()
            engineNeedsRestart = false
        } catch {
            print("Haptic engine creation failed: \(error)")
        }
        preloadPatterns()
    }

    private static func ensureEngineRunning() {
        guard supportsHaptics, engineNeedsRestart else { return }
        do {
            try hapticEngine?.start()
            engineNeedsRestart = false
        } catch {
            print("Haptic engine restart failed: \(error)")
        }
    }

    // MARK: - AHAP Pattern Loading

    private static func preloadPatterns() {
        for sound in SoundEffect.allCases {
            guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "ahap") else {
                continue
            }
            do {
                let data = try Data(contentsOf: url)
                guard let dict = try JSONSerialization.jsonObject(with: data) as? [CHHapticPattern.Key: Any] else {
                    continue
                }
                let pattern = try CHHapticPattern(dictionary: dict)
                patterns[sound] = pattern
            } catch {
                print("Failed to load haptic pattern for \(sound.fileName): \(error)")
            }
        }
        print("Preloaded \(patterns.count) haptic patterns")
    }

    // MARK: - Pattern Playback

    /// Play the AHAP haptic pattern associated with a sound effect
    static func playPattern(for sound: SoundEffect) {
        guard AudioManager.shared.hapticsEnabled else { return }

        if supportsHaptics, let pattern = patterns[sound] {
            ensureEngineRunning()
            do {
                let player = try hapticEngine?.makePlayer(with: pattern)
                try player?.start(atTime: CHHapticTimeImmediate)
            } catch {
                // Fall through to UIKit fallback
                Task { @MainActor in
                    playUIKitFallback(for: sound)
                }
            }
        } else {
            Task { @MainActor in
                playUIKitFallback(for: sound)
            }
        }
    }

    @MainActor
    private static func playUIKitFallback(for sound: SoundEffect) {
        switch sound {
        case .attackIncoming, .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .malusMessage:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .upgrade, .milestone:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        default:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    // MARK: - Existing Public API (preserved for call sites)

    @MainActor
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard AudioManager.shared.hapticsEnabled else { return }
        if supportsHaptics {
            let intensity: Float
            switch style {
            case .light: intensity = 0.4
            case .medium: intensity = 0.6
            case .heavy: intensity = 0.8
            case .rigid: intensity = 0.9
            case .soft: intensity = 0.3
            @unknown default: intensity = 0.5
            }
            playTransient(intensity: intensity, sharpness: 0.5)
        } else {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }

    @MainActor
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard AudioManager.shared.hapticsEnabled else { return }
        if supportsHaptics {
            let sound: SoundEffect
            switch type {
            case .success: sound = .upgrade
            case .warning: sound = .warning
            case .error: sound = .error
            @unknown default: sound = .tick
            }
            playPattern(for: sound)
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(type)
        }
    }

    @MainActor
    static func selection() {
        guard AudioManager.shared.hapticsEnabled else { return }
        if supportsHaptics {
            playTransient(intensity: 0.3, sharpness: 0.6)
        } else {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }

    // MARK: - Helpers

    private static func playTransient(intensity: Float, sharpness: Float) {
        ensureEngineRunning()
        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Silent failure is acceptable for haptics
        }
    }
}
