//
//  NSNumber+Formatting.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 08/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension NSNumber {
    @objc var displayTime: String {
        if SettingsManager().timeFormatting == .default {
            return stringValueNumberFormatted().append(withWhiteSpace: LocalizationConstants.hourShort)
        } else {
            return numberToTimeString()
        }
    }
}
