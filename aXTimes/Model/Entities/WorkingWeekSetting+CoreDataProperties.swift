//
//  WorkingWeekSetting+CoreDataProperties.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 21/03/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation
import CoreData

extension WorkingWeekSetting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkingWeekSetting> {
        return NSFetchRequest<WorkingWeekSetting>(entityName: "WorkingWeekSetting")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var day: NSNumber?
    @NSManaged public var lastModifiedDate: NSDate?
    @NSManaged public var month: NSNumber?
    @NSManaged public var validUntil: NSDate?
    @NSManaged public var validUntilString: String?
    @NSManaged public var validUntilTimeZone: String?
    @NSManaged public var year: NSNumber?
    @NSManaged public var monday: NSNumber?
    @NSManaged public var tuesday: NSNumber?
    @NSManaged public var wednesday: NSNumber?
    @NSManaged public var thursday: NSNumber?
    @NSManaged public var friday: NSNumber?
    @NSManaged public var saturday: NSNumber?
    @NSManaged public var sunday: NSNumber?
    @NSManaged public var identifier: String?

}
