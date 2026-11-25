//
//  AXCalculation+Swift.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 09/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension AXCalculation {
    @objc static func overtimeHours(withTargetWorkingDays targetDays: NSDecimalNumber,
                              withHoursPerDay hoursPerDay: NSDecimalNumber,
                              withNetTimeHours netHours: NSDecimalNumber) -> NSDecimalNumber? {
        guard NSDecimalNumber.zero.compare(hoursPerDay) == .orderedAscending else {
            return nil
        }

        let targetNetHours = hoursPerDay.multiplying(by: targetDays)
        let overtime = netHours.subtracting(targetNetHours)

        return overtime
    }

    @objc static func averageHoursPerDay(days: NSDecimalNumber, hours: NSDecimalNumber) -> NSDecimalNumber? {
        guard NSDecimalNumber.zero.compare(days) == .orderedAscending else {
            return nil
        }

        return hours.dividing(by: days)
    }
}
