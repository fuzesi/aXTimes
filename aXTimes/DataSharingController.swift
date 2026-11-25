//
//  ImportController.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 20/02/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation
enum CodecError: Error { case invalid(String) }

final class BackupCodec {
    let context: NSManagedObjectContext
    private var objects: [String: NSManagedObject] = [:]
    private let formatter: DateFormatter = {
        let result = DateFormatter()
        // Backup dates use a fixed Gregorian format, independent of device locale.
        result.locale = Locale(identifier: "en_US_POSIX")
        result.calendar = Calendar(identifier: .gregorian)
        result.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        return result
    }()

    init(context: NSManagedObjectContext) { self.context = context }

    func decode(_ json: [String: Any], entity name: String) throws -> NSManagedObject {
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else {
            throw CodecError.invalid("Missing entity \(name)")
        }
        let identifier = json["id"] as? String
        let key = identifier.map { name + ":" + $0 }
        let object: NSManagedObject
        if let key = key, let existing = objects[key] {
            object = existing
        } else {
            object = NSEntityDescription.insertNewObject(forEntityName: name, into: context)
            if let key = key { objects[key] = object }
        }

        for attribute in entity.attributesByName.values {
            guard let key = attribute.userInfo?["JSONKeyPath"] as? String,
                  let raw = json[key] else { continue }
            if raw is NSNull {
                object.setValue(nil, forKey: attribute.name)
            } else if attribute.attributeType == .dateAttributeType {
                guard let string = raw as? String, let date = formatter.date(from: string) else {
                    throw CodecError.invalid("Invalid date in \(name).\(key)")
                }
                object.setValue(date, forKey: attribute.name)
            } else if attribute.attributeType == .decimalAttributeType {
                guard let value = raw as? NSNumber else { throw CodecError.invalid("Invalid number in \(name).\(key)") }
                object.setValue(NSDecimalNumber(decimal: value.decimalValue), forKey: attribute.name)
            } else {
                object.setValue(raw, forKey: attribute.name)
            }
        }
        for relationship in entity.relationshipsByName.values {
            guard let key = relationship.userInfo?["JSONKeyPath"] as? String,
                  let destination = relationship.destinationEntity?.name,
                  let raw = json[key] else { continue }
            if raw is NSNull {
                object.setValue(nil, forKey: relationship.name)
            } else if relationship.isToMany {
                guard let values = raw as? [[String: Any]] else { throw CodecError.invalid("Invalid relationship \(name).\(key)") }
                let decoded = try values.map { try decode($0, entity: destination) }
                object.setValue(NSSet(array: decoded), forKey: relationship.name)
            } else {
                guard let value = raw as? [String: Any] else { throw CodecError.invalid("Invalid relationship \(name).\(key)") }
                object.setValue(try decode(value, entity: destination), forKey: relationship.name)
            }
        }
        return object
    }

    func encode(_ object: NSManagedObject, visiting: Set<NSManagedObjectID> = []) throws -> [String: Any] {
        guard !visiting.contains(object.objectID) else { throw CodecError.invalid("Cyclic relationship") }
        var visiting = visiting
        visiting.insert(object.objectID)
        var result: [String: Any] = [:]
        for attribute in object.entity.attributesByName.values {
            guard let key = attribute.userInfo?["JSONKeyPath"] as? String else { continue }
            guard let value = object.value(forKey: attribute.name) else { result[key] = NSNull(); continue }
            if attribute.attributeType == .dateAttributeType {
                guard let date = value as? Date else { throw CodecError.invalid("Invalid date") }
                result[key] = formatter.string(from: date)
            } else if attribute.attributeType == .decimalAttributeType {
                guard let number = value as? NSDecimalNumber else { throw CodecError.invalid("Invalid decimal") }
                result[key] = number as NSNumber
            } else {
                result[key] = value
            }
        }
        for relationship in object.entity.relationshipsByName.values {
            guard let key = relationship.userInfo?["JSONKeyPath"] as? String else { continue }
            guard let value = object.value(forKey: relationship.name) else { result[key] = NSNull(); continue }
            if relationship.isToMany {
                guard let values = value as? Set<NSManagedObject> else { throw CodecError.invalid("Invalid relationship") }
                result[key] = try values.map { try encode($0, visiting: visiting) }
            } else {
                guard let value = value as? NSManagedObject else { throw CodecError.invalid("Invalid relationship") }
                result[key] = try encode(value, visiting: visiting)
            }
        }
        return result
    }
}


