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
        speechQueue.append(text)
        processQueue(language: language)
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
