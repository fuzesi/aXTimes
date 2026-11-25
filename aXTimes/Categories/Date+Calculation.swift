//
//  Date+Calculation.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 08/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension Date {
    func add(days: NSInteger) -> Date? {
        let calendar = Calendar.defaultCalendar(isStatic: true)
        var components = DateComponents()
        components.day = days
        return calendar.date(byAdding: components,
                             to: self)
    }
}
