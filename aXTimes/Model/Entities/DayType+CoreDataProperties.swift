//
//  DayType+CoreDataProperties.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 13/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation
import CoreData

extension DayType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayType> {
        return NSFetchRequest<DayType>(entityName: "DayType")
    }

    @NSManaged public var calendarDate: NSDate?
    @NSManaged public var calendarDateTimeZone: String?
    @NSManaged public var calendarDay: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var day: NSNumber?
    @NSManaged public var holiday: NSNumber?
    @NSManaged public var lastModifiedDate: NSDate?
    @NSManaged public var month: NSNumber?
    @NSManaged public var sickness: NSNumber?
    @NSManaged public var vacation: NSNumber?
    @NSManaged public var work: NSNumber?
    @NSManaged public var year: NSNumber?
    @NSManaged public var identifier: String?

}
