//
//  DefaultPauseSetting+CoreDataProperties.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 13/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation
import CoreData

extension DefaultPauseSetting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DefaultPauseSetting> {
        return NSFetchRequest<DefaultPauseSetting>(entityName: "DefaultPauseSetting")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var dayOfWeek: NSNumber?
    @NSManaged public var end: NSDate?
    @NSManaged public var lastModifiedDate: NSDate?
    @NSManaged public var start: NSDate?
    @NSManaged public var identifier: String?

}
