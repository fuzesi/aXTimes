//
//  Project+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 03/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension Project {
    @objc var allDayEntries: [DayEntry] {
        if let actualSubProjects = subProjects as? Set<Project>, parent == nil, actualSubProjects.count > 0 {
            // has no parent and more than 0 subprojects
            var tempEntries = [DayEntry]()
            for subProject in actualSubProjects {
                if let entries = subProject.dayEntries as? Set<DayEntry> {
                    tempEntries.append(contentsOf: entries)
                }
            }
            return tempEntries
        } else {
            if let entries = dayEntries as? Set<DayEntry> {
                return Array(entries)
            } else {
                return [DayEntry]()
            }
        }
    }

    @objc var netTimeHours: NSNumber {
        return DayEntry.netTime(forArray: allDayEntries)
    }

    @objc func netTimeDays(withHoursPerDay hoursPerDay: NSNumber) -> NSNumber? {
        guard hoursPerDay.isGreaterZero else {
            return nil
        }

        return netTimeHours.hoursToDays(withHoursPerDay: NSDecimalNumber(decimal: hoursPerDay.decimalValue))
    }

    @objc func remainingBudgetHoursTotal(withHoursPerDay hoursPerDay: NSNumber) -> NSNumber? {
        guard actualBudget.isGreaterZero, hoursPerDay.isGreaterZero else {
            return nil
        }

        return remainingBudget(withEntries: allDayEntries)
    }

    @objc func remainingBudgetDaysTotal(withHoursPerDay hoursPerDay: NSNumber) -> NSNumber? {
        guard let remainingBudgetHours = remainingBudgetHoursTotal(withHoursPerDay: hoursPerDay) else {
            return nil
        }

        return remainingBudgetHours.hoursToDays(withHoursPerDay: NSDecimalNumber(decimal: hoursPerDay.decimalValue))
    }

    @objc var income: NSNumber {
        return DayEntry.income(forArray: allDayEntries)
    }
}
