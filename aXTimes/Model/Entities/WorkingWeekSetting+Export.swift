//
//  WorkingWeekSetting+Export.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 17/03/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension WorkingWeekSetting: JSONRepresentable {
    func jsonRepresentation() -> [String: Any] {
        var dict: [String: Any] = ["validUntil": JSONHelper.JSONObject(object: validUntil),
                                   "validUntilTimeZone": JSONHelper.JSONObject(object: validUntilTimeZone),
                                   "validUntilString": JSONHelper.JSONObject(object: validUntilString),
                                   "day": JSONHelper.JSONObject(object: day),
                                   "month": JSONHelper.JSONObject(object: month),
                                   "year": JSONHelper.JSONObject(object: year)]
        if let workingWeek = workingWeekArrayJsonRepresentation() {
            dict.update(workingWeek)
        }
        return dict
    }
    
    private func workingWeekArrayJsonRepresentation() -> [String: Any]? {
        guard let workingWeek = NSKeyedUnarchiver.unarchiveObject(with: workingWeekArray) as? [NSNumber] else {
            return nil
        }
        return WorkingWeekSetting.workingWeekJsonRepresentation(workingWeek)
    }
    
    static func workingWeekJsonRepresentation(_ workingWeek: [NSNumber]) -> [String: Any]? {
        guard workingWeek.count == 7 else {
            return nil
        }
        let dict: [String: Any] = ["monday": JSONHelper.JSONObject(object: workingWeek[0]),
                                   "tuesday": JSONHelper.JSONObject(object: workingWeek[1]),
                                   "wednesday": JSONHelper.JSONObject(object: workingWeek[2]),
                                   "thursday": JSONHelper.JSONObject(object: workingWeek[3]),
                                   "friday": JSONHelper.JSONObject(object: workingWeek[4]),
                                   "saturday": JSONHelper.JSONObject(object: workingWeek[5]),
                                   "sunday": JSONHelper.JSONObject(object: workingWeek[6])]
        return dict
    }
}
