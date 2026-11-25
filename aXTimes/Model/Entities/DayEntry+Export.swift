//
//  DayEntry+Export.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 17/03/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension DayEntry: JSONRepresentable {
    func jsonRepresentation() -> [String: Any] {
        let dict: [String: Any] = ["checkInTime": JSONHelper.JSONObject(object: checkInTime),
                                   "checkInTimeZone": JSONHelper.JSONObject(object: checkInTimeZone),
                                   "checkOutTime": JSONHelper.JSONObject(object: checkOutTime),
                                   "checkOutTimeZone": JSONHelper.JSONObject(object: checkOutTimeZone),
                                   "comment": JSONHelper.JSONObject(object: comment),
                                   "creationDate": JSONHelper.JSONObject(object: creationDate),
                                   "hourlyWage": JSONHelper.JSONObject(object: hourlyWage),
                                   "pauses": JSONHelper.JSONObject(object: pausesJsonRepresentation())]
        return dict
    }
    
    private func pausesJsonRepresentation() -> [[String: Any]] {
        var tempPauses = [[String: Any]]()
        if let actualPauses = pauses as? Set<Pause> {
            actualPauses.forEach {
                tempPauses.append($0.jsonRepresentation())
            }
        }
        return tempPauses
    }
}
