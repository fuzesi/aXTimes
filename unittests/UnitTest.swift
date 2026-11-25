import XCTest
import CoreData
import UniformTypeIdentifiers
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
        let encodedStart = try XCTUnwrap(encoded["checkInTime"] as? String)
        XCTAssertEqual(formatter.date(from: encodedStart), start)
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

    func testRejectedBackupDoesNotAlterExistingStore() throws {
        #if !targetEnvironment(simulator)
        throw XCTSkip("Backup restore tests run only in the dedicated simulator")
        #else
        let store = try XCTUnwrap(AXDataStore.sharedInstance())
        let context = try XCTUnwrap(store.managedObjectContext)
        let entityNames = ["Pause", "DayEntry", "Project", "Customer", "DefaultPauseSetting", "WorkingWeekSetting", "DayType", "Comment"]
        func identifiers() throws -> [String: Set<NSManagedObjectID>] {
            var result: [String: Set<NSManagedObjectID>] = [:]
            for entity in entityNames {
                let request = NSFetchRequest<NSManagedObject>(entityName: entity)
                result[entity] = Set(try context.fetch(request).map { $0.objectID })
            }
            return result
        }
        let before = try identifiers()
        let hadChanges = context.hasChanges
        let settings = SettingsManager()
        let previousHours = settings.hoursPerDay
        var basic = project()
        basic["basicProject"] = true
        basic["name"] = GlobalConstants.basicGlobalProjectName
        let info = try XCTUnwrap(Bundle.main.infoDictionary)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
        defer { try? FileManager.default.removeItem(at: url) }
        var invalidDate = entry()
        invalidDate["checkInTime"] = "not-a-date"
        var missingProject = entry()
        missingProject["project"] = NSNull()
        missingProject["pauses"] = [[String: Any]]()
        for (index, badEntry) in [invalidDate, missingProject].enumerated() {
            let payload: [String: Any] = ["settings": ["settings_hoursperday": 1],
                "dayEntries": [badEntry], "projects": [basic], "pauses": [], "customers": [],
                "defaultPauseSettings": [], "workingWeekSettings": [], "dayTypes": []]
            let document: [String: Any] = [
                "kAXSourceApplicationNameKey": try XCTUnwrap(info["CFBundleDisplayName"] as? String),
                "kAXSourceApplicationIdentifierKey": try XCTUnwrap(info["CFBundleIdentifier"] as? String),
                "kAXPayloadKey": payload]
            try JSONSerialization.data(withJSONObject: document).write(to: url)
            XCTAssertThrowsError(try DataSharingController(settingsManager: settings).restoreFromBackup(withBackupFileURL: url)) { error in
                if index == 0 {
                    XCTAssertTrue(error is CodecError, "The invalid date must be rejected during import")
                } else {
                    let validationError = error as NSError
                    XCTAssertEqual(validationError.domain, NSCocoaErrorDomain)
                    XCTAssertTrue([NSValidationMissingMandatoryPropertyError, NSValidationMultipleErrorsError].contains(validationError.code),
                                  "A missing project must fail Core Data validation")
                }
            }
            XCTAssertEqual(try identifiers(), before)
            XCTAssertEqual(context.hasChanges, hadChanges)
            XCTAssertEqual(settings.hoursPerDay, previousHours)
        }
        #endif
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

    func testBackupRestoreOpensSingleDocumentPicker() throws {
        #if !targetEnvironment(simulator)
        throw XCTSkip("Document picker test runs only in the simulator")
        #else
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousKeyWindow = scene.windows.first { $0.isKeyWindow }
        let window = UIWindow(windowScene: scene)
        let controller = DataManagementTableViewController(style: .grouped)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer {
            controller.dismiss(animated: false)
            window.isHidden = true
            previousKeyWindow?.makeKeyAndVisible()
        }
        controller.loadViewIfNeeded()
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 1))
        let presented = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            controller.presentedViewController is UINavigationController
        }, object: nil)
        wait(for: [presented], timeout: 5)
        let navigation = try XCTUnwrap(controller.presentedViewController as? UINavigationController)
        let picker = try XCTUnwrap(navigation.viewControllers.first as? UIDocumentPickerViewController)
        XCTAssertFalse(picker.allowsMultipleSelection)
        XCTAssertTrue(picker.delegate === controller)
        XCTAssertTrue(UTType.json.conforms(to: .text), "JSON backups must remain selectable as text")
        #endif
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

    func testSegmentedControlCellLoadsItsSettings() throws {
        XCTAssertTrue(Thread.isMainThread)
        let cell = try XCTUnwrap(UINib(nibName: "SegmentedControlCell", bundle: .main)
            .instantiate(withOwner: nil).first as? SegmentedControlCell)
        XCTAssertEqual(cell.selectionStyle, .none)
        XCTAssertTrue(cell.customTextLabel.adjustsFontForContentSizeCategory)
        XCTAssertNotNil(cell.customTextLabel.font)
        XCTAssertNotNil(cell.segmentedControl)
        NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil)
        XCTAssertNotNil(cell.customTextLabel.font)
    }

    func testSettingsRetainSupportAndOfferAppStoreReview() throws {
        let controller = AXOverviewSettingsTableViewController(style: .grouped)
        controller.loadViewIfNeeded()
        XCTAssertEqual(controller.numberOfSections(in: controller.tableView), 5)
        XCTAssertEqual(controller.tableView(controller.tableView, numberOfRowsInSection: 4), 3)
        let support = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 4))
        let review = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 2, section: 4))
        XCTAssertFalse((support.textLabel?.text ?? "").isEmpty)
        XCTAssertFalse((review.textLabel?.text ?? "").isEmpty)
        let url = try XCTUnwrap(AXOverviewSettingsTableViewController.appReviewURL())
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "apps.apple.com")
        XCTAssertEqual(components.path, "/app/id1341474620")
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "action" })?.value, "write-review")
    }

    func testDaylightSavingEntryPauseAndReportTotals() throws {
        let context = try makeContext()
        let codec = BackupCodec(context: context)
        let day = try XCTUnwrap(codec.decode(entry(), entity: "DayEntry") as? DayEntry)
        let project = try XCTUnwrap(day.project)
        project.hourlyWage = NSDecimalNumber(string: "125.75")
        project.timeUnit = 1
        project.roundingBehaviour = 0
        try context.save()

        // The wall clock jumps forward: 00:30–04:30 is three actual hours,
        // and 01:30–03:30 is a one-hour pause.
        XCTAssertEqual(day.minutesWorked.doubleValue, 120, accuracy: 0.001)
        XCTAssertEqual(day.hoursPaused.doubleValue, 1, accuracy: 0.001)
        XCTAssertEqual(day.netHours.doubleValue, 2, accuracy: 0.001)
        XCTAssertEqual(day.income.doubleValue, 251.50, accuracy: 0.001)
        XCTAssertEqual(DayEntry.netTime(forArray: [day]).doubleValue, 2, accuracy: 0.001)
        XCTAssertEqual(DayEntry.pauseTime(forArray: [day]).doubleValue, 1, accuracy: 0.001)
        XCTAssertEqual(DayEntry.income(forArray: [day]).doubleValue, 251.50, accuracy: 0.001)

        var secondData = entry()
        secondData["id"] = "entry-2"
        secondData["checkInTime"] = "2025-03-31T08:00:00+02:00"
        secondData["checkOutTime"] = "2025-03-31T09:00:00+02:00"
        secondData["pauses"] = [[String: Any]]()
        let secondDay = try XCTUnwrap(codec.decode(secondData, entity: "DayEntry") as? DayEntry)
        XCTAssertEqual(secondDay.netHours.doubleValue, 1, accuracy: 0.001)

        let settings = SettingsManager()
        let previousHours = settings.hoursPerDay
        defer { settings.hoursPerDay = previousHours }
        settings.hoursPerDay = 8
        let target = AXDayTypesCalculationResult()
        target.wholeRangeTargetDays = 1
        target.limitedRangeTargetDays = 1
        let report = AXCalculation().calculationResult(forFetchedEntries: [day, secondDay],
            for: target, andProject: project)
        XCTAssertEqual(report?.targetTimeInHours?.doubleValue ?? -1, 8, accuracy: 0.001)
        XCTAssertEqual(report?.netWorkingTimeHours?.doubleValue ?? -1, 3, accuracy: 0.001)
        XCTAssertEqual(report?.pauseTimeHours?.doubleValue ?? -1, 1, accuracy: 0.001)
        XCTAssertEqual(report?.overtimeHours?.doubleValue ?? 0, -5, accuracy: 0.001)
        XCTAssertEqual(report?.income?.doubleValue ?? -1, 377.25, accuracy: 0.001)
    }

    func testProjectTimeRoundingModes() throws {
        let context = try makeContext()
        let codec = BackupCodec(context: context)
        let day = try XCTUnwrap(codec.decode(entry(), entity: "DayEntry") as? DayEntry)
        let project = try XCTUnwrap(day.project)
        project.timeUnit = 15
        project.roundingBehaviour = 0
        XCTAssertEqual(day.netMinutes(fromGrossMinutes: 67).doubleValue, 60, accuracy: 0.001)
        XCTAssertEqual(day.netMinutes(fromGrossMinutes: 68).doubleValue, 75, accuracy: 0.001)
        project.roundingBehaviour = 1
        XCTAssertEqual(day.netMinutes(fromGrossMinutes: 68).doubleValue, 60, accuracy: 0.001)
        project.roundingBehaviour = 2
        XCTAssertEqual(day.netMinutes(fromGrossMinutes: 61).doubleValue, 75, accuracy: 0.001)
    }

    func testCheckInAndCheckOutPersist() throws {
        let context = try makeContext()
        let codec = BackupCodec(context: context)
        var data = entry()
        data["pauses"] = [[String: Any]]()
        let day = try XCTUnwrap(codec.decode(data, entity: "DayEntry") as? DayEntry)
        let project = try XCTUnwrap(day.project)
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(2 * 60 * 60)
        let settings = SettingsManager()
        let previousDefaultPause = settings.isDefaultPause
        defer { settings.isDefaultPause = previousDefaultPause }
        settings.isDefaultPause = false
        AXAttendanceRecorder.performCheckIn(for: day, withTime: start, with: project)
        AXAttendanceRecorder.performCheckOut(for: day, withTime: end)
        XCTAssertEqual(day.netHours.doubleValue, 2, accuracy: 0.001)
        XCTAssertEqual(day.project?.objectID, project.objectID)
        try context.save()
        context.reset()
        let request = NSFetchRequest<DayEntry>(entityName: "DayEntry")
        let restored = try XCTUnwrap(context.fetch(request).first)
        XCTAssertEqual(restored.netHours.doubleValue, 2, accuracy: 0.001)
        XCTAssertEqual(restored.project?.identifier, "project-1")
        XCTAssertNotNil(restored.checkInTime)
        XCTAssertNotNil(restored.checkOutTime)
    }

    func testFinishingPausePreservesCompletedPauseAndDiscardsShortPause() throws {
        let context = try makeContext()
        let codec = BackupCodec(context: context)
        _ = try codec.decode(entry(), entity: "DayEntry")
        let request = NSFetchRequest<Pause>(entityName: "Pause")
        let completed = try XCTUnwrap(context.fetch(request).first)
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        completed.configure(withStart: start, andTimeZone: TimeZone.current.identifier)
        completed.endTime = nil
        let end = start.addingTimeInterval(120)
        AXAttendanceRecorder.finish(completed, atTime: end)
        XCTAssertEqual(completed.endTime as Date?, end)
        XCTAssertEqual(completed.endTimeZone, TimeZone.current.identifier)
        XCTAssertEqual(completed.minutesPaused(), 2, accuracy: 0.001)
        try context.save()
        context.reset()
        let saved = try XCTUnwrap(context.fetch(request).first)
        XCTAssertEqual(saved.endTime as Date?, end)

        var shortData = pause()
        shortData["id"] = "short-pause"
        let short = try XCTUnwrap(codec.decode(shortData, entity: "Pause") as? Pause)
        short.dayentry = saved.dayentry
        short.configure(withStart: start, andTimeZone: TimeZone.current.identifier)
        short.endTime = nil
        AXAttendanceRecorder.finish(short, atTime: start.addingTimeInterval(30))
        try context.save()
        XCTAssertEqual(try context.count(for: request), 1)
    }

    func testExistingPremiumUnlockRemainsAvailable() throws {
        let suite = "axtimes.tests.purchases." + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let product = IAPProducts.projects
        defaults.set(true, forKey: product)
        let helper = IAPHelper(productIds: [product], defaults: defaults, observePaymentQueue: false)
        XCTAssertEqual(product, "com.aximilate.axtimespro.projects")
        XCTAssertTrue(helper.isProductPurchased(product))
        XCTAssertFalse(helper.isProductPurchased("unrelated.product"))
    }

    func testPurchaseDeliveryPersistsAndNotifies() throws {
        let suite = "axtimes.tests.purchases." + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let center = NotificationCenter()
        let product = IAPProducts.projects
        let helper = IAPHelper(productIds: [product], defaults: defaults,
                               notificationCenter: center, observePaymentQueue: false)
        let notified = expectation(description: "Purchase notification")
        let token = center.addObserver(forName: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                       object: nil, queue: nil) { note in
            XCTAssertEqual(note.object as? String, product)
            notified.fulfill()
        }
        defer { center.removeObserver(token) }
        XCTAssertFalse(helper.isProductPurchased(product))
        helper.deliverPurchaseNotificationFor(identifier: product)
        XCTAssertTrue(helper.isProductPurchased(product))
        XCTAssertTrue(defaults.bool(forKey: product))
        wait(for: [notified], timeout: 1)
        let reloaded = IAPHelper(productIds: [product], defaults: defaults, observePaymentQueue: false)
        XCTAssertTrue(reloaded.isProductPurchased(product))
    }

}

