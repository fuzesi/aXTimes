//
//  DataProcessingController.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 21/02/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

class DataProcessingController: NSObject {
    
    static private let packageDataKey = "packageDataKey"
    
    static private let kAXSourceApplicationNameKey = "kAXSourceApplicationNameKey"
    static private let kAXSourceApplicationIdentifierKey = "kAXSourceApplicationIdentifierKey"
    static private let kAXSourceApplicationVersionKey = "kAXSourceApplicationVersionKey"
    static private let kAXSourceApplicationBuildKey = "kAXSourceApplicationBuildKey"
    static private let kAXPayloadKey = "kAXPayloadKey"
    
    static func jsonDataForMigration(selectedDayEntries: [DayEntry]) -> Data? {
        guard let infoPlist = Bundle.main.infoDictionary else {
            return nil
        }
        guard let currentApplicationName = infoPlist["CFBundleDisplayName"] as? String else {
            return nil
        }
        guard let currentApplicationIdentifier = infoPlist["CFBundleIdentifier"] as? String else {
            return nil
        }
        guard let currentApplicationVersion = infoPlist["CFBundleShortVersionString"] as? String else {
            return nil
        }
        guard let currentApplicationBuild = infoPlist["CFBundleVersion"] as? String else {
            return nil
        }

        let settingsManager = AXSettingsManager()
        
        let settings: [String: Any] = ["settings_hoursperday": JSONHelper.JSONObject(object: settingsManager.getHoursPerDay()),
                                       "settings_hourlywage": JSONHelper.JSONObject(object: settingsManager.getHourlyWageAsNumber()),
                                       "settings_currencyiso": JSONHelper.JSONObject(object: settingsManager.getCurrencyIso()),
                                       "settings_worktimeunit": JSONHelper.JSONObject(object: settingsManager.getWorkTimeUnit()),
                                       "settings_netrounding": JSONHelper.JSONObject(object: settingsManager.getNetRounding().rawValue),
                                       "settings_defaultcomment": JSONHelper.JSONObject(object: settingsManager.getDefaultComment()),
                                       "settings_workingweek": JSONHelper.JSONObject(object: WorkingWeekSetting.workingWeekJsonRepresentation(settingsManager.getWorkingweek())),
                                       "settings_defaultpause": JSONHelper.JSONObject(object: settingsManager.isDefaultPause()), //mhm
                                       "settings_defaultpausestart": JSONHelper.JSONObject(object: settingsManager.getDefaultPauseStart()),
                                       "settings_defaultpauseend": JSONHelper.JSONObject(object: settingsManager.getDefaultPauseEnd()),
                                       "settings_export_email": JSONHelper.JSONObject(object: settingsManager.getExportEmail()),
                                       "settings_export_languagelocale": JSONHelper.JSONObject(object: settingsManager.getExportLanguageLocale()),
                                       "settings_export_wage": JSONHelper.JSONObject(object: settingsManager.getExportWage()), //mhm
                                       "settings_export_decimalseparator": JSONHelper.JSONObject(object: settingsManager.getExportDecimalSeparator()),
                                       "settings_export_incl_timezone": JSONHelper.JSONObject(object: settingsManager.getInclTimezone()), //mhm
                                       "settings_time_formatting": JSONHelper.JSONObject(object: AXSettingsManager.timeFormatting().rawValue)]
        var dayEntries = [[String: Any]]()
        var comments = [[String: Any]]()
        var workingWeekSettings = [[String: Any]]()
        var dayTypes = [[String: Any]]()

        dayEntries = selectedDayEntries.map({
            $0.jsonRepresentation()
        })

        if let tempArray = AXDataStore.sharedInstance().getAllManagedObjects(for: Comment.self) as? [Comment] {
            comments = tempArray.map({
                $0.jsonRepresentation()
            })
        }
        
        if let tempArray = AXDataStore.sharedInstance().getAllManagedObjects(for: WorkingWeekSetting.self) as? [WorkingWeekSetting] {
            workingWeekSettings = tempArray.map({
                $0.jsonRepresentation()
            })
        }
        
        if let tempArray = AXDataStore.sharedInstance().getAllManagedObjects(for: DayType.self) as? [DayType] {
            dayTypes = tempArray.map({
                $0.jsonRepresentation()
            })
        }
        
        let payload = ["purpose": "migration",
                       "settings": settings,
                       "dayEntries": dayEntries,
                       "comments": comments,
                       "workingWeekSettings": workingWeekSettings,
                       "dayTypes": dayTypes] as [String : Any]
        
        let dict = [DataProcessingController.kAXSourceApplicationNameKey: currentApplicationName,
                    DataProcessingController.kAXSourceApplicationIdentifierKey: currentApplicationIdentifier,
                    DataProcessingController.kAXSourceApplicationVersionKey: currentApplicationVersion,
                    DataProcessingController.kAXSourceApplicationBuildKey: currentApplicationBuild,
                    DataProcessingController.kAXPayloadKey: payload] as [String: Any]
        
        
        if (JSONSerialization.isValidJSONObject(dict)) {
            do {
//                let data =  try JSONSerialization.data(withJSONObject: dict,
//                                                       options: [.prettyPrinted])
                let data =  try JSONSerialization.data(withJSONObject: dict,
                                                       options: [])
                return data
            } catch  {
                print("error: \(error)")

            }
        }
        
        return nil
    }
}
