//
//  DayEntry+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 03/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension DayEntry {
    @objc func configure(withStart start: Date,
                   andTimeZone timeZone: String = NSTimeZone.system.identifier) {
        checkInTime = start as NSDate
        checkInTimeZone = timeZone
    }

    @objc func configure(withEnd end: Date,
                   andTimeZone timeZone: String = NSTimeZone.system.identifier) {
        checkOutTime = end as NSDate
        checkOutTimeZone = timeZone
    }

    @objc func normalize() {
        if let checkInTime = checkInTime as Date? {
            self.checkInTime = checkInTime.truncateSeconds() as NSDate?
        }
        if let checkOutTime = checkOutTime as Date? {
            self.checkOutTime = checkOutTime.truncateSeconds() as NSDate?
        }
        for pause in sortedPauses {
            pause.normalize()
        }
    }

    @objc func deepCopy(toTargetDate targetDate: Date) -> DayEntry? {
        guard let checkInTime = checkInTime as Date?,
        let checkInTimeZone = checkInTimeZone,
        let checkOutTime = checkOutTime as Date?,
        let checkOutTimeZone = checkOutTimeZone else {
            return nil
        }

        let dayEntry = AXDataStore.sharedInstance().managedObjectContext.newDayEntryEntity(withStart: checkInTime)

        let finalCheckInTime = checkInTime.updateDayMonthYearComponent(withDate: targetDate)

        dayEntry.checkInTime = finalCheckInTime as NSDate?
        dayEntry.checkInTimeZone = checkInTimeZone

        var difference: TimeInterval = checkOutTime.timeIntervalSince(checkInTime)
        dayEntry.checkOutTime = Date(timeInterval: difference, since: finalCheckInTime) as NSDate?
        dayEntry.checkOutTimeZone = checkOutTimeZone

        dayEntry.comment = comment

        dayEntry.hourlyWage = hourlyWage
        dayEntry.creationDate = Date() as NSDate?

        dayEntry.project = self.project

        for pause in sortedPauses {
            if let pauseStartTime = pause.startTime as Date?,
                let pauseEndTime = pause.endTime as Date?,
                let newPause = dayEntry.managedObjectContext?.newPauseEntity(withStart: pauseStartTime) {
                difference = pauseStartTime.timeIntervalSince(checkInTime)
                let newPauseStartTime = Date(timeInterval: difference,
                                             since: finalCheckInTime)
                newPause.startTime = newPauseStartTime as NSDate?
                newPause.startTimeZone = pause.startTimeZone

                difference = pauseEndTime.timeIntervalSince(pauseStartTime)
                newPause.endTime = Date(timeInterval: difference,
                                        since: newPauseStartTime) as NSDate?
                newPause.endTimeZone = pause.endTimeZone
                dayEntry.addToPauses(newPause)
            }
        }
        return dayEntry
    }

    // MARK: - getters

    private static let yearMonthDayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

    @objc static let decimalNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.roundingIncrement = NSNumber(value: 0.01)
        formatter.roundingMode = .halfUp
        return formatter
    }()

    @objc var dayKey: String {
        guard let checkInTime = checkInTime as Date? else { return "" }
        return DayEntry.yearMonthDayDateFormatter.string(from: checkInTime)
    }

    @objc var actualHourlyWage: NSDecimalNumber {
        guard let project = project else {
            // sollte nur der Fall sein während man aus der alten App Einträge importiert und diese methode auf den Einträgen aufgerufen wird
            return  hourlyWage ?? NSDecimalNumber.zero
        }
        // wenn Projekt isBasic true (was nur bei dem unsichtbaren Projekt)
        // der Fall ist, dann gib hourlyWage vom DayEntry selbst zurück zurück
        if project.isBasic {
            return hourlyWage ?? NSDecimalNumber.zero
        } else {
            return project.actualHourlyWage
        }
    }

    @objc func netMinutes(fromGrossMinutes minutes: NSDecimalNumber) -> NSDecimalNumber {
        guard let project = project else { return minutes }

        let timeUnitInMinutes: Double = Double(project.actualWorkTimeUnit)
        var timeUnitsWorked: Double = minutes.doubleValue / timeUnitInMinutes
        let currentRoundingBehaviour: RoundingBehaviour = project.actualRoundingBehaviour
        var returnValue: Double = 0.0

        switch currentRoundingBehaviour {
        case .default :
            let tempTimeUnitsWorked: Double = floor(timeUnitsWorked)

            let moduloRemainder: Double = timeUnitsWorked - tempTimeUnitsWorked

            if moduloRemainder >= 0.5 {
                timeUnitsWorked = tempTimeUnitsWorked + 1
            } else {
                timeUnitsWorked = tempTimeUnitsWorked
            }
            returnValue = timeUnitsWorked * timeUnitInMinutes
            break

        case .roundDown :
            returnValue = floor(timeUnitsWorked) * timeUnitInMinutes
            break
        case .roundUp :
            returnValue = ceil(timeUnitsWorked) * timeUnitInMinutes
            break
        }

        return NSDecimalNumber(value: returnValue)
    }

    @objc var minutesWorked: NSDecimalNumber {
        return NSDecimalNumber(value: secondsWorkedAsDouble() / 60.0)
    }

    @objc var hoursWorked: NSDecimalNumber {
        return minutesWorked.dividing(by: NSDecimalNumber.sixty)
    }

    @objc var netMinutes: NSDecimalNumber {
        return netMinutes(fromGrossMinutes: minutesWorked)
    }

    @objc var netHours: NSDecimalNumber {
        let netHours = netMinutes.dividing(by: NSDecimalNumber.sixty)
        // rounding einheitlich für alle hier, somit hat das runden mit dem numberformatter später keine auswirkungen mehr
        let returnValue: Double = round(100 * netHours.doubleValue) / 100
        return NSDecimalNumber(value: returnValue)
    }

    @objc func secondsWorkedAsDouble() -> Double {
        guard let checkInTime = checkInTime as Date?,
            let checkOutTime = checkOutTime as Date? else {
                return 0.0
        }

        let tempCheckin = checkInTime.truncateSeconds()
        let tempCheckout = checkOutTime.truncateSeconds()

        var distanceBetweenDates: TimeInterval = tempCheckout.timeIntervalSince(tempCheckin)
        for pause in sortedPauses {
            if pause.startTime != nil && pause.endTime != nil {
                distanceBetweenDates -= pause.secondsPaused()
            }
        }
        return distanceBetweenDates
    }

    @objc func secondsWorkedUntil(targetDate date: Date) -> NSDecimalNumber {
        guard let checkInTime = checkInTime as Date? else {
                return NSDecimalNumber.zero
        }
        var distanceBetweenDates: TimeInterval = date.timeIntervalSince(checkInTime)
        if sortedPauses.count > 0 {
            let lastObjectIndex: Int = sortedPauses.count - 1
            for (index, pause) in sortedPauses.enumerated() {
                if let pauseStartTime = pause.startTime as Date?,
                    let pauseEndTime = pause.endTime as Date? {
                    distanceBetweenDates -= pauseEndTime.timeIntervalSince(pauseStartTime)
                } else if index == lastObjectIndex {
                    if let pauseStartTime = pause.startTime as Date? {
                        distanceBetweenDates -= date.timeIntervalSince(pauseStartTime)
                    }
                }
            }
        }
        return NSDecimalNumber(value: distanceBetweenDates)
    }

    private var secondsWorkedUntilNow: NSDecimalNumber {
        return secondsWorkedUntil(targetDate: Date())
    }

    @objc var minutesWorkedUntilNow: NSDecimalNumber {
        return secondsWorkedUntilNow.dividing(by: NSDecimalNumber.sixty)
    }

    @objc var minutesPaused: NSDecimalNumber {
        guard checkInTime as Date? != nil,
            checkOutTime as Date? != nil else { return NSDecimalNumber.zero }

        var distanceBetweenDates: TimeInterval = 0
        for pause in sortedPauses {
            if pause.startTime != nil && pause.endTime != nil {
                distanceBetweenDates += pause.secondsPaused()
            }
        }
        return NSDecimalNumber(value: distanceBetweenDates / 60.0)
    }

    @objc var minutesPausedNotZeroed: NSDecimalNumber {
        if (self.checkInTime == nil) || (self.checkInTime == nil && self.checkOutTime == nil) {
            return NSDecimalNumber.zero
        } else {
            var distanceBetweenDates: TimeInterval = 0
            for pause in sortedPauses {
                if pause.startTime != nil && pause.endTime != nil {
                    distanceBetweenDates += pause.secondsPausedNotZeroed()
                }
            }
            return NSDecimalNumber(value: distanceBetweenDates / 60.0)
        }
    }

    @objc func netHoursAsNumber() -> NSNumber {
        let netHours = DayEntry.decimalNumberFormatter.number(from: netHoursAsDecimalStringWithoutH)
        return netHours! //FIXME
    }

    // MARK: - pause related

    @objc var sortedPauses: [Pause] {
        guard let pauses = pauses else { return [] }
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: true)
        return pauses.sortedArray(using: [sortDescriptor]) as! [Pause] // FIXME
    }

    @objc var lastSortedPause: Pause? {
        guard let pauses = pauses, pauses.count > 0 else { return nil }
        let lastObjectIndex = pauses.count - 1
        return sortedPauses[lastObjectIndex]
    }

    @objc var firstSortedPause: Pause? {
        guard let pauses = pauses, pauses.count > 0 else { return nil }
        return sortedPauses[0]
    }

    // MARK: - display values

    @objc var netHoursAsDecimalStringWithoutH: String {
        let formattedNumber = DayEntry.decimalNumberFormatter.string(from: netHours)
        return formattedNumber ?? ""
    }

    @objc var hourlyWageAsDecimalString: String {
        return DayEntry.decimalNumberFormatter.string(from: actualHourlyWage) ?? ""
    }

    @objc var secondsWorkedUntilNowDisplayValue: String {
        return secondsWorkedUntilNow.numberAsSecondsToCountdownString()
    }

    // MARK: - class methods

    @objc class func distinctParentProjects(forArray array: [DayEntry]?) -> [Project] {
        var projects = [Project]()

        guard let actualArray = array else {
            return projects
        }

        for entry in actualArray {
            if let actualProject = entry.project {
                var tempProject: Project?

                if let actualParent = actualProject.parent {
                    tempProject = actualParent
                } else {
                    tempProject = actualProject
                }

                if let actualTempProject = tempProject, !projects.contains(actualTempProject) {
                    projects.append(actualTempProject)
                }
            }
        }
        return projects
    }
}
