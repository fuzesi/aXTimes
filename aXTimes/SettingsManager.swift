//
//  SettingsManager+Swift.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 08/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

@objc enum TimeFormatting: Int {
    case `default` = 0, hhmm
}

private enum StartUpConstants {
    static let currency = "EUR"
}

class SettingsManager: NSObject {
    @objc let decimalSeparators = [GlobalConstants.nullString,
                             ",",
                             "."]

    @objc let languageLocales = [GlobalConstants.nullString,
                           "de",
                           "en",
                           "hu",
                           "sv"]
    @objc let roundingBehaviourNames = [LocalizationConstants.kaufmannRounding,
                                  LocalizationConstants.roundDown,
                                  LocalizationConstants.roundUp]


    @nonobjc var initialPauseStart: Date {
        let calendar = Calendar.defaultCalendar(isStatic: true)
        var components = DateComponents()
        components.hour = 12
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }

    @nonobjc var initialPauseEnd: Date = {
        let calendar = Calendar.defaultCalendar(isStatic: true)
        var components = DateComponents()
        components.hour = 13
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }()
}

extension SettingsManager {

    private var initialWorkingWeek: [NSNumber] {
        return [NSNumber(value: true),
                NSNumber(value: true),
                NSNumber(value: true),
                NSNumber(value: true),
                NSNumber(value: true),
                NSNumber(value: false),
                NSNumber(value: false)]
    }

    @objc func setupInitial(force: Bool = false) {
        guard !UserDefaults.standard.bool(forKey: SettingConstants.launchedOnce) || force else {
            return
        }

        let defaults = UserDefaults.standard

        if !force {
            defaults.set(true, forKey: SettingConstants.showWelcomePopup)
            defaults.set(true, forKey: SettingConstants.showTutorial)
        }

        currencyIso = StartUpConstants.currency
        hoursPerDay = NSNumber(value: 8)
        timeFormatting = .default
        isDefaultPause = false
        defaultPauseStart = initialPauseStart
        defaultPauseEnd = initialPauseEnd
        workingWeek = initialWorkingWeek
        exportEmail = ""
        exportLanguageLocale = languageLocales[0]
        exportDecimalSeparator = decimalSeparators[0]
        isExportTimeZone = true
        isExportWage = false
        isShakeToUndo = true

        isCheckinSettingNoProject = true
        isCheckinSettingLastProject = false

        setProjectColorRotationIndex(0)
        setClientColorRotationIndex(0)

        defaults.set(true, forKey: SettingConstants.launchedOnce)
        defaults.synchronize()
    }

    @objc var currencyIso: String {
        get {
            return UserDefaults.standard.string(forKey: SettingConstants.currencyIso) ?? StartUpConstants.currency
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.currencyIso)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var timeFormatting: TimeFormatting {
        get {
            return TimeFormatting(rawValue: UserDefaults.standard.integer(forKey: SettingConstants.timeFormatting)) ?? .default
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SettingConstants.timeFormatting)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var hoursPerDay: NSNumber {
        get {
            guard let hoursperday =  UserDefaults.standard.object(forKey: SettingConstants.hoursperday) as? NSNumber else {
                return NSNumber(value: 8)
            }
            return hoursperday
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.hoursperday)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var hoursPerDayDisplayValue: String {
        let formatter = NumberFormatter.defaultFormatter(isStatic: true)
        return formatter.string(from: hoursPerDay)!
    }

    @objc var hourlyWageDisplayValue: String {
        let formatter = NumberFormatter.defaultFormatter(isStatic: true)
        return formatter.string(from: hourlyWage)!
    }

    @objc var workingWeek: [NSNumber] {
        get {
            guard let workingWeek =  UserDefaults.standard.object(forKey: SettingConstants.workingWeek) as? [NSNumber] else {
                return initialWorkingWeek
            }
            return workingWeek
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.workingWeek)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var exportEmail: String {
        get {
            return UserDefaults.standard.string(forKey: SettingConstants.exportEmail) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.exportEmail)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var exportLanguageLocale: String {
        get {
            return UserDefaults.standard.string(forKey: SettingConstants.exportLanguageLocale) ?? languageLocales[0]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.exportLanguageLocale)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var isCustomExportLanguage: Bool {
        return UserDefaults.standard.string(forKey: SettingConstants.exportLanguageLocale) != GlobalConstants.nullString
    }

    @objc var exportLanguageLocaleDisplayValue: String {
        return AXUtility.locale(toExportLanguageString: exportLanguageLocale)
    }

    @objc var exportDecimalSeparator: String {
        get {
            return UserDefaults.standard.string(forKey: SettingConstants.exportDecimalSeparator) ?? decimalSeparators[0]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.exportDecimalSeparator)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var isCustomSeparator: Bool {
        return UserDefaults.standard.string(forKey: SettingConstants.exportDecimalSeparator) != GlobalConstants.nullString
    }

    @objc var exportDecimalSeparatorDisplayValue: String {
        if exportDecimalSeparator == GlobalConstants.nullString {
            return "\(LocalizationConstants.system) (\(NumberFormatter().decimalSeparator ?? ""))"
        } else {
            return exportDecimalSeparator
        }
    }

    @objc var isExportTimeZone: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingConstants.exportInclTimeZone)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.exportInclTimeZone)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var isExportWage: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingConstants.exportWage)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.exportWage)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var isShakeToUndo: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingConstants.shakeToUndo)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.shakeToUndo)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var isCheckinSettingNoProject: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingConstants.projectsNoProject)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.projectsNoProject)
            UserDefaults.standard.synchronize()
            if newValue {
                isCheckinSettingLastProject = !newValue
            }
        }
    }

    // last project cannot be set if the last project
    // checked-in on is not running anymore
    @objc var isCheckinSettingLastProject: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingConstants.projectsLastProject)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.projectsLastProject)
            UserDefaults.standard.synchronize()
            if newValue {
                isCheckinSettingNoProject = !newValue
            }
        }
    }
}
