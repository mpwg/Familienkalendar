# Product Backlog: Digitaler Familien-Wandkalender

Stand: 3. Maerz 2026
Kontext: Der aktuelle SwiftUI-Code gilt als Prototyp und liefert bereits Monatsansicht, lokale Kalenderauswahl, .ics-Feeds und Basis-Event-Darstellung.

## Ausgangslage aus dem Prototyp
Bereits vorhanden:
- Monatsansicht mit Spalten je Kalender/Feed
- Navigation zwischen Monaten
- EventKit-Zugriff auf lokale Geraetekalender
- Remote-.ics-Feeds inkl. Speicherung in `UserDefaults`
- Einfaches ICS-Parsing und Eventanzeige je Tag

Noch offen fuer Produktreife:
- Persistentes Domain-Modell (statt rein ViewModel/UserDefaults)
- Zuverlaessiger Sync inkl. Fehler- und Retry-Strategie
- Konflikterkennung/Logistik-Funktionen
- Rollen/Rechte und Familien-Workflows
- Qualitaetssicherung (Unit/UI-Tests, Monitoring)

## Epics (priorisiert)
1. E1 - Fundament & Architekturhaertung
2. E2 - Kalenderkern MVP (Termine, Wiederholungen, Heute-Board)
3. E3 - Familie & Alltag (Aufgaben, Fahrten, Rollen)
4. E4 - Integrationen & Zuverlaessigkeit
5. E5 - UX, Lesbarkeit auf Distanz, Performance
6. E6 - Betrieb, Beta und Qualitaet

## Ticket-Set (Issue-fertig)

### E1 - Fundament & Architekturhaertung

#### FK-001: Domain-Modell in SwiftData einfuehren
User Story:
Als Entwickler moechte ich Events, Personen, Routinen und Feeds in einem konsistenten Modell speichern, damit Features robust erweitert werden koennen.

Akzeptanzkriterien:
- SwiftData-Modelle fuer `Person`, `CalendarEvent`, `RemoteFeed`, `Task`, `ReminderRule` vorhanden.
- Migration von bestehender `UserDefaults`-Feedliste in neues Modell implementiert.
- App startet ohne Datenverlust bei bestehender Prototyp-Installation.

#### FK-002: Datenzugriff ueber Repository-Layer abstrahieren
User Story:
Als Entwickler moechte ich EventKit/ICS/Persistenz entkoppeln, damit Sync-Logik testbar wird.

Akzeptanzkriterien:
- `CalendarRepository`-Protokoll + Implementierungen fuer lokal und remote vorhanden.
- ViewModel nutzt nur Repository-Interfaces.
- Mindestens 3 Unit-Tests mit Mocks fuer Laden/Mergen/Fehlerpfade.

#### FK-003: Feature-Module schneiden (Calendar, Settings, Sync)
User Story:
Als Team moechten wir klare Modulgrenzen, damit parallele Entwicklung moeglich wird.

Akzeptanzkriterien:
- Code in Feature-Ordnern strukturiert (`Calendar`, `Settings`, `Sync`, `Shared`).
- Keine zirkulaeren Abhaengigkeiten zwischen Features.
- Build laeuft unveraendert im bestehenden Target.

### E2 - Kalenderkern MVP

#### FK-010: Heute-Board implementieren
User Story:
Als Familienmitglied moechte ich auf einen Blick die naechsten Termine sehen, damit ich den Tag schnell planen kann.

Akzeptanzkriterien:
- Eigene Ansicht "Heute" mit naechsten 3-5 Terminen.
- Anzeige enthaelt Uhrzeit, Titel, Quelle (Kalender/Feed), Person/Farbe.
- Leerer Zustand mit klarer Aussage, wenn keine Termine vorhanden sind.

#### FK-011: Termin-Erfassung in <= 3 Taps
User Story:
Als Nutzer moechte ich sehr schnell einen Termin erstellen, damit der Wandkalender aktiv genutzt wird.

