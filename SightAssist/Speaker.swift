import Foundation
import AVFoundation

final class Speaker: ObservableObject {
    private let synth = AVSpeechSynthesizer()

    func speak(_ text: String, language: String = "de-DE") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synth.stopSpeaking(at: .immediate)
        synth.speak(utterance)
    }
}
