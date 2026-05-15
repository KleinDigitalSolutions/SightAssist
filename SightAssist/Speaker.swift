import Foundation
import AVFoundation
import Combine

final class Speaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synth = AVSpeechSynthesizer()
    private var speechQueue: [String] = []
    private var isProcessingQueue = false

    @Published private(set) var isSpeaking = false

    override init() {
        super.init()
        synth.delegate = self
    }

    func speak(_ text: String, language: String = "de-DE") {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        speechQueue.append(trimmed)
        processQueue(language: language)
    }

    /// Satzweise puffern: spricht erst bei Satzzeichen (., !, ?, :, \n)
    func streamChunk(_ chunk: String, buffer: inout String) {
        buffer += chunk
        let enders: Set<Character> = [".", "!", "?", ":", "\n"]
        if let last = buffer.last, enders.contains(last) {
            let toSpeak = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
            if !toSpeak.isEmpty { speak(toSpeak) }
            buffer = ""
        }
    }

    private func processQueue(language: String = "de-DE") {
        guard !isProcessingQueue, !speechQueue.isEmpty else { return }
        isProcessingQueue = true
        let text = speechQueue.removeFirst()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synth.speak(utterance)
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        isProcessingQueue = false
        if !speechQueue.isEmpty {
            processQueue()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        isProcessingQueue = false
        if !speechQueue.isEmpty {
            processQueue()
        }
    }
}
