//
//  Date+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 13/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension Date {
    static let defaultCalendarComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second, .timeZone, .weekday]

    func truncateSeconds() -> Date {
        let calendar = Calendar.defaultCalendar(isStatic: true)
        let unitFlags: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .timeZone]
        let fromDateComponents = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: fromDateComponents)! //FIXME
    }

    func truncateHours() -> Date {
        let calendar = Calendar.defaultCalendar(isStatic: true)
        let unitFlags: Set<Calendar.Component> = [.year, .month, .day, .timeZone]
        let fromDateComponents = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: fromDateComponents)! //FIXME
    }

    func updateDayMonthYearComponent(withDate date: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var componentsSelfDate = calendar.dateComponents(Date.defaultCalendarComponents, from: self)
        let componentsDayDate = calendar.dateComponents(Date.defaultCalendarComponents, from: date)
        componentsSelfDate.day = componentsDayDate.day
        componentsSelfDate.month = componentsDayDate.month
        componentsSelfDate.year = componentsDayDate.year
        return calendar.date(from: componentsSelfDate)! //FIXME
    }

    func displayValue(forSelfTimeZone timeZone: String, andTargetDate date: Date) -> String {
        let dateFormatter: DateFormatter
        if isSameDay(date,
                     receiverTimeZoneName: timeZone,
                     inputTimeZoneName:  TimeZone.current.identifier) {
            dateFormatter = DateFormatter.HHmm(isStatic: false)
        } else if isSameMonth(date,
                              receiverTimeZoneName: timeZone,
                              inputTimeZoneName: TimeZone.current.identifier) {
            dateFormatter = DateFormatter.HHmmdMMM(isStatic: false)
        } else {
            dateFormatter = DateFormatter.HHmmdMMMyy(isStatic: false)
        }
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        return dateFormatter.string(from: self)
    }
}
