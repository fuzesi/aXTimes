//
//  SettingsManager+DefaultPause.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 17/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension SettingsManager {

    @objc var isDefaultPause: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingConstants.defaultPause)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.defaultPause)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var defaultPauseStart: Date {
        get {
            guard let defaultPauseStart =  UserDefaults.standard.object(forKey: SettingConstants.defaultPauseStart) as? Date else {
                return initialPauseStart
            }
            return defaultPauseStart
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.defaultPauseStart)
            UserDefaults.standard.synchronize()
        }
    }

    @objc var defaultPauseEnd: Date {
        get {
            guard let defaultPauseEnd =  UserDefaults.standard.object(forKey: SettingConstants.defaultPauseEnd) as? Date else {
                return initialPauseEnd
            }
            return defaultPauseEnd
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingConstants.defaultPauseEnd)
            UserDefaults.standard.synchronize()
        }
    }

    // week start at monday with index 0
    @objc func defaultPauseStart(forWeekday weekday: UInt) -> Date {
        if let defaultPauseSetting = AXDataStore.sharedInstance().defaultPauseSettingEntry(forWeekDayIndex: weekday),
            let start = defaultPauseSetting.start as Date? {
            return start
        } else {
            return defaultPauseStart
        }
    }

    @objc func defaultPauseEnd(forWeekday weekday: UInt) -> Date {
        if let defaultPauseSetting = AXDataStore.sharedInstance().defaultPauseSettingEntry(forWeekDayIndex: weekday),
            let end = defaultPauseSetting.end as Date? {
            return end
        } else {
            return defaultPauseEnd
        }
    }
}
