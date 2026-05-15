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

### Modus 1: Kontext-Beschreiber (OCR)
Erkennt Text im Kamerabild und liest ihn vor. Für Schilder, Speisekarten, Türschilder, Produktetiketten.

### Modus 2: Objekt-Erkennung (Person, Text, Schild)
Erkennt Personen und Text gleichzeitig. Sagt z. B.: *„2 Personen erkannt. Text: Notausgang.“*

*Geplant: Modus 3 – lokale VLM-Bildbeschreibung mit Google Gemma 4 E2B*

## 🏗️ Architektur

```
SightAssist/
├── SightAssistApp.swift          # @main Einstiegspunkt
├── ContentView.swift              # Haupt-UI: Kamera, Modi, Gesten
├── AppMode.swift                  # Modus-Enum (Kontext / Objekt-Erkennung)
├── CameraView.swift               # AVCaptureSession SwiftUI-Wrapper
├── CaptureController.swift        # Kamera-Zugriff, Session, Aufnahme
├── TextRecognizer.swift           # Vision OCR (VNRecognizeTextRequest)
├── ObjectDetector.swift           # Vision Person+Text (VNDetectHumanRectangles)
├── Speaker.swift                  # TTS mit AVSpeechSynthesizer + Queue
├── Haptics.swift                  # Haptisches Feedback
├── Utilities.swift                # Gemeinsame Extensions
└── Assets.xcassets/               # App-Icon und Assets
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
