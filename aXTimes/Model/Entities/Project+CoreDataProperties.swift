//
//  Project+CoreDataProperties.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 13/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation
import CoreData

extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var active: NSNumber?
    @NSManaged public var basicProject: NSNumber?
    @NSManaged public var budget: NSDecimalNumber?
    @NSManaged public var code: String?
    @NSManaged public var colourAsHex: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var defaultComment: String?
    @NSManaged public var defaultProject: NSNumber?
    @NSManaged public var filterActive: NSNumber?
    @NSManaged public var fromDate: NSDate?
    @NSManaged public var fromDateTimeZone: String?
    @NSManaged public var hourlyWage: NSDecimalNumber?
    @NSManaged public var useSubProjectsBudget: NSNumber?
    @NSManaged public var lastModifiedDate: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var partialFilterActive: NSNumber?
    @NSManaged public var position: NSNumber?
    @NSManaged public var projectDescription: String?
    @NSManaged public var roundingBehaviour: NSNumber?
    @NSManaged public var timeUnit: NSNumber?
    @NSManaged public var toDate: NSDate?
    @NSManaged public var toDateTimeZone: String?
    @NSManaged public var customer: Customer?
    @NSManaged public var dayEntries: NSSet?
    @NSManaged public var parent: Project?
    @NSManaged public var subProjects: NSSet?
    @NSManaged public var identifier: String?

}

// MARK: Generated accessors for dayEntries
extension Project {

    @objc(addDayEntriesObject:)
    @NSManaged public func addToDayEntries(_ value: DayEntry)

    @objc(removeDayEntriesObject:)
    @NSManaged public func removeFromDayEntries(_ value: DayEntry)

    @objc(addDayEntries:)
    @NSManaged public func addToDayEntries(_ values: NSSet)

    @objc(removeDayEntries:)
    @NSManaged public func removeFromDayEntries(_ values: NSSet)

}

// MARK: Generated accessors for subProjects
extension Project {

    @objc(addSubProjectsObject:)
    @NSManaged public func addToSubProjects(_ value: Project)

    @objc(removeSubProjectsObject:)
    @NSManaged public func removeFromSubProjects(_ value: Project)

    @objc(addSubProjects:)
    @NSManaged public func addToSubProjects(_ values: NSSet)

    @objc(removeSubProjects:)
    @NSManaged public func removeFromSubProjects(_ values: NSSet)

}
