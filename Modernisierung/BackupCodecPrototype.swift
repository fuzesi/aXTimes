// Isolated compatibility experiment: imports a backup into an in-memory Core Data
// store. This file is not part of the app target and does not modify the backup.
import CoreData
import Foundation

enum CodecError: Error { case invalid(String) }

final class BackupCodecPrototype {
    let context: NSManagedObjectContext
    private var objects: [String: NSManagedObject] = [:]
    private let formatter: DateFormatter = {
        let result = DateFormatter()
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
            object = NSManagedObject(entity: entity, insertInto: context)
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

guard CommandLine.arguments.count == 3 else {
    fatalError("Usage: BackupCodecPrototype /path/to/DataModel.momd /path/to/backup.json")
}
let modelURL = URL(fileURLWithPath: CommandLine.arguments[1])
guard let model = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Cannot load model") }
let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil)
let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
context.persistentStoreCoordinator = coordinator
let backupData = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[2]))
guard let backup = try JSONSerialization.jsonObject(with: backupData) as? [String: Any],
      var payload = backup["kAXPayloadKey"] as? [String: Any],
      var projects = payload["projects"] as? [[String: Any]],
      var entries = payload["dayEntries"] as? [[String: Any]] else { fatalError("Invalid backup") }
let basic = projects.indices.filter {
    (projects[$0]["basicProject"] as? NSNumber)?.boolValue == true &&
    (projects[$0]["name"] as? String) == "__basic__global__axtimes__project__"
}
guard basic.count == 1 else { fatalError("Invalid basic project") }
if projects[basic[0]]["id"] is NSNull || projects[basic[0]]["id"] == nil {
    let id = UUID().uuidString
    projects[basic[0]]["id"] = id
    for index in entries.indices {
        if var project = entries[index]["project"] as? [String: Any],
           (project["basicProject"] as? NSNumber)?.boolValue == true,
           (project["name"] as? String) == "__basic__global__axtimes__project__",
           project["id"] is NSNull || project["id"] == nil {
            project["id"] = id
            entries[index]["project"] = project
        }
    }
}
payload["projects"] = projects
payload["dayEntries"] = entries
let codec = BackupCodecPrototype(context: context)
let types = [("dayEntries", "DayEntry"), ("pauses", "Pause"), ("projects", "Project"),
             ("customers", "Customer"), ("defaultPauseSettings", "DefaultPauseSetting"),
             ("workingWeekSettings", "WorkingWeekSetting"), ("dayTypes", "DayType")]