// http://stackoverflow.com/questions/39176196/how-to-provide-a-localized-description-with-an-error-type-in-swift

protocol DataSharingControllerDelegate: NSObjectProtocol {
    func shouldOverwrite(existingEntriesFromDate date: Date, handler: @escaping ((Bool) -> Void))
}

enum MigrationRestoreError: Int, Error {
    case badQuery
    case missingPasteboardName
    case missingPasteboard
    case missingData
    case deserialization
    case missingKey
    case metaDataInvalid
    case missingPayload
    case missingSettings
    case projectHourlyRateMismatch
    case projectDurationMismatch
    case missingProjectStart
    case missingCheckInTime
    case failedToCreateEntityFromDictionary
}

enum BackupRestoreError: Int, Error {
    case fileReading
    case deserialization
    case missingPayload
    case missingSettings
    case invalidState
    case metaInformationMissing
    case missingKey
}

enum BackupCreationError: Int, Error {
    case metaInformationMissing
    case invalidJSON
    case fileCreation
}

class DataSharingController: NSObject {

    weak var delegate: DataSharingControllerDelegate?

    static private let readPasteboardDataQuery = "readPasteboardData"
    static private let pasteBoardType = "com.aximilate.DataSharing.DataPackage"

    static fileprivate let kAXSourceApplicationNameKey = "kAXSourceApplicationNameKey"
    static fileprivate let kAXSourceApplicationIdentifierKey = "kAXSourceApplicationIdentifierKey"
    static fileprivate let kAXSourceApplicationVersionKey = "kAXSourceApplicationVersionKey"
    static fileprivate let kAXSourceApplicationBuildKey = "kAXSourceApplicationBuildKey"
    static fileprivate let kAXPayloadKey = "kAXPayloadKey"

    static private let oldApplicationName = "aXTimes"
    static private let oldApplicationIdentifierKey = "com.aximilate.aXTimes"

    fileprivate let settingsManager: SettingsManager

