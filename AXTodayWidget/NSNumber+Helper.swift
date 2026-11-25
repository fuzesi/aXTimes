//
//  NSNumber+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 09/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension NSNumber {

    func decimalNumber() -> NSDecimalNumber {
        return NSDecimalNumber(decimal: decimalValue)
    }

    func hoursToDays(withHoursPerDay hoursPerDay: NSDecimalNumber) -> NSDecimalNumber? {
        guard NSDecimalNumber.zero.compare(hoursPerDay) == .orderedAscending else {
            return nil
        }

        let handler = NSDecimalNumberHandler(roundingMode: .plain,
                                             scale: 2,
                                             raiseOnExactness: false,
                                             raiseOnOverflow: false,
                                             raiseOnUnderflow: false,
                                             raiseOnDivideByZero: false)
        let days = decimalNumber().dividing(by: hoursPerDay,
                                            withBehavior: handler)
        return days
    }

    func greaterZero() -> Bool {
        return NSDecimalNumber.zero.compare(NSDecimalNumber(decimal: self.decimalValue)) == .orderedAscending
    }

    func clockDisplayValue() -> String {
        var secondsWorked = doubleValue
        let minutesWorked: Double = secondsWorked / 60.0
        let tempString: String = String(format:"%f", minutesWorked)
        var timeArray = tempString.components(separatedBy: ".")
        var minutes: Int = Int((timeArray[0] as String))!

        let hoursWorked = Double(minutes) / 60.0

        timeArray = String(format:"%f", hoursWorked).components(separatedBy: ".")
        let hours: Int = Int((timeArray[0] as String))!

        minutes -= (hours * 60)

        let hoursToSubstract = (Double(hours) * 60.0 * 60.0)
        let minutesToSubstract = (Double(minutes) * 60.0)
        secondsWorked -= (hoursToSubstract + minutesToSubstract)
        timeArray =  String(format:"%f", secondsWorked).components(separatedBy: ".")
        let seconds: Int = Int((timeArray[0] as String))!

        let secondsFormat = "02"

        // http://stackoverflow.com/questions/24051314/precision-string-format-specifier-in-swift
        return hours.format(secondsFormat) + ":" + minutes.format(secondsFormat) + ":" + seconds.format(secondsFormat)
    }
}

extension Int {
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)d" as NSString, self) as String
    }
}