var mismatches = 0
for (key, name) in types {
    guard let items = payload[key] as? [[String: Any]] else { throw CodecError.invalid("Missing \(key)") }
    for item in items { _ = try codec.decode(item, entity: name) }
}
for (key, name) in types {
    let expected = (payload[key] as! [[String: Any]]).count
    let count = try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: name))
    print("\(name): expected=\(expected), actual=\(count)")
    if expected != count { mismatches += 1 }
}
try context.save()
// Verify all fields represented in the historical JSON and all explicit links.
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
for (key, name) in types {
    let request = NSFetchRequest<NSManagedObject>(entityName: name)
    let fetched = try context.fetch(request)
    let byID = Dictionary(uniqueKeysWithValues: fetched.compactMap { object -> (String, NSManagedObject)? in
        guard let identifier = object.value(forKey: "identifier") as? String else { return nil }
        return (identifier, object)
    })
    var fieldErrors = 0, relationshipErrors = 0
    for item in payload[key] as! [[String: Any]] {
        guard let id = item["id"] as? String, let object = byID[id] else {
            fieldErrors += 1
            continue
        }
        for attribute in object.entity.attributesByName.values {
            guard let jsonKey = attribute.userInfo?["JSONKeyPath"] as? String,
                  let raw = item[jsonKey] else { continue }
            let value = object.value(forKey: attribute.name)
            if raw is NSNull {
                if value != nil { fieldErrors += 1 }
            } else if attribute.attributeType == .dateAttributeType {
                if let string = raw as? String, let expected = dateFormatter.date(from: string),
                   let actual = value as? Date, abs(expected.timeIntervalSince(actual)) < 0.001 { continue }
                fieldErrors += 1
            } else if attribute.attributeType == .decimalAttributeType {
                if let expected = raw as? NSNumber, let actual = value as? NSNumber,
                   NSDecimalNumber(decimal: expected.decimalValue).compare(actual) == .orderedSame { continue }
                fieldErrors += 1
            } else if !((raw as AnyObject).isEqual(value)) {
                fieldErrors += 1
            }
        }
        for relationship in object.entity.relationshipsByName.values {
            guard let jsonKey = relationship.userInfo?["JSONKeyPath"] as? String,
                  let raw = item[jsonKey] else { continue }
            if relationship.isToMany, let expected = raw as? [[String: Any]],
               let actual = object.value(forKey: relationship.name) as? Set<NSManagedObject> {
                let expectedIDs = Set(expected.compactMap { $0["id"] as? String })
                let actualIDs = Set(actual.compactMap { $0.value(forKey: "identifier") as? String })
                if expectedIDs != actualIDs || expected.count != actual.count { relationshipErrors += 1 }
            } else if let expected = raw as? [String: Any],
                      let actual = object.value(forKey: relationship.name) as? NSManagedObject {
                if (expected["id"] as? String) != (actual.value(forKey: "identifier") as? String) { relationshipErrors += 1 }
            } else if !(raw is NSNull && object.value(forKey: relationship.name) == nil) {
                relationshipErrors += 1
            }
        }
    }
    print("\(name): fieldErrors=\(fieldErrors), relationshipErrors=\(relationshipErrors)")
    mismatches += fieldErrors + relationshipErrors
}
// Encode all imported records and decode them into a second isolated store.
let secondCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
try secondCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil)
let secondContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
secondContext.persistentStoreCoordinator = secondCoordinator
let decoder = BackupCodecPrototype(context: secondContext)
for (_, name) in types {
    let request = NSFetchRequest<NSManagedObject>(entityName: name)
    for object in try context.fetch(request) {
        let encoded = try codec.encode(object)
        guard JSONSerialization.isValidJSONObject(encoded) else { throw CodecError.invalid("Invalid encoded JSON") }
        _ = try decoder.decode(encoded, entity: name)
    }
}
try secondContext.save()
for (key, name) in types {
    let expected = (payload[key] as! [[String: Any]]).count
    let count = try secondContext.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: name))
    print("\(name): roundtrip expected=\(expected), actual=\(count)")
    if expected != count { mismatches += 1 }
}
for (key, name) in types {
    let request = NSFetchRequest<NSManagedObject>(entityName: name)
    let fetched = try secondContext.fetch(request)
    let byID = Dictionary(uniqueKeysWithValues: fetched.compactMap { object -> (String, NSManagedObject)? in
        guard let identifier = object.value(forKey: "identifier") as? String else { return nil }
        return (identifier, object)
    })
    var fieldErrors = 0, relationshipErrors = 0
    for item in payload[key] as! [[String: Any]] {
        guard let id = item["id"] as? String, let object = byID[id] else {
            fieldErrors += 1
            continue
        }
        for attribute in object.entity.attributesByName.values {
            guard let jsonKey = attribute.userInfo?["JSONKeyPath"] as? String,
                  let raw = item[jsonKey] else { continue }
            let value = object.value(forKey: attribute.name)
            if raw is NSNull {
                if value != nil { fieldErrors += 1 }
            } else if attribute.attributeType == .dateAttributeType {
                if let string = raw as? String, let expected = dateFormatter.date(from: string),
                   let actual = value as? Date, abs(expected.timeIntervalSince(actual)) < 0.001 { continue }
                fieldErrors += 1
            } else if attribute.attributeType == .decimalAttributeType {
                if let expected = raw as? NSNumber, let actual = value as? NSNumber,
                   NSDecimalNumber(decimal: expected.decimalValue).compare(actual) == .orderedSame { continue }
                fieldErrors += 1
            } else if !((raw as AnyObject).isEqual(value)) {
                fieldErrors += 1
            }
        }
        for relationship in object.entity.relationshipsByName.values {
            guard let jsonKey = relationship.userInfo?["JSONKeyPath"] as? String,
                  let raw = item[jsonKey] else { continue }
            if relationship.isToMany, let expected = raw as? [[String: Any]],
               let actual = object.value(forKey: relationship.name) as? Set<NSManagedObject> {
                let expectedIDs = Set(expected.compactMap { $0["id"] as? String })
                let actualIDs = Set(actual.compactMap { $0.value(forKey: "identifier") as? String })
                if expectedIDs != actualIDs || expected.count != actual.count { relationshipErrors += 1 }
            } else if let expected = raw as? [String: Any],
                      let actual = object.value(forKey: relationship.name) as? NSManagedObject {
                if (expected["id"] as? String) != (actual.value(forKey: "identifier") as? String) { relationshipErrors += 1 }
            } else if !(raw is NSNull && object.value(forKey: relationship.name) == nil) {
                relationshipErrors += 1
            }
        }
    }
    print("\(name): roundtrip fieldErrors=\(fieldErrors), relationshipErrors=\(relationshipErrors)")
    mismatches += fieldErrors + relationshipErrors
}
print("PROTOTYPE_TEST mismatches=\(mismatches)")
if mismatches > 0 { exit(1) }
