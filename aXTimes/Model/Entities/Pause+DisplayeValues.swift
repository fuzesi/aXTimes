//
//  Pause+DisplayeValues.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 13/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension Pause {
    @objc var hoursPausedDisplayValue: String {
        return NSNumber(value: hoursPaused()).displayTime
    }

    @objc var totalTimeUntilNowWithSeconds: String {
        return secondsPausedUntilNow().numberAsSecondsToCountdownString()
    }

    @objc func timeRangeDisplayValue(forTargetDate date: Date) -> String {
        var timeRange = ""
        if startTime != nil {
            timeRange = "\(startTimeDisplayValue(forTargetDate: date)) - "
            if endTime != nil {
                timeRange = "\(timeRange)\(endTimeDisplayValue(forTargetDate: date))"
            }
        }
        return timeRange
    }

    @objc func startTimeDisplayValue(forTargetDate date: Date) -> String {
        guard let startTime = startTime as Date?,
            let startTimeZone = startTimeZone else {
                return ""
        }
        return startTime.displayValue(forSelfTimeZone: startTimeZone,
                                      andTargetDate: date)
    }

    @objc func endTimeDisplayValue(forTargetDate date: Date) -> String {
        guard let endTime = endTime as Date?,
            let endTimeZone = endTimeZone else {
                return ""
        }
        return endTime.displayValue(forSelfTimeZone: endTimeZone,
                                    andTargetDate: date)
    }
}
