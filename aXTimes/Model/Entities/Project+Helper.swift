//
//  Project+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 08/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

@objc enum BudgetCalculationBasis: Int {
    case `default` = 0, subprojects
}

//@objc enum RoundingBehaviour: UInt {
//    case `default` = 0, roundDown, roundUp
//}

extension Project {
    @objc func configure(
        withStart start: Date,
        andTimeZone timeZone: String = NSTimeZone.system.identifier
    ) {
        fromDate = start as NSDate
        fromDateTimeZone = timeZone
    }

    @objc func configure(
        withEnd end: Date,
        andTimeZone timeZone: String = NSTimeZone.system.identifier
    ) {
        toDate = end as NSDate
        toDateTimeZone = timeZone
    }

    @objc func configureFilter(_ newValue: Bool) {
        filterActive = NSNumber(value: newValue)
        // also try to de-/activate filter on parent
        // if subproject
        if let parentProject = parent {
            if parentProject.isFilterActive != parentProject.isFilterActiveForAllSubProjects {
                parentProject.filterActive = NSNumber(value: parentProject.isFilterActiveForAllSubProjects)
            }
            parentProject.updatePartialFilter()
        } else { // if parent
            setFilterActiveForAllSubProjects(filterActive: newValue)
            updatePartialFilter()
        }
    }

    @objc func updatePartialFilter() {
        if isFilterActiveForAtLeastOneSubProject {
            partialFilterActive = NSNumber(value: true)
        } else {
            partialFilterActive = NSNumber(value: false)
        }
    }

    @objc var unsortedSubProjects: [Project] {
        guard let subProjects = subProjects as? Set<Project> else { return [] }
        return Array(subProjects)
    }

    @objc var unsortedDayEntries: [DayEntry] {
        guard let entries = dayEntries as? Set<DayEntry> else { return [] }
        return Array(entries)
    }

    @objc var sortedSubProjects: [Project] {
        guard let subProjects = subProjects as? Set<Project> else { return [] }
        return subProjects.sorted(by: { (projectA, projectB) -> Bool in
            guard let nameA = projectA.name,
                let nameB = projectB.name else {
                    return false
            }
            return nameA < nameB
        })
    }

    @objc var sortedSubProjectsWithFilterActivated: [Project] {
        guard let subProjects = subProjects as? Set<Project> else { return [] }
        let projects = subProjects.filter { $0.isFilterActive }
        return projects.sorted(by: { (projectA, projectB) -> Bool in
            guard let nameA = projectA.name,
                let nameB = projectB.name else {
                    return false
            }
            return nameA < nameB
        })
    }

    @objc var isBasic: Bool {
        if let actualName = name,
            let isBasic = basicProject?.boolValue,
            actualName == GlobalConstants.basicGlobalProjectName,
            isBasic {
            return true
        }
        return false
    }

    @objc var isDefaultProject: Bool {
        return defaultProject?.boolValue ?? false
    }

    @objc var isFilterActive: Bool {
        return filterActive?.boolValue ?? false
    }

    @objc var isFilterActiveForAtLeastOneSubProject: Bool {
        guard let subProjects = subProjects as? Set<Project> else {
            return false
        }
        for subProject in subProjects where subProject.isFilterActive {
            return true
        }
        return false
    }

    @objc var isFilterActiveForAllSubProjects: Bool {
        guard let subProjects = subProjects as? Set<Project> else {
            return true
        }
        for subProject in subProjects where !subProject.isFilterActive {
            return false
        }
        return true
    }

    @objc func setFilterActiveForAllSubProjects(filterActive: Bool) {
        guard let subProjects = subProjects as? Set<Project> else { return }
        subProjects.forEach { $0.filterActive = NSNumber(value: filterActive) }
    }

    @objc var actualRoundingBehaviour: RoundingBehaviour {
        if let parentProject = parent {
            if let value = parentProject.roundingBehaviour?.uintValue {
                return RoundingBehaviour(rawValue: value) ?? .default // fallback
            }
        }
        if let value = roundingBehaviour?.uintValue {
            return RoundingBehaviour(rawValue: value) ?? .default // fallback
        }
        return .default // fallback
    }

