//
//  Project+DisplayValuesWrapper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 03/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension Project {
    @objc func displayName() -> String {
        return displayName(withGlobalProjectName: GlobalConstants.basicGlobalProjectName,
                           andNoProjectName: LocalizationConstants.noProject)
    }

    @objc func displayNameForTreeView() -> String {
        return displayNameForTreeView(withGlobalProjectName: GlobalConstants.basicGlobalProjectName,
                                      andNoProjectName: LocalizationConstants.noProject)
    }

    @objc func displayNameForHourlyWage() -> String {
        if basicProject?.boolValue ?? false {
            return ""
        } else if let actualParent = parent {
            return "\(actualParent.name ?? "")"
        }
        return name ?? ""
    }

    @objc func netTimeDaysDisplayValue() -> String {
        return netTimeDaysDisplayValue(withHoursPerDay: SettingsManager().hoursPerDay,
                                       withDaysString: LocalizationConstants.days)
    }

    @objc func budgetDaysDescription() -> String {
        return budgetDaysDescription(defaultLabelName: LocalizationConstants.projectBudget,
                                     subProjectsLabelName: LocalizationConstants.subprojects)
    }

    @objc func budgetDaysDisplayValue() -> String {
        return budgetDaysDisplayValue(withHoursString: LocalizationConstants.days)
    }

    @objc func remainingBudgetHoursTotalDisplayValue() -> String {
        return remainingBudgetHoursTotalDisplayValue(withHoursPerDay: SettingsManager().hoursPerDay)
    }

    @objc func remainingBudgetDaysTotalDisplayValue() -> String {
        return remainingBudgetDaysTotalDisplayValue(withHoursPerDay: SettingsManager().hoursPerDay,
                                                    withDaysString: LocalizationConstants.days)
    }

    @objc func remainingBudgetDaysLeftTotalDisplayValue() -> String {
        return remainingBudgetDaysTotalDisplayValue(withHoursPerDay: SettingsManager().hoursPerDay,
                                                    withDaysString: LocalizationConstants.daysLeft)
    }

    @objc func incomeDisplayValue() -> String {
        return incomeDisplayValue(withCurrencyIso: SettingsManager().currencyIso)
    }
}
