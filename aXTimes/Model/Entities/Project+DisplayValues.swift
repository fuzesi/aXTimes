//
//  Project+DisplayValues.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 03/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension Project {
    @objc var timeRangeDisplayValue: String {
        var timeRangeString = ""
        let dateFormatter = DateFormatter.dayMonthYear(isStatic: false)
        if let fromDate = fromDate as Date?,
            let fromDateTimeZone = fromDateTimeZone {
            dateFormatter.timeZone = TimeZone(identifier: fromDateTimeZone)
            timeRangeString = "\(dateFormatter.string(from: fromDate)) - "
            if let toDate = toDate as Date?,
                let toDateTimeZone = toDateTimeZone {
                dateFormatter.timeZone = TimeZone(identifier: toDateTimeZone)
                timeRangeString = "\(timeRangeString)\(dateFormatter.string(from: toDate))"
            }
        }
        return timeRangeString
    }

    @objc var color: UIColor {
        guard let parent = parent else {
            return UIColor(fromHex: colourAsHex)
        }
        return UIColor(fromHex: parent.colourAsHex)

    }

    @objc func displayName(withGlobalProjectName globalProjectName: String,
                     andNoProjectName noProjectName: String) -> String {
        if name == globalProjectName &&
            basicProject?.boolValue ?? false {
            return noProjectName
        } else if let actualParent = parent {
            return "\(actualParent.name ?? "")/\(name ?? "")"
        }
        return name ?? ""
    }

    @objc func displayNameForTreeView(withGlobalProjectName globalProjectName: String,
                                andNoProjectName noProjectName: String) -> String {
        if name == globalProjectName &&
            basicProject?.boolValue ?? false {
            return noProjectName
        } else if parent != nil {
            return "\(name ?? "")"
        }
        return name ?? ""
    }

    @objc var netTimeHoursDisplayValue: String {
        return netTimeHours.displayTime
    }

    @objc func netTimeDaysDisplayValue(withHoursPerDay hoursPerDay: NSNumber,
                                 withDaysString days: String) -> String {
        return netTimeDays(withHoursPerDay: hoursPerDay)?.stringValueNumberFormatted().append(withWhiteSpace: days) ?? "-"
    }

    @objc func budgetDaysDescription(defaultLabelName: String,
                               subProjectsLabelName: String) -> String {
        if useSubProjectsBudget?.boolValue ?? false {
            return "\(defaultLabelName) (\(subProjectsLabelName))"
        } else {
            return defaultLabelName
        }
    }

    @objc func budgetDaysDisplayValue(withHoursString hours: String) -> String {
        return actualBudget.stringValueNumberFormatted().append(withWhiteSpace: hours) ?? "-"
    }

    @objc func remainingBudgetHoursTotalDisplayValue(withHoursPerDay hoursPerDay: NSNumber) -> String {
        return remainingBudgetHoursTotal(withHoursPerDay: hoursPerDay)?.displayTime ?? "-"
    }

    @objc func remainingBudgetDaysTotalDisplayValue(withHoursPerDay hoursPerDay: NSNumber,
                                              withDaysString days: String) -> String {
        return remainingBudgetDaysTotal(withHoursPerDay: hoursPerDay)?.stringValueNumberFormatted().append(withWhiteSpace: days) ?? "-"
    }

    @objc func incomeDisplayValue(withCurrencyIso currencyIso: String) -> String {
        return income.stringValueNumberFormatted().append(withWhiteSpace: currencyIso)
    }
}
