import Foundation

#if canImport(CoreHaptics)
import CoreHaptics

enum Haptics {
    private static var hapticEngine: CHHapticEngine?

    static func tap() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let engine: CHHapticEngine
            if let existing = hapticEngine {
                engine = existing
            } else {
                engine = try CHHapticEngine()
                hapticEngine = engine
            }
            try engine.start()
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            engine.notifyWhenPlayersFinished { _ in .stopEngine }
        } catch {
            // Fail silently
        }
    }
}

#else

enum Haptics {
    static func tap() {}
}

#endif
