//
//  NSManagedObjectContext+DayType.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 18/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension NSManagedObjectContext {
    @objc func newDayEntryEntity(withStart date: Date) -> DayEntry {
        // swiftlint:disable force_cast
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: DayEntry.self),
                                                            into: self) as! DayEntry
        newEntity.configure(withStart: date)
        newEntity.comment = SettingsManager().defaultComment
        newEntity.hourlyWage = SettingsManager().hourlyWage
        return newEntity
    }

    @objc func newPauseEntity(withStart date: Date) -> Pause {
        // swiftlint:disable force_cast
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: Pause.self),
                                                            into: self) as! Pause
        newEntity.configure(withStart: date)
        return newEntity
    }

    @objc func newDayTypeEntity(forTargetDate date: Date) -> DayType {
        // swiftlint:disable force_cast
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: DayType.self),
                                                            into: self) as! DayType
        newEntity.configure(withDate: date)
        newEntity.setWork()
        return newEntity
    }

    @objc func newWorkingWeekSettingEntity(withValidUntilDate validUntil: Date) -> WorkingWeekSetting {
        // swiftlint:disable force_cast
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: WorkingWeekSetting.self),
                                                            into: self) as! WorkingWeekSetting
        newEntity.configure(withValidUntilDate: validUntil)
        newEntity.configure(withWorkingWeek: newEntity.workingWeek)
        return newEntity
    }

    @objc func newCommentEntity(withComment comment: String) -> Comment {
        // swiftlint:disable force_cast
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: Comment.self),
                                                            into: self) as! Comment
        newEntity.commentText = comment
        newEntity.lastUsedDate = Date() as NSDate
        newEntity.usage = NSNumber(value: 1)
        return newEntity
    }
}
