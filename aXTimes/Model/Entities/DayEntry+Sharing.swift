//
//  DayEntry+Sharing.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 13/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension DayEntry: JSONRepresentable {
    @objc var jsonRepresentation: [String : Any] {
        let dict: [String: Any] = ["checkInTime": JSONHelper.jsonObject(object: checkInTime),
                                   "checkInTimeZone": JSONHelper.jsonObject(object: checkInTimeZone),
                                   "checkOutTime": JSONHelper.jsonObject(object: checkOutTime),
                                   "checkOutTimeZone": JSONHelper.jsonObject(object: checkOutTimeZone),
                                   "comment": JSONHelper.jsonObject(object: comment),
                                   "creationDate": JSONHelper.jsonObject(object: creationDate),
                                   "hourlyWage": JSONHelper.jsonObject(object: hourlyWage),
                                   "pauses": JSONHelper.jsonObject(object: pausesJsonRepresentation)]
        return dict
    }

    private var pausesJsonRepresentation: [[String: Any]] {
        var tempPauses = [[String: Any]]()
        if let actualPauses = pauses as? Set<Pause> {
            actualPauses.forEach { tempPauses.append($0.jsonRepresentation) }
        }
        return tempPauses
    }

    @objc convenience init?(dictionary: [String: Any],
                      insertIntoManagedObjectContext context: NSManagedObjectContext) {
        guard let actualCheckInTime = JSONHelper.date(object: dictionary["checkInTime"]),
            let actualCheckInTimeZone = dictionary["checkInTimeZone"] as? String,
            let actualCheckOutTime = JSONHelper.date(object: dictionary["checkOutTime"]),
            let actualCheckOutTimeZone = dictionary["checkOutTimeZone"] as? String,
            let finalHourlyWage = dictionary["hourlyWage"] as? NSNumber else {
                return nil
        }
        guard let pauses = dictionary["pauses"] as? [[String: Any]] else {
            return nil
        }
        var actualPauses = [Pause]()
        for pauseDict in pauses {
            if let pause = Pause(dictionary: pauseDict,
                                 insertIntoManagedObjectContext: context) {
                actualPauses.append(pause)
            } else {
                actualPauses.forEach { context.delete($0) }
                return nil
            }
        }
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: DayEntry.self),
                                                      in: context) else {
                                                        return nil
        }
        self.init(entity: entity,
                  insertInto: context)
        checkInTime = actualCheckInTime
        checkInTimeZone = actualCheckInTimeZone
        checkOutTime = actualCheckOutTime
        checkOutTimeZone = actualCheckOutTimeZone
        if let finalComment = dictionary["comment"] as? String {
            comment = finalComment
        } else {
            comment = ""
        }
        creationDate = JSONHelper.date(object: dictionary["creationDate"])
        hourlyWage = finalHourlyWage.decimalNumber
        actualPauses.forEach { addToPauses($0) }
    }
}
