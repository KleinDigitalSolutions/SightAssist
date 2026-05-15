# SightAssist

[![Swift](https://img.shields.io/badge/Swift-5.0+-FA7343?style=flat-square&logo=swift)](https://www.swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018+-000000?style=flat-square&logo=apple)](https://www.apple.com/ios)
[![Devices](https://img.shields.io/badge/Devices-iPhone%2014+-blue?style=flat-square)](https://www.apple.com/iphone)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-blue?style=flat-square)](https://developer.apple.com/xcode/swiftui)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**Eine KI-gestützte Sehhilfe-App für blinde und sehbehinderte Menschen. Nimmt die Umgebung über die Kamera auf, analysiert sie mit lokaler KI und beschreibt sie per Sprachausgabe – vollständig auf dem Gerät, kein Internet nötig.**

## 🎯 Für wen und warum

SightAssist verwandelt ein iPhone in ein sprechendes Auge. Die App fotografiert die Umgebung, erkennt Text, Gegenstände und Personen und liest die Beschreibung vor. Alles läuft lokal auf dem Gerät – kein einziges Byte verlässt das iPhone. Das ist entscheidend, denn:

- **Kein Netz nötig** – funktioniert auch in Kellern, U‑Bahnen, Wald
- **Keine Privatsphäre‑Risiken** – Bilder werden nie hochgeladen
- **Sofort** – keine Latenz durch Server‑Anfragen
- **Zuverlässig** – kein Cloud-Dienst, der ausfallen kann

## 📱 System-Voraussetzungen

| Anforderung | Minimum |
|---|---|
| iOS | 18.0 oder höher |
| Gerät | iPhone 14 oder neuer |
| RAM | 6 GB (für lokale KI-Modelle) |
| Kamera | Rückkamera erforderlich |

*App läuft auch auf Mac (Apple Silicon) und Apple Vision Pro mit reduzierter Funktionalität.*

## ✨ Modi

| # | Modus | Geste | Funktion |
|---|-------|-------|----------|
| 1 | **Scannen** | Single Tap | Text, Objekte, Farbe parallel |
| 2 | **Navigieren** | Live (kein Tap) | Ampeln, Buslinien, Schilder |
| 3 | **Beschreiben** | Double Tap | Gemma 4 E2B lokal |

Wischen wechselt den Modus. VoiceOver sagt jeden Modus an.



## 🏗️ Architektur

```
SightAssist/
├── SightAssistApp.swift          # @main Einstiegspunkt
├── ContentView.swift              # Haupt-UI: Kamera, Modi, Gesten
├── AppMode.swift                  # Modus-Enum (Kontext / Objekt-Erkennung)
├── CameraView.swift               # AVCaptureSession SwiftUI-Wrapper
├── CaptureController.swift        # Kamera-Zugriff, Session, Aufnahme
├── TextRecognizer.swift           # Vision OCR
├── ObjectDetector.swift           # Multi-Detektion: Text + Personen + Farbe
├── Speaker.swift                  # Premium-Voice TTS + Queue
├── Haptics.swift                  # 4 Muster: Richtung, Erfolg, Fehler, Denken
├── Utilities.swift                # Gemeinsame Extensions
├── AppMode.swift                  # 3 Modi: Scannen, Navigieren, Beschreiben
├── ModeManager.swift              # Modus-Wechsel + VoiceOver + Haptik
├── CameraGuidance.swift           # Framing-Assistent
├── LiveNavigationAnalyzer.swift   # Live: Ampeln, Buslinien, Schilder
├── VisionModel.swift              # Gemma 4 E2B via MLX Swift
└── Assets.xcassets/               # App-Icon
```

## 🧱 Technologie-Stack

| Komponente | Technologie |
|---|---|
| UI | SwiftUI |
| Kamera | AVFoundation (AVCaptureSession) |
| OCR | Vision (VNRecognizeTextRequest) |
| Objekt-Erkennung | Vision (VNDetectHumanRectanglesRequest) |
| Sprachausgabe | AVSpeechSynthesizer |
| Haptik | CoreHaptics |
| Geplant: VLM | MLX Swift + Gemma 4 E2B |
| Barrierefreiheit | VoiceOver, Accessibility Labels, Hints |

## 🎮 Bedienung

| Geste | Aktion |
|---|---|
| **Doppeltippen** | Bild analysieren (aktueller Modus) |
| **Nach links wischen** | Nächster Modus |
| **Nach rechts wischen** | Vorheriger Modus |

VoiceOver sagt den aktuellen Modus beim Start und bei jedem Wechsel an.

## 🔐 Berechtigungen

| Schlüssel | Grund |
|---|---|
| `NSCameraUsageDescription` | Kamera-Zugriff für Umgebungsanalyse |
| (geplant) `NSMicrophoneUsageDescription` | Spracheingabe für Fragen |
| (geplant) `NSSpeechRecognitionUsageDescription` | On‑Device Spracherkennung |

## 🚀 Installation

```bash
git clone https://github.com/KleinDigitalSolutions/SightAssist.git
cd SightAssist
open SightAssist.xcodeproj
```

Team in Signing & Capabilities setzen, ⌘R.

## 📄 Lizenz

MIT – siehe [LICENSE](LICENSE).

## 👤 Autor

**Özgür Azap** – [@KleinDigitalSolutions](https://github.com/KleinDigitalSolutions)

---

*Entwickelt mit Fokus auf Barrierefreiheit. Alle Features sind für VoiceOver optimiert.*