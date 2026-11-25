//
//  ProjectHeaderRow.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 28.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation

protocol ExportRow {
    func values() -> [String]
}

struct ProjectContentRow: ExportRow {

    private let project: Project
    private let isExportWage: Bool
    private let formatter: NumberFormatter

    init(
        project: Project,
        isExportWage: Bool,
        formatter: NumberFormatter
        ) {
        self.project = project
        self.isExportWage = isExportWage
        self.formatter = formatter
    }

    func values() -> [String] {
        var projectName = ""
        var subProjectName = ""
        var projectDescription = ""
        var from = ""
        var to = ""
        var workingTime = ""
        var budget = ""
        var remainingBudget = ""

        if let parent = project.parent {
            projectName = parent.displayNameForTreeView()
            subProjectName = project.displayNameForTreeView()
        } else {
            projectName = project.displayNameForTreeView()
        }
        if let actualProjectDescription = project.projectDescription {
            projectDescription = actualProjectDescription.stripped
        }
        if let actualDate = project.fromDate as Date? {
            from = DateFormatter.dayMonthYear(isStatic: true).string(from: actualDate)
        }
        if let actualDate = project.toDate as Date? {
            to = DateFormatter.dayMonthYear(isStatic: true).string(from: actualDate)
        }
        workingTime = formatter.string(from: project.netTimeHours) ?? ""
        budget = formatter.string(from: project.actualBudget) ?? ""
        if let actualRemainingBudget = project.remainingBudgetDaysTotal() {
            remainingBudget = formatter.string(from: actualRemainingBudget) ?? ""
        }

        var row: [String] = [
            projectName,
            subProjectName,
            projectDescription,
            from,
            to,
            workingTime,
            budget,
            remainingBudget
        ]

        if isExportWage {
            row.append(formatter.string(from: project.income) ?? "")
        }

        return row
    }
}

struct ProjectHeaderRow: ExportRow {

    private let exportLanguage: String?

    init(exportLanguage: String?) {
        self.exportLanguage = exportLanguage
    }

    func values() -> [String] {
        return [
            "Projects".localized(exportLanguage: exportLanguage),
            "Subprojects".localized(exportLanguage: exportLanguage),
            "Description".localized(exportLanguage: exportLanguage),
            "Start".localized(exportLanguage: exportLanguage),
            "End".localized(exportLanguage: exportLanguage),
            "Working_time".localized(exportLanguage: exportLanguage),
            "Budget".localized(exportLanguage: exportLanguage),
            "Remaining Budget".localized(exportLanguage: exportLanguage)
            ]
    }
}

struct SalaryHeaderRow: ExportRow {

    private let exportRow: ExportRow
    private let exportLanguage: String?
    private let currencyIso: String
    private let income: String

    init(
        exportRow: ExportRow,
        exportLanguage: String?,
        currencyIso: String
        ) {
        self.exportLanguage = exportLanguage
        self.exportRow = exportRow
        self.currencyIso = currencyIso
        income = "Wage in".localized(exportLanguage: exportLanguage)
    }

    func values() -> [String] {
        var exportRowValues = exportRow.values()
        exportRowValues.append("\(income) \(currencyIso)")
        return exportRowValues
    }
}

struct YearExportHeaderRow: ExportRow {

    private let exportLanguage: String?

    init(exportLanguage: String?) {
        self.exportLanguage = exportLanguage
    }

    func values() -> [String] {
        return [
            "Month".localized(exportLanguage: exportLanguage),
            "Working_time".localized(exportLanguage: exportLanguage),
            "Overtime".localized(exportLanguage: exportLanguage)
            ]
    }
}

struct EntriesExportHeaderRow: ExportRow {

    private let exportLanguage: String?

    init(exportLanguage: String?) {
        self.exportLanguage = exportLanguage
    }

    func values() -> [String] {
        return [
            "Project".localized(exportLanguage: exportLanguage),
            "Subproject".localized(exportLanguage: exportLanguage),
            "Check-In date".localized(exportLanguage: exportLanguage),
            "Check-In time".localized(exportLanguage: exportLanguage),
            "Check-Out date".localized(exportLanguage: exportLanguage),
            "Check-Out time".localized(exportLanguage: exportLanguage),
            "Pause time".localized(exportLanguage: exportLanguage),
            "Working_time".localized(exportLanguage: exportLanguage),
            "Comment".localized(exportLanguage: exportLanguage)
            ]
    }
}

