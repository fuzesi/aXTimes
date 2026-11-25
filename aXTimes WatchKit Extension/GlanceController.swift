//
//  GlanceController.swift
//  aXTimes WatchKit Extension
//
//  Created by fuesec on 26/05/15.
//  Copyright (c) 2015 aXimilate. All rights reserved.
//

import WatchKit
import Foundation
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

class GlanceController: WKInterfaceController {

    // MARK: - variables
    fileprivate var clockTimer: Timer?
    fileprivate var checkInTime: Date?
    fileprivate var checkOutTime: Date?
    fileprivate var startTime: Date?
    fileprivate var checkInTimeZone: String?
    fileprivate var checkOutTimeZone: String?
    fileprivate var comment: String?
    fileprivate var secondsPaused: NSNumber?
    fileprivate var checkoutTimeString: String?
    fileprivate var hourlyWage: NSNumber?
    fileprivate var currency: String?
    fileprivate var checkoutSalaryString: String?

    fileprivate let NSLS_PAUSE = NSLocalizedString("Pause", comment: "Label: Pause")
    fileprivate let NSLS_CHECKED_IN_AT = NSLocalizedString("Checked in at:", comment: "Small label on main screen for displaying the check-in time. Translate the prefix: Checked in at")
    fileprivate let NSLS_TIME_WORKED_TODAY = NSLocalizedString("Time worked today", comment: "Small label on main screen for displaying the time which the user has already worked. Translate the prefix: Time worked today")
    fileprivate let NSLS_CHECKED_OUT_AT = NSLocalizedString("Checked out at:", comment: "Label on main screen for displaying the check-out time. Translate the prefix: Checked out at")
    fileprivate let NSLS_NOT_WORKED_TODAY = NSLocalizedString("Not yet worked today", comment: "Small label on main screen which is displayed if the user has not worked on that particular day. Translate: Not yet worked today")

    fileprivate let decimalNumberFormatter: NumberFormatter = NumberFormatter()

