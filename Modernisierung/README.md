# Tests für die Modernisierung

Die automatisierten Tests verwenden künstliche Daten und einen isolierten Core-Data-Speicher. Sie prüfen den Backup-Codec, Beziehungen, den Umgang mit fehlerhaften Eingaben, einen Rundlauf zwischen zwei Datenbanken, eine Sommerzeitgrenze und gespeicherte Hex-Farben.

```bash
xcrun simctl list devices available
./Scripts/test-modernisierung.sh <Simulator-UDID>
```

Das Skript führt gezielt `Unit Tests/UnitTest` aus, nicht die gesamte historische Testsuite. Der Simulator sollte für Tests vorgesehen sein; die App wird als Test-Host gestartet. `DEVELOPER_DIR` kann bei einer abweichenden Xcode-Installation gesetzt werden.

`compare_backup.py` und `compare_backup_json.py` vergleichen optional ein privates Backup mit einer wiederhergestellten Testdatenbank beziehungsweise einem erneut erzeugten Backup. Sie geben nur aggregierte Unterschiede aus. Persönliche Backups gehören nicht ins Repository.

Die Vergleichsprogramme `BackupCodecPrototype.swift`, `ModelMappingCheck.swift`, `StoreMigrationCheck.swift` und `WeekCalculationComparison.swift` sind experimentelle Diagnosewerkzeuge. Der Wochenvergleich benötigt die frühere SwiftDate-Bibliothek; sie wird von der App nicht mehr eingebunden. Ein erfolgreicher Modellvergleich garantiert keine vollständige Migration realer Daten.

## Stand der Prüfung für ein App-Update

Ein unsignierter Release-Build für iOS-Geräte wurde mit `CODE_SIGNING_ALLOWED=NO` gebaut. Seine Bundle-ID ist `com.aximilate.axtimespro`, die Version ist `1.0.7` (Build `155`). Vor einem Update müssen diese Angaben, das Apple-Team und die Berechtigungen mit dem tatsächlich veröffentlichten App-Eintrag abgeglichen werden. Der unsignierte Build beweist keine korrekte Signierung oder Installierbarkeit.

Der aktuelle Core-Data-Modellstand ist `DataModel_2.0.0`. `ModelMappingCheck.swift` findet für alle vier enthaltenen Modellversionen ein theoretisches Mapping. `StoreMigrationCheck.swift` zeigt jedoch mit einem künstlichen Zeiteintrag, dass der tatsächliche automatische SQLite-Umstieg aus `DataModel`, `DataModel_1.1.0` und `DataModel_1.2.0` an der im Zielmodell erforderlichen Projektbeziehung scheitert. Der Testdatensatz aus `DataModel_2.0.0` lässt sich öffnen. Ein inferierbares Mapping allein ist daher kein Beleg für eine erfolgreiche Migration.

Die Modellversion der tatsächlich auf dem iPhone installierten App ist dadurch nicht festgestellt; ein JSON-Backup enthält keine zuverlässige Aussage über die Core-Data-Speicherversion. Vor einem Update muss der tatsächliche Upgrade-Pfad auf einer isolierten Kopie geprüft und bei Bedarf eine verlustfreie Migration für ältere Datenmodelle entwickelt und getestet werden. Insbesondere dürfen Projektbeziehungen nicht ohne Prüfung pauschal ersetzt werden. Bis dahin ist die Update-Kompatibilität nicht bestätigt.
