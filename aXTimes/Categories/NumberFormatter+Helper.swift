//
//  File.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 25/01/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension NumberFormatter {

    private static let staticFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.roundingIncrement = NSNumber(value: 0.01)
        formatter.roundingMode = .halfUp
        return formatter
    }()

    @objc static func defaultFormatter(isStatic: Bool) -> NumberFormatter {
        if isStatic {
            return staticFormatter
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            formatter.roundingIncrement = NSNumber(value: 0.01)
            formatter.roundingMode = .halfUp
            return formatter
        }
    }
}
