//
//  Pause+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 13/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension Pause {
    @objc func configure(withStart start: Date,
                   andTimeZone timeZone: String = NSTimeZone.system.identifier) {
        startTime = start as NSDate
        startTimeZone = timeZone
    }

    @objc func configure(withEnd end: Date,
                   andTimeZone timeZone: String = NSTimeZone.system.identifier) {
        endTime = end as NSDate
        endTimeZone = timeZone
    }

    @objc func normalize() {
        if let startTime = startTime as Date? {
            self.startTime = startTime.truncateSeconds() as NSDate?
        }
        if let endTime = endTime as Date? {
            self.endTime = endTime.truncateSeconds() as NSDate?
        }
    }

    @objc func secondsPausedUntilNow() -> NSNumber {
        guard let startTime = startTime as Date? else {
            return NSNumber(value: 0)
        }
        let distanceBetweenDates: TimeInterval = Date().timeIntervalSince(startTime)
        return NSNumber(value: distanceBetweenDates)
    }

    @objc func secondsPaused() -> Double {
        guard let startTime = startTime as Date?,
            let endTime = endTime as Date? else {
                return 0.0
        }
        let tempCheckin = startTime.truncateSeconds()
        let tempCheckout = endTime.truncateSeconds()
        let distanceBetweenDates: TimeInterval = tempCheckout.timeIntervalSince(tempCheckin)
        return distanceBetweenDates
    }

    @objc func secondsPausedNotZeroed() -> Double {
        guard let startTime = startTime as Date?,
            let endTime = endTime as Date? else {
                return 0.0
        }
        let distanceBetweenDates: TimeInterval = endTime.timeIntervalSince(startTime)
        return distanceBetweenDates
    }

    @objc func minutesPaused() -> Double {
        let minutesPaused = secondsPaused() / 60.0
        return minutesPaused
    }

    @objc func hoursPaused() -> Double {
        let hoursPaused = minutesPaused() / 60.0
        return hoursPaused
    }

    @objc var isComplete: Bool {
        if self.startTime != nil &&
            self.endTime != nil {
            return true
        }
        return false
    }

    @objc var isCurrentlyRunning: Bool {
        if self.startTime != nil &&
            self.endTime == nil {
            return true
        }
        return false
    }
}
