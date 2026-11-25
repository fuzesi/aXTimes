//
//  AXDataStore+Project.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 08/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension AXDataStore {
    @objc func defaultProject() -> Project? {
        let fetchedResultsController = getAllProjects()
        let projects = fetchedResultsController?.fetchedObjects
        if let actualProjects = projects as? [Project] {
            for project in actualProjects {
                if project.isDefaultProject {
                    return project
                }
                for subProject in project.unsortedSubProjects where subProject.isDefaultProject {
                    return subProject
                }
            }
        }
        return nil
    }

    @objc func lastProjectCheckedInOn() -> Project? {
        return previousDayEntry(withCheckinLesser: Date())?.project
    }

    @objc func lastProjectCheckedInOn(withCheckinLesser date: Date) -> Project? {
        //checkout has to be set otherwise we might get the entry back which we are currently looking at
        return previousDayEntry(withCheckinLesser: date,
                                checkOutHasToBeSet: true)?.project
    }

    @objc func defaultCheckInProject() -> Project {
        return defaultCheckInProject(withCheckInDate: Date())
    }

    @objc func defaultCheckInProject(withCheckInDate date: Date) -> Project {
        var settingsProject: Project
        if SettingsManager().isCheckinSettingNoProject {
            settingsProject = getBasicProject()
        } else if SettingsManager().isCheckinSettingLastProject {
            if let lastProject = lastProjectCheckedInOn(withCheckinLesser: date) {
                settingsProject = lastProject
            } else {
                // eg this is the case if the user has no dayentries
                // where the last project can be rertieved from
                settingsProject = getBasicProject()
            }
        } else {
            if let defaultProject = defaultProject() {
                settingsProject = defaultProject
            } else {
                // there should be at least always one default project or
                // 'SettingsManager().isCheckinSettingLastProject' should be true
                // so at this point we have a problem and 
                // should make the basicProject the default project
                SettingsManager().makeBasicProjectDefault()
                settingsProject = getBasicProject()
            }
        }

        let tempDate = date.add(days: 1)
        let upper = tempDate?.truncateHours()
        let lower = tempDate?.add(days: -1)

        // test whether the selected project to check-in on
        // is fine regarding the date bounds
        // if not set the basicProject and perform the default project check
        // which throws out not running projects
        // this might also be the case if the last Project setting is selected
        // and the last project is not running
        // in this case the basicProject will be selected for the user
        // but the settings will not be changed
        // in the other cases the setting will be changed back to basicProject
        if let fromDate = settingsProject.fromDate as Date?, let actualLower = lower,
            let toDate = settingsProject.toDate as Date?, let actualUpper = upper {
            if !(fromDate.isEarlierOrEqual(than: actualLower) &&
                toDate.isLaterOrEqual(than:actualUpper)) {
                SettingsManager().defaultProjectCheck()
                settingsProject = getBasicProject()
            }
        }

        return settingsProject
    }
}
