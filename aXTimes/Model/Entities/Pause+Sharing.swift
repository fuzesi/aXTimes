//
//  Pause+Sharing.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 04/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension Pause: JSONRepresentable {
    @objc var jsonRepresentation: [String : Any] {
        let dict: [String: Any] = ["endTime": JSONHelper.jsonObject(object: endTime),
                                   "startTime": JSONHelper.jsonObject(object: startTime),
                                   "endTimeZone": JSONHelper.jsonObject(object: endTimeZone),
                                   "startTimeZone": JSONHelper.jsonObject(object: startTimeZone)]
        return dict
    }

    @objc convenience init?(dictionary: [String: Any],
                      insertIntoManagedObjectContext context: NSManagedObjectContext) {
        guard let actualStart = JSONHelper.date(object: dictionary["endTime"]),
            let actualStartTimeZone = dictionary["startTimeZone"] as? String,
            let actualEnd = JSONHelper.date(object: dictionary["startTime"]),
            let actualEndTimeZone = dictionary["endTimeZone"] as? String else {
                return nil
        }
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: Pause.self),
                                                      in: context) else {
                                                        return nil
        }
        self.init(entity: entity,
                  insertInto: context)
        startTime = actualEnd
        startTimeZone = actualStartTimeZone
        endTime = actualStart
        endTimeZone = actualEndTimeZone
    }
}
