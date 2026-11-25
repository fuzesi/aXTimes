//
//  TodayViewController.swift
//  AXTodayWidget
//
//  Created by fuesec on 09/09/14.
//  Copyright (c) 2014 aXimilate. All rights reserved.
//

import UIKit
import NotificationCenter
import os.log


class TodayViewController: UIViewController, NCWidgetProviding {

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

    // MARK: - outlets
    @IBOutlet var tickerLabel: UILabel!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var firstBottomLabel: UILabel!
    @IBOutlet var secondBottomLabel: UILabel!
    @IBOutlet var buttonGoTo: UIButton!

    // MARK: - outlet methods
    @IBAction func goToAppAction(_ sender: AnyObject) {
        openApp()
    }

    @IBAction func goToAction(_ sender: AnyObject) {
        openApp()
    }

    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0.0, height: 200.0)
            firstBottomLabel.isHidden = false
            secondBottomLabel.isHidden = false
        } else if activeDisplayMode == .compact {
            preferredContentSize = maxSize
            firstBottomLabel.isHidden = true
            secondBottomLabel.isHidden = true
        }
        tickerLabel.adjustsFontSizeToFitWidth = true
    }

    // MARK: - lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            tickerLabel.textColor = UIColor.black
            topLabel.textColor = UIColor.black
            firstBottomLabel.textColor = UIColor.black
            secondBottomLabel.textColor = UIColor.black
            buttonGoTo.setTitleColor(UIColor.black,
                                     for: .normal)
        }

//        self.view.backgroundColor = UIColor.redColor()

        self.tickerLabel.adjustsFontSizeToFitWidth = true
        self.tickerLabel.numberOfLines = 1
        self.tickerLabel.baselineAdjustment = UIBaselineAdjustment.alignCenters
        self.tickerLabel.text = ""
        self.tickerLabel.isUserInteractionEnabled = false // since we have a separate button to go back to the app
//        self.buttonTicker.backgroundColor = UIColor.redColor()

        buttonGoTo.setTitle(LocalizationConstants.openApp, for: UIControlState())
//        self.buttonGoTo.backgroundColor = UIColor.blueColor()

        self.retrieveSettingsFromSharedSpace()

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
            topLabel.text = "\(LocalizationConstants.checkOutAt) \(checkOuttime!)"

            self.tickerLabel.text = self.checkoutTimeString
            self.firstBottomLabel.text = "\(self.checkoutSalaryString!) \(self.currency!)"

        } else if let defineteStartTime = self.startTime {
            // pausing
            secondBottomLabel.text = LocalizationConstants.pause
            if let defineteCheckInTime = self.checkInTime {
                topLabel.text = "\(LocalizationConstants.timeWorkedToday) \(totalTimeBetweenDatesWithSeconds(defineteCheckInTime, laterDate: defineteStartTime))"
            }
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
            topLabel.text = "\(LocalizationConstants.checkedInAt) \(checkIntime!)"
        } else {
            // no dayentries yet
            topLabel.text = LocalizationConstants.notWorkedToday
            self.tickerLabel.text = "00:00:00"
            self.updateClock()
            self.retrieveSettingsFromSharedSpace()
        }

        if self.checkOutTime == nil && self.checkInTime != nil {
            self.updateClock() // for first update
            self.clockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TodayViewController.updateClock), userInfo: nil, repeats: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOSApplicationExtension 10.0, *) {
            if extensionContext?.widgetActiveDisplayMode == .expanded {
                self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 200) // 187 self.view.frame.height
            }
        } else {
            self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 30, height: 200) // 187 self.view.frame.height
        }
        var lineShape: CAShapeLayer? = nil
        var linePath: CGMutablePath? = nil
        linePath = CGMutablePath()
        lineShape = CAShapeLayer()

        lineShape!.lineWidth = 0.09
        lineShape!.lineCap = kCALineCapSquare

        if #available(iOS 10.0, *) {
            lineShape!.strokeColor = UIColor.black.cgColor
        } else {
            lineShape!.strokeColor = UIColor.white.cgColor
        }

        let x: CGFloat = 0 //203 self.view.frame.height self.buttonGoTo.frame.height
        var y: CGFloat =  172 - 21 - 10
        if #available(iOS 10.0, *) {
            y += 12
        }
        let toX: CGFloat = self.view.frame.width
        let toY: CGFloat = y

        linePath?.move(to: CGPoint(x: x, y: y))
        linePath?.addLine(to: CGPoint(x: toX, y: toY))
        lineShape!.path = linePath
        self.view.layer.addSublayer(lineShape!)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.clockTimer?.invalidate()
        self.clockTimer = nil
    }

    // MARK: - widget delegate methods
