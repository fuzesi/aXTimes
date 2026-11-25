import Foundation
import SwiftDate
// Comparison against the archived SwiftDate framework; no user data is used.
var checked = 0
var errors = 0
var formatted = 0
var formattingErrors = 0
for zoneName in ["Europe/Berlin", "America/New_York", "Asia/Tokyo", "Pacific/Auckland", "UTC"] {
    for firstDay in [1, 2] {
        let zone = TimeZone(identifier: zoneName)!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        calendar.firstWeekday = firstDay
        let region = Region(tz: zone, cal: calendar, loc: Locale(identifier: "en_US_POSIX"))
        Date.setDefaultRegion(region)
        let formatter = Foundation.ISO8601DateFormatter()
        formatter.timeZone = zone
        formatter.formatOptions = [.withFullDate]
        for day in 0..<800 {
            let date = Date(timeIntervalSince1970: 1_704_067_200 + Double(day * 86_400 + 43_200))
            let oldStart = date.startWeek
            let oldEnd = oldStart.add(components: [.day: 7])
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { fatalError("No week") }
            if oldStart != interval.start || oldEnd != interval.end { errors += 1 }
            if date.string(format: .iso8601(options: [.withFullDate]), in: region) != formatter.string(from: date) {
                formattingErrors += 1
            }
            checked += 1
            formatted += 1
        }
    }
}
print("WEEK_TEST checked=\(checked) errors=\(errors)")
print("DATE_TEST checked=\(formatted) errors=\(formattingErrors)")
if errors != 0 || formattingErrors != 0 { exit(1) }
