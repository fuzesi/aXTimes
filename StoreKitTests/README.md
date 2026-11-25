# StoreKit-Kompatibilitätstest

Das Schema `aXTimes-StoreKit-Tests` aktiviert die lokale Konfiguration `PremiumTest.storekit`. Sie enthält ausschließlich ein fiktives Testprodukt und darf nicht für App-Store-Builds verwendet werden. Das normale Schema `aXTimes` bleibt unverändert.

Den Test `StoreKitIntegrationTest/testLegacyPurchaseIsVisibleToModernStoreKit` in Xcode mit dem Testschema auf einem eigens dafür eingerichteten iOS-Simulator ausführen. Er löscht die lokalen StoreKit-Testtransaktionen vor und nach dem Test. Deshalb keinen Simulator verwenden, dessen StoreKit-Testtransaktionen erhalten bleiben sollen. Der Test überprüft, dass ein über die bisherige StoreKit-Schnittstelle ausgelöster Testkauf nach Synchronisierung als verifizierte StoreKit-2-Berechtigung erscheint.

Der Test belegt weder die Wiederherstellung eines echten App-Store-Kaufs noch die Aktualisierung der installierten App auf einem iPhone. Diese Abläufe müssen vor einer Veröffentlichung separat geprüft werden.

`testModernEntitlementRestoresEmptyLocalState` simuliert einen neuen lokalen Kaufstatus: Nach einem lokalen Testkauf wird eine neue, leere Einstellungsdomäne verwendet. Der Test prüft, ob die verifizierte StoreKit-2-Berechtigung vor und nach einer ausdrücklichen Synchronisierung verfügbar ist und der bisherige Freischaltungsstatus damit gesetzt werden kann. Er simuliert weder eine echte Neuinstallation noch den produktiven Wiederherstellungsablauf; die App verwendet weiterhin StoreKit 1.

## Offene Prüfung mit Apples Sandbox

Ein experimenteller StoreKit-1-Wiederherstellungstest meldete im lokalen Simulator den Abschluss, lieferte aber trotz Testkaufs keine Transaktion im Zustand `restored`. Die Ursache ist ungeklärt. Ein ähnliches Verhalten wurde bereits für ältere Xcode-Versionen im [Apple Developer Forum](https://developer.apple.com/forums/thread/657081) gemeldet; daraus folgt nicht, dass das Problem dieselbe Ursache hat oder bei echten Käufen auftritt.

Für einen aussagekräftigen Test werden Apples [Sandbox-Umgebung](https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox), die zur App passende Bundle-ID und Produkt-ID, ein Sandbox-Testkonto und ein geeignetes Testgerät beziehungsweise TestFlight benötigt. Vor einem Test auf einem iPhone mit vorhandenen Daten muss die Installation so geplant werden, dass die bestehende App und ihre Daten geschützt bleiben. Sandbox-Käufe sind simuliert; sie belegen nicht die Übernahme eines echten Kaufs aus dem normalen App Store. Die Übernahme des echten Kaufstatus und der Daten bei einem Update bleibt vor der Veröffentlichung gesondert zu prüfen.
