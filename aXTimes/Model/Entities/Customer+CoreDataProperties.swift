//
//  Customer+CoreDataProperties.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 04/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation
import CoreData

extension Customer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }

    @NSManaged public var active: NSNumber?
    @NSManaged public var addressAddition: String?
    @NSManaged public var addressCity: String?
    @NSManaged public var addressCountry: String?
    @NSManaged public var addressPostalCode: String?
    @NSManaged public var addressState: String?
    @NSManaged public var addressStreet: String?
    @NSManaged public var addressStreetNumber: String?
    @NSManaged public var code: String?
    @NSManaged public var colourAsHex: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var displayName: String?
    @NSManaged public var email: String?
    @NSManaged public var lastModifiedDate: NSDate?
    @NSManaged public var notes: String?
    @NSManaged public var phone: String?
    @NSManaged public var projects: NSSet?
    @NSManaged public var identifier: String?

}

// MARK: Generated accessors for projects
extension Customer {

    @objc(addProjectsObject:)
    @NSManaged public func addToProjects(_ value: Project)

    @objc(removeProjectsObject:)
    @NSManaged public func removeFromProjects(_ value: Project)

    @objc(addProjects:)
    @NSManaged public func addToProjects(_ values: NSSet)

    @objc(removeProjects:)
    @NSManaged public func removeFromProjects(_ values: NSSet)

}
