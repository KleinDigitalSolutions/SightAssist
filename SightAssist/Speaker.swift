//
//  Speaker.swift
//  SightAssist
//

import Foundation
import AVFoundation
import Combine

final class Speaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synth = AVSpeechSynthesizer()
    private var speechQueue: [String] = []
    private var isProcessingQueue = false
    private let voice: AVSpeechSynthesisVoice

    @Published private(set) var isSpeaking = false

    override init() {
        self.voice = Speaker.findBestGermanVoice()
        super.init()
        synth.delegate = self
    }

    /// Sucht die beste deutsche Stimme: Premium > Enhanced > Standard
    private static func findBestGermanVoice() -> AVSpeechSynthesisVoice {
        if let premium = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.de-DE.Anna") {
            return premium
        }
        let enhancedIDs = [
            "com.apple.voice.enhanced.de-DE.Anna",
            "com.apple.voice.enhanced.de-DE.Helena",
            "com.apple.voice.enhanced.de-DE.Martin",
        ]
        for id in enhancedIDs {
            if let voice = AVSpeechSynthesisVoice(identifier: id) { return voice }
        }
        for name in ["Helena", "Martin"] {
            if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.de-DE.\(name)") {
                return voice
            }
        }
        if let standard = AVSpeechSynthesisVoice(language: "de-DE") { return standard }
        return AVSpeechSynthesisVoice(language: "de-DE") ?? AVSpeechSynthesisVoice()
    }

    func speak(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        speechQueue.append(trimmed)
        processQueue()
    }

    func streamChunk(_ chunk: String, buffer: inout String) {
        buffer += chunk
        let enders: Set<Character> = [".", "!", "?", ":", "\n"]
        if let last = buffer.last, enders.contains(last) {
            let toSpeak = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
            if !toSpeak.isEmpty { speak(toSpeak) }
            buffer = ""
        }
    }

    func stop() {
        synth.stopSpeaking(at: .immediate)
        speechQueue.removeAll()
        isProcessingQueue = false
    }

    private func processQueue() {
        guard !isProcessingQueue, !speechQueue.isEmpty else { return }
        isProcessingQueue = true
        let text = speechQueue.removeFirst()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        synth.speak(utterance)
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        isProcessingQueue = false
        if !speechQueue.isEmpty { processQueue() }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        isProcessingQueue = false
        if !speechQueue.isEmpty { processQueue() }
    }
}
