# Roadmap: Digitaler Wandkalender

## Zielbild
Ein digitaler Familien-Wandkalender, der in 5 Sekunden den Tagesplan klarmacht, Konflikte früh zeigt und Routinen spielerisch unterstützt.

## Priorisierung (Must / Should / Could)

### Must (MVP, 0-8 Wochen)
- Familienkalender mit Monats-, Wochen- und Tagesansicht
- Farb- oder Avatar-Zuordnung pro Person
- Schnelles Erfassen: Termin in <= 3 Taps
- Wiederkehrende Termine (Schule, Sport, Muell, Routinen)
- Heute-Board mit den naechsten 3-5 Terminen
- Basis-Benachrichtigungen (in App + lokal)
- Konflikt-Erkennung bei Ueberschneidungen
- Offline-Lesbarkeit mit spaeterem Sync
- Rollen und Rechte (Eltern editieren alles, Kinder eingeschraenkt)
- Stabiler Sync mit iCloud/Google Kalender (mind. 1 Provider im MVP)

### Should (v1.1, 2-4 Monate)
- Smart Widgets: Wetter, Ferien/Feiertage, Geburtstage
- Aufgabenliste mit Faelligkeit und Zuordnung pro Person
- "Wer bringt wen?"-Ansicht fuer Fahrten/Logistik
- QR-Link zum mobilen Schnell-Add
- Vorlagen (Training, Arzt, Elternabend)
- Abfahrts- und Pufferzeiten (z. B. 20 Minuten vorher)
- Familien-Dashboard fuer Morgen/Abend-Routine
- Home-Screen/Standby-optimierte "Ambient"-Ansicht

### Could (v2+, 4-8 Monate)
- KI-Vorschlaege fuer freie Zeitfenster
- Gamification fuer Kinder (Punkte, Badges, Wochenziele)
- Sprachsteuerung (Siri/Alexa/Google)
- Smart-Home-Aktionen (z. B. Morgenlicht bei erstem Termin)
- Erinnerungsfotos "Vor einem Jahr"
- Gastmodus per QR (nur relevante Termine sichtbar)
- Multi-Display Sync (z. B. Flur + Kueche + E-Ink Companion)

## Tech-Stack-Empfehlung

### 1) Frontend (Wanddisplay + Mobile)
- Primar: SwiftUI (iPad-App als Wanddisplay) fuer maximale Apple-Integration
- Optional spaeter: kleine iPhone-Companion-Views fuer Quick Add
- Architektur: MVVM + klare Feature-Module

### 2) Datenmodell & Persistence
- Lokal: SwiftData (oder Core Data, falls komplexe Migrationen erwartet)
- Sync-Strategie: Offline-first mit Konfliktaufloesung pro Datensatz
- Entities:
  - `Person`
  - `CalendarEvent`
  - `Task`
  - `Routine`
  - `ReminderRule`
  - `TransportPlan`

### 3) Kalender-Integrationen
- Apple Calendar via EventKit (nahtlos fuer iCloud)
- Google Calendar via REST API + OAuth (zweiter Schritt)
- Einheitliche interne Abstraktion (`CalendarProvider`) fuer spaetere Erweiterungen

### 4) Backend (nur wenn noetig)
- Start ohne eigenes Backend (schneller MVP)
- Spaeter fuer Familien-Sharing/AI:
  - API: Vapor (Swift) oder FastAPI (Python)
  - DB: PostgreSQL
  - Queue/Jobs: Redis + Background Worker

### 5) KI/Automationen (spaeter)
- Vorschlaege als nicht-blockierende Hinweise (nie automatisch ohne Bestaetigung)
- Modelle via API, kapselt in `SuggestionService`
- Regeln priorisieren Deterministik (z. B. Schulzeiten, feste Routinen) vor KI

### 6) Qualitaet & Betrieb
- Tests:
  - Unit Tests fuer Konfliktlogik, Wiederholungsregeln, Sync-Merge
  - Snapshot/UI Tests fuer 2-Meter-Lesbarkeit
- Observability:
  - strukturiertes Logging
  - Crash Reporting
- Deployment:
  - TestFlight fuer Familien-Beta

## Empfohlene Releases

### Release 1: MVP (8 Wochen)
- Must-Liste ohne KI
- Fokus: Zuverlaessigkeit, schnelle Eingabe, hohe Lesbarkeit

### Release 2: Familien-Komfort (weitere 6-8 Wochen)
- Should-Liste (Wetter, Aufgaben, Transport)
- UX-Feinschliff + Performance

### Release 3: Wow-Faktor (ab Monat 5)
- Ausgewaehlte Could-Features (Gamification, AI-Slots, Sprachsteuerung)

## Umsetzungsplan (konkret)
1. Woche 1-2: Datenmodell, EventKit-Anbindung, Basis-UI
2. Woche 3-4: Wiederkehrungen, Konfliktlogik, Heute-Board
3. Woche 5-6: Rollen, Notifications, Offline-Sync
4. Woche 7-8: Stabilisierung, Tests, Pilot im Haushalt
5. Danach: Should-Features anhand realer Nutzung priorisieren

## Entscheidungsleitlinien
- Jede neue Funktion muss eine 5-Sekunden-Entscheidung verbessern.
- Lesbarkeit auf Distanz ist wichtiger als maximale Informationsdichte.
- Automationen duerfen helfen, aber nie Kontrolle wegnehmen.
