# SightAssist

[![Swift](https://img.shields.io/badge/Swift-5.9+-FF6B6B?style=flat-square&logo=swift)](https://www.swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-000000?style=flat-square&logo=apple)](https://www.apple.com/ios)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-blue?style=flat-square)](https://developer.apple.com/xcode/swiftui)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

Eine moderne iOS-App zur Bildanalyse mit Kamerazugriff und Sprachausgabe. SightAssist nutzt SwiftUI und AVFoundation für eine benutzerfreundliche Oberfläche und bietet umfangreiche Barrierefreiheitsfunktionen.

## 🎯 Features

- 📷 **Live-Kameravorschau** – Echtzeit-Kamerafeed mit optimalem Seitenverhältnis
- 🖼️ **Bildanalyse** – Verarbeitung und Analyse von Fotos
- 🔊 **Sprachausgabe** – Akustische Ausgabe von Analyseergebnissen
- ♿ **Barrierefreiheit** – Umfangreiche VoiceOver- und Accessibility-Unterstützung
- 🎨 **Native SwiftUI UI** – Modernes Design mit gerundeten Elementen und Material-Effekten
- 🚀 **Performant** – Optimiert für schnelle Bildverarbeitung

## 📋 Systemanforderungen

- **iOS 16.0** oder höher
- **Xcode 15.0** oder höher
- **Swift 5.9** oder höher
- Gerät mit Kamera (iPhone oder iPad)

## 🚀 Installation

### Aus dem Quellcode

1. Repository klonen:
```bash
git clone https://github.com/KleinDigitalSolutions/SightAssist.git
cd SightAssist
```

2. In Xcode öffnen:
```bash
open SightAssist.xcodeproj
```

3. Zielgerät auswählen und **Run** drücken (⌘R)

### Anforderungen im Info.plist

Die App benötigt folgende Berechtigungen:
- **NSCameraUsageDescription** – Kamerazugriff
- **NSMicrophoneUsageDescription** – Mikrofonzugriff (optional, für Sprachausgabe)

## 📁 Projektstruktur

```
SightAssist/
├── SightAssistApp.swift          # App-Einstiegspunkt
├── ContentView.swift              # Hauptschnittstelle mit Kamera & Bedienelemente
├── CameraView.swift               # UIViewRepresentable Kamera-Komponente
├── CaptureController.swift        # Verwaltung der Bildaufnahme
├── Speaker.swift                  # Sprachausgabe-Modul
├── Assets.xcassets/               # App-Icons und Assets
└── README.md                       # Diese Datei

SightAssistTests/                  # Unit Tests
SightAssistUITests/                # UI-Tests
```

## 💻 Hauptkomponenten

### ContentView
Die zentrale Benutzeroberfläche mit:
- Live-Kamerastream
- Doppeltipp-Gesten zum Analysieren
- Statusanzeige (Analysieren/Bereit)
- Barrierefreiheitsunterstützung

### CameraView
SwiftUI-Wrapper für AVCaptureSession:
- Kamera-Videostream-Rendering
- Optimiertes Seitenverhältnis (resizeAspectFill)
- UIViewRepresentable-Implementierung

### CaptureController
ObservableObject zur Verwaltung:
- AVCaptureSession
- Gerätezugriff und Berechtigungen
- Bilderfassung und Verarbeitung

### Speaker
Sprachausgabe-Modul für:
- Text-zu-Sprache (AVSpeechSynthesizer)
- Deutsche Sprachausgabe
- Asynchrone Verarbeitung

## 🎮 Verwendung

### Einfache Bildanalyse

1. App öffnen
2. Kamera auf Objekt/Szene richten
3. **Doppeltippen** auf dem Bildschirm
4. Analyseergebnis wird vorgelesen

### Mit VoiceOver

Die App ist vollständig für VoiceOver optimiert:
- **Doppeltippen**: Bild analysieren
- **Alle UI-Elemente** sind beschriftet
- **Englische/Deutsche Labels** verfügbar

## 🔧 Konfiguration

### Kamerazugriff aktivieren

In `ContentView.swift`:
```swift
CameraView(session: controller.session)
    .accessibilityLabel("Kameravorschau")
```

### Sprache anpassen

In `Speaker.swift` die Sprache wechseln:
```swift
utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
```

## 🧪 Tests

### Unit Tests ausführen
```bash
xcodebuild test -scheme SightAssist
```

### UI Tests ausführen
```bash
xcodebuild test -scheme SightAssistUITests
```

## 📱 Build & Deployment

### Release Build erstellen
```bash
xcodebuild -scheme SightAssist -configuration Release build
```

### Für App Store
1. Xcode → Product → Archive
2. Organizer öffnen
3. App Store Connect → Distribute App

## 🤝 Contributing

Beiträge sind willkommen! Bitte folgen Sie diesen Schritten:

1. Fork des Repositories
2. Feature Branch erstellen (`git checkout -b feature/AmazingFeature`)
3. Änderungen committen (`git commit -m 'Add AmazingFeature'`)
4. Branch pushen (`git push origin feature/AmazingFeature`)
5. Pull Request öffnen

### Code Style
- SwiftUI-Konventionen verwenden
- Barrierefreiheit beachten (accessibility labels)
- Aussagekräftige Commits schreiben

## 🐛 Bug Reports

Bugs können über GitHub Issues gemeldet werden. Bitte folgendes hinzufügen:
- iOS-Version
- Gerät (iPhone/iPad)
- Schritte zum Reproduzieren
- Erwartetes vs. aktuelles Verhalten

## 📄 Lizenz

Dieses Projekt ist unter der [MIT-Lizenz](LICENSE) lizenziert. Siehe die [LICENSE](LICENSE) Datei für Details.

## 👤 Autor

**Özgür Azap** – [@KleinDigitalSolutions](https://github.com/KleinDigitalSolutions)

## 🙏 Danksagungen

- Apple SwiftUI Framework
- AVFoundation für Kamerazugriff
- Community für Feedback und Unterstützung

## 📚 Ressourcen

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [AVFoundation Guide](https://developer.apple.com/av-foundation/)
- [Accessibility Guide](https://developer.apple.com/accessibility/)

---

**Aktiv entwickelt** ✨ – Für Fragen und Suggestions: [Issues](https://github.com/KleinDigitalSolutions/SightAssist/issues)
