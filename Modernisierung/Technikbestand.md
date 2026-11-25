# Technischer Bestand und nächste Schritte

Stand: 25. November 2026. Grundlage ist der App-Quellcode und ein Simulator-Build des damaligen Projektstands. Die Liste ist eine Arbeitsgrundlage, keine vollständige Sicherheitsprüfung.

## Direkt eingebundener Code

- **JTCalendar**: Monatskalender in der Detailansicht; der Quellcode liegt im App-Projekt. Auswahl, Monatswechsel, Markierungen und Kalenderhöhe vor einem Austausch absichern.
- **DDCalendar / OBDragDrop**: Tages- und Zeitleistenansicht sowie zugehörige Gesten; die Darstellung und Bearbeitung von Zeiteinträgen vor einem Austausch absichern.
- **RESideMenu**: Navigation und Seitenmenü; die Navigation zwischen allen Hauptansichten vor einem Austausch prüfen.
- **SKSTableView**: aufklappbare Tabellen für Projekte und Navigation; Hierarchien und Auswahlverhalten vor einem Austausch prüfen.
- **UAAppReviewManager**: Aus dem App-Build entfernt. In den Einstellungen bleiben der vorhandene Support-Link und ein direkter App-Store-Bewertungslink verfügbar. Der ursprüngliche Quellcode liegt noch im Repository. Es wird keine automatische Bewertungsaufforderung ausgelöst; der Bewertungslink öffnet den App Store auf Wunsch der Nutzerin oder des Nutzers.
- **IAPHelper / ursprüngliche StoreKit-API**: In-App-Käufe und Wiederherstellung. Eine Umstellung auf Apples aktuelle API benötigt Tests für bestehende Käufe und Wiederherstellung im StoreKit-Test beziehungsweise mit Sandbox-Konto.

Diese Quelltextkopien haben keine im Projekt zuverlässig ausgewiesene Paketversion. Es darf daher nicht angenommen werden, dass sie dem aktuellen Stand ihres jeweiligen Ursprungsprojekts entsprechen.

## Swift-6-Prüfung

Der App-Target verwendet Swift-Sprachmodus 5. Ein isolierter Debug-Simulator-Build mit Xcode 27.2, Swift-Compiler 6.4.2 und `SWIFT_STRICT_CONCURRENCY=complete` im bestehenden Sprachmodus war erfolgreich. Er erzeugte 237 unterschiedliche nebenläufigkeitsbezogene Diagnosezeilen an 18 Swift-Dateien. Die Zahl ist eine Momentaufnahme und kein Maß für die Anzahl tatsächlicher Fehler.

Betroffen sind unter anderem UI-Isolation, gemeinsam genutzte Zustände in Datenweitergabe, In-App-Käufen und Watch-Anbindung sowie Objective-C/Swift-Protokolle. Diagnose für Diagnose prüfen, das korrekte Threading herstellen und jeweils Tests ausführen. Nicht allein durch Unterdrücken der Warnungen oder pauschales Wechseln des Sprachmodus als abgeschlossen betrachten.

## Daten und Freigabe

Die Bestandsaufnahme und die technische Umstellung können unabhängig vom laufenden iPhone-Backup erfolgen. Bevor die bestehende Installation ersetzt oder eine Version ausgeliefert wird, sind der konkrete Update-Pfad von aXTimes Pro 1.0.6 Build 135, seine Daten und die App-Identität separat zu prüfen. Siehe [README.md](README.md).