    @IBOutlet var tickerLabel: WKInterfaceLabel!
    @IBOutlet var topLabel: WKInterfaceLabel!
    @IBOutlet var firstBottomLabel: WKInterfaceLabel!
    @IBOutlet var secondBottomLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        self.decimalNumberFormatter.numberStyle = NumberFormatter.Style.decimal
        self.decimalNumberFormatter.maximumFractionDigits = 2
        self.decimalNumberFormatter.minimumFractionDigits = 2
        self.decimalNumberFormatter.roundingIncrement = 0.01
        self.decimalNumberFormatter.roundingMode = NumberFormatter.RoundingMode.halfUp
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.retrieveSettingsFromSharedSpace()
        self.setupTickerUI()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        self.clockTimer?.invalidate()
        self.clockTimer = nil
    }

    // MARK: - setup methods
    @objc func retrieveSettingsFromSharedSpace() {
        self.checkInTime = nil
        self.checkOutTime = nil
        self.startTime = nil
        self.checkInTimeZone = nil
        self.checkOutTimeZone = nil
        self.comment = nil
        self.secondsPaused = nil
        self.checkoutTimeString = nil
        self.hourlyWage = nil
        self.currency = nil
        self.checkoutSalaryString = nil

        let suiteName = "group.\(Bundle.main.bundleIdentifier!)"

        if let userDefaults = UserDefaults(suiteName: suiteName) {

            self.checkInTime = userDefaults.object(forKey: "checkInTime") as? Date
            self.checkOutTime = userDefaults.object(forKey: "checkOutTime") as? Date
            self.startTime = userDefaults.object(forKey: "startTime") as? Date
            self.checkInTimeZone = userDefaults.object(forKey: "checkInTimeZone") as? String
            self.checkOutTimeZone = userDefaults.object(forKey: "checkOutTimeZone") as? String
            self.comment = userDefaults.object(forKey: "comment") as? String
            self.secondsPaused = userDefaults.object(forKey: "secondsPaused") as? NSNumber
            self.checkoutTimeString = userDefaults.object(forKey: "checkoutTimeString") as? String
            self.hourlyWage = userDefaults.object(forKey: "hourlyWage") as? NSNumber
            self.currency = userDefaults.object(forKey: "currency") as? String
            self.checkoutSalaryString = userDefaults.object(forKey: "checkoutSalaryString") as? String
        }
    }

    @objc func setupTickerUI() {
        self.clockTimer?.invalidate()
        self.clockTimer = nil
        self.tickerLabel.setText("")
        self.firstBottomLabel.setText("")
        self.secondBottomLabel.setText("")
        self.topLabel.setText("")
        self.clearAllMenuItems()

        let checkInDateFormatter = DateFormatter()
        checkInDateFormatter.dateFormat = "HH:mm:ss"

        let checkInDateFormatterDayDifferent = DateFormatter()
        checkInDateFormatterDayDifferent.dateFormat = "HH:mm:ss (d. MMM)"

        let checkInDateFormatterYearDifferent = DateFormatter()
        checkInDateFormatterYearDifferent.dateFormat = "HH:mm:ss (d. MMM yy)"

        var tempDateFormatter: DateFormatter?

        if let defineteCheckOutTime = self.checkOutTime {
            // checkout out
            if defineteCheckOutTime.isSameDay(Date(), receiverTimeZoneName: self.checkOutTimeZone!, inputTimeZoneName: TimeZone.current.identifier) {
                tempDateFormatter = checkInDateFormatter
            } else if defineteCheckOutTime.isSameMonth(Date(), receiverTimeZoneName: self.checkOutTimeZone!, inputTimeZoneName: TimeZone.current.identifier) {
                tempDateFormatter = checkInDateFormatterDayDifferent
            } else {
                tempDateFormatter = checkInDateFormatterYearDifferent
            }

            tempDateFormatter?.timeZone = TimeZone(identifier: self.checkOutTimeZone!)
            let checkOuttime = tempDateFormatter?.string(from: defineteCheckOutTime)
            self.topLabel.setText("\(NSLS_CHECKED_OUT_AT) \(checkOuttime!)")
            self.tickerLabel.setText(self.checkoutTimeString)
            self.firstBottomLabel.setText("\(self.checkoutSalaryString!) \(self.currency!)")
        } else if let defineteStartTime = self.startTime {
            // pausing
            self.secondBottomLabel.setText(NSLS_PAUSE)
            self.topLabel.setText("\(NSLS_TIME_WORKED_TODAY) \(self.totalTimeUntilNowWithSeconds(defineteStartTime))")
        } else if let defineteCheckInTime = self.checkInTime {
            // checked in but not pausing
            if defineteCheckInTime.isSameDay(Date(), receiverTimeZoneName: self.checkInTimeZone!, inputTimeZoneName: TimeZone.current.identifier) {
                tempDateFormatter = checkInDateFormatter
            } else if defineteCheckInTime.isSameMonth(Date(), receiverTimeZoneName: self.checkInTimeZone!, inputTimeZoneName: TimeZone.current.identifier) {
                tempDateFormatter = checkInDateFormatterDayDifferent
            } else {
                tempDateFormatter = checkInDateFormatterYearDifferent
            }

            tempDateFormatter?.timeZone = TimeZone(identifier: self.checkInTimeZone!)
            let checkIntime = tempDateFormatter?.string(from: defineteCheckInTime)
            self.topLabel.setText("\(NSLS_CHECKED_IN_AT) \(checkIntime!)")
        } else {
            // no dayentries yet
            self.topLabel.setText(NSLS_NOT_WORKED_TODAY)
            self.tickerLabel.setText("00:00:00")
        }

        if self.checkOutTime == nil &&
            self.checkInTime != nil {
                self.updateClock() // for first update
                self.clockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GlanceController.updateClock), userInfo: nil, repeats: true)
        }
    }

    @objc func updateClock() {
        if self.checkInTime != nil &&
            self.startTime == nil {
                // working
                let time = self.totalTimeUntilNowWithSeconds(self.checkInTime!, secondsToSubstract: self.secondsPaused!)
                self.tickerLabel.setText(time)
        } else if let defineteStartTime = self.startTime {
            // pausing
            let time = self.totalTimeUntilNowWithSeconds(defineteStartTime)
            self.tickerLabel.setText(time)
        }

        let bottomLabelText: String
        if self.startTime != nil {
            bottomLabelText = "\(self.checkoutSalaryString!) \(self.currency!)"
        } else {
            bottomLabelText = "\(self.decimalNumberFormatter.string(from: self.salaryUntilNowAsDouble())!) \(self.currency!)"
        }
        self.firstBottomLabel.setText(bottomLabelText)
    }

    @objc func salaryUntilNowAsDouble() -> NSNumber {
        var returnValue: Double = 0

        if self.hourlyWage?.doubleValue <= 0 {
            return NSNumber(value: 0 as Double)
        }

        let hoursWorked: Double = self.minutesWorkedUntilNowAsDouble() / 60.0
        let hourlyWage: Double? = self.hourlyWage?.doubleValue

        if let unwrappedHourlyWage = hourlyWage {
            returnValue = hoursWorked * unwrappedHourlyWage
        }

        return NSNumber(value: returnValue as Double)
    }

    @objc func minutesWorkedUntilNowAsDouble() -> Double {
        guard let checkInTime = checkInTime,
            let secondsPaused = secondsPaused else {
                return 0.0
        }
        let resultSecondsPausedUntilNow = secondsPausedUntilNow(checkInTime, secondsToSubstract: secondsPaused)
        let returnValue: Double = resultSecondsPausedUntilNow.doubleValue / 60.0

        return returnValue
    }

    @objc func totalTimeUntilNowWithSeconds(_ date: Date) -> String {

        return self.numberAsSecondsToCountdownString(self.secondsPausedUntilNow(date))
    }

    @objc func totalTimeUntilNowWithSeconds(_ date: Date, secondsToSubstract: NSNumber) -> String {

        return self.numberAsSecondsToCountdownString(self.secondsPausedUntilNow(date, secondsToSubstract: secondsToSubstract))
    }

    @objc func totalTimeBetweenDatesWithSeconds(_ earlierDate: Date, laterDate: Date) -> String {

        return self.numberAsSecondsToCountdownString(self.secondsPausedBetweenDates(earlierDate, laterDate: laterDate))
    }

    @objc func totalTimeBetweenDatesWithSeconds(_ earlierDate: Date, laterDate: Date, secondsToSubstract: NSNumber) -> String {

        return self.numberAsSecondsToCountdownString(self.secondsPausedBetweenDates(earlierDate, laterDate: laterDate, secondsToSubstract: secondsToSubstract))
    }

    @objc func secondsPausedUntilNow(_ date: Date) -> NSNumber {

        let nowDate = Date()

        return self.secondsPausedBetweenDates(date, laterDate: nowDate)
    }

    @objc func secondsPausedUntilNow(_ date: Date, secondsToSubstract: NSNumber) -> NSNumber {

        let nowDate = Date()

        return self.secondsPausedBetweenDates(date, laterDate: nowDate, secondsToSubstract: secondsToSubstract)
    }

    @objc func secondsPausedBetweenDates(_ earlierDate: Date, laterDate: Date) -> NSNumber {

        let distanceBetweenDates = laterDate.timeIntervalSince(earlierDate)

        return NSNumber(value: distanceBetweenDates as Double)
    }

    @objc func secondsPausedBetweenDates(_ earlierDate: Date, laterDate: Date, secondsToSubstract: NSNumber) -> NSNumber {

        let toSubstract = secondsToSubstract.doubleValue
        let tempDistanceBetweenDates = laterDate.timeIntervalSince(earlierDate)
        let distanceBetweenDates = tempDistanceBetweenDates - toSubstract

        return NSNumber(value: distanceBetweenDates as Double)
    }

    @objc func numberAsSecondsToCountdownString(_ number: NSNumber) -> String {
        var secondsWorked = number.doubleValue
        let minutesWorked: Double = secondsWorked / 60.0
        let tempString: String = String(format:"%f", minutesWorked)
        var timeArray =   tempString.components( separatedBy: ".")
        var minutes: Int = Int((timeArray[0] as String))!

        let hoursWorked = Double(minutes) / 60.0

        timeArray =  String(format:"%f", hoursWorked).components(separatedBy: ".")
        let hours: Int = Int((timeArray[0] as String))!

        minutes -= (hours * 60)

        secondsWorked -= (Double(hours) * 60.0 * 60.0) - (Double(minutes) * 60.0)
        timeArray =   String(format:"%f", secondsWorked).components(separatedBy: ".")
        let seconds: Int = Int((timeArray[0] as String))!

        let secondsFormat = "02"

        // http://stackoverflow.com/questions/24051314/precision-string-format-specifier-in-swift
        return hours.format(secondsFormat) + ":" + minutes.format(secondsFormat) + ":" + seconds.format(secondsFormat)
    }
}

