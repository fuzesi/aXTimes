//
//  Pause+CoreDataProperties.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 13/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation
import CoreData

extension Pause {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pause> {
        return NSFetchRequest<Pause>(entityName: "Pause")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var endTime: NSDate?
    @NSManaged public var endTimeZone: String?
    @NSManaged public var lastModifiedDate: NSDate?
    @NSManaged public var startTime: NSDate?
    @NSManaged public var startTimeZone: String?
    @NSManaged public var dayentry: DayEntry?
    @NSManaged public var identifier: String?

}
