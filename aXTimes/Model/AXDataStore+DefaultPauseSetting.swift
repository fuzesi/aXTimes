//
//  AXDataStore+DefaultPauseSetting.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 17/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension AXDataStore {
    // week start at monday with index 0
    @objc func defaultPauseSettingEntry(forWeekDayIndex weekDayIndex: UInt) -> DefaultPauseSetting? {
        let fetchRequest: NSFetchRequest<DefaultPauseSetting> = DefaultPauseSetting.fetchRequest()
        fetchRequest.fetchLimit = 1

        let predicate = NSPredicate(format: "(dayOfWeek == %@)",
                                    argumentArray: [weekDayIndex])
        fetchRequest.predicate = predicate

        do {
            let results = try managedObjectContext?.fetch(fetchRequest)
            if let actualResults = results, actualResults.count > 0 {
                return actualResults[0]
            } else {
                return nil
            }
        } catch {
            print("Error with request: \(error)")
            return nil
        }
    }
}
