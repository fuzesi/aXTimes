//
//  DayEntry+Calculations.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 09/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension DayEntry {
    // MARK: - class methods

    @objc class func netTime(forArray array: [DayEntry]) -> NSDecimalNumber {
        var netTime = NSDecimalNumber.zero
        array.forEach { netTime = netTime.adding($0.netHours) }
        return netTime
    }

    @objc class func pauseTime(forArray array: [DayEntry]) -> NSDecimalNumber {
        var pauseTime = NSDecimalNumber.zero
        array.forEach { pauseTime = pauseTime.adding($0.hoursPaused) }
        return pauseTime
    }

    // MARK: - other methods

    @objc var hoursPaused: NSDecimalNumber {
        return minutesPaused.dividing(by: NSDecimalNumber.sixty)
    }
}
