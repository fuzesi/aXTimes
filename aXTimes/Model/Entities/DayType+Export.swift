//
//  DataType+Export.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 21/02/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension DayType: JSONRepresentable {
    func jsonRepresentation() -> [String: Any] {
        let dict: [String: Any] = ["calendarDate": JSONHelper.JSONObject(object: calendarDate),
                                   "calendarDateTimeZone": JSONHelper.JSONObject(object: calendarDateTimeZone),
                                   "calendarDay": JSONHelper.JSONObject(object: calendarDay),
                                   "vacation": JSONHelper.JSONObject(object: vacation),
                                   "sickness": JSONHelper.JSONObject(object: sickness),
                                   "work": JSONHelper.JSONObject(object: work),
                                   "holiday": JSONHelper.JSONObject(object: holiday),
                                   "year": JSONHelper.JSONObject(object: year),
                                   "month": JSONHelper.JSONObject(object: month),
                                   "day": JSONHelper.JSONObject(object: day)]
        return dict
    }
}
