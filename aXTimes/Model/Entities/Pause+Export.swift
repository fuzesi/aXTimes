//
//  Pause+Export.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 17/03/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension Pause: JSONRepresentable {
    func jsonRepresentation() -> [String: Any] {
        let dict: [String: Any] = ["endTime": JSONHelper.JSONObject(object: endTime),
                                   "startTime": JSONHelper.JSONObject(object: startTime),
                                   "endTimeZone": JSONHelper.JSONObject(object: endTimeZone),
                                   "startTimeZone": JSONHelper.JSONObject(object: startTimeZone)]
        return dict
    }
}
