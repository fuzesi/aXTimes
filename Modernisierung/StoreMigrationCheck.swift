import CoreData
import Foundation

guard CommandLine.arguments.count == 2 else {
    fatalError("Usage: swift StoreMigrationCheck.swift /path/to/DataModel.momd")
}
let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
guard let target = NSManagedObjectModel(contentsOf: directory) else { fatalError("Missing target model") }
let models = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
    .filter { $0.pathExtension == "mom" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
defer { try? FileManager.default.removeItem(at: root) }
let checkIn = Date(timeIntervalSince1970: 1_500_000_000)
let checkOut = checkIn.addingTimeInterval(8 * 3600)
let marker = "Migration test entry"
var failures = 0
for url in models {
    do {
        guard let source = NSManagedObjectModel(contentsOf: url),
              let entity = source.entitiesByName["DayEntry"] else { throw NSError(domain: "Missing model", code: 1) }
        let storeURL = root.appendingPathComponent(url.deletingPathExtension().lastPathComponent + ".sqlite")
        let oldCoordinator = NSPersistentStoreCoordinator(managedObjectModel: source)
        let oldStore = try oldCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL)
        let oldContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        oldContext.persistentStoreCoordinator = oldCoordinator
        let entry = NSManagedObject(entity: entity, insertInto: oldContext)
        if entity.relationshipsByName["project"] != nil,
           let projectEntity = source.entitiesByName["Project"] {
            let project = NSManagedObject(entity: projectEntity, insertInto: oldContext)
            for attribute in projectEntity.attributesByName.values where !attribute.isOptional && attribute.defaultValue == nil {
                switch attribute.attributeType {
                case .stringAttributeType: project.setValue("Migration test", forKey: attribute.name)
                case .booleanAttributeType: project.setValue(false, forKey: attribute.name)
                case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType: project.setValue(0, forKey: attribute.name)
                case .dateAttributeType: project.setValue(checkIn, forKey: attribute.name)
                default: break
                }
            }
            entry.setValue(project, forKey: "project")
        }
        entry.setValue(checkIn, forKey: "checkInTime")
        entry.setValue(checkOut, forKey: "checkOutTime")
        entry.setValue("Europe/Berlin", forKey: "checkInTimeZone")
        entry.setValue("Europe/Berlin", forKey: "checkOutTimeZone")
        entry.setValue(marker, forKey: "comment")
        try oldContext.save()
        oldContext.reset()
        try oldCoordinator.remove(oldStore)

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: target)
        let store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        let request = NSFetchRequest<NSManagedObject>(entityName: "DayEntry")
        let entries = try context.fetch(request)
        guard entries.count == 1, entries[0].value(forKey: "comment") as? String == marker,
              entries[0].value(forKey: "checkInTime") as? Date == checkIn,
              entries[0].value(forKey: "checkOutTime") as? Date == checkOut,
              entries[0].value(forKey: "checkInTimeZone") as? String == "Europe/Berlin" else {
            throw NSError(domain: "Entry changed during migration", code: 2)
        }
        context.reset()
        try coordinator.remove(store)
        print("OK   \(url.lastPathComponent): test entry preserved")
    } catch {
        failures += 1
        print("FAIL \(url.lastPathComponent): \(error)")
    }
}
if models.isEmpty || failures > 0 { exit(1) }
