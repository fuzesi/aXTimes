//
//  ExportNumberFormatter.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 28.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation

protocol ExportNumberFormatterProtocol {
    var isCommaSeparator: Bool { get }
    func formatter() -> NumberFormatter
}

struct ExportNumberFormatter: ExportNumberFormatterProtocol {

    var isCommaSeparator: Bool {
        return numberFormatter.decimalSeparator == ExportConstants.commaSeparatorChar
    }

    private let numberFormatter: NumberFormatter

    init(settingsManager: SettingsManager) {
        let numberFormatter = NumberFormatter.defaultFormatter(isStatic: false)
        if settingsManager.isCustomSeparator {
            numberFormatter.decimalSeparator = settingsManager.exportDecimalSeparator
        }
        numberFormatter.usesGroupingSeparator = false
        self.numberFormatter = numberFormatter
    }

    func formatter() -> NumberFormatter {
        return numberFormatter
    }

}
