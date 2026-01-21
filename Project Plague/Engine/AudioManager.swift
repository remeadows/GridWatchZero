// AudioManager.swift
// ProjectPlague
// Sound effects and audio management

import AVFoundation
import UIKit
import SwiftUI

// MARK: - Sound Types

enum SoundEffect: String, CaseIterable {
    case upgrade = "upgrade"
    case attackIncoming = "attack_incoming"
    case attackEnd = "attack_end"
    case malusMessage = "malus_message"
    case tick = "tick"
    case error = "error"
    case milestone = "milestone"
    case warning = "warning"

    /// System sound with cyberpunk/electronic feel
    var systemSoundID: SystemSoundID {
        switch self {
        case .upgrade: return 1113        // Ascending electronic tone
        case .attackIncoming: return 1005 // Harsh digital alarm
        case .attackEnd: return 1111      // Electronic sweep down
        case .malusMessage: return 1033   // Deep electronic pulse
        case .tick: return 1103           // Soft electronic blip
        case .error: return 1006          // Harsh digital buzz
        case .milestone: return 1115      // Synth achievement chime
        case .warning: return 1007        // Electronic warning beep
        }
    }
}

// MARK: - Audio Manager

final class AudioManager: @unchecked Sendable {
    static let shared = AudioManager()

    private var isSoundEnabled: Bool = true
    private var volume: Float = 0.7

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    func playSound(_ sound: SoundEffect) {
        guard isSoundEnabled else { return }

        // Use system sound as fallback
        AudioServicesPlaySystemSound(sound.systemSoundID)

        // Add haptic feedback for important events
        Task { @MainActor in
            switch sound {
            case .attackIncoming, .warning:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            case .malusMessage:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            case .upgrade, .milestone:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            default:
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }

    /// Speak text with distorted "AI" voice for Malus
    func speakMalusMessage(_ text: String) {
        guard isSoundEnabled else { return }
        playSound(.malusMessage)
    }

    func toggleSound() {
        isSoundEnabled.toggle()
    }

    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
    }
}

// MARK: - Ambient Audio Manager

/// Generates procedural ambient cyberpunk background audio
final class AmbientAudioManager: @unchecked Sendable {
    static let shared = AmbientAudioManager()

    private var audioEngine: AVAudioEngine?
    private var toneNode: AVAudioSourceNode?
    private var isPlaying: Bool = false
    private var volume: Float = 0.15

    // Tone parameters for cyberpunk drone
    private var baseFrequency: Double = 55.0  // Low A
    private var phase: Double = 0.0
    private var lfoPhase: Double = 0.0

    private init() {}

    func startAmbient() {
        guard !isPlaying else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Ambient audio session setup failed: \(error)")
            return
        }

        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }

        let mainMixer = engine.mainMixerNode
        let outputFormat = mainMixer.outputFormat(forBus: 0)
        let sampleRate = outputFormat.sampleRate

        // Create procedural tone generator
        toneNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }

            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                // Low frequency oscillator for subtle modulation
                let lfoRate = 0.1  // Very slow modulation
                self.lfoPhase += lfoRate / sampleRate
                if self.lfoPhase > 1.0 { self.lfoPhase -= 1.0 }
                let lfo = sin(self.lfoPhase * 2.0 * .pi) * 5.0  // ±5Hz modulation

                // Main oscillator with LFO modulation
                let frequency = self.baseFrequency + lfo
                self.phase += frequency / sampleRate
                if self.phase > 1.0 { self.phase -= 1.0 }

                // Mix of sine and slight saw for richer tone
                let sine = sin(self.phase * 2.0 * .pi)
                let saw = (self.phase * 2.0 - 1.0)
                let sample = Float((sine * 0.7 + saw * 0.3) * Double(self.volume))

                // Apply soft envelope/filter effect
                let filtered = sample * 0.8

                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = filtered
                }
            }

            return noErr
        }

        guard let toneNode = toneNode else { return }

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.attach(toneNode)
        engine.connect(toneNode, to: mainMixer, format: format)

        mainMixer.outputVolume = 1.0

        do {
            try engine.start()
            isPlaying = true
        } catch {
            print("Ambient audio engine start failed: \(error)")
        }
    }

    func stopAmbient() {
        audioEngine?.stop()
        if let toneNode = toneNode {
            audioEngine?.detach(toneNode)
        }
        toneNode = nil
        audioEngine = nil
        isPlaying = false
    }

    func setVolume(_ newVolume: Float) {
        volume = max(0, min(1, newVolume)) * 0.2  // Cap at 20% for ambient
    }

    func toggleAmbient() {
        if isPlaying {
            stopAmbient()
        } else {
            startAmbient()
        }
    }

    var isAmbientPlaying: Bool {
        isPlaying
    }
}

// MARK: - Haptic Manager

struct HapticManager {
    @MainActor
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    @MainActor
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    @MainActor
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
