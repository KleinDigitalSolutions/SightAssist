//
//  AppMode.swift
//  SightAssist
//

import Foundation

enum AppMode: String, CaseIterable {
    case scan       // Modus 1: Scannen – Text, Objekte, Farbe (Single Tap)
    case navigate   // Modus 2: Navigieren – Live, Bus, Ampel (kein Tap)
    case describe   // Modus 3: Beschreiben – Gemma (Double Tap)

    static let vlmEnabled = false
    static var activeCases: [AppMode] {
        allCases.filter { $0 != .describe || vlmEnabled }
    }

    var voiceOverLabel: String {
        switch self {
        case .scan:
            return "Modus: Scannen. Einfach tippen. Erkennt Text, Objekte und Farben."
        case .navigate:
            return "Modus: Navigieren. Läuft live. Erkennt Ampeln, Buslinien und Schilder."
        case .describe:
            return "Modus: Beschreiben. Doppeltippen für KI-Bildbeschreibung."
        }
    }

    var shortLabel: String {
        switch self {
        case .scan:      return "Scannen"
        case .navigate:  return "Navigieren"
        case .describe:  return "Beschreiben"
        }
    }

    var launchAnnouncement: String {
        switch self {
        case .scan:
            return "SightAssist bereit. Modus Scannen. Einfach tippen zum Analysieren."
        case .navigate:
            return "SightAssist bereit. Modus Navigieren. Kamera auf die Umgebung richten."
        case .describe:
            return "SightAssist bereit. Modus Beschreiben. Doppeltippen für KI-Analyse."
        }
    }
}
