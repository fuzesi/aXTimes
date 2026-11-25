//
//  Project+CalculationsWrapper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 03/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension Project {
    @objc func remainingBudgetHoursTotal() -> NSNumber? {
        return remainingBudgetHoursTotal(withHoursPerDay: SettingsManager().hoursPerDay)
    }

    @objc func remainingBudgetDaysTotal() -> NSNumber? {
        return remainingBudgetDaysTotal(withHoursPerDay: SettingsManager().hoursPerDay)
    }

    @objc func netTimeDays() -> NSNumber? {
        return netTimeDays(withHoursPerDay: SettingsManager().hoursPerDay)
    }
}