Akzeptanzkriterien:
- Quick-Add-Flow fuer Standardtermin (Titel, Zeit, Kalender).
- Flow ist vom Hauptscreen in maximal 3 Interaktionen erreichbar.
- Neuer Termin erscheint ohne manuellen Refresh in Monats- und Heute-Ansicht.

#### FK-012: Wiederkehrende Termine robust darstellen
User Story:
Als Familie moechten wir wiederkehrende Termine verlaesslich sehen, damit Routinen nicht vergessen werden.

Akzeptanzkriterien:
- Wiederholungen aus EventKit werden korrekt geladen.
- .ics-Wiederholungen mit `RRULE` fuer gaengige Faelle (taeglich/woechentlich) werden unterstützt.
- Mindestens 5 Testfaelle fuer Wiederholungslogik inkl. Zeitzone.

#### FK-013: Konflikterkennung fuer Ueberschneidungen
User Story:
Als Eltern moechten wir Termin-Konflikte sehen, damit wir Betreuung/Fahrten frueh planen koennen.

Akzeptanzkriterien:
- Konflikte werden bei zeitlicher Ueberschneidung markiert.
- Konfliktliste nach Schweregrad (hart/soft) im Heute-Board sichtbar.
- Toggle in Einstellungen: Konfliktwarnungen ein/aus.

### E3 - Familie & Alltag

#### FK-020: Personen-/Rollenmodell (Eltern/Kinder)
User Story:
Als Familie moechten wir Rollen definieren, damit nicht jeder alles veraendert.

Akzeptanzkriterien:
- Rollen `Parent` und `Child` im Modell vorhanden.
- Schreibrechte fuer sensible Bereiche (Feed-Setup, Sync-Einstellungen) nur fuer `Parent`.
- Leserechte fuer Kalenderinhalte fuer alle Rollen.

#### FK-021: Aufgabenliste pro Person
User Story:
Als Familie moechten wir Aufgaben im selben System sehen, damit Termine und To-dos zusammenpassen.

Akzeptanzkriterien:
- Task-CRUD mit Faelligkeit und Zuweisung an Person.
- Filter: Heute, Diese Woche, Erledigt.
- Erledigte Aufgaben sind im Verlauf einsehbar.

#### FK-022: "Wer bringt wen?"-Plan
User Story:
Als Eltern moechten wir Transportzustaendigkeiten planen, damit Fahrten nicht kollidieren.

Akzeptanzkriterien:
- Pro Termin kann ein Transportverantwortlicher hinterlegt werden.
- Konflikt-Hinweis bei zwei gleichzeitigen Transportpflichten derselben Person.
- Wochenuebersicht fuer alle geplanten Fahrten.

### E4 - Integrationen & Zuverlaessigkeit

#### FK-030: iCloud/EventKit-Sync robust machen
User Story:
Als Nutzer moechte ich mich auf aktuelle Daten verlassen koennen, damit der Wandkalender vertrauenswuerdig ist.

Akzeptanzkriterien:
- Manuelles und automatisches Refresh mit Last-Sync-Zeit.
- Fehlerzustand mit Retry-Button bei fehlendem Zugriff/Netzwerk.
- Kein UI-Freeze bei langsamen Kalenderquellen.

#### FK-031: ICS-Fetching haerten (Timeout, Retry, Validierung)
User Story:
Als Nutzer moechte ich stabile Feed-Updates, damit externe Kalender nicht still ausfallen.

Akzeptanzkriterien:
- Netz-Timeout und begrenzte Retry-Logik implementiert.
- Pro Feed wird Erfolgs-/Fehlerstatus gespeichert.
- Ungueltige Feed-Daten fuehren nicht zum Abbruch anderer Feeds.

#### FK-032: Google-Kalender als zusaetzlicher Provider
User Story:
Als Familie mit gemischten Geraeten moechten wir Google-Kalender einbinden, damit alle Termine zentral sichtbar sind.

Akzeptanzkriterien:
- OAuth-Login fuer Google vorhanden.
- Lesesync in MVP-Qualitaet (mindestens Termine laden + anzeigen).
- Provider ist als `CalendarProvider` integriert, nicht als Sonderfall.