    @objc init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        super.init()
    }

    // MARK: - public migration methods

    @objc func restoreFromMigrationData(
        withPasteboardDataURL sendPasteboardDataURL: URL,
        targetProject: Project,
        completion: @escaping (Error?) -> Void ) throws {
        guard
            let query = sendPasteboardDataURL.query,
            query == DataSharingController.readPasteboardDataQuery
            else {
                throw MigrationRestoreError.badQuery
        }
        guard
            let pasteboardName = sendPasteboardDataURL.fragment
            else {
                throw MigrationRestoreError.missingPasteboardName
        }
        guard
            let pasteBoard = UIPasteboard(
                name: UIPasteboard.Name(rawValue: pasteboardName),
                create: false
            )
            else {
                throw MigrationRestoreError.missingPasteboard
        }
        guard
            let data = pasteBoard.data(forPasteboardType: DataSharingController.pasteBoardType)
            else {
                throw MigrationRestoreError.missingData
        }
        guard
            let parsedData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else {
                throw MigrationRestoreError.deserialization
        }
        guard
            let name = parsedData[DataSharingController.kAXSourceApplicationNameKey] as? String
            else {
                throw MigrationRestoreError.missingKey
        }
        guard
            let identifierKey = parsedData[DataSharingController.kAXSourceApplicationIdentifierKey] as? String
            else {
                throw MigrationRestoreError.missingKey
        }
        guard
            name == DataSharingController.oldApplicationName,
            identifierKey == DataSharingController.oldApplicationIdentifierKey
            else {
                throw MigrationRestoreError.metaDataInvalid
        }
        guard
            let importedDictionary = parsedData[DataSharingController.kAXPayloadKey] as? [String: Any]
            else {
                throw MigrationRestoreError.missingPayload
        }
        guard
            let settingsPart = importedDictionary["settings"] as? [String: Any]
            else {
                throw MigrationRestoreError.missingSettings
        }

        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        AXDataStore.sharedInstance().turn(intoChildContext: childContext)
        let currenEntries = childContext.allDayEntries()

//        settingsManager.setupInitial(force: true)

        //            debugPrint(importedDictionary)
        //        try context.batchDeleteEntities(ofType: Pause.self)
        //        try context.batchDeleteEntities(ofType: DayEntry.self)
        //        try context.batchDeleteEntities(ofType: Comment.self)
        // TODO check comments

        try childContext.batchDeleteEntities(ofType: WorkingWeekSetting.self)
        try childContext.batchDeleteEntities(ofType: DayType.self)

        let project = AXDataStore.sharedInstance().fetchObjectWithManagedObjectID(
            withChildContext: targetProject.objectID,
            andContext: childContext) as! Project
        let newEntries = try processEntitiesFromMigration(
            withImportedDictionary: importedDictionary,
            withContext: childContext,
            targetProject: project)

        var isProblemFound = false
        outer: for newEntry in newEntries {
            inner: for existingEntry in currenEntries {
                var isOverlapping = false
                if let newEntryCheckInTime = newEntry.checkInTime as Date?,
                    let newEntryCheckOutTime = newEntry.checkOutTime as Date?,
                    let existingEntryCheckInTime = existingEntry.checkInTime as Date? {
                    if let existingEntryCheckOutTime = existingEntry.checkOutTime as Date? {
                        if (newEntryCheckInTime >= existingEntryCheckInTime && newEntryCheckInTime <= existingEntryCheckOutTime) ||
                            (newEntryCheckOutTime >= existingEntryCheckInTime && newEntryCheckOutTime <= existingEntryCheckOutTime) {
                            isOverlapping = true
                        }
                    } else {
                        if newEntryCheckInTime >= existingEntryCheckInTime ||
                            newEntryCheckOutTime >= existingEntryCheckInTime {
                            isOverlapping = true
                        }
                    }
                }

                if isOverlapping, let delegate = delegate, let date = existingEntry.checkInTime as Date? {
                    isProblemFound = true
                    delegate.shouldOverwrite(
                        existingEntriesFromDate: date,
                        handler: { (shouldOverwrite) in
                            guard shouldOverwrite else { return }
                            do {
                                try self.finishRestoreMigration(
                                    childContext: childContext,
                                    existingDayEntries: currenEntries,
                                    firstEntryToDelete: existingEntry,
                                    withSettingsDictionary: settingsPart)
                                completion(nil)
                            } catch {
                                completion(error)
                            }
                    })
                    break outer
                }
            }
        }

        guard !isProblemFound else {
            return
        }

        do {
            try finishRestoreMigration(
                childContext: childContext,
                existingDayEntries: currenEntries,
                firstEntryToDelete: nil,
                withSettingsDictionary: settingsPart)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    private func finishRestoreMigration(
        childContext: NSManagedObjectContext,
        existingDayEntries: [DayEntry],
        firstEntryToDelete: DayEntry?,
        withSettingsDictionary dictionary: [String: Any]) throws {

        var deleteEverythingFromNow = false
        if let firstEntryToDelete = firstEntryToDelete {
            for existingEntry in existingDayEntries {
                if !deleteEverythingFromNow,
                    firstEntryToDelete.objectID == existingEntry.objectID {
                    deleteEverythingFromNow = true
                    childContext.delete(firstEntryToDelete)
                } else if deleteEverythingFromNow {
                    childContext.delete(existingEntry)
                }
            }
        }

        //            let dataString = String(data: data, encoding: String.Encoding.utf8)!
        //            debugPrint(dataString)

        try childContext.save()

        processSettings(
            withSettingsDictionary: dictionary)
    }

    // MARK: - public backup methods

    @objc func backupFileURL() throws -> NSURL {
        let directory = NSTemporaryDirectory()
        let fileName = NSUUID().uuidString + ".json"
        // This returns a URL? even though it is an NSURL class method
        guard let fullURL = NSURL
            .fileURL(withPathComponents: [directory,
                                          fileName]) else {
                                            throw BackupCreationError.fileCreation
        }
        let data = try jsonDataForBackup()
        try data.write(to: fullURL,
                       options: .atomic)
        return fullURL as NSURL
    }

    // swiftlint:disable cyclomatic_complexity
    @objc func restoreFromBackup(withBackupFileURL backupFileURL: URL) throws {
        guard let data = FileManager.default.contents(atPath: backupFileURL.path) else {
            throw BackupRestoreError.fileReading
        }
        guard let parsedData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw BackupRestoreError.deserialization
        }
        guard let infoPlist = Bundle.main.infoDictionary else {
            throw BackupRestoreError.metaInformationMissing
        }
        guard let currentApplicationName = infoPlist["CFBundleDisplayName"] as? String else {
            throw BackupRestoreError.metaInformationMissing
        }
        guard let currentApplicationIdentifier = infoPlist["CFBundleIdentifier"] as? String else {
            throw BackupRestoreError.metaInformationMissing
        }
        guard let name = parsedData[DataSharingController.kAXSourceApplicationNameKey] as? String else {
            throw BackupRestoreError.missingKey
        }
        guard let identifierKey = parsedData[DataSharingController.kAXSourceApplicationIdentifierKey] as? String else {
            throw BackupRestoreError.missingKey
        }
        guard name == currentApplicationName && identifierKey == currentApplicationIdentifier else {
            throw BackupRestoreError.invalidState
        }
        guard let payload = parsedData[DataSharingController.kAXPayloadKey] as? [String: Any] else {
            throw BackupRestoreError.missingPayload
        }
        guard let settingsPart = payload["settings"] as? [String: Any] else {
            throw BackupRestoreError.missingSettings
        }
        let importedDictionary = try normalizedBackupPayload(payload)
        do {
            let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            AXDataStore.sharedInstance().turn(intoChildContext: childContext)

            try wipeExistingData(withContext: childContext)
            try processEntities(withImportedDictionary: importedDictionary,
                                withContext: childContext)

            let basicProjectCount = childContext.basicProjectCount
            guard basicProjectCount == 1 else {
                throw BackupRestoreError.invalidState
            }
            for (key, entity) in [("dayEntries", "DayEntry"), ("pauses", "Pause"),
                                  ("projects", "Project"), ("customers", "Customer"),
                                  ("defaultPauseSettings", "DefaultPauseSetting"),
                                  ("workingWeekSettings", "WorkingWeekSetting"), ("dayTypes", "DayType")] {
                guard let entries = importedDictionary[key] as? [[String: Any]],
                      try childContext.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: entity)) == entries.count else {
                    throw BackupRestoreError.invalidState
                }
            }
            let store = AXDataStore.sharedInstance()!
            store.preservingImportedMetadata = true
            defer { store.preservingImportedMetadata = false }
            try childContext.save()
            if let parent = childContext.parent { try parent.save() }
            settingsManager.setupInitial(force: true)
            processSettings(withSettingsDictionary: settingsPart)
        }
    }
}

