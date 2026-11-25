//
//  EntriesYearExport.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 28.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation

enum EntriesYearExportError: Error {
    case dateConstructionFailed
    case numberFormatterFailed
    case missingCalculationResult
}

@objc class EntriesYearExport: NSObject, Export {

    private let entries: [DayEntry]
    private let settingsManager: SettingsManager
    private let calculation: AXCalculation
    private let exportNumberFormatter: ExportNumberFormatter

    @objc init(
        entries: [DayEntry],
        settingsManager: SettingsManager,
        calculation: AXCalculation
        ) {
        self.entries = entries
        self.settingsManager = settingsManager
        self.calculation = calculation
        self.exportNumberFormatter = ExportNumberFormatter(settingsManager: settingsManager)
        super.init()
    }

    @objc func data() throws -> Data {
        let isExportWage = settingsManager.isExportWage
        let language: String? = settingsManager.isCustomExportLanguage ? settingsManager.exportLanguageLocale : nil
        let numberFormatter = exportNumberFormatter.formatter()
        let yearExportHeaderRow = YearExportHeaderRow(exportLanguage: language)
        let currency = settingsManager.currencyIso
        let headerRow: ExportRow = isExportWage ? SalaryHeaderRow(exportRow: yearExportHeaderRow, exportLanguage: language, currencyIso: currency) : yearExportHeaderRow
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let calendar = Calendar.defaultCalendar(isStatic: true)
        var components = calendar.dateComponents(Date.defaultCalendarComponents, from: now)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.day = 1

        var table = [headerRow.values().escaped()]
        var overtime = NSDecimalNumber.zero
        for index in 1...12 {
            components.month = index
            guard let monthDate = calendar.date(from: components) else {
                throw EntriesYearExportError.dateConstructionFailed
            }
            let monthString = dateFormatter.string(from: monthDate)
            var tempEntries: [DayEntry] = []
            for entry in entries {
                if entry.checkInTime?.isSameMonthOnlyMonthComponent(monthDate) ?? false {
                    tempEntries.append(entry)
                }
            }

            var netTimeWorkedString = GlobalConstants.nullString
            var overtimeString = GlobalConstants.nullString

            if tempEntries.count > 0 {
                let netTimeHours = DayEntry.netTime(forArray: tempEntries)
                netTimeWorkedString = numberFormatter.string(from: netTimeHours) ?? ""
                let lastEntry = tempEntries[tempEntries.count - 1]
                guard let calculationResult = calculation.getTargetWorkingDays(
                    forTime: .month,
                    andDate: monthDate,
                    andLast: lastEntry
                    ) else {
                        throw EntriesYearExportError.missingCalculationResult
                }
                let hoursPerDay = NSDecimalNumber(decimal: settingsManager.hoursPerDay.decimalValue)
                if let overtimeTemp = AXCalculation.overtimeHours(
                    withTargetWorkingDays: calculationResult.wholeRangeTargetDays.decimalNumber,
                    withHoursPerDay: hoursPerDay,
                    withNetTimeHours: netTimeHours.decimalNumber
                    ) {
                    overtime = overtime.adding(overtimeTemp)
                    overtimeString = numberFormatter.string(from: overtimeTemp) ?? ""
                }
            }

            var row = [monthString, netTimeWorkedString, overtimeString]

            if isExportWage {
                let income = DayEntry.income(forArray: tempEntries)
                guard let hourlyWageString = numberFormatter.string(from: income) else {
                    throw EntriesYearExportError.numberFormatterFailed
                }
                row.append(hourlyWageString)
            }

            row = row.escaped()
            table.append(row)
        }

        guard let totalNetTimeWorkedString = numberFormatter.string(from: DayEntry.netTime(forArray: entries)),
            let totalOvertimeString = numberFormatter.string(from: overtime) else {
                throw EntriesYearExportError.numberFormatterFailed
        }

        // bottom row for total
        var bottomRow = ["Total".localized(exportLanguage: language), totalNetTimeWorkedString, totalOvertimeString]

        if isExportWage {
            guard let totalHourlyWageString = numberFormatter.string(from: DayEntry.income(forArray: entries)) else {
                throw EntriesYearExportError.numberFormatterFailed
            }
            bottomRow.append(totalHourlyWageString)
        }

        bottomRow = bottomRow.escaped()
        table.append(bottomRow)

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
