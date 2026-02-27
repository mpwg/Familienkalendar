# Familienkalender

## Vision
Der **Familienkalender** soll den analogen Wandkalender ersetzen:
- mehrere Kalender in einer gemeinsamen Monatsansicht
- Kalender optional überlagert bzw. gemeinsam angezeigt
- Tageszusammenfassung mit Apple Intelligence
- Anzeige von Schul- und Kindergartenferien

## Aktueller Status

### Bereits umgesetzt
- Monatsansicht mit Tageszeilen in einem familienfreundlichen Layout
- Navigation zwischen Monaten
- Auswahl von Gerätekalendern (EventKit, inkl. iCloud wenn Berechtigung erteilt ist)
- Einbindung externer `.ics`-Feeds
- Unterstützung von `webcal://`-Links (z. B. öffentliche iCloud-Kalender), intern auf `https://` normalisiert
- Persistenz der Kalendersauswahl und Feed-Konfiguration in `UserDefaults`
- App-Icon eingebunden

### Teilweise umgesetzt / in Arbeit
- Kalender werden aktuell primär als eigene Spalten dargestellt; eine echte visuelle Überlagerung ist noch ausbaufähig
- Kalenderberechtigungen sind integriert, Verhalten auf Mac Catalyst wurde bereits angepasst

### Noch offen
- Tageszusammenfassung mit Apple Intelligence
- Eigene Ferien-Logik (Schule/Kindergarten) inkl. Datenquelle, Filter und Darstellung
- Bessere Konflikt-/Überlagerungsdarstellung bei vielen Einträgen pro Tag

## Nächste sinnvolle Schritte
1. Apple-Intelligence-Zusammenfassung pro Tag (Prompt + UI + Trigger)
2. Ferienquellen definieren (Bundesland/Region) und als optionalen Kalender-Layer einbinden
3. Überlagerungsmodus im UI ergänzen (statt nur separater Spalten)
