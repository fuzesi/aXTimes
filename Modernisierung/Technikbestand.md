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

Das getrennte Schema `aXTimes-StoreKit-Tests` verwendet ein lokales Testprodukt. Drei Tests prüfen die Sichtbarkeit eines über die alte Schnittstelle ausgelösten Testkaufs in StoreKit 2, die Wiederherstellung eines leeren lokalen Status aus einer simulierten Berechtigung und den Fall ohne Kauf. Sie ersetzen keinen Sandbox-Test und belegen nicht die Übernahme eines echten App-Store-Kaufs. Der bisherige StoreKit-1-Wiederherstellungsversuch meldete lokal den Abschluss, aber keine wiederhergestellte Transaktion; die Ursache ist ungeklärt. Einzelheiten stehen in [StoreKitTests/README.md](../StoreKitTests/README.md).