// MARK: - private shared methods

fileprivate extension DataSharingController {

    // Early Pro backups omitted the basic project's identifier even in embedded
    // references. Give only that specific project a shared identity in memory.
    func normalizedBackupPayload(_ payload: [String: Any]) throws -> [String: Any] {
        guard var projects = payload["projects"] as? [[String: Any]],
              var entries = payload["dayEntries"] as? [[String: Any]] else {
            throw BackupRestoreError.missingKey
        }
        func isBasic(_ project: [String: Any]) -> Bool {
            return (project["basicProject"] as? NSNumber)?.boolValue == true &&
                (project["name"] as? String) == GlobalConstants.basicGlobalProjectName
        }
        func hasID(_ project: [String: Any]) -> Bool {
            return (project["id"] as? String)?.isEmpty == false
        }
        let basic = projects.indices.filter { isBasic(projects[$0]) }
        guard basic.count == 1 else { throw BackupRestoreError.invalidState }
        let index = basic[0]
        if !hasID(projects[index]) {
            let id = UUID().uuidString
            projects[index]["id"] = id
            for i in entries.indices {
                if var project = entries[i]["project"] as? [String: Any], isBasic(project) && !hasID(project) {
                    project["id"] = id
                    entries[i]["project"] = project
                }
            }
        }
        var result = payload
        result["projects"] = projects
        result["dayEntries"] = entries
        return result
    }
    // swiftlint:disable cyclomatic_complexity
    fileprivate func processSettings(withSettingsDictionary dictionary: [String: Any]) {
        if let hoursPerDay = dictionary["settings_hoursperday"] as? NSNumber {
            settingsManager.hoursPerDay = hoursPerDay
        }
        if let hourlyWage = dictionary["settings_hourlywage"] as? NSNumber {
            settingsManager.hourlyWage = hourlyWage.decimalNumber
        }
        if let currencyIso = dictionary["settings_currencyiso"] as? String {
            settingsManager.currencyIso = currencyIso
        }
        if let workTimeUnit = dictionary["settings_worktimeunit"] as? UInt {
            settingsManager.workTimeUnit = workTimeUnit
        }
        if let netRounding = dictionary["settings_netrounding"] as? UInt,
            let behaviour = RoundingBehaviour(rawValue: netRounding) {
            settingsManager.netRounding = behaviour
        }
        if let defaultComment = dictionary["settings_defaultcomment"] as? String {
            settingsManager.defaultComment = defaultComment
        }
        if let workingWeek = dictionary["settings_workingweek"] as? [String: Any],
            workingWeek.count == 7,
            let monday = workingWeek["monday"] as? NSNumber,
            let tuesday = workingWeek["tuesday"] as? NSNumber,
            let wednesday = workingWeek["wednesday"] as? NSNumber,
            let thursday = workingWeek["thursday"] as? NSNumber,
            let friday = workingWeek["friday"] as? NSNumber,
            let saturday = workingWeek["saturday"] as? NSNumber,
            let sunday = workingWeek["sunday"] as? NSNumber {
            settingsManager.workingWeek = [monday,
                                           tuesday,
                                           wednesday,
                                           thursday,
                                           friday,
                                           saturday,
                                           sunday]
        }
        if let isDefaultPause = dictionary["settings_defaultpause"] as? Bool {
            settingsManager.isDefaultPause = isDefaultPause
        }
        if let defaultPauseStart = JSONHelper.date(object: dictionary["settings_defaultpausestart"]) as Date? {
            settingsManager.defaultPauseStart = defaultPauseStart
        }
        if let defaultPauseEnd = JSONHelper.date(object: dictionary["settings_defaultpauseend"]) as Date? {
            settingsManager.defaultPauseEnd = defaultPauseEnd
        }
        if let exportEmail = dictionary["settings_export_email"] as? String {
            settingsManager.exportEmail = exportEmail
        }
        if let exportLanguageLocale = dictionary["settings_export_languagelocale"] as? String {
            settingsManager.exportLanguageLocale = exportLanguageLocale
        }
        if let exportDecimalSeparator = dictionary["settings_export_decimalseparator"] as? String {
            settingsManager.exportDecimalSeparator = exportDecimalSeparator
        }
        if let isExportWage = dictionary["settings_export_wage"] as? Bool {
            settingsManager.isExportWage = isExportWage
        }
        if let isExportTimeZone = dictionary["settings_export_incl_timezone"] as? Bool {
            settingsManager.isExportTimeZone = isExportTimeZone
        }
        if let timeFormatting = dictionary["settings_time_formatting"] as? Int,
            let formatting = TimeFormatting(rawValue: timeFormatting) {
            settingsManager.timeFormatting = formatting
        }
    }
}

