# Mitwirkungsrichtlinien

Danke, dass Sie zu SightAssist beitragen möchten! Bitte beachten Sie die folgenden Richtlinien:

## Code Standard

- **Swift Code Style**: Folgen Sie den [Apple Swift Style Guide](https://www.swift.org/documentation/api-design-guidelines/)
- **Barrierefreiheit**: Alle UI-Komponenten müssen `accessibilityLabel` und `accessibilityHint` haben
- **Dokumentation**: Schreiben Sie aussagekräftige Kommentare für komplexe Logik
- **Tests**: Unit Tests für neue Features hinzufügen

## Branch Policy

- `main` – Stabile, getestete Releases
- `develop` – Entwicklungsbranch
- Feature Branches: `feature/feature-name`

## Commit Messages

```
[TYPE] Kurze Beschreibung (max 50 Zeichen)

Längere Erklärung, falls notwendig (max 72 Zeichen pro Zeile).
```

Typen:
- `feat:` – Neue Funktion
- `fix:` – Fehlerbehebung
- `docs:` – Dokumentation
- `style:` – Code Style (keine funktionalen Änderungen)
- `refactor:` – Umstrukturierung ohne neue Features
- `test:` – Tests hinzufügen/ändern

## Pull Request Prozess

1. **Aktualisieren Sie** den main Branch: `git pull origin main`
2. **Erstellen Sie** einen Feature Branch: `git checkout -b feature/my-feature`
3. **Testen Sie** lokal: `xcodebuild test -scheme SightAssist`
4. **Committen Sie** mit aussagekräftigen Messages
5. **Pushen Sie**: `git push origin feature/my-feature`
6. **Öffnen Sie** einen PR gegen `main`
7. **Code Review** durchlaufen
8. **Mergen** nach Genehmigung

## Reporting Issues

Bitte verwenden Sie die Issue Template und fügen Sie hinzu:
- iOS Version & Gerät
- Xcode Version
- Schritte zum Reproduzieren
- Screenshot/Video falls relevant

Danke für Ihren Beitrag! 🙏
