# Bestandsaufnahme: Watch-App und Heute-Widget

Stand: 25. November 2026

## Ausgangslage

Im iPhone-Target `aXTimes` sind weder die Einbettungsphasen noch die Target-Abhängigkeiten für die vorhandene Watch-App und das Today-Widget eingetragen. Das gilt bereits für den ersten Commit dieses modernisierten Repositories; die Bestandteile wurden also nicht durch die spätere Entfernung von CocoaPods aus dem Build gelöst. Das lokale, unsignierte iPhone-Archiv enthält weder eine Watch-App noch eine App-Erweiterung. Ob diese Bestandteile in der tatsächlich installierten App enthalten sind, ist damit noch nicht geklärt.

## Watch-App

Der Quellcode enthält eine WatchKit-App samt separater Extension und WatchConnectivity-Anbindung. Die vorgesehenen Aktionen umfassen Ein- und Ausstempeln sowie Beginn und Ende einer Pause; die Anzeige enthält Zeiten und Verdienstinformationen.

Ein Build mit den bestehenden Einstellungen scheitert: Das konfigurierte Mindestziel watchOS 3.2 und die Architektur armv7k werden vom installierten Xcode nicht mehr unterstützt. Mit ausschließlich temporären Build-Overrides `WATCHOS_DEPLOYMENT_TARGET=9.0` und `ARCHS=arm64_32` ließ sich das Watch-App-Target einschließlich Extension unsigniert bauen. Das ist kein Laufzeit-, Signierungs- oder App-Store-Test und ändert keine Projekteinstellungen. Xcode meldet unter anderem veraltete Storyboards und Menü-APIs. Die Funktionsfähigkeit und die Einbettung in den iPhone-Build sind offen.

Apple empfiehlt für bestehende Watch-Projekte eine Modernisierung auf SwiftUI und die neuere App-Struktur: https://developer.apple.com/documentation/technotes/tn3157-updating-your-watchos-project-for-swiftui-and-widgetkit

## Heute-Widget

`Ticker Today Extension` implementiert ein älteres Today-Widget, das Zeiten und weitere Statusinformationen anzeigt und die App öffnen kann. Ein separater Build scheitert derzeit unter anderem an veralteten Swift-Bezeichnungen. Das allein zu reparieren würde das Widget für aktuelle Systeme nicht wiederherstellen: Apple hat die Unterstützung für alte Today-View-Erweiterungen in iOS 18 entfernt. Ein Ersatz erfordert daher ein neues WidgetKit-Widget und eine sorgfältige Prüfung der Aktualisierung und Datenübergabe.

Quelle: https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-18-release-notes

## Folgeschritte

1. Feststellen, ob und wie die veröffentlichte Version Watch-App und Widget tatsächlich anbietet, und die benötigten Funktionen festhalten.
2. Watch-Funktionen und Kommunikation auf aktueller Architektur nachbilden und im Watch-Simulator prüfen. Anschließend Einbettung, Kennungen und Signierung für ein App-Update prüfen.
3. Ein WidgetKit-Konzept für die vorhandenen Statusinformationen erarbeiten und auf Datenkonsistenz, Aktualisierung und Datenschutz prüfen.
4. Erst nach diesen Prüfungen den signierten TestFlight-Build und die Übernahme auf einem Gerät testen.
