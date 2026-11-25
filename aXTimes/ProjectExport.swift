//
//  ProjectExport.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 24/01/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

@objc class ProjectExport: NSObject, Export {

    private let settingsManager: SettingsManager
    private let projects: [Project]
    private let exportNumberFormatter: ExportNumberFormatter

    @objc init(
        projects: [Project],
        settingsManager: SettingsManager
        ) {
        self.projects = projects
        self.settingsManager = settingsManager
        self.exportNumberFormatter = ExportNumberFormatter(settingsManager: settingsManager)
        super.init()
    }

    @objc func data() throws -> Data {
        let isExportWage = settingsManager.isExportWage
        let language: String? = settingsManager.isCustomExportLanguage ? settingsManager.exportLanguageLocale : nil
        let numberFormatter = exportNumberFormatter.formatter()
        let projectHeaderRow = ProjectHeaderRow(exportLanguage: language)
        let currency = settingsManager.currencyIso
        let headerRow: ExportRow = isExportWage ? SalaryHeaderRow(exportRow: projectHeaderRow, exportLanguage: language, currencyIso: currency) : projectHeaderRow

        var table = [headerRow.values().escaped()]
        projects.forEach { parentProject in
            let row = ProjectContentRow(project: parentProject, isExportWage: isExportWage, formatter: numberFormatter)
            table.append(row.values())
            let subProjects = parentProject.sortedSubProjectsWithFilterActivated
            subProjects.forEach {
                let row = ProjectContentRow(project: $0, isExportWage: isExportWage, formatter: numberFormatter)
                table.append(row.values())
            }
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