    @objc var actualWorkTimeUnit: UInt {
        if let parentProject = parent {
            return parentProject.timeUnit?.uintValue ?? 1
        }
        return timeUnit?.uintValue ?? 1
    }

    @objc var actualHourlyWage: NSDecimalNumber {
        if let parentProject = parent {
            return parentProject.hourlyWage ?? NSDecimalNumber.zero
        }
        return hourlyWage ?? NSDecimalNumber.zero
    }

    @objc var actualDefaultComment: String {
        if let parentProject = parent {
            return parentProject.defaultComment ?? ""
        }
        return defaultComment ?? ""
    }

    @objc var sumOfSubProjectBudgets: NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        guard let subProjects = subProjects as? Set<Project> else { return sum }
        for subProject in subProjects {
            if let budget = subProject.budget {
                sum = budget.adding(sum)
            }
        }
        return sum
    }

    @objc var actualBudget: NSDecimalNumber {
        if useSubProjectsBudget?.boolValue ?? false {
            if let subProjects = subProjects as? Set<Project>,
                subProjects.count > 0 {
                return sumOfSubProjectBudgets
            } else {
                return NSDecimalNumber.zero
            }
        } else {
            return budget ?? NSDecimalNumber.zero
        }
    }

    @objc func remainingBudget(withEntries entries: [DayEntry]) -> NSNumber {
        let tempNetTimeHoursNumber = DayEntry.netTime(forArray: entries)
        // FIXME berechnung schöner
        let budget: Double = actualBudget.doubleValue * SettingsManager().hoursPerDay.doubleValue
        let remaining: Double = budget - tempNetTimeHoursNumber.doubleValue
        return NSNumber(value: remaining)
    }

    @objc func fetchEntries(withEnd end: Date) -> [DayEntry] {
        let entries: [DayEntry]
        if parent == nil {
            var tempEntries = [DayEntry]()
            unsortedSubProjects.forEach {
                tempEntries.append(contentsOf: $0.unsortedDayEntries)
            }
            entries = tempEntries
        } else {
            entries = unsortedDayEntries
        }

        guard let timeZoneIncludedEndDate: Date = end.add(days: 1) else {
            return entries
        } //TODO warum

        var tempFetchedResults = entries.filter { (entry) -> Bool in
            guard let checkInTime = entry.checkInTime as Date?,
                entry.checkOutTime as Date? != nil else {
                    return false
            }
            if checkInTime <= timeZoneIncludedEndDate {
                return true
            }
            return false
        }
        let actuallyNotInThisMonth = entries.filter { (entry) -> Bool in
            guard let checkInTime = entry.checkInTime as Date?,
                entry.checkOutTime as Date? != nil else {
                    return false
            }
            if checkInTime > end {
                return true
            }
            return false
        }

        for entry in actuallyNotInThisMonth {
            if let checkInTimeZone = entry.checkInTimeZone,
                checkInTimeZone == TimeZone.current.identifier {
                tempFetchedResults.remove(object: entry)
            } else {
                if let checkInTime = entry.checkInTime as Date?,
                    let checkInTimeZone = entry.checkInTimeZone,
                    checkInTime > end,
                    !checkInTime.isSameDay(end,
                        receiverTimeZoneName: checkInTimeZone,
                        inputTimeZoneName: TimeZone.current.identifier) {
                    tempFetchedResults.remove(object: entry)
                }
            }
        }
        return tempFetchedResults
    }

    @objc var isRunning: Bool {
        if isBasic {
            return true
        }
        // from date always exists
        let from = fromDate! as Date
        let now = Date()
        // start in the past, no end date
        if from <= now, toDate == nil {
            return true
        }
        // start in the future, no end date
        if from > now, toDate == nil {
            return true
        }
        if let to = toDate as Date? {
            // start in the past, end in the future
            if from <= now, to >= now {
                return true
            }
            // start in the future, end in the future
            if from > now, to > now {
                return true
            }
        }
        return false
    }
}
