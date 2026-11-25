//
//  EntriesExport.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 28.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation

enum EntriesExportError: Error {
    case dayEntryIncomplete
    case numberFormatterFailed
}

@objc class EntriesExport: NSObject, Export {

    private let entries: [DayEntry]
    private let projects: [Project]
    private let mainResult: AXSummaryCalculationResult
    private let projectResults: [NSManagedObjectID: AXSummaryCalculationResult]
    private let settingsManager: SettingsManager
    private let exportNumberFormatter: ExportNumberFormatter

    @objc init(
        entries: [DayEntry],
        projects: [Project],
        mainResult: AXSummaryCalculationResult,
        projectResults: [NSManagedObjectID: AXSummaryCalculationResult],
        settingsManager: SettingsManager
        ) {
        self.entries = entries
        self.projects = projects
        self.mainResult = mainResult
        self.projectResults = projectResults
        self.settingsManager = settingsManager
        self.exportNumberFormatter = ExportNumberFormatter(settingsManager: settingsManager)
        super.init()
    }

    @objc func data() throws -> Data {
        let isExportWage = settingsManager.isExportWage
        let isExportTimeZone = settingsManager.isExportTimeZone
        let language: String? = settingsManager.isCustomExportLanguage ? settingsManager.exportLanguageLocale : nil
        let numberFormatter = exportNumberFormatter.formatter()
        let dateDateFormatter = DateFormatter.dayMonthYear(isStatic: false)
        let timeDateFormatter = DateFormatter.HHmm(isStatic: false)
        let timestampDateFormatter = DateFormatter.fulltimeStamp(isStatic: false)
        var headerRow = EntriesExportHeaderRow(exportLanguage: language).values()
        let currency = settingsManager.currencyIso

        if isExportTimeZone {
            headerRow.insert("Check-In timezone".localized(exportLanguage: language), at: 2)
            headerRow.insert("Check-In timestamp".localized(exportLanguage: language), at: 3)
            headerRow.insert("Check-Out timezone".localized(exportLanguage: language), at: 6)
            headerRow.insert("Check-Out timestamp".localized(exportLanguage: language), at: 7)
        }

        if isExportWage {
            let hourlyWage = "\("Hourly wage".localized(exportLanguage: language)) \(currency)"
            headerRow.insert(hourlyWage, at: headerRow.count - 1)
            let income = "\("Wage in".localized(exportLanguage: language)) \(currency)"
            headerRow.insert(income, at: headerRow.count - 1)
        }

        headerRow = headerRow.escaped()

        var table = [headerRow]

        var checkInDate = ""
        var checkInTime = ""
        var checkInTimezone = ""
        var checkInTimestamp = ""

        var checkOutDate = ""
        var checkOutTime = ""
        var checkOutTimezone = ""
        var checkOutTimestamp = ""

        for dayEntry in entries {
            guard let checkInTimeZoneString = dayEntry.checkInTimeZone,
                let checkInTimeZone = TimeZone(identifier: checkInTimeZoneString),
                let checkInTimeDate = dayEntry.checkInTime as Date?,
                let checkOutTimeDate = dayEntry.checkOutTime as Date?,
                let checkOutTimeZoneString = dayEntry.checkOutTimeZone,
                let checkOutTimeZone = TimeZone(identifier: checkOutTimeZoneString)
                else {
                    throw EntriesExportError.dayEntryIncomplete
            }
            dateDateFormatter.timeZone = checkInTimeZone
            timeDateFormatter.timeZone = checkInTimeZone
            timestampDateFormatter.timeZone = checkInTimeZone

            checkInDate = dateDateFormatter.string(from: checkInTimeDate)
            checkInTime = timeDateFormatter.string(from: checkInTimeDate)

            dateDateFormatter.timeZone = checkOutTimeZone
            timeDateFormatter.timeZone = checkOutTimeZone
            timestampDateFormatter.timeZone = checkOutTimeZone

            checkOutDate = dateDateFormatter.string(from: checkOutTimeDate)
            checkOutTime = timeDateFormatter.string(from: checkOutTimeDate)

            guard let pauseTimeString = numberFormatter.string(from: dayEntry.hoursPaused),
                let netTimeWorkedString = numberFormatter.string(from: dayEntry.netHours) else {
                    throw EntriesExportError.numberFormatterFailed
            }
            let commentString = dayEntry.comment?.stripped ?? ""
            var projectString = GlobalConstants.nullString
            var subProjectString = GlobalConstants.nullString

            if dayEntry.project?.parent == nil,
                let project = dayEntry.project { // parent project
                projectString = project.displayName()
            } else if let subProject = dayEntry.project,
                let parent = subProject.parent {
                projectString = parent.name ?? ""
                subProjectString = subProject.name ?? ""
            }

            var row = [
                projectString,
                subProjectString,
                checkInDate,
                checkInTime,
                checkOutDate,
                checkOutTime,
                pauseTimeString,
                netTimeWorkedString,
                commentString
            ]

            if isExportTimeZone {
                checkInTimezone = checkInTimeZoneString
                checkInTimestamp = timestampDateFormatter.string(from: checkInTimeDate)
                row.insert(checkInTimezone, at: 2)
                row.insert(checkInTimestamp, at: 3)
                checkOutTimezone = checkOutTimeZoneString
                checkOutTimestamp = timestampDateFormatter.string(from: checkOutTimeDate)
                row.insert(checkOutTimezone, at: 6)
                row.insert(checkOutTimestamp, at: 7)
            }

            if isExportWage {
                guard let hourlyWageString = numberFormatter.string(from: dayEntry.actualHourlyWage),
                    let salaryString = numberFormatter.string(from: dayEntry.income) else {
                    throw EntriesExportError.numberFormatterFailed
                }
                row.insert(hourlyWageString, at: row.count - 1)
                row.insert(salaryString, at: row.count - 1)
            }

            row = row.escaped()
            table.append(row)
        }

        var totalNetTimeWorkedString = ""
        var totalPauseTimeString = ""

        if let netWorkingTimeHours = mainResult.netWorkingTimeHours,
            let text = numberFormatter.string(from: netWorkingTimeHours) {
            totalNetTimeWorkedString = text
        }
        if let pauseTimeHours = mainResult.pauseTimeHours,
            let text = numberFormatter.string(from: pauseTimeHours) {
            totalPauseTimeString = text
        }

        var bottomRow = [
            "Total".localized(exportLanguage: language),
            "",
            "",
            "",
            "",
            "",
            totalPauseTimeString,
            totalNetTimeWorkedString,
            ""
        ]

        if isExportTimeZone {
            bottomRow.insert("", at: 2)
            bottomRow.insert("", at: 3)
            bottomRow.insert("", at: 6)
            bottomRow.insert("", at: 7)
        }

        if isExportWage {
            bottomRow.insert("", at: bottomRow.count - 1)
            var totalHourlyWageString = ""
            if let income = mainResult.income,
                let text = numberFormatter.string(from: income) {
                totalHourlyWageString = text
            }
            bottomRow.insert(totalHourlyWageString, at: bottomRow.count - 1)
        }

        bottomRow = bottomRow.escaped()
        table.append(bottomRow)

        for project in projects {
            guard let result = projectResults[project.objectID] else {
                continue
            }
            var netTimeWorkedString = ""
            var pauseTimeString = ""
            if let netWorkingTimeHours = result.netWorkingTimeHours,
                let text = numberFormatter.string(from: netWorkingTimeHours) {
                netTimeWorkedString = text
            }
            if let pauseTimeHours = result.pauseTimeHours,
                let text = numberFormatter.string(from: pauseTimeHours) {
                pauseTimeString = text
            }

            var projectString = GlobalConstants.nullString
            var subProjectString = GlobalConstants.nullString

            if project.parent == nil { // parent project
                projectString = project.displayName()
            } else if let parent = project.parent {
                projectString = parent.name ?? ""
                subProjectString = project.name ?? ""
            }

            var row = [
                projectString,
                subProjectString,
                "",
                "",
                "",
                "",
                pauseTimeString,
                netTimeWorkedString,
                ""
            ]

            if isExportTimeZone {
                row.insert("", at: 2)
                row.insert("", at: 3)
                row.insert("", at: 6)
                row.insert("", at: 7)
            }

            if isExportWage {
                row.insert("", at: row.count - 1)
                var hourlyWageString = ""
                if let income = result.income,
                    let text = numberFormatter.string(from: income) {
                    hourlyWageString = text
                }
                row.insert(hourlyWageString, at: row.count - 1)
            }

            row = row.escaped()
            table.append(row)
        }

        let separator = exportNumberFormatter.isCommaSeparator ? ExportConstants.semicolonSeparatorChar : ExportConstants.commaSeparatorChar
        let csvText = CSVText(
            separator: separator,
            lineBreak: ExportConstants.lineBreak,
            table: table,
            isUseBom: true
        )

        guard let data = csvText.value().data(using: .utf8) else {
            throw ExportError.dataConstructionFailed
        }
        return data
    }
}
