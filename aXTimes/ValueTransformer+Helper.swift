//
//  Groot+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 23/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

func numberToDecimalNumber(_ value: NSNumber) -> NSDecimalNumber? {
    return value.decimalNumber
}

func decimalNumberToNumber(_ value: NSDecimalNumber) -> NSNumber? {
    return value as NSNumber
}

func stringToDate(_ value: String) -> Date? {
    return formatter.date(from: value)
}

func dateToString(_ value: Date) -> String? {
    return formatter.string(from: value)
}

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
    return formatter
}()

