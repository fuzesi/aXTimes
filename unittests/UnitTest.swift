import XCTest
import CoreData
@testable import aXTimes

final class UnitTest: XCTestCase {
    private func makeContext() throws -> NSManagedObjectContext {
        let modelURL = try XCTUnwrap(Bundle.main.url(forResource: "DataModel", withExtension: "momd"))
        let model = try XCTUnwrap(NSManagedObjectModel(contentsOf: modelURL))
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }

    private func project() -> [String: Any] {
        ["id": "project-1", "name": "Testprojekt", "code": "T", "projectDescription": "",
         "colourAsHex": "#123456", "basicProject": false, "active": true,
         "defaultProject": false, "filterActive": true, "partialFilterActive": false,
         "roundingBehaviour": 0, "timeUnit": 1]
    }

    private func pause() -> [String: Any] {
        ["id": "pause-1", "startTime": "2025-03-30T01:30:00+01:00",
         "startTimeZone": "Europe/Berlin", "endTime": "2025-03-30T03:30:00+02:00",
         "endTimeZone": "Europe/Berlin"]
    }

    private func entry() -> [String: Any] {
        ["id": "entry-1", "checkInTime": "2025-03-30T00:30:00+01:00",
         "checkInTimeZone": "Europe/Berlin", "checkOutTime": "2025-03-30T04:30:00+02:00",
         "checkOutTimeZone": "Europe/Berlin", "comment": "Test", "hourlyWage": 125.75,
         "project": project(), "pauses": [pause()]]
    }

    func testBackupCodecPreservesRelationshipsAndValues() throws {
        let context = try makeContext()
        let codec = BackupCodec(context: context)
        let day = try codec.decode(entry(), entity: "DayEntry")
        let project = try codec.decode(project(), entity: "Project")
        let pause = try codec.decode(pause(), entity: "Pause")
        XCTAssertEqual((day.value(forKey: "project") as? NSManagedObject)?.objectID, project.objectID)
        XCTAssertEqual((pause.value(forKey: "dayentry") as? NSManagedObject)?.objectID, day.objectID)
        XCTAssertEqual(try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: "Project")), 1)
        try context.save()
        let encoded = try codec.encode(day)
        XCTAssertEqual(encoded["comment"] as? String, "Test")
        XCTAssertEqual((encoded["hourlyWage"] as? NSNumber)?.doubleValue, 125.75)
        XCTAssertEqual((encoded["project"] as? [String: Any])?["id"] as? String, "project-1")
        XCTAssertEqual(((encoded["pauses"] as? [[String: Any]])?.first)?["id"] as? String, "pause-1")
        let formatter = ISO8601DateFormatter()
        let start = try XCTUnwrap(formatter.date(from: entry()["checkInTime"] as! String))
        let end = try XCTUnwrap(formatter.date(from: entry()["checkOutTime"] as! String))
        XCTAssertEqual(end.timeIntervalSince(start), 3 * 60 * 60)
        XCTAssertEqual(day.value(forKey: "checkInTime") as? Date, start)
        XCTAssertEqual(day.value(forKey: "checkOutTime") as? Date, end)
    }

    func testBackupCodecRejectsInvalidDate() throws {
        let codec = BackupCodec(context: try makeContext())
        var invalid = entry()
        invalid["checkInTime"] = "not-a-date"
        XCTAssertThrowsError(try codec.decode(invalid, entity: "DayEntry"))
    }

    func testBackupCodecRoundTripIntoIndependentStore() throws {
        let sourceContext = try makeContext()
        let sourceCodec = BackupCodec(context: sourceContext)
        let original = try sourceCodec.decode(entry(), entity: "DayEntry")
        try sourceContext.save()
        let encoded = try sourceCodec.encode(original)

        let destinationContext = try makeContext()
        let restored = try BackupCodec(context: destinationContext).decode(encoded, entity: "DayEntry")
        try destinationContext.save()
        XCTAssertEqual(restored.value(forKey: "identifier") as? String, "entry-1")
        XCTAssertEqual(restored.value(forKey: "comment") as? String, "Test")
        XCTAssertEqual(restored.value(forKey: "checkInTime") as? Date, original.value(forKey: "checkInTime") as? Date)
        XCTAssertEqual(restored.value(forKey: "checkOutTime") as? Date, original.value(forKey: "checkOutTime") as? Date)
        let restoredProject = try XCTUnwrap(restored.value(forKey: "project") as? NSManagedObject)
        XCTAssertEqual(restoredProject.value(forKey: "identifier") as? String, "project-1")
        let restoredPauses = try XCTUnwrap(restored.value(forKey: "pauses") as? Set<NSManagedObject>)
        XCTAssertEqual(restoredPauses.count, 1)
        XCTAssertEqual(restoredPauses.first?.value(forKey: "identifier") as? String, "pause-1")
    }

    func testBackupCodecRejectsInvalidRelationship() throws {
        let codec = BackupCodec(context: try makeContext())
        var invalid = entry()
        invalid["pauses"] = "not-a-list"
        XCTAssertThrowsError(try codec.decode(invalid, entity: "DayEntry"))
    }

    func testBackupCodecKeepsDistinctProjectsDistinct() throws {
        let context = try makeContext()
        let codec = BackupCodec(context: context)
        var other = project()
        other["id"] = "project-2"
        _ = try codec.decode(project(), entity: "Project")
        _ = try codec.decode(other, entity: "Project")
        XCTAssertEqual(try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: "Project")), 2)
    }

    func testLegacyHexColorsPreserveRGBAndAlpha() {
        XCTAssertEqual("#123456".color.hex, "#123456")
        XCTAssertEqual("#12345680".color.hex, "#123456")
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        XCTAssertTrue("#12345680".color.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        XCTAssertEqual(alpha, 128.0 / 255.0, accuracy: 0.0001)
    }
}
