//
//  SettingsManager+BasicProject.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 28/01/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension SettingsManager {

    @objc func defaultProjectCheck() {
        // check for incosistencies
        guard AXDataStore.sharedInstance().managedObjectContext.defaultProjectCount < 2 else {
            // serious problem
            makeBasicProjectDefault()
            return
        }

        if isCheckinSettingNoProject {
            isCheckinSettingLastProject = false
            if let basicProject = AXDataStore.sharedInstance().getBasicProject(),
                let actualDefaultProject = AXDataStore.sharedInstance().defaultProject() {
                if basicProject.objectID != actualDefaultProject.objectID {
                    makeBasicProjectDefault()
                    return
                }
            } else {
                makeBasicProjectDefault()
                return
            }
        } else if isCheckinSettingLastProject {
            if AXDataStore.sharedInstance().managedObjectContext.defaultProjectCount != 0 {
                let controller = AXDataStore.sharedInstance().getAllProjects()
                if let projects = controller?.fetchedObjects as? [Project] {
                    for project in projects {
                        project.defaultProject = NSNumber(value: false)
                        for subProject in project.unsortedSubProjects {
                            subProject.defaultProject = NSNumber(value: false)
                        }
                    }
                }
            }
            return
        }

        checkForOutDatedProjects()
    }

    @objc func checkForOutDatedProjects() {
        var resetNeeded = false

        if let actualDefaultProject = AXDataStore.sharedInstance().defaultProject() { // else lastProject is selected
            let now = Date()
            if let fromDate = actualDefaultProject.fromDate as Date?, fromDate.isLater(than: now) {
                resetNeeded = true
            } else if let toDate = actualDefaultProject.toDate as Date?, toDate.isEarlier(than: now) {
                resetNeeded = true
            }
        }

        if resetNeeded {
            makeBasicProjectDefault()
        }
    }

    @objc func makeBasicProjectDefault() {
        isCheckinSettingNoProject = true
        isCheckinSettingLastProject = false
        if let basicProject = AXDataStore.sharedInstance().getBasicProject() {
            basicProject.defaultProject = NSNumber(value: true)
            let controller = AXDataStore.sharedInstance().getAllProjectsWithoutBasic()
            if let projects = controller?.fetchedObjects as? [Project] {
                for project in projects {
                    project.defaultProject = NSNumber(value: false)
                    for subProject in project.unsortedSubProjects {
                        subProject.defaultProject = NSNumber(value: false)
                    }
                }
            }
        }
    }

    @objc var hourlyWage: NSDecimalNumber {
        get {
            if let basicProject = AXDataStore.sharedInstance().getBasicProject(),
                let hourlyWage = basicProject.hourlyWage {
                return hourlyWage
            } else {
                return NSDecimalNumber(value: 0)
            }
        }
        set {
            if let basicProject = AXDataStore.sharedInstance().getBasicProject() {
                basicProject.hourlyWage = newValue
            }
        }
    }

    @objc var workTimeUnit: UInt {
        get {
            if let basicProject = AXDataStore.sharedInstance().getBasicProject(),
                let timeUnit = basicProject.timeUnit?.uintValue {
                return timeUnit
            } else {
                return 1
            }
        }
        set {
            if let basicProject = AXDataStore.sharedInstance().getBasicProject() {
                basicProject.timeUnit = NSNumber(value: newValue)
            }
        }
    }

    @objc var workTimeUnitDisplayValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: workTimeUnit)) ?? "") \(LocalizationConstants.minuteShort)"
    }

    @objc var netRounding: RoundingBehaviour {
        get {
            if let basicProject = AXDataStore.sharedInstance().getBasicProject(),
                let intValue = basicProject.roundingBehaviour?.uintValue,
                let roundingBehaviour = RoundingBehaviour(rawValue: intValue) {
                return roundingBehaviour
            } else {
                return .default
            }
        }
        set {
            if let basicProject = AXDataStore.sharedInstance().getBasicProject() {
                basicProject.roundingBehaviour = NSNumber(value: newValue.rawValue)
            }
        }
    }

    @objc var netRoundingDisplayValue: String {
        return roundingBehaviourNames[Int(netRounding.rawValue)]
    }

    @objc var defaultComment: String {
        get {
            if let basicProject = AXDataStore.sharedInstance().getBasicProject(),
                let defaultComment = basicProject.defaultComment {
                return defaultComment
            } else {
                return ""
            }
        }
        set {
            if let basicProject = AXDataStore.sharedInstance().getBasicProject() {
                basicProject.defaultComment = newValue
            }
        }
    }
}
