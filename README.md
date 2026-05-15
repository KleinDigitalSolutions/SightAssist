# SightAssist

[![Swift](https://img.shields.io/badge/Swift-5.0+-FA7343?style=flat-square&logo=swift)](https://www.swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018+-000000?style=flat-square&logo=apple)](https://www.apple.com/ios)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-blue?style=flat-square)](https://developer.apple.com/xcode/swiftui)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**KI-Sehhilfe für blinde Menschen. Analysiert die Kamera und spricht das Ergebnis — komplett lokal, kein Internet.**

## Modi

| # | Modus | Geste |
|---|-------|-------|
| 1 | **Scannen** | Tippen — Text, Personen, Farbe |
| 2 | **Navigieren** | Live — Ampeln, Bus, Schilder |

*Modus 3 (KI-Bildbeschreibung via Gemma 4) optional, via `AppMode.vlmEnabled = true`.*

## Bedienung

| Geste | Aktion |
|---|---|
| Einfach tippen | Scannen |
| Wischen links/rechts | Modus wechseln |

Erklärt sich beim ersten Benutzen selbst. VoiceOver-kompatibel.

## Voraussetzungen

- iOS 18+, jedes iPhone mit Kamera
- iPhone 14+ (6 GB RAM) nur für optionalen VLM-Modus

## Architektur

`SightAssistApp.swift` → `ContentView.swift` → `ModeManager`, `CaptureController`, `ObjectDetector`, `LiveNavigationAnalyzer`, `Haptics`, `Speaker` (Premium Anna), `VisionModel` (optional)

## Berechtigungen

`NSCameraUsageDescription`, `NSMicrophoneUsageDescription` (vorbereitet), `NSSpeechRecognitionUsageDescription` (vorbereitet)

## Installation

```bash
git clone https://github.com/KleinDigitalSolutions/SightAssist.git
cd SightAssist && open SightAssist.xcodeproj
```

## Lizenz

MIT

---

*Für blinde Nutzer entwickelt. VoiceOver-optimiert. Keine visuelle UI nötig.*
