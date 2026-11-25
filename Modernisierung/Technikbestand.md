# Technischer Bestand und nächste Schritte

Stand: 25. November 2026. Grundlage ist der App-Quellcode und ein Simulator-Build des damaligen Projektstands. Die Liste ist eine Arbeitsgrundlage, keine vollständige Sicherheitsprüfung.

## Direkt eingebundener Code

- **JTCalendar**: Monatskalender in der Detailansicht; der Quellcode liegt im App-Projekt. Auswahl, Monatswechsel, Markierungen und Kalenderhöhe vor einem Austausch absichern.
- **DDCalendar / OBDragDrop**: Tages- und Zeitleistenansicht sowie zugehörige Gesten; die Darstellung und Bearbeitung von Zeiteinträgen vor einem Austausch absichern.
- **RESideMenu**: Navigation und Seitenmenü; die Navigation zwischen allen Hauptansichten vor einem Austausch prüfen.
- **SKSTableView**: aufklappbare Tabellen für Projekte und Navigation; Hierarchien und Auswahlverhalten vor einem Austausch prüfen.
- **UAAppReviewManager**: Aus dem App-Build entfernt. In den Einstellungen bleiben der vorhandene Support-Link und ein direkter App-Store-Bewertungslink verfügbar. Der ursprüngliche Quellcode liegt noch im Repository. Es wird keine automatische Bewertungsaufforderung ausgelöst; der Bewertungslink öffnet den App Store auf Wunsch der Nutzerin oder des Nutzers.
- **IAPHelper / ursprüngliche StoreKit-API**: In-App-Käufe und Wiederherstellung. Die bestehende Projektfreischaltung nutzt die Kennung `com.aximilate.axtimespro.projects` und einen lokal gespeicherten Status. Isolierte Tests prüfen dessen Erhalt, das Speichern und die Benachrichtigung. Dies simuliert keine echte StoreKit-Transaktion und beweist keine Wiederherstellung aus dem App Store. Vor der Umstellung auf die aktuelle API müssen Kauf und Wiederherstellung zusätzlich mit StoreKit-Test beziehungsweise Sandbox-Konto geprüft werden.

Diese Quelltextkopien haben keine im Projekt zuverlässig ausgewiesene Paketversion. Es darf daher nicht angenommen werden, dass sie dem aktuellen Stand ihres jeweiligen Ursprungsprojekts entsprechen.

## Swift-6-Prüfung

Der App-Target verwendet Swift-Sprachmodus 5. Ein isolierter Debug-Simulator-Build mit Xcode 27.2, Swift-Compiler 6.4.2 und `SWIFT_STRICT_CONCURRENCY=complete` im bestehenden Sprachmodus war erfolgreich. Er erzeugte 237 unterschiedliche nebenläufigkeitsbezogene Diagnosezeilen an 18 Swift-Dateien. Die Zahl ist eine Momentaufnahme und kein Maß für die Anzahl tatsächlicher Fehler.

Betroffen sind unter anderem UI-Isolation, gemeinsam genutzte Zustände in Datenweitergabe, In-App-Käufen und Watch-Anbindung sowie Objective-C/Swift-Protokolle. Diagnose für Diagnose prüfen, das korrekte Threading herstellen und jeweils Tests ausführen. Nicht allein durch Unterdrücken der Warnungen oder pauschales Wechseln des Sprachmodus als abgeschlossen betrachten.

## Daten und Freigabe

Die Bestandsaufnahme und die technische Umstellung können unabhängig vom laufenden iPhone-Backup erfolgen. Bevor die bestehende Installation ersetzt oder eine Version ausgeliefert wird, sind der konkrete Update-Pfad von aXTimes Pro 1.0.6 Build 135, seine Daten und die App-Identität separat zu prüfen. Siehe [README.md](README.md).

## StoreKit-Teststand

Ein temporäres Testprodukt mit eigener, nicht produktiver Kennung wurde für StoreKit Testing erstellt. In einem isolierten Versuch mit der neueren StoreKit-Schnittstelle ließen sich eine verifizierte Testtransaktion und die Berechtigung nach `AppStore.sync()` prüfen. Dieser Versuch testete nicht die bestehende Kaufoberfläche.

Der bisherige Wiederherstellungsweg meldete bei weiteren lokalen Versuchen den Abschluss, aber keine `.restored`-Transaktion. Ein erneuter Lauf auf einem frisch eingerichteten Simulator blieb außerdem bei einer Apple-Account-Anmeldung hängen; die Ursache der Testkonfiguration beziehungsweise Simulatorumgebung ist nicht geklärt. Deshalb beweist der bisherige Versuch weder eine funktionierende noch eine fehlerhafte Wiederherstellung echter Käufe. Vor einer Umstellung ist ein reproduzierbarer, isolierter Test von Kauf und Wiederherstellung nötig. Die experimentelle Testkonfiguration wurde nicht in das reguläre App-Scheme übernommen.