#if targetEnvironment(simulator)
import StoreKitTest
import StoreKit

final class StoreKitIntegrationTest: XCTestCase {
    func testNoPurchaseHasNoModernEntitlement() async throws {
        guard ProcessInfo.processInfo.environment["AXTIMES_STOREKIT_TESTS"] == "1" else {
            throw XCTSkip("Use the dedicated StoreKit test scheme and an isolated simulator")
        }
        let source = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let session = try SKTestSession(contentsOf: source.appendingPathComponent("StoreKitTests/PremiumTest.storekit"))
        session.disableDialogs = true
        session.clearTransactions()
        defer { session.clearTransactions() }
        let id = "com.aximilate.axtimespro.test.projects"
        let suite = "axtimes.tests.no-purchase." + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let helper = IAPHelper(productIds: [id], defaults: defaults, observePaymentQueue: false)
        try await AppStore.sync()
        var found = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == id {
                found = true
            }
        }
        XCTAssertFalse(found, "A fresh test account must not have a purchase entitlement")
        XCTAssertFalse(helper.isProductPurchased(id))
        XCTAssertFalse(defaults.bool(forKey: id))
    }

    func testModernEntitlementRestoresEmptyLocalState() async throws {
        guard ProcessInfo.processInfo.environment["AXTIMES_STOREKIT_TESTS"] == "1" else {
            throw XCTSkip("Use the dedicated StoreKit test scheme and an isolated simulator")
        }
        let source = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let session = try SKTestSession(contentsOf: source.appendingPathComponent("StoreKitTests/PremiumTest.storekit"))
        session.disableDialogs = true
        session.clearTransactions()
        defer { session.clearTransactions() }
        let id = "com.aximilate.axtimespro.test.projects"
        let products = try await Product.products(for: [id])
        let product = try XCTUnwrap(products.first)
        guard case .success(.verified(let transaction)) = try await product.purchase() else {
            XCTFail("The local test purchase must be verified")
            return
        }
        await transaction.finish()

        // Model a reinstall: the local unlock is empty but the App Store entitlement remains.
        let suite = "axtimes.tests.restore." + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let helper = IAPHelper(productIds: [id], defaults: defaults, observePaymentQueue: false)
        XCTAssertFalse(helper.isProductPurchased(id))
        var entitlement: Transaction?
        for await result in Transaction.currentEntitlements {
            if case .verified(let candidate) = result, candidate.productID == id {
                entitlement = candidate
            }
        }
        XCTAssertNotNil(entitlement, "A verified purchase must be available without a manual sync")
        if let entitlement = entitlement {
            helper.deliverPurchaseNotificationFor(identifier: entitlement.productID)
        }
        XCTAssertTrue(helper.isProductPurchased(id))
        XCTAssertTrue(defaults.bool(forKey: id))

        // This models a user explicitly requesting synchronization from the restore button.
        try await AppStore.sync()
        var foundAfterSync = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let candidate) = result, candidate.productID == id {
                foundAfterSync = true
            }
        }
        XCTAssertTrue(foundAfterSync, "A verified purchase must remain available after sync")
    }

    func testLegacyPurchaseIsVisibleToModernStoreKit() async throws {
        guard ProcessInfo.processInfo.environment["AXTIMES_STOREKIT_TESTS"] == "1" else {
            throw XCTSkip("Use the dedicated StoreKit test scheme and an isolated simulator")
        }
        let source = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let session = try SKTestSession(contentsOf: source.appendingPathComponent("StoreKitTests/PremiumTest.storekit"))
        session.disableDialogs = true
        session.clearTransactions()
        defer { session.clearTransactions() }
        let suite = "axtimes.tests.storekit." + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let center = NotificationCenter()
        let id = "com.aximilate.axtimespro.test.projects"
        let helper = IAPHelper(productIds: [id], defaults: defaults, notificationCenter: center)
        defer { SKPaymentQueue.default().remove(helper) }
        let purchased = expectation(description: "Legacy purchase delivered")
        purchased.assertForOverFulfill = false
        let token = center.addObserver(forName: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: nil, queue: nil) { note in
            if note.object as? String == id { purchased.fulfill() }
        }
        defer { center.removeObserver(token) }
        let loaded = expectation(description: "Legacy product loaded")
        var storeProduct: SKProduct?
        helper.requestProducts { success, products in
            XCTAssertTrue(success)
            storeProduct = products?.first
            loaded.fulfill()
        }
        await fulfillment(of: [loaded], timeout: 15)
        helper.buyProduct(try XCTUnwrap(storeProduct))
        await fulfillment(of: [purchased], timeout: 15)
        XCTAssertTrue(helper.isProductPurchased(id))
        try await AppStore.sync()
        var found = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == id { found = true }
        }
        XCTAssertTrue(found, "A purchase made with the legacy API must be available to the modern API")
    }
}
#endif