//// MARK: - extensions
//extension Int {
//    func format(f: String) -> String {
//        return NSString(format: "%\(f)d", self) as String
//    }
//}
//
//extension NSDate {
//    
//    var flags: NSCalendarUnit {
//        get {
//            return .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond | .CalendarUnitTimeZone
//        }
//    }
//    
//    func isSameDay(date: NSDate, receiverTimeZoneName: String, inputTimeZoneName: String) -> Bool {
//        
//        let calendarReceiver = NSCalendar(identifier: NSCalendarIdentifierGregorian)
//        calendarReceiver?.timeZone = NSTimeZone(name: receiverTimeZoneName)!
//        
//        let calendarInput = NSCalendar(identifier: NSCalendarIdentifierGregorian)
//        calendarInput?.timeZone = NSTimeZone(name: inputTimeZoneName)!
//        
//        let componentsSelfDate = calendarReceiver?.components(flags, fromDate: self)
//        let componentsCompareDate = calendarInput?.components(flags, fromDate: date)
//        
//        if (componentsSelfDate?.year == componentsCompareDate?.year && componentsSelfDate?.month == componentsCompareDate?.month && componentsSelfDate?.day == componentsCompareDate?.day) {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func isSameMonth(date: NSDate, receiverTimeZoneName: String, inputTimeZoneName: String) -> Bool {
//        
//        let calendarReceiver = NSCalendar(identifier: NSCalendarIdentifierGregorian)
//        calendarReceiver?.timeZone = NSTimeZone(name: receiverTimeZoneName)!
//        
//        let calendarInput = NSCalendar(identifier: NSCalendarIdentifierGregorian)
//        calendarInput?.timeZone = NSTimeZone(name: inputTimeZoneName)!
//        
//        let componentsSelfDate = calendarReceiver?.components(flags, fromDate: self)
//        let componentsCompareDate = calendarInput?.components(flags, fromDate: date)
//        
//        if (componentsSelfDate?.year == componentsCompareDate?.year && componentsSelfDate?.month == componentsCompareDate?.month) {
//            return true
//        } else {
//            return false
//        }
//    }
//}
