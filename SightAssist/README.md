# SightAssist – Projektdokumentation
**Lokale KI-Kamera-App für blinde und sehbehinderte Menschen**
*Stand: Mai 2025 – iOS First (iPhone 14+)*

---

## 1. Grundphilosophie

- **Copilot-Ansatz:** Kein Ersatz für Blindenstock oder Blindenhund – ergänzendes Assistenzwerkzeug
- **Privacy by Design / Zero-Cloud:** Keine Bilddaten verlassen das Gerät. Vollständig offline-fähig.
- **Zielgruppe DACH-Raum:** Bestehende Apps (Seeing AI, Envision, Be My Eyes) sind im deutschsprachigen Raum kaum bekannt – hier liegt die Marktlücke
- **Monetarisierung:** Einmalige Gebühr ~1,99 € zur Deckung der Apple Developer Gebühr (99 $/Jahr). Kein Abo, keine Serverkosten. Alternativ: Open Source + Ko-fi/Sponsoring

---

## 2. Alleinstellungsmerkmal (USP)

| Merkmal | Seeing AI | Envision | Be My AI | **SightAssist** |
|---|---|---|---|---|
| Vollständig offline | Teilweise | Nein | Nein | **Ja** |
| Datenschutz / kein Cloud | Nein | Nein | Nein | **Ja** |
| Deutsch nativ | Übersetzt | Übersetzt | Übersetzt | **Ja** |
| Kostenlos / einmalig | Kostenlos | Abo | Kostenlos | **~1,99 € einmalig** |
| Open Vocabulary Suche | Nein | Nein | Ja (Cloud) | **Ja (on-device)** |

---

## 3. Hardware-Voraussetzungen

- **Minimum:** iPhone 14 (A15 Bionic, 16-Core Neural Engine)
- **Empfohlen:** iPhone 14 Pro oder neuer (zusätzlich LiDAR für Tiefenmessung)
- **Im App Store gesperrt** für ältere Geräte (wird als Mindestanforderung hinterlegt)
- **Zubehör-Empfehlung:** Knochenschall-Kopfhörer (Bone Conduction) – Ohren müssen für Umgebungsgeräusche frei bleiben

---

## 4. Funktionsumfang

### Modus 1 – Kontext-Beschreiber *(MVP-Priorität: Hoch – hier starten)*
**Ziel:** Verstehen von Umgebungen, Texten, Farben, Gegenständen, sozialen Situationen

**Auslöser:** Doppeltippen → Bild einfrieren → optional kurze Spracheingabe → VLM analysiert → TTS liest vor

**Anwendungsfälle:**
- Post / Briefe / Rechnungen / Behördenschreiben lesen
- Medikamente identifizieren
- Ablaufdatum auf Lebensmitteln
- Avocado reif? Fleisch noch frisch?
- Kleidung: Farbe, Stil, Kombination passend?
- Möbel: Passt das Sofa farblich zum Raum?
- Speisekarte im Restaurant
- Preisschild im Laden
- Busliniennummer eines heranfahrenden Busses
- Herd-Einstellungen kontrollieren
- Welche Flasche ist Shampoo, welche Duschgel?
- Welcher Aufzug-Knopf ist welches Stockwerk?
- Stimmung / Emotionen einer Person einschätzen
- Raumgröße und Personenanzahl einschätzen

**Prompt-Strategie:**
