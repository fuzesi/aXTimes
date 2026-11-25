import XCTest
import CoreData
@testable import aXTimes

private final class EmptyColorPickerModel: NSObject, ColorPickerViewModelProtocol {
    let numberOfSections = 1
    let numberOfRowsInSection = 0
    func isSelected(indexPath: IndexPath) -> Bool { false }
    func color(indexPath: IndexPath) -> UIColor? { nil }
    func selectedIndexPath(indexPath: IndexPath) {}
}

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

    func testDayTypeChooserOffersAllTypesAndCancel() {
        let options = DayTypeChooser.options
        XCTAssertEqual(options.map { $0.type.rawValue }, [
            DayTypus.noSelectionIsWork.rawValue,
            DayTypus.vacationDay.rawValue,
            DayTypus.sickDay.rawValue,
            DayTypus.holiday.rawValue,
            DayTypus.notAWorkingDay.rawValue
        ])
        var selected: [Int] = []
        let chooser = DayTypeChooserViewController { selected.append(Int($0.rawValue)) }
        chooser.loadViewIfNeeded()
        XCTAssertEqual(chooser.optionButtons.count, options.count)
        for (button, option) in zip(chooser.optionButtons, options) {
            XCTAssertEqual(button.configuration?.title, option.title)
            XCTAssertNotNil(button.configuration?.image)
            XCTAssertEqual(button.configuration?.baseForegroundColor, option.color)
            button.sendActions(for: .touchUpInside)
        }
        XCTAssertEqual(selected, options.map { Int($0.type.rawValue) })
        chooser.cancelButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(selected.count, options.count)
    }
    // Runs only against the dedicated simulator's app container, never the user's backup.
    func testDayTypeSelectionPersistsForOneAndMultipleDays() throws {
        let store = AXDataStore.sharedInstance()!
        let context = store.managedObjectContext!
        let calendar = Calendar.current
        let dates = try (1...4).map { day in
            try XCTUnwrap(calendar.date(from: DateComponents(year: 2157, month: 3, day: day, hour: 12)))
        }
        for date in dates {
            guard store.getDayType(forCalendarDay: date) == nil else {
                throw XCTSkip("Test dates are already in use; existing data must remain untouched")
            }
        }
        defer {
            for date in dates {
                if let created = store.getDayType(forCalendarDay: date) { context.delete(created) }
            }
            try? context.save()
        }

        let single = DayTypeChooserViewController { type in
            AXUtility.dayTypeChanged(with: type.rawValue, with: dates[0])
        }
        single.loadViewIfNeeded()
        single.optionButtons[1].sendActions(for: .touchUpInside)
        context.processPendingChanges()
        XCTAssertEqual(store.getDayType(forCalendarDay: dates[0])?.isVacation, true)

        let multiple = DayTypeChooserViewController { type in
            AXUtility.dayTypeArrayChanged(type.rawValue, withDateArray: NSMutableArray(array: [dates[1], dates[2]]))
        }
        multiple.loadViewIfNeeded()
        multiple.optionButtons[3].sendActions(for: .touchUpInside)
        context.processPendingChanges()
        XCTAssertEqual(store.getDayType(forCalendarDay: dates[1])?.isHoliday, true)
        XCTAssertEqual(store.getDayType(forCalendarDay: dates[2])?.isHoliday, true)

        let cancelled = DayTypeChooserViewController { type in
            AXUtility.dayTypeChanged(with: type.rawValue, with: dates[3])
        }
        cancelled.loadViewIfNeeded()
        cancelled.cancelButton.sendActions(for: .touchUpInside)
        context.processPendingChanges()
        XCTAssertNil(store.getDayType(forCalendarDay: dates[3]))

        // Reload from SQLite rather than reading the existing managed objects.
        if context.hasChanges { try context.save() }
        context.reset()
        XCTAssertEqual(store.getDayType(forCalendarDay: dates[0])?.isVacation, true)
        XCTAssertEqual(store.getDayType(forCalendarDay: dates[1])?.isHoliday, true)
        XCTAssertEqual(store.getDayType(forCalendarDay: dates[2])?.isHoliday, true)
        XCTAssertNil(store.getDayType(forCalendarDay: dates[3]))
    }

    func testColorAndProductsViewsFillTheirContainer() throws {
        let color = ColorPickerViewController()
        color.viewModel = EmptyColorPickerModel()
        color.loadViewIfNeeded()
        let colorTable = try XCTUnwrap(color.view.subviews.first { $0 is UITableView })
        let products = ProductsViewController()
        products.loadViewIfNeeded()

        for size in [CGSize(width: 390, height: 700), CGSize(width: 700, height: 390)] {
            for (controller, subviews) in [
                (color as UIViewController, [colorTable]),
                (products as UIViewController, [products.tableView, products.activityIndicator] as [UIView])
            ] {
                controller.view.frame = CGRect(origin: .zero, size: size)
                controller.view.setNeedsLayout()
                controller.view.layoutIfNeeded()
                for subview in subviews {
                    XCTAssertEqual(subview.frame, controller.view.bounds)
                }
            }
        }
    }

    func testDayEntriesAndProjectSummaryFillTheirContainer() throws {
        let dayEntries = AXDayEntriesListViewController()
        dayEntries.date = Date()
        dayEntries.entries = []
        let controllers: [UIViewController] = [dayEntries, AXProjectsSummaryViewController()]
        for controller in controllers {
            controller.loadViewIfNeeded()
            let table = try XCTUnwrap(controller.view.subviews.first { $0 is UITableView })
            for size in [CGSize(width: 390, height: 700), CGSize(width: 700, height: 390)] {
                controller.view.frame = CGRect(origin: .zero, size: size)
                controller.view.setNeedsLayout()
                controller.view.layoutIfNeeded()
                XCTAssertEqual(table.frame, controller.view.bounds)
            }
        }
    }

    func testOverviewCalendarKeepsItsLayoutAndAdjustableHeight() throws {
        let overview = AXOverviewViewController()
        overview.selectedDateViewModel = SelectedDateViewModel(date: Date())
        overview.loadViewIfNeeded()
        let menu = try XCTUnwrap(overview.value(forKey: "calendarMenuView") as? UIView)
        let calendar = try XCTUnwrap(overview.value(forKey: "calendarContentView") as? UIView)
        let container = try XCTUnwrap(overview.value(forKey: "containerView") as? UIView)
        let height = try XCTUnwrap(overview.value(forKey: "calendarContentViewHeightConstraint") as? NSLayoutConstraint)
        for size in [CGSize(width: 390, height: 800), CGSize(width: 700, height: 500)] {
            overview.view.frame = CGRect(origin: .zero, size: size)
            for calendarHeight in [240.0, 300.0] {
                height.constant = calendarHeight
                overview.view.setNeedsLayout()
                overview.view.layoutIfNeeded()
                XCTAssertEqual(menu.frame.height, 50, accuracy: 0.5)
                XCTAssertEqual(calendar.frame.height, calendarHeight, accuracy: 0.5)
                XCTAssertEqual(calendar.frame.minY, menu.frame.maxY, accuracy: 0.5)
                XCTAssertEqual(container.frame.minY, calendar.frame.maxY, accuracy: 0.5)
                XCTAssertEqual(container.frame.maxY, size.height, accuracy: 0.5)
                XCTAssertEqual(menu.frame.width, size.width, accuracy: 0.5)
                XCTAssertEqual(calendar.frame.width, size.width, accuracy: 0.5)
            }
        }
    }

}
