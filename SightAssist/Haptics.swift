//
//  Haptics.swift
//  SightAssist
//

import Foundation

#if canImport(CoreHaptics)
import CoreHaptics

enum Haptics {
    private static var engine: CHHapticEngine?
    private static var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    enum Direction { case left, right }

    // MARK: - Pattern: Richtung

    static func direction(_ dir: Direction) {
        guard supportsHaptics else { return }
        let events: [CHHapticEvent]
        switch dir {
        case .left:
            events = [event(0.0, 0.6, 0.4), event(0.08, 0.3, 0.4)]
        case .right:
            events = [event(0.0, 0.3, 0.4), event(0.08, 0.6, 0.4)]
        }
        play(events)
    }

    // MARK: - Pattern: Erfolg (lang, weich)

    static func success() {
        guard supportsHaptics else { return }
        play([
            event(0.0, 0.3, 0.2),
            event(0.1, 0.6, 0.3),
            event(0.25, 0.8, 0.35),
            event(0.45, 0.4, 0.25),
        ])
    }

    // MARK: - Pattern: Fehler (doppelt kurz)

    static func error() {
        guard supportsHaptics else { return }
        play([
            event(0.0, 0.8, 0.5),
            event(0.15, 0.0, 0.0),
            event(0.25, 0.8, 0.5),
        ])
    }

    // MARK: - Pattern: Denken (rhythmisch, für Gemma)

    static func thinking() {
        guard supportsHaptics else { return }
        play((0..<3).map { i in event(Double(i) * 0.4, 0.4, 0.3) })
    }

    // MARK: - Intern

    private static func event(_ time: TimeInterval, _ intensity: Float, _ sharpness: Float) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
            ],
            relativeTime: time
        )
    }

    private static func play(_ events: [CHHapticEvent]) {
        do {
            if engine == nil { engine = try CHHapticEngine() }
            try engine?.start()
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            engine?.notifyWhenPlayersFinished { _ in .stopEngine }
        } catch {}
    }
}

#else

enum Haptics {
    enum Direction { case left, right }
    static func direction(_ dir: Direction) {}
    static func success() {}
    static func error() {}
    static func thinking() {}
}

#endif
