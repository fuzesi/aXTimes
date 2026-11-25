# Tests für die Modernisierung

Die automatisierten Tests verwenden künstliche Daten und einen isolierten Core-Data-Speicher. Sie prüfen den Backup-Codec, Beziehungen, den Umgang mit fehlerhaften Eingaben, einen Rundlauf zwischen zwei Datenbanken, eine Sommerzeitgrenze und gespeicherte Hex-Farben.

```bash
xcrun simctl list devices available
./Scripts/test-modernisierung.sh <Simulator-UDID>
```

Das Skript führt gezielt `Unit Tests/UnitTest` aus, nicht die gesamte historische Testsuite. Der Simulator sollte für Tests vorgesehen sein; die App wird als Test-Host gestartet. `DEVELOPER_DIR` kann bei einer abweichenden Xcode-Installation gesetzt werden.

`compare_backup.py` und `compare_backup_json.py` vergleichen optional ein privates Backup mit einer wiederhergestellten Testdatenbank beziehungsweise einem erneut erzeugten Backup. Sie geben nur aggregierte Unterschiede aus. Persönliche Backups gehören nicht ins Repository.

Die Vergleichsprogramme `BackupCodecPrototype.swift`, `ModelMappingCheck.swift`, `StoreMigrationCheck.swift` und `WeekCalculationComparison.swift` sind experimentelle Diagnosewerkzeuge. Der Wochenvergleich benötigt die frühere SwiftDate-Bibliothek; sie wird von der App nicht mehr eingebunden. Ein erfolgreicher Modellvergleich garantiert keine vollständige Migration realer Daten.
