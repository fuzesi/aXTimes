//
//  Date+Comparison.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 08/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension Date {

    var flags: NSCalendar.Unit {
        return [NSCalendar.Unit.year,
                NSCalendar.Unit.month,
                NSCalendar.Unit.day,
                NSCalendar.Unit.hour,
                NSCalendar.Unit.minute,
                NSCalendar.Unit.second,
                NSCalendar.Unit.timeZone]
    }

    func isEarlier(than date: Date) -> Bool {
        return compare(date) == .orderedAscending
    }

    func isEarlierOrEqual(than date: Date) -> Bool {
        return compare(date) == .orderedAscending || compare(date) == .orderedSame
    }

    func isLater(than date: Date) -> Bool {
        return compare(date) == .orderedDescending
    }

    func isLaterOrEqual(than date: Date) -> Bool {
        return compare(date) == .orderedDescending || compare(date) == .orderedSame
    }

    func isSameDay(_ date: Date, receiverTimeZoneName: String, inputTimeZoneName: String) -> Bool {
        var calendarReceiver = Calendar(identifier: Calendar.Identifier.gregorian)
        calendarReceiver.timeZone = TimeZone(identifier: receiverTimeZoneName)!

        var calendarInput = Calendar(identifier: Calendar.Identifier.gregorian)
        calendarInput.timeZone = TimeZone(identifier: inputTimeZoneName)!

        let componentsSelfDate = (calendarReceiver as NSCalendar?)?.components(flags, from: self)
        let componentsCompareDate = (calendarInput as NSCalendar?)?.components(flags, from: date)

        if componentsSelfDate?.year == componentsCompareDate?.year && componentsSelfDate?.month == componentsCompareDate?.month && componentsSelfDate?.day == componentsCompareDate?.day {
            return true
        } else {
            return false
        }
    }

    func isSameMonth(_ date: Date, receiverTimeZoneName: String, inputTimeZoneName: String) -> Bool {
        var calendarReceiver = Calendar(identifier: Calendar.Identifier.gregorian)
        calendarReceiver.timeZone = TimeZone(identifier: receiverTimeZoneName)!

        var calendarInput = Calendar(identifier: Calendar.Identifier.gregorian)
        calendarInput.timeZone = TimeZone(identifier: inputTimeZoneName)!

        let componentsSelfDate = (calendarReceiver as NSCalendar?)?.components(flags, from: self)
        let componentsCompareDate = (calendarInput as NSCalendar?)?.components(flags, from: date)

        if componentsSelfDate?.year == componentsCompareDate?.year && componentsSelfDate?.month == componentsCompareDate?.month {
            return true
        } else {
            return false
        }
    }
}
