//
//  Calendar+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 08/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension Calendar {
    private static let staticCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        // -> da dann automatisch gesetzt wird [cal setMinimumDaysInFirstWeek:4]
        // ISO 8601 "The first week of a year is the week that contains the first Thursday of the year."
        calendar.locale = Locale.current
        calendar.minimumDaysInFirstWeek = 4
        calendar.firstWeekday = 2
        return calendar
    }()

    static func defaultCalendar(isStatic: Bool) -> Calendar {
        if isStatic {
            return staticCalendar
        } else {
            var calendar = Calendar(identifier: .gregorian)
            // -> da dann automatisch gesetzt wird [cal setMinimumDaysInFirstWeek:4]
            // ISO 8601 "The first week of a year is the week that contains the first Thursday of the year."
            calendar.locale = Locale.current
            calendar.minimumDaysInFirstWeek = 4
            calendar.firstWeekday = 2
            return calendar
        }
    }
}