### E5 - UX, Lesbarkeit, Performance

#### FK-040: 2-Meter-Lesbarkeit optimieren
User Story:
Als Wanddisplay-Nutzer moechte ich Inhalte aus Distanz lesen, damit der Kalender alltagstauglich ist.

Akzeptanzkriterien:
- Typografie- und Zeilenhoehen-Review fuer Distanznutzung dokumentiert.
- Mindestkontrast fuer wichtige Elemente erfuellt.
- Optionale "Large Display"-Darstellung in Einstellungen.

#### FK-041: Ambient-Modus fuer Idle-Zustand
User Story:
Als Familie moechten wir im Vorbeigehen relevante Infos sehen, ohne die App aktiv zu bedienen.

Akzeptanzkriterien:
- Idle-Ansicht zeigt Datum, naechste Termine, Wetter-Platzhalter.
- Wechsel zwischen aktivem und Ambient-Modus ohne Datenverlust.
- Keine stark bewegten Animationen im Standardmodus.

#### FK-042: Rendering-Performance fuer grosse Monate
User Story:
Als Nutzer moechte ich fluessiges Scrollen auch bei vielen Terminen, damit die App nicht traege wirkt.

Akzeptanzkriterien:
- Messung der Renderzeit auf Zielgeraet (iPad) dokumentiert.
- Sichtbare Ruckler bei Monaten mit hoher Eventdichte reduziert.
- Kein merklicher Memory-Leak beim Monatswechsel.

### E6 - Betrieb, Beta und Qualitaet

#### FK-050: Unit-Test-Suite fuer Kernlogik
User Story:
Als Team moechten wir Regressionen frueh erkennen, damit neue Features stabil bleiben.

Akzeptanzkriterien:
- Tests fuer Datumslogik, Konflikterkennung, ICS-Parser, Merge-Strategie.
- Mindestabdeckung fuer Kernmodule vereinbart und dokumentiert.
- Tests laufen in CI bei jedem Pull Request.

#### FK-051: UI-/Snapshot-Tests fuer Hauptansichten
User Story:
Als Team moechten wir visuelle Stabilitaet sicherstellen, damit Distanzlesbarkeit nicht regressiert.

Akzeptanzkriterien:
- Snapshot-Tests fuer Monatsansicht, Heute-Board, Settings.
- Mindestens ein Test fuer Dynamic-Type/Skalierung.
- Fehlende Baselines sind im Repo versioniert.

#### FK-052: TestFlight-Beta mit Feedback-Loop
User Story:
Als Produktteam moechten wir echte Familien-Usage messen, damit Priorisierung datenbasiert passiert.

Akzeptanzkriterien:
- Beta-Runde mit definiertem Test-Skript und Feedback-Formular.
- Mindestens 10 qualitative Feedbacks gesammelt.
- Top-10 Pain-Points in neues Sprint-Backlog ueberfuehrt.

## Release-Zuordnung
- R1 (MVP, 8 Wochen): FK-001, FK-002, FK-010, FK-011, FK-012, FK-030, FK-031, FK-050
- R2 (Komfort, +6 bis 8 Wochen): FK-003, FK-013, FK-020, FK-021, FK-022, FK-040, FK-051
- R3 (Wow, ab Monat 5): FK-032, FK-041, FK-042, FK-052

## Definition of Ready (DoR)
Ein Ticket startet nur, wenn:
- User Story + Nutzen klar sind
- Akzeptanzkriterien testbar sind
- Abhaengigkeiten benannt sind
- Design/Copy (falls relevant) vorliegt

## Definition of Done (DoD)
Ein Ticket ist fertig, wenn:
- Akzeptanzkriterien erfuellt sind
- Relevante Tests gruen laufen
- Fehlerzustaende behandelt sind
- Dokumentation/Release Notes aktualisiert sind

## Vorschlag fuer Labels (GitHub Issues)
- `type:feature`
- `type:tech-debt`
- `type:bug`
- `priority:P0`
- `priority:P1`
- `priority:P2`
- `epic:E1` bis `epic:E6`
- `release:R1` bis `release:R3`
