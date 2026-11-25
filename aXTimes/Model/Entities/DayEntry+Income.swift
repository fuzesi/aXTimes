//
//  DayEntry+Income.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 14/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension DayEntry {

    // MARK: - class methods

    @objc class func income(forArray array: [DayEntry]) -> NSDecimalNumber {
        var returnSalary = NSDecimalNumber.zero
        array.forEach { returnSalary = returnSalary.adding($0.income) }
        return returnSalary
    }

    // MARK: - main income methods

    // salary based on net hours
    @objc var income: NSDecimalNumber {
        guard actualHourlyWage.isGreaterZero else {
            return NSDecimalNumber.zero
        }
        let hoursWorked = netHoursAsNumber().decimalNumber
        let returnValue = hoursWorked.multiplying(by: actualHourlyWage)
        return returnValue
    }

    @objc var incomeUntilNow: NSDecimalNumber {
        return income(withMinutesWorked: minutesWorkedUntilNow)
    }

    @objc func income(withMinutesWorked minutes: NSDecimalNumber) -> NSDecimalNumber {
        guard actualHourlyWage.isGreaterZero else {
            return NSDecimalNumber.zero
        }
        let hoursWorked = minutes.dividing(by: NSDecimalNumber.sixty)
        let returnValue = hoursWorked.multiplying(by: actualHourlyWage)
        return returnValue
    }

    // MARK: - display values

    @objc var incomeDisplayValueForCounter: String {
        return DayEntry.decimalNumberFormatter.string(from: income) ?? ""
    }

    @objc var incomeWithCurrencyDisplayValue: String {
        let currencyString = SettingsManager().currencyIso
        let returnString = "\(DayEntry.decimalNumberFormatter.string(from: income) ?? "") \(currencyString)"
        return returnString
    }

    @objc var incomeUntilNowDisplayValue: String {
        return DayEntry.decimalNumberFormatter.string(from: incomeUntilNow) ?? ""
    }
}
