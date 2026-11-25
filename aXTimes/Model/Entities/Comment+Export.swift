//
//  Comment+Export.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 17/03/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension Comment: JSONRepresentable {
    func jsonRepresentation() -> [String: Any] {
        let dict: [String: Any] = ["commentText": JSONHelper.JSONObject(object: commentText),
                                   "lastUsedDate": JSONHelper.JSONObject(object: lastUsedDate),
                                   "usage": JSONHelper.JSONObject(object: usage)]
        return dict
    }
}
