//
//  AppMode.swift
//  SightAssist
//

import Foundation

enum AppMode: String, CaseIterable {
    case context    // Modus 1: Kontext-Beschreiber – Vision OCR
    case detection  // Modus 2: Objekt-Erkennung – Person + Text
    case vlm        // Modus 3: VLM-Bildbeschreibung – Gemma 4 lokal

    var voiceOverLabel: String {
        switch self {
        case .context:
            return "Modus 1: Kontext-Beschreiber – erkennt Text in der Umgebung."
        case .detection:
            return "Modus 2: Objekt-Erkennung – erkennt Personen, Text und Schilder."
        case .vlm:
            return "Modus 3: Bildbeschreibung – beschreibt das Bild detailliert mit lokaler KI."
        }
    }

    var shortLabel: String {
        switch self {
        case .context:
            return "Kontext"
        case .detection:
            return "Objekte"
        case .vlm:
            return "VLM"
        }
    }

    var accessibilityHint: String {
        switch self {
        case .context:
            return "Doppeltippen zum Analysieren des Kamerabilds auf Text."
        case .detection:
            return "Doppeltippen zum Erkennen von Objekten im Kamerabild."
        case .vlm:
            return "Doppeltippen für eine KI-Bildbeschreibung. Benötigt Modell-Download beim ersten Start."
        }
    }
}
