//
//  NSManagedObjectContext+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 19/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension NSManagedObjectContext {
    @objc var defaultProjectCount: Int {
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        let predicate = NSPredicate(format: "defaultProject == %@",
                                    argumentArray: [true])
        request.predicate = predicate
        do {
            let defaultProjectsCount = try count(for: request)
            return defaultProjectsCount
        } catch {
            print("Error with defaultProjectCount request: \(error)")
            return 0
        }
    }

    @objc var basicProjectCount: Int {
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        let predicate = NSPredicate(format: "basicProject == %@ AND name == %@",
                                    argumentArray: [true, GlobalConstants.basicGlobalProjectName])
        request.predicate = predicate
        do {
            let defaultProjectsCount = try count(for: request)
            return defaultProjectsCount
        } catch {
            print("Error with defaultProjectCount request: \(error)")
            return 0
        }
    }

    @objc func allDayEntries() -> [DayEntry] {
        let fetchRequest: NSFetchRequest<DayEntry> = DayEntry.fetchRequest()
        let dateSort = NSSortDescriptor(
            key: "checkInTime",
            ascending: true)
        fetchRequest.sortDescriptors = [dateSort]

        //        var checkOutPredicate = ""
        //        if checkOutHasToBeSet {
        //            checkOutPredicate = " AND checkOutTime != nil"
        //        }

        //        let predicate: NSPredicate
        //        if filter {
        //            predicate = NSPredicate(format: "(checkInTime \(sign.rawValue) %@ AND project.filterActive == %@\(checkOutPredicate))",
        //                argumentArray: [date, true])
        //        } else {
        //            predicate = NSPredicate(format: "(checkInTime \(sign.rawValue) %@\(checkOutPredicate))",
        //                argumentArray: [date])
        //        }
        //        fetchRequest.predicate = predicate

        do {
            let results = try fetch(fetchRequest)
            return results
//            if let actualResults = results, actualResults.count > 0 {
//                return actualResults
//            } else {
//                return []()
//            }
        } catch {
            print("Error with request: \(error)")
            return [DayEntry]()
        }
    }
}
