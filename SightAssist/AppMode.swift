//
//  AppMode.swift
//  SightAssist
//

import Foundation

enum AppMode: String, CaseIterable {
    case context    // Modus 1: Kontext-Beschreiber (OCR)
    case detection  // Modus 2: Objekt-Erkennung (Person/Text/Schild)

    var voiceOverLabel: String {
        switch self {
        case .context:
            return "Modus 1: Kontext-Beschreiber – erkennt Text in der Umgebung."
        case .detection:
            return "Modus 2: Objekt-Erkennung – erkennt Personen, Text und Schilder."
        }
    }

    var shortLabel: String {
        switch self {
        case .context:
            return "Kontext-Beschreiber"
        case .detection:
            return "Objekt-Erkennung"
        }
    }

    var accessibilityHint: String {
        switch self {
        case .context:
            return "Doppeltippen zum Analysieren des Kamerabilds auf Text."
        case .detection:
            return "Doppeltippen zum Erkennen von Objekten im Kamerabild."
        }
    }
}
