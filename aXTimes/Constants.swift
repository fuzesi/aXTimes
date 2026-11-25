//
//  Constants.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 02/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation
import UIKit

enum LocalizationConstants {
    static let system = "System".localized
    static let color = "Colour".localized
    static let kaufmannRounding = "Kaufmännisch".localized
    static let roundDown = "Round down".localized
    static let roundUp = "Round up".localized

    static let hourShort = "Hour_short".localized
    static let minuteShort = "Minute_short".localized

    static let dayType = "Day type".localized
    static let dayTypeInstructions = "Change day type for currently selected date".localized

    static let projectDetails = NSLocalizedString("Project Details", comment: "")
    static let editProject = NSLocalizedString("Edit Project", comment: "")
    static let addSubproject = "Add Subproject".localized
    static let addSubprojectWarning = "addSubprojectWarning".localized
    static let subprojects = "Subprojects".localized
    static let name = "Name".localized
    static let duration = "Duration".localized
    static let description = "Description".localized
    static let code = "Code".localized
    static let phone = "Phone".localized
    static let client = "Client".localized
    static let hourlyWage = "Hourly wage".localized
    static let defaultComment = "Default Comment".localized
    static let projectBudget = "Budget".localized
    static let days = "days".localized
    static let remainingBudget = "Remaining Budget".localized
    static let noProject = "No Project assigned".localized
    static let email = "E-Mail".localized
    static let projects = "Projects".localized
    static let start = "Start".localized
    static let end = "End".localized
    static let workingTime = "Working_time".localized
    static let income = "Salary".localized

    static let daysLeft = "left".localized
    static let vacation = "Vacation".localized
    static let sickness = "Sickness day".localized
    static let holiday = "Public holiday".localized
    static let dayOffSingular = "Day off".localized
    static let workDay = "Work day".localized

    static let ok = "OK".localized
    static let cancel = "Cancel".localized
    static let `continue` = "Continue".localized
    static let error = "Error".localized
    static let success = "Success".localized

    static let dataManagement = "Data management".localized

    static let reportSettings = NSLocalizedString("Report_settings_section_title", comment: "Translate the tern 'Report' which is diplayed e.g. as a label section header in the settings view for settings like 'Time unit' and 'Rounding'.")
    static let timeUnit = "Time unit".localized
    static let rounding = "Rounding".localized
    static let currency = "Currency".localized
    static let language = "Language".localized

    // MARK: - Ticker Today Extension

    static let notWorkedToday = NSLocalizedString("Not yet worked today", comment: "Small label on main screen which is displayed if the user has not worked on that particular day. Translate: Not yet worked today")
    static let openApp = NSLocalizedString("Open App", comment: "Translate 'Open App'")
    static let pause = NSLocalizedString("Pause", comment: "Label: Pause")
    static let checkedInAt = NSLocalizedString("Checked in at:", comment: "Small label on main screen for displaying the check-in time. Translate the prefix: Checked in at")
    static let timeWorkedToday = NSLocalizedString("Time worked today", comment: "Small label on main screen for displaying the time which the user has already worked. Translate the prefix: Time worked today")
    static let checkOutAt = NSLocalizedString("Checked out at:", comment: "Label on main screen for displaying the check-out time. Translate the prefix: Checked out at")

    // Daten aus aXTimes 1.5 importieren
    static let oldDataImportTitle = "oldDataImportTitle".localized
    // Deine Daten werden aus aXTimes 1.5 importiert. Du kannst dabei einen Zeitraum auswählen oder die kompletten Daten übernehmen. Du kannst auch entscheiden welchem bereits angelegten aXTimes Pro-Projekt die Daten zugeordnet werden sollen. Bereits vorhandene Daten in aXTimes Pro werden überschrieben. Der Import kann mehrfach ausgeführt werden.
    static let oldDataImportActionDescription = "oldDataImportActionDescription".localized
    // aXTimes 1.5 wird gestartet um die Daten zu importieren. Bitte bis zum nächsten Hinweis warten.
    static let oldDataImportStartMessage = "oldDataImportStartMessage".localized
    // Welchem Projekt möchtest du die Daten zuordnen?
    static let oldDataImportProjectQuestion = "oldDataImportProjectQuestion".localized
    static let oldDataImportProjectHoulyWageMismatch = "oldDataImportProjectHoulyWageMismatch".localized
    static let oldDataImportProjectDurationMismatch = "oldDataImportProjectDurationMismatch".localized
    // Ab dem DD.MM.YYYY sind bereits Zeiten in aXTimes Pro erfasst. Diese Daten werden überschrieben.
    static let warning = "Warning".localized
    static let oldDataImportOverwriteQuestion = "oldDataImportOverwriteQuestion".localized
    // Daten wurden erfolgreich importiert.
    static let oldDataImportSuccess = "oldDataImportSuccess".localized
    static let oldDataImportProjectSelectionTitle = "oldDataImportProjectSelectionTitle".localized
    static let oldDataImportGenericError = "oldDataImportGenericError".localized

