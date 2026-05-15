import Foundation
import CoreHaptics

enum Haptics {
    static func tap() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let engine = try CHHapticEngine()
            try engine.start()
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            engine.notifyWhenPlayersFinished { _ in .stopEngine }
        } catch {
            // Fail silently for devices without haptics or errors
        }
    }
}
