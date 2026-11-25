//
//  DayType+Sharing.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 13/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension DayType: JSONRepresentable {
    @objc var jsonRepresentation: [String : Any] {
        let dict: [String: Any] = ["calendarDate": JSONHelper.jsonObject(object: calendarDate),
                                   "calendarDateTimeZone": JSONHelper.jsonObject(object: calendarDateTimeZone),
                                   "calendarDay": JSONHelper.jsonObject(object: calendarDay),
                                   "vacation": JSONHelper.jsonObject(object: vacation),
                                   "sickness": JSONHelper.jsonObject(object: sickness),
                                   "work": JSONHelper.jsonObject(object: work),
                                   "holiday": JSONHelper.jsonObject(object: holiday),
                                   "year": JSONHelper.jsonObject(object: year),
                                   "month": JSONHelper.jsonObject(object: month),
                                   "day": JSONHelper.jsonObject(object: day)]
        return dict
    }

    @objc convenience init?(dictionary: [String: Any],
                      insertIntoManagedObjectContext context: NSManagedObjectContext) {
        guard let actualCalendarDate = JSONHelper.date(object: dictionary["calendarDate"]),
            let actualTimeZone = dictionary["calendarDateTimeZone"] as? String,
            let actualCalendarDay = dictionary["calendarDay"] as? String,
            let actualWork = dictionary["work"] as? NSNumber,
            let actualVacation = dictionary["vacation"] as? NSNumber,
            let actualSickness = dictionary["sickness"] as? NSNumber,
            let actualHoliday = dictionary["holiday"] as? NSNumber,
            let actualYear = dictionary["year"] as? NSNumber,
            let actualMonth = dictionary["month"] as? NSNumber,
            let actualDay = dictionary["day"] as? NSNumber else {
                return nil
        }
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: DayType.self),
                                                      in: context) else {
                                                        return nil
        }
        self.init(entity: entity,
                  insertInto: context)
        calendarDate = actualCalendarDate
        calendarDateTimeZone = actualTimeZone
        calendarDay = actualCalendarDay
        vacation = actualVacation
        sickness = actualSickness
        work = actualWork
        holiday = actualHoliday
        year = actualYear
        month = actualMonth
        day = actualDay
    }
}