// MARK: - private backup methods

fileprivate extension DataSharingController {

    // MARK: - create backup

    fileprivate func jsonDataForBackup() throws -> Data {
        guard let infoPlist = Bundle.main.infoDictionary else {
            throw BackupCreationError.metaInformationMissing
        }
        guard let currentApplicationName = infoPlist["CFBundleDisplayName"] as? String else {
            throw BackupCreationError.metaInformationMissing
        }
        guard let currentApplicationIdentifier = infoPlist["CFBundleIdentifier"] as? String else {
            throw BackupCreationError.metaInformationMissing
        }
        guard let currentApplicationVersion = infoPlist["CFBundleShortVersionString"] as? String else {
            throw BackupCreationError.metaInformationMissing
        }
        guard let currentApplicationBuild = infoPlist["CFBundleVersion"] as? String else {
            throw BackupCreationError.metaInformationMissing
        }

        let settings = settingsJSON()
        let entities = try entitiesJSON()

        let payload = ["purpose": "backup",
                       "settings": settings,
                       "dayEntries": entities["dayEntries"] ?? [[String: Any]](),
                       "pauses": entities["pauses"] ?? [[String: Any]](),
                       "projects": entities["projects"] ?? [[String: Any]](),
                       "customers": entities["customers"] ?? [[String: Any]](),
                       "defaultPauseSettings": entities["defaultPauseSettings"] ?? [[String: Any]](),
                       "comments": entities["comments"] ?? [[String: Any]](),
                       "workingWeekSettings": entities["workingWeekSettings"] ?? [[String: Any]](),
                       "dayTypes": entities["dayTypes"] ?? [[String: Any]]()] as [String: Any]

        let dict = [DataSharingController.kAXSourceApplicationNameKey: currentApplicationName,
                    DataSharingController.kAXSourceApplicationIdentifierKey: currentApplicationIdentifier,
                    DataSharingController.kAXSourceApplicationVersionKey: currentApplicationVersion,
                    DataSharingController.kAXSourceApplicationBuildKey: currentApplicationBuild,
                    DataSharingController.kAXPayloadKey: payload] as [String: Any]

        //        debugPrint(dict)
        if JSONSerialization.isValidJSONObject(dict) {
            do {
                #if DEBUG
                    let data = try JSONSerialization.data(withJSONObject: dict,
                                                          options: [.prettyPrinted])
                #else
                    let data = try JSONSerialization.data(withJSONObject: dict,
                                                          options: [])
                #endif

                return data
            } catch {
                debugPrint("error: \(error)")
                throw BackupCreationError.invalidJSON
            }
        } else {
            throw BackupCreationError.invalidJSON
        }
    }

    private func settingsJSON() -> [String: Any] {
        return ["settings_hoursperday": JSONHelper.jsonObject(object: settingsManager.hoursPerDay),
                "settings_currencyiso": JSONHelper.jsonObject(object: settingsManager.currencyIso),
                "settings_workingweek": JSONHelper.jsonObject(object: WorkingWeekSetting.workingWeekJsonRepresentation(settingsManager.workingWeek)),
                "settings_defaultpause": JSONHelper.jsonObject(object: settingsManager.isDefaultPause),
                "settings_defaultpausestart": JSONHelper.jsonObject(object: settingsManager.defaultPauseStart),
                "settings_defaultpauseend": JSONHelper.jsonObject(object: settingsManager.defaultPauseEnd),
                "settings_export_email": JSONHelper.jsonObject(object: settingsManager.exportEmail),
                "settings_export_languagelocale": JSONHelper.jsonObject(object: settingsManager.exportLanguageLocale),
                "settings_export_wage": JSONHelper.jsonObject(object: settingsManager.isExportWage),
                "settings_export_decimalseparator": JSONHelper.jsonObject(object: settingsManager.exportDecimalSeparator),
                "settings_export_incl_timezone": JSONHelper.jsonObject(object: settingsManager.isExportTimeZone), //mhm
            "settings_time_formatting": JSONHelper.jsonObject(object: settingsManager.timeFormatting.rawValue)]
    }

    private func entitiesJSON() throws -> [String: Any] {
        guard let context = AXDataStore.sharedInstance().managedObjectContext else { throw BackupCreationError.invalidJSON }
        let codec = BackupCodec(context: context)
        // Comments are generated automatically
        // upon insertion during import from backup
        var dayEntries = [[String: Any]]()
        var pauses = [[String: Any]]()
        var projects = [[String: Any]]()
        var customers = [[String: Any]]()
        var defaultPauseSettings = [[String: Any]]()
        var workingWeekSettings = [[String: Any]]()
        var dayTypes = [[String: Any]]()

        if let tempArray = AXDataStore.sharedInstance().getAllManagedObjects(for: DayEntry.self) as? [DayEntry] {
            do { let entities = try tempArray.map { try codec.encode($0) }
                dayEntries = entities
            }
        }
        if let tempArray = AXDataStore.sharedInstance().getAllManagedObjects(for: Pause.self) as? [Pause] {
            do { let entities = try tempArray.map { try codec.encode($0) }
                pauses = entities
            }
        }
        if let tempArray = AXDataStore.sharedInstance().getAllManagedObjects(for: Project.self) as? [Project] {
            do { let entities = try tempArray.map { try codec.encode($0) }
                projects = entities
            }
        }
        if let tempArray = AXDataStore.sharedInstance().getAllManagedObjects(for: Customer.self) as? [Customer] {
            do { let entities = try tempArray.map { try codec.encode($0) }
                customers = entities
            }
        }
        if let tempArray = AXDataStore.sharedInstance().getAllManagedObjects(for: DefaultPauseSetting.self) as? [DefaultPauseSetting] {
            do { let entities = try tempArray.map { try codec.encode($0) }
                defaultPauseSettings = entities
            }
        }
        if let tempArray = AXDataStore.sharedInstance().getAllManagedObjects(for: WorkingWeekSetting.self) as? [WorkingWeekSetting] {
            do { let entities = try tempArray.map { try codec.encode($0) }
                workingWeekSettings = entities
            }
        }
        if let tempArray = AXDataStore.sharedInstance().getAllManagedObjects(for: DayType.self) as? [DayType] {
            do { let entities = try tempArray.map { try codec.encode($0) }
                dayTypes = entities
            }
        }

        return  ["dayEntries": dayEntries,
                 "pauses": pauses,
                 "projects": projects,
                 "customers": customers,
                 "defaultPauseSettings": defaultPauseSettings,
                 "workingWeekSettings": workingWeekSettings,
                 "dayTypes": dayTypes] as [String: Any]
    }

    // MARK: - restore from backup

    fileprivate func wipeExistingData(withContext context: NSManagedObjectContext) throws {
        // Delete through the child context so a rejected restore cannot perform
        // irreversible batch deletes directly against the persistent store.
        for entity in ["Pause", "DayEntry", "Project", "Customer", "DefaultPauseSetting", "WorkingWeekSetting", "DayType", "Comment"] {
            let request = NSFetchRequest<NSManagedObject>(entityName: entity)
            for object in try context.fetch(request) { context.delete(object) }
        }
    }

    fileprivate func processEntities(withImportedDictionary importedDictionary: [String: Any],
                                     withContext context: NSManagedObjectContext) throws {
        let codec = BackupCodec(context: context)
        guard let dayEntries = importedDictionary["dayEntries"] as? [[String: Any]] else {
            throw BackupRestoreError.missingKey
        }
        for item in dayEntries { _ = try codec.decode(item, entity: "DayEntry") }

        guard let pauses = importedDictionary["pauses"] as? [[String: Any]] else {
            throw BackupRestoreError.missingKey
        }
        for item in pauses { _ = try codec.decode(item, entity: "Pause") }

        guard let projects = importedDictionary["projects"] as? [[String: Any]] else {
            throw BackupRestoreError.missingKey
        }
        for item in projects { _ = try codec.decode(item, entity: "Project") }

        guard let customers = importedDictionary["customers"] as? [[String: Any]] else {
            throw BackupRestoreError.missingKey
        }
        for item in customers { _ = try codec.decode(item, entity: "Customer") }

        guard let defaultPauseSettings = importedDictionary["defaultPauseSettings"] as? [[String: Any]] else {
            throw BackupRestoreError.missingKey
        }
        for item in defaultPauseSettings { _ = try codec.decode(item, entity: "DefaultPauseSetting") }

        guard let workingWeekSettings = importedDictionary["workingWeekSettings"] as? [[String: Any]] else {
            throw BackupRestoreError.missingKey
        }
        for item in workingWeekSettings { _ = try codec.decode(item, entity: "WorkingWeekSetting") }

        guard let dayTypes = importedDictionary["dayTypes"] as? [[String: Any]] else {
            throw BackupRestoreError.missingKey
        }
        for item in dayTypes { _ = try codec.decode(item, entity: "DayType") }
    }
}

