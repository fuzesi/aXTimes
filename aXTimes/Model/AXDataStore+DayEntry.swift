//
//  AXDataStore+DayEntry.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 07/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension AXDataStore {

    enum ComparisonSign: String {
        case less = "<"
        case equalLess = "=<"
        case greater = ">"
        case equalGreater = "=>"
    }

    @objc func currentWeekEntries(forDate date: Date) -> [DayEntry] {
        let calendar = Calendar.autoupdatingCurrent
        guard let week = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        return standardSummaryFetchWithCheck(in: week.start, andCheckOut: week.end)
    }

    @objc func nextDayEntry(withCheckinEqualGreater date: Date,
                      honouringProjectFilter filter: Bool) -> DayEntry? {
        return dayEntry(withCheckinDateToCompare: date,
                        withComparisonSign: .equalGreater,
                        honouringProjectFilter: filter)
    }

    @objc func nextDayEntry(withCheckinGreater date: Date,
                      honouringProjectFilter filter: Bool) -> DayEntry? {
        return dayEntry(withCheckinDateToCompare: date,
                        withComparisonSign: .greater,
                        honouringProjectFilter: filter)
    }

    @objc func nextDayEntry(withCheckinEqualGreater date: Date) -> DayEntry? {
        return dayEntry(withCheckinDateToCompare: date,
                        withComparisonSign: .equalGreater,
                        honouringProjectFilter: false)
    }

    @objc func nextDayEntry(withCheckinGreater date: Date) -> DayEntry? {
        return dayEntry(withCheckinDateToCompare: date,
                        withComparisonSign: .greater,
                        honouringProjectFilter: false)
    }

    @objc func previousDayEntry(withCheckinEqualLesser date: Date,
                          honouringProjectFilter filter: Bool) -> DayEntry? {
        return dayEntry(withCheckinDateToCompare: date,
                        withComparisonSign: .equalLess,
                        honouringProjectFilter: filter)
    }

    @objc func previousDayEntry(withCheckinLesser date: Date,
                          honouringProjectFilter filter: Bool) -> DayEntry? {
        return dayEntry(withCheckinDateToCompare: date,
                        withComparisonSign: .less,
                        honouringProjectFilter: filter)
    }

    @objc func previousDayEntry(withCheckinEqualLesser date: Date) -> DayEntry? {
        return dayEntry(withCheckinDateToCompare: date,
                        withComparisonSign: .equalLess,
                        honouringProjectFilter: false)
    }

    @objc func previousDayEntry(withCheckinLesser date: Date) -> DayEntry? {
        return dayEntry(withCheckinDateToCompare: date,
                        withComparisonSign: .less,
                        honouringProjectFilter: false)
    }

    @objc func previousDayEntry(withCheckinLesser date: Date,
                          checkOutHasToBeSet: Bool = false) -> DayEntry? {
        return dayEntry(withCheckinDateToCompare: date,
                        withComparisonSign: .less,
                        honouringProjectFilter: false,
                        checkOutHasToBeSet: checkOutHasToBeSet)
    }

    func dayEntry(withCheckinDateToCompare date: Date,
                  withComparisonSign sign: ComparisonSign,
                  honouringProjectFilter filter: Bool,
                  checkOutHasToBeSet: Bool = false) -> DayEntry? {
        let fetchRequest: NSFetchRequest<DayEntry> = DayEntry.fetchRequest()

        let isAscending: Bool

        switch sign {
        case .less:
            isAscending = false
        case .equalLess:
            isAscending = false
        case .greater:
            isAscending = true
        case .equalGreater:
            isAscending = true
        }

        let dateSort = NSSortDescriptor(key: "checkInTime",
                                        ascending: isAscending)
        fetchRequest.sortDescriptors = [dateSort]
        fetchRequest.fetchLimit = 1

        var checkOutPredicate = ""
        if checkOutHasToBeSet {
            checkOutPredicate = " AND checkOutTime != nil"
        }

        let predicate: NSPredicate
        if filter {
            predicate = NSPredicate(format: "(checkInTime \(sign.rawValue) %@ AND project.filterActive == %@\(checkOutPredicate))",
                                    argumentArray: [date, true])
        } else {
            predicate = NSPredicate(format: "(checkInTime \(sign.rawValue) %@\(checkOutPredicate))",
                                    argumentArray: [date])
        }
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