    // Backup wiederherstellen
    static let restoreBackupTitle = "restoreBackupTitle".localized
    // Deine Daten werden aus einem vorherigen Backup wiederhergestellt. Alle bestehenden Daten werden überschrieben.
    static let restoreBackupActionDescription = "restoreBackupActionDescription".localized
    static let restoreBackupPickertitle = "restoreBackupPickertitle".localized
    // Willst du dein Backup wiederherstellen? Warnung! Alle bestehenden Daten werden dabei gelöscht.
    static let restoreBackupStartMessage = "restoreBackupStartMessage".localized
    // Backup erfolgreich wiederhergestellt.
    static let restoreBackupSuccess = "restoreBackupSuccess".localized
    static let restoreBackupGenericError = "restoreBackupGenericError".localized

    // Backup erstellen
    static let createBackupTitle = "createBackupTitle".localized
    static let createBackupActionDescription = "createBackupActionDescription".localized
    static let createBackupGenericError = "BackupCreationErrorText".localized
    // Backup erfolgreich erstellt.
    static let createBackupSuccess = "createBackupSuccess".localized

    // MARK: - In-App purchases
    static let notAvailable = "notAvailable".localized
    static let buy = "buy".localized
    static let restore = "restore".localized
    static let premiumFeatures = "premiumFeatures".localized
}

enum GlobalConstants {
    static let basicGlobalProjectName = "__basic__global__axtimes__project__"
    static let nullString = "-"
    static let urlScheme = "com.aximilate.axtimespro://"

    static let roundingBehaviourNames = [LocalizationConstants.kaufmannRounding,
                                         LocalizationConstants.roundDown,
                                         LocalizationConstants.roundUp]
}

extension Notification.Name {
    static let importDataFinished = Notification.Name("notification_importDataFinished")
}

enum SettingConstants {
    static let launchedOnce = "settings_launchedOnce"

    static let showWelcomePopup = "settings_showwelcomepopup"
    static let showTutorial = "settings_showtutorial"

    static let exportInclTimeZone = "settings_export_incl_timezone"
    static let workingWeek = "settings_workingweek"
    static let exportWage = "settings_export_wage"
    static let currencyIso = "settings_currencyiso"
    static let exportEmail = "settings_export_email"
    static let timeFormatting = "settings_time_formatting"
    static let exportLanguageLocale = "settings_export_languagelocale"
    static let exportDecimalSeparator = "settings_export_decimalseparator"
    static let hoursperday = "settings_hoursperday"

    static let projectColorRotation = "settings_projectcolorrotation"
    static let clientColorRotation = "settings_clientcolorrotation"

    static let defaultPause = "settings_defaultpause"
    static let defaultPauseStart = "settings_defaultpausestart"
    static let defaultPauseEnd = "settings_defaultpauseend"

    static let shakeToUndo = "settings_projects_shaketoundo"

    static let projectsNoProject = "settings_projects_noproject"
    static let projectsLastProject = "settings_projects_lastproject"
}

enum ColorPalette {
    // #359BA5
    static let signature = UIColor(red: 53/255, green: 155/255, blue: 165/255, alpha: 1)
    static let systemRed = UIColor.red
    static let systemGreen = UIColor.green

    // #A53F16
    static let sickness = UIColor(red: 165/255, green: 63/255, blue: 22/255, alpha: 1.0)
    // #73BF71
    static let holiday = UIColor(red: 115/255, green: 191/255, blue: 113/255, alpha: 1.0)
    // #A59135
    static let vacation = UIColor(red: 165/255, green: 145/255, blue: 53/255, alpha: 1.0)
    // #336F33
    static let dayOff = UIColor(red: 51/255, green: 111/255, blue: 51/255, alpha: 1.0)
    // #251E31
    static let today = UIColor(red: 37/255, green: 30/255, blue: 49/255, alpha: 1.0)
    static let nextMonth = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
    static let weekend = UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1.0)
    static let selectedDate = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1.0)
}
