# R1 Sprint-Plan (MVP)

Stand: 3. Maerz 2026
Basis: Milestone `R1` in GitHub Issues

## Ziel von R1
Eine stabile MVP-Basis liefern: robuste Daten- und Sync-Schicht + nutzbare Kernfunktionen (Heute-Board, Quick-Add, Wiederholungen) mit testbarer Architektur.

## Sprint-Schnitt
- Sprint 1 (2 Wochen): Fundament + Zuverlaessigkeit
- Sprint 2 (2 Wochen): Nutzerfunktionen auf stabilem Fundament

## Sprint 1 (Fundament + Zuverlaessigkeit)
Zugeordnete Issues:
- FK-001 (`#4`) Domain-Modell in SwiftData einfuehren
- FK-002 (`#5`) Datenzugriff ueber Repository-Layer abstrahieren
- FK-030 (`#14`) iCloud/EventKit-Sync robust machen
- FK-031 (`#15`) ICS-Fetching haerten (Timeout, Retry, Validierung)
- FK-050 (`#20`) Unit-Test-Suite fuer Kernlogik

Reihenfolge (empfohlen):
1. FK-001 -> Datenmodell + Migration
2. FK-002 -> Repository-Abstraktion
3. FK-031 -> Remote-Fetching robust
4. FK-030 -> Lokaler Sync/Refresh + Fehlerzustaende
5. FK-050 -> Tests fuer Parser/Merge/Datumslogik vervollstaendigen

Sprint-1 Exit-Kriterien:
- Keine Blocker durch Datenmigration bei Update von Prototyp-Build.
- Sync-Fehler sind sichtbar und recoverbar (Retry + Last Sync Timestamp).
- Kernlogik hat belastbare Unit-Tests in CI.

## Sprint 2 (Kernfunktionen)
Zugeordnete Issues:
- FK-010 (`#7`) Heute-Board implementieren
- FK-011 (`#8`) Termin-Erfassung in <= 3 Taps
- FK-012 (`#9`) Wiederkehrende Termine robust darstellen

Reihenfolge (empfohlen):
1. FK-012 -> Wiederholungslogik stabilisieren
2. FK-010 -> Heute-Board auf belastbare Event-Pipeline setzen
3. FK-011 -> Quick-Add (inkl. Live-Refresh in Monat/Heute)

Sprint-2 Exit-Kriterien:
- Heute-Board zeigt konsistente Daten aus lokalen Kalendern + Feeds.
- Quick-Add ist in <= 3 Interaktionen erreichbar.
- Wiederkehrende Termine funktionieren fuer EventKit + gaengige ICS-RRULEs.

## Abhaengigkeiten
- FK-010, FK-011, FK-012 haengen technisch von FK-001/FK-002 ab.
- FK-012 benoetigt Teile von FK-031 (saubere Feed-Datenbasis).
- FK-050 soll in Sprint 1 bereits die Basis fuer Sprint-2-Regressionstests schaffen.

## Hauptrisiken + Gegenmassnahmen
- Risiko: SwiftData-Migration erzeugt inkonsistente Bestandsdaten.
  - Gegenmassnahme: Einmalige Migration mit Fallback auf read-only Import und Logging.
- Risiko: ICS-Varianten brechen Parser.
  - Gegenmassnahme: Testkorpus mit realen Feeds + defensive Parser-Strategie.
- Risiko: Performance bei vielen Events verschlechtert UX.
  - Gegenmassnahme: fruehe Messung in Sprint 1, Caching und inkrementelles Laden.

## Empfohlene WIP-Regeln
- Maximal 2 parallele Entwicklungs-Issues pro Person.
- Keine neuen Features in Sprint 1, bevor FK-001/002 stabil sind.
- Jedes abgeschlossene Issue muss mindestens einen Testfall ergaenzen (falls Kernlogik betroffen).
