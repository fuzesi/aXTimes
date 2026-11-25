//
//  DayEntry+CoreDataProperties.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 22/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation
import CoreData

extension DayEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayEntry> {
        return NSFetchRequest<DayEntry>(entityName: "DayEntry")
    }

    @NSManaged public var checkInTime: NSDate?
    @NSManaged public var checkInTimeZone: String?
    @NSManaged public var checkOutTime: NSDate?
    @NSManaged public var checkOutTimeZone: String?
    @NSManaged public var comment: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var hourlyWage: NSDecimalNumber?
    @NSManaged public var lastModifiedDate: NSDate?
    @NSManaged public var identifier: String?
    @NSManaged public var pauses: NSSet?
    @NSManaged public var project: Project?

}

// MARK: Generated accessors for pauses
extension DayEntry {

    @objc(addPausesObject:)
    @NSManaged public func addToPauses(_ value: Pause)

    @objc(removePausesObject:)
    @NSManaged public func removeFromPauses(_ value: Pause)

    @objc(addPauses:)
    @NSManaged public func addToPauses(_ values: NSSet)

    @objc(removePauses:)
    @NSManaged public func removeFromPauses(_ values: NSSet)

}
