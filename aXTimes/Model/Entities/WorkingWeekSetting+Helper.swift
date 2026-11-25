//
//  WorkingWeekSetting+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 21/03/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension WorkingWeekSetting {

    @objc func isWorkingWeekEqual(to workingWeekSetting: WorkingWeekSetting) -> Bool {
        for (index, element) in workingWeek.enumerated() {
            if !element.isEqual(to: workingWeekSetting.workingWeek[index]) {
                return false
            }
        }
        return true
    }

    @objc func isWorkingWeekEqual(workingWeekArray: [NSNumber]) -> Bool {
        guard workingWeekArray.count == 7 else {
            return false
        }
        for (index, element) in workingWeek.enumerated() {
            if !element.isEqual(to: workingWeekArray[index]) {
                return false
            }
        }
        return true
    }

    @objc func configure(withValidUntilDate validUntil: Date,
                   andTimeZone timeZone: String = NSTimeZone.system.identifier) {
        self.validUntil = validUntil as NSDate
        validUntilTimeZone = timeZone

        let formatter = DateFormatter()
        formatter.locale = NSLocale.current
        formatter.dateFormat = "yyyy_MM_dd"
        validUntilString = formatter.string(from: validUntil)

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        formatter.dateFormat = "yyyy"
        year = numberFormatter.number(from: formatter.string(from: validUntil))

        formatter.dateFormat = "MM"
        month = numberFormatter.number(from: formatter.string(from: validUntil))

        formatter.dateFormat = "dd"
        day = numberFormatter.number(from: formatter.string(from: validUntil))
    }

    @objc var dayKey: String {
        return validUntilString?.replacingOccurrences(of: "_", with: "") ?? ""
    }

    @objc var workingWeek: [NSNumber] {
        let y = NSNumber(value: true)
        let n = NSNumber(value: false)
        let monday = self.monday ?? y
        let tuesday = self.tuesday ?? y
        let wednesday = self.wednesday ?? y
        let thursday = self.thursday ?? y
        let friday = self.friday ?? y
        let saturday = self.saturday ?? n
        let sunday = self.sunday ?? n
        return [monday,
                tuesday,
                wednesday,
                thursday,
                friday,
                saturday,
                sunday]
    }

    @objc func configure(withWorkingWeek workingWeek: [NSNumber]) {
        guard workingWeek.count == 7 else {
            return
        }
        monday = workingWeek[0]
        tuesday = workingWeek[1]
        wednesday = workingWeek[2]
        thursday = workingWeek[3]
        friday = workingWeek[4]
        saturday = workingWeek[5]
        sunday = workingWeek[6]
    }
}
