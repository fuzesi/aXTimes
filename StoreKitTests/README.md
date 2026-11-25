# StoreKit-Kompatibilitätstest

Das Schema `aXTimes-StoreKit-Tests` aktiviert die lokale Konfiguration `PremiumTest.storekit`. Sie enthält ausschließlich ein fiktives Testprodukt und darf nicht für App-Store-Builds verwendet werden. Das normale Schema `aXTimes` bleibt unverändert.

Den Test `StoreKitIntegrationTest/testLegacyPurchaseIsVisibleToModernStoreKit` in Xcode mit dem Testschema auf einem eigens dafür eingerichteten iOS-Simulator ausführen. Er löscht die lokalen StoreKit-Testtransaktionen vor und nach dem Test. Deshalb keinen Simulator verwenden, dessen StoreKit-Testtransaktionen erhalten bleiben sollen. Der Test überprüft, dass ein über die bisherige StoreKit-Schnittstelle ausgelöster Testkauf nach Synchronisierung als verifizierte StoreKit-2-Berechtigung erscheint.

Der Test belegt weder die Wiederherstellung eines echten App-Store-Kaufs noch die Aktualisierung der installierten App auf einem iPhone. Diese Abläufe müssen vor einer Veröffentlichung separat geprüft werden.
