//
//  Comment+CoreDataProperties.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 20/03/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation
import CoreData

extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var commentText: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var lastModifiedDate: NSDate?
    @NSManaged public var lastUsedDate: NSDate?
    @NSManaged public var usage: NSNumber?
    @NSManaged public var identifier: String?

}
