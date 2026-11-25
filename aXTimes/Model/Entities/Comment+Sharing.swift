//
//  Comment+Sharing.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 20/03/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension Comment: JSONRepresentable {
    @objc var jsonRepresentation: [String : Any] {
        let dict: [String: Any] = ["commentText": JSONHelper.jsonObject(object: commentText),
                                   "lastUsedDate": JSONHelper.jsonObject(object: lastUsedDate),
                                   "usage": JSONHelper.jsonObject(object: usage)]
        return dict
    }

    @objc convenience init?(dictionary: [String: Any],
                      insertIntoManagedObjectContext context: NSManagedObjectContext) {
        guard let actualComment = dictionary["commentText"] as? String,
            let actualLastUsedDate = JSONHelper.date(object: dictionary["lastUsedDate"]),
            let actualUsage = dictionary["usage"] as? NSNumber else {
                return nil
        }
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: Comment.self),
                                                      in: context) else {
                                                        return nil
        }
        self.init(entity: entity,
                  insertInto: context)
        commentText = actualComment
        lastUsedDate = actualLastUsedDate
        usage = actualUsage
    }
}