//    func widgetPerformUpdateWithCompletionHandler(_ completionHandler: ((NCUpdateResult) -> Void)!) {
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Swift.Void) {

        // Perform any setup necessary in order to update the view.

        // If an error is encoutered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.newData)
    }

    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: defaultMarginInsets.left,
                            bottom: 0,
                            right: defaultMarginInsets.right + 7.0)
    }

    // MARK: - setup methods
    @objc func retrieveSettingsFromSharedSpace() {
        var suiteName = "group.\(Bundle.main.bundleIdentifier!)"
        suiteName = "group.com.aximilate.axtimespro"
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

    // MARK: - private methods
    @objc func openApp() {
        extensionContext?.open(URL(string: GlobalConstants.urlScheme)!, completionHandler: nil)
    }

    @objc func updateClock() {
        if let actualCheckInTime = checkInTime, startTime == nil {
            // working
            tickerLabel.text = totalTimeUntilNowWithSeconds(actualCheckInTime,
                                                            secondsToSubstract: secondsPaused!)
        } else if let defineteStartTime = self.startTime {
            // pausing
            self.tickerLabel.text = self.totalTimeUntilNowWithSeconds(defineteStartTime)
        }

        if self.startTime != nil {
            self.firstBottomLabel.text = "\(self.checkoutSalaryString!) \(self.currency!)"
        } else {
            self.firstBottomLabel.text = "\(NumberFormatter.defaultFormatter(isStatic: true).string(from: self.salaryUntilNowAsDouble())!) \(self.currency!)"
        }
    }

    @objc func salaryUntilNowAsDouble() -> NSNumber {
        guard let hourlyWage = self.hourlyWage,
            hourlyWage.isGreaterZero else {
                return NSNumber(value: 0)
        }
        var returnValue: Double = 0

        let hoursWorked: Double = self.minutesWorkedUntilNowAsDouble() / 60.0
        returnValue = hoursWorked * hourlyWage.doubleValue

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
        return secondsPausedUntilNow(date).clockDisplayValue
    }

    @objc func totalTimeUntilNowWithSeconds(_ date: Date,
                                      secondsToSubstract: NSNumber) -> String {
        return secondsPausedUntilNow(date,
                                     secondsToSubstract: secondsToSubstract).clockDisplayValue
    }

    @objc func totalTimeBetweenDatesWithSeconds(_ earlierDate: Date,
                                          laterDate: Date) -> String {
        return secondsPausedBetweenDates(earlierDate,
                                         laterDate: laterDate).clockDisplayValue
    }

    @objc func totalTimeBetweenDatesWithSeconds(_ earlierDate: Date,
                                          laterDate: Date,
                                          secondsToSubstract: NSNumber) -> String {
        return secondsPausedBetweenDates(earlierDate,
                                         laterDate: laterDate,
                                         secondsToSubstract: secondsToSubstract).clockDisplayValue
    }

    @objc func secondsPausedUntilNow(_ date: Date) -> NSNumber {

        let nowDate = Date()

        return self.secondsPausedBetweenDates(date, laterDate: nowDate)
    }

    @objc func secondsPausedUntilNow(_ date: Date,
                               secondsToSubstract: NSNumber) -> NSNumber {
        let nowDate = Date()
        return secondsPausedBetweenDates(date,
                                         laterDate: nowDate,
                                         secondsToSubstract: secondsToSubstract)
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
}