// MARK: - migration methods

fileprivate extension DataSharingController {
    fileprivate func wipeExistingDataForMigration(withContext context: NSManagedObjectContext) throws {
        try context.batchDeleteEntities(ofType: Pause.self)
        try context.batchDeleteEntities(ofType: DayEntry.self)
        try context.batchDeleteEntities(ofType: WorkingWeekSetting.self)
        try context.batchDeleteEntities(ofType: DayType.self)
        try context.batchDeleteEntities(ofType: Comment.self)
    }

    fileprivate func processEntitiesFromMigration(
        withImportedDictionary importedDictionary: [String: Any],
        withContext context: NSManagedObjectContext,
        targetProject: Project) throws -> [DayEntry] {
        // no need to import comments because they are automatically generated for newly
        // added dayentries in 'AXDataStore'
        let workingWeekSettings = importedDictionary["workingWeekSettings"] as? [[String: Any]]
        workingWeekSettings?.forEach {
            _ = WorkingWeekSetting(dictionary: $0,
                                   insertIntoManagedObjectContext: context)
        }
        let dayTypes = importedDictionary["dayTypes"] as? [[String: Any]]
        dayTypes?.forEach {
            _ = DayType(dictionary: $0,
                        insertIntoManagedObjectContext: context)
        }
        let dayEntries = importedDictionary["dayEntries"] as? [[String: Any]]

        var newEntries = [DayEntry]()
        try dayEntries?.forEach {
            let dayEntry = DayEntry(dictionary: $0,
                                    insertIntoManagedObjectContext: context)
            // dayEntry darf in der Pro version von aXTimes nicht ohne project abgespeichert werden
            guard
                let actualDayEntry = dayEntry
                else {
                    throw MigrationRestoreError.failedToCreateEntityFromDictionary
            }
            if !targetProject.isBasic {
                guard
                    actualDayEntry.actualHourlyWage == targetProject.actualHourlyWage
                    else {
                        throw MigrationRestoreError.projectHourlyRateMismatch
                }
                let projectStart: Date?
                if let parent = targetProject.parent {
                    projectStart = parent.fromDate as Date?
                } else {
                    projectStart = targetProject.fromDate as Date?
                }
                guard
                    let actualProjectStart = projectStart
                    else {
                        // should not happen
                        throw MigrationRestoreError.missingProjectStart
                }
                guard
                    let checkIn = actualDayEntry.checkInTime as Date?
                    else {
                        // should not happen
                        throw MigrationRestoreError.missingCheckInTime
                }
                guard
                    actualProjectStart <= checkIn
                    else {
                        throw MigrationRestoreError.projectDurationMismatch
                }
                if let projectEnd = targetProject.toDate as Date?,
                    projectEnd < checkIn {
                    throw MigrationRestoreError.projectDurationMismatch
                }
            }

            actualDayEntry.project = targetProject
            newEntries.append(actualDayEntry)
        }
        return newEntries.sorted(by: { (a, b) in
            guard
                let checkInTimeA = a.checkInTime as Date?,
                let checkInTimeB = b.checkInTime as Date?
                else {
                    // should not happen
                    return false
            }
            return checkInTimeA < checkInTimeB
        })
    }
}
