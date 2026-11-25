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

Unterstützt werden muss nach Vorgabe des Eigentümers das Update der aktuell genutzten aXTimes-Pro-Version 1.0.6 (Build 135) einschließlich ihrer vorhandenen Daten. Eine allgemeine Migration weiterer sehr alter App- und Datenmodellversionen ist nicht erforderlich.

Die Core-Data-Modellversion der tatsächlich auf dem iPhone installierten App ist noch nicht festgestellt; ein JSON-Backup weist sie nicht zuverlässig aus. Vor einem Update muss deshalb der konkrete Upgrade-Pfad dieser Installation auf einer isolierten Kopie geprüft werden. Falls gerade diese Installation eine der älteren Modellversionen verwendet, muss ihr Upgrade dennoch verlustfrei funktionieren. Projektbeziehungen dürfen nicht ohne Prüfung pauschal ersetzt werden. Bis zur Prüfung ist die Update-Kompatibilität nicht bestätigt.
