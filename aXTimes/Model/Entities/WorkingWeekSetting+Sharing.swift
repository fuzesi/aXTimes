//
//  WorkingWeekSetting+Export.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 21/02/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension WorkingWeekSetting: JSONRepresentable {
    @objc var jsonRepresentation: [String : Any] {
        var dict: [String: Any] = ["validUntil": JSONHelper.jsonObject(object: validUntil),
                                   "validUntilTimeZone": JSONHelper.jsonObject(object: validUntilTimeZone),
                                   "validUntilString": JSONHelper.jsonObject(object: validUntilString),
                                   "day": JSONHelper.jsonObject(object: day),
                                   "month": JSONHelper.jsonObject(object: month),
                                   "year": JSONHelper.jsonObject(object: year)]
        // weirdest compile time bug ever
        // http://stackoverflow.com/a/40407950/1113632
        let week: [String: Any] = ["monday": JSONHelper.jsonObject(object: monday),
                                   "tuesday": JSONHelper.jsonObject(object: tuesday),
                                   "wednesday": JSONHelper.jsonObject(object: wednesday),
                                   "thursday": JSONHelper.jsonObject(object: thursday),
                                   "friday": JSONHelper.jsonObject(object: friday),
                                   "saturday": JSONHelper.jsonObject(object: saturday),
                                   "sunday": JSONHelper.jsonObject(object: sunday)]
        dict.update(week)

        return dict
    }

    @objc convenience init?(dictionary: [String: Any],
                      insertIntoManagedObjectContext context: NSManagedObjectContext) {
        guard let actualValidUntil = JSONHelper.date(object: dictionary["validUntil"]),
            let actualValidUntilTimeZone = dictionary["validUntilTimeZone"] as? String,
            let actualValidUntilString = dictionary["validUntilString"] as? String,
            let actualYear = dictionary["year"] as? NSNumber,
            let actualMonth = dictionary["month"] as? NSNumber,
            let actualDay = dictionary["day"] as? NSNumber,
            let actualMonday = dictionary["monday"] as? NSNumber,
            let actualTuesday = dictionary["tuesday"] as? NSNumber,
            let actualWednesday = dictionary["wednesday"] as? NSNumber,
            let actualThursday = dictionary["thursday"] as? NSNumber,
            let actualFriday = dictionary["friday"] as? NSNumber,
            let actualSaturday = dictionary["saturday"] as? NSNumber,
            let actualSunday = dictionary["sunday"] as? NSNumber else {
                return nil
        }
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: WorkingWeekSetting.self),
                                                      in: context) else {
                                                        return nil
        }
        self.init(entity: entity,
                  insertInto: context)
        validUntil = actualValidUntil
        validUntilString = actualValidUntilString
        validUntilTimeZone = actualValidUntilTimeZone
        day = actualDay
        month = actualMonth
        year = actualYear
        monday = actualMonday
        tuesday = actualTuesday
        wednesday = actualWednesday
        thursday = actualThursday
        friday = actualFriday
        saturday = actualSaturday
        sunday = actualSunday
    }

    @objc static func workingWeekJsonRepresentation(_ workingWeek: [NSNumber]) -> [String: Any]? {
        guard workingWeek.count == 7 else {
            return nil
        }
        let dict: [String: Any] = ["monday": JSONHelper.jsonObject(object: workingWeek[0]),
                                   "tuesday": JSONHelper.jsonObject(object: workingWeek[1]),
                                   "wednesday": JSONHelper.jsonObject(object: workingWeek[2]),
                                   "thursday": JSONHelper.jsonObject(object: workingWeek[3]),
                                   "friday": JSONHelper.jsonObject(object: workingWeek[4]),
                                   "saturday": JSONHelper.jsonObject(object: workingWeek[5]),
                                   "sunday": JSONHelper.jsonObject(object: workingWeek[6])]
        return dict
    }
}
