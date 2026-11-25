//
//  DayEntry+DisplayValues.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 09/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension DayEntry {
    @objc var hoursDisplayValue: String {
        return hoursWorked.displayTime
    }

    @objc var netHoursDisplayValue: String {
        return netHours.displayTime
    }

    @objc func timeRangeDisplayValue(forTargetDate date: Date) -> String {
        var timeRange = ""
        if checkInTime != nil {
            timeRange = "\(checkInTimeDisplayValue(forTargetDate: date)) - "
            if checkOutTime != nil {
                timeRange = "\(timeRange)\(checkOutTimeDisplayValue(forTargetDate: date))"
            }
        }
        return timeRange
    }

    @objc func checkInTimeDisplayValue(forTargetDate date: Date) -> String {
        guard let checkInTime = checkInTime as Date?,
            let checkInTimeZone = checkInTimeZone else {
                return ""
        }
        return checkInTime.displayValue(forSelfTimeZone: checkInTimeZone,
                                        andTargetDate: date)
    }

    @objc func checkOutTimeDisplayValue(forTargetDate date: Date) -> String {
        guard let checkOutTime = checkOutTime as Date?,
            let checkOutTimeZone = checkOutTimeZone else {
                return ""
        }
        return checkOutTime.displayValue(forSelfTimeZone: checkOutTimeZone,
                                         andTargetDate: date)
    }

    @objc var pauseTimesDisplayValue: String {
        guard let checkInTime = checkInTime as Date? else {
            return ""
        }
        var pauseTimes = ""

        for (index, pause) in sortedPauses.enumerated() {
            pauseTimes += pause.timeRangeDisplayValue(forTargetDate: checkInTime)
            if index != (sortedPauses.count - 1) {
                pauseTimes += "\n"
            }
        }

        return pauseTimes
    }
}
