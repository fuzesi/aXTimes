//
//  InterfaceController.swift
//  aXTimes WatchKit Extension
//
//  Created by fuesec on 26/05/15.
//  Copyright (c) 2015 aXimilate. All rights reserved.
//

import WatchKit
import Foundation

private enum WatchAction: String {
    case checkIn = "checkIn"
    case checkOut = "checkOut"
    case pauseIn = "pauseIn"
    case pauseOut = "pauseOut"
    case load = "load"
}

class InterfaceController: WKInterfaceController, WatchCommunicationWatchDelegate, WatchCommunicationDelegate {

    // MARK: - variables
    private var clockTimer: Timer?
    private var checkInTime: Date?
    private var checkOutTime: Date?
    private var startTime: Date?
    private var checkInTimeZone: String?
    private var checkOutTimeZone: String?
    private var comment: String?
    private var secondsPaused: NSNumber?
    private var checkoutTimeString: String?
    private var hourlyWage: NSNumber?
    private var currency: String?
    private var checkoutSalaryString: String?

    @IBOutlet private var tickerLabel: WKInterfaceLabel!
    @IBOutlet private var topLabel: WKInterfaceLabel!
    @IBOutlet private var firstBottomLabel: WKInterfaceLabel!
    @IBOutlet private var secondBottomLabel: WKInterfaceLabel!

    // MARK: - lifecycle methods
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        WatchCommunication.shared.delegate = self
        topLabel.setText("")
        tickerLabel.setText("--:--:--")
        firstBottomLabel.setText("")
        secondBottomLabel.setText("")
        tickerLabel.setTextColor(ColorPalette.signature)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("willActivate")
        WatchCommunication.shared.watchDelegate = self
        if WatchCommunication.shared.isActive {
            sendActionToAppAndClearMenu(.load)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("didDeactivate")
        clockTimer?.invalidate()
        clockTimer = nil
    }

    // MARK: - watch communication delegate

    func sessionActivated() {
        DispatchQueue.main.async {
            WatchCommunication.shared.watchDelegate = self
            self.sendActionToAppAndClearMenu(.load)
        }
    }

    func latestContext(_ context: [String: Any]) {
        DispatchQueue.main.async {
//            self.retrieveData(from: context)
            self.saveDataFromDictionary(context)
            self.setupTickerUI()
        }
    }

    // MARK: - setup methods

    @objc func retrieveData(from context: [String: Any]) {
//        checkInTime = nil
//        checkOutTime = nil
//        startTime = nil
//        checkInTimeZone = nil
//        checkOutTimeZone = nil
//        comment = nil
//        secondsPaused = nil
//        checkoutTimeString = nil
//        hourlyWage = nil
//        currency = nil
//        checkoutSalaryString = nil
//
//        checkInTime = context["checkInTime"] as? Date
//        checkOutTime = context["checkOutTime"] as? Date
//        startTime = context["startTime"] as? Date
//        checkInTimeZone = context["checkInTimeZone"] as? String
//        checkOutTimeZone = context["checkOutTimeZone"] as? String
//        comment = context["comment"] as? String
//        secondsPaused = context["secondsPaused"] as? NSNumber
//        checkoutTimeString = context["checkoutTimeString"] as? String
//        hourlyWage = context["hourlyWage"] as? NSNumber
//        currency = context["currency"] as? String
//        checkoutSalaryString = context["checkoutSalaryString"] as? String
    }

    @objc func saveDataFromDictionary(_ context: [String: Any]) {
        checkInTime = context["checkInTime"] as? Date
        checkOutTime = context["checkOutTime"] as? Date
        startTime = context["startTime"] as? Date
        checkInTimeZone = context["checkInTimeZone"] as? String
        checkOutTimeZone = context["checkOutTimeZone"] as? String
        comment = context["comment"] as? String
        secondsPaused = context["secondsPaused"] as? NSNumber
        checkoutTimeString = context["checkoutTimeString"] as? String
        hourlyWage = context["hourlyWage"] as? NSNumber
        currency = context["currency"] as? String
        checkoutSalaryString = context["checkoutSalaryString"] as? String
    }

    @objc func setupTickerUI() {
        clockTimer?.invalidate()
        clockTimer = nil
        tickerLabel.setTextColor(ColorPalette.signature)
        tickerLabel.setText("")
        firstBottomLabel.setText("")
        secondBottomLabel.setText("")
        topLabel.setText("")
        clearAllMenuItems()

        let checkInDateFormatter = DateFormatter()
        checkInDateFormatter.dateFormat = "HH:mm:ss"

        let checkInDateFormatterDayDifferent = DateFormatter()
        checkInDateFormatterDayDifferent.dateFormat = "HH:mm:ss (d. MMM)"

        let checkInDateFormatterYearDifferent = DateFormatter()
        checkInDateFormatterYearDifferent.dateFormat = "HH:mm:ss (d. MMM yy)"

        var tempDateFormatter: DateFormatter?

        if let defineteCheckOutTime = checkOutTime {
            // checkout out
            if defineteCheckOutTime.isSameDay(Date(), receiverTimeZoneName: checkOutTimeZone!, inputTimeZoneName: TimeZone.current.identifier) {
                tempDateFormatter = checkInDateFormatter
            } else if defineteCheckOutTime.isSameMonth(Date(), receiverTimeZoneName: checkOutTimeZone!, inputTimeZoneName: TimeZone.current.identifier) {
                tempDateFormatter = checkInDateFormatterDayDifferent
            } else {
                tempDateFormatter = checkInDateFormatterYearDifferent
            }

            tempDateFormatter?.timeZone = TimeZone(identifier: checkOutTimeZone!)
            let checkOuttime = tempDateFormatter?.string(from: defineteCheckOutTime)
            topLabel.setText("\(LocalizationConstants.checkOutAt) \(checkOuttime!)")

            if self.checkoutTimeString != nil {
                self.tickerLabel.setText(self.checkoutTimeString)
            }

            if checkoutSalaryString != nil &&
                currency != nil {
                firstBottomLabel.setText("\(checkoutSalaryString!) \(currency!)")
            }
            addMenuItem(withImageNamed: "Check-In", title: "CheckIn", action: #selector(InterfaceController.checkIn))
        } else if let defineteStartTime = startTime {
            // pausing
            secondBottomLabel.setText(LocalizationConstants.pause)
            if let defineteCheckInTime = checkInTime {
                topLabel.setText("\(LocalizationConstants.timeWorkedToday) \(totalTimeBetweenDatesWithSeconds(defineteCheckInTime, laterDate: defineteStartTime))")
            }
            addMenuItem(withImageNamed: "Play", title: "Resume", action: #selector(InterfaceController.pauseOut))
        } else if let defineteCheckInTime = checkInTime {
            // checked in but not pausing
            if defineteCheckInTime.isSameDay(Date(), receiverTimeZoneName: checkInTimeZone!, inputTimeZoneName: TimeZone.current.identifier) {
                tempDateFormatter = checkInDateFormatter
            } else if defineteCheckInTime.isSameMonth(Date(), receiverTimeZoneName: checkInTimeZone!, inputTimeZoneName: TimeZone.current.identifier) {
                tempDateFormatter = checkInDateFormatterDayDifferent
            } else {
                tempDateFormatter = checkInDateFormatterYearDifferent
            }

            tempDateFormatter?.timeZone = TimeZone(identifier: checkInTimeZone!)
            let checkIntime = tempDateFormatter?.string(from: defineteCheckInTime)
            topLabel.setText("\(LocalizationConstants.checkedInAt) \(checkIntime!)")

            addMenuItem(withImageNamed: "Check-Out", title: "Checkout", action: #selector(InterfaceController.checkOut))
            addMenuItem(withImageNamed: "Pause", title: "Pause", action: #selector(InterfaceController.pauseIn))
        } else {
            // no dayentries yet
            topLabel.setText(LocalizationConstants.notWorkedToday)
            tickerLabel.setText("00:00:00")
            addMenuItem(withImageNamed: "Check-In", title: "CheckIn", action: #selector(InterfaceController.checkIn))
        }

        if checkOutTime == nil && checkInTime != nil {
            updateClock() // for first update
            clockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateClock), userInfo: nil, repeats: true)
        }
    }

    // MARK: - action methods

    @objc func checkOut() {
        sendActionToAppAndClearMenu(.checkOut)
    }

    @objc func pauseIn() {
        sendActionToAppAndClearMenu(.pauseIn)
    }

    @objc func pauseOut() {
        sendActionToAppAndClearMenu(.pauseOut)
    }

    @objc func checkIn() {
        sendActionToAppAndClearMenu(.checkIn)
    }

    private func sendActionToAppAndClearMenu(_ action: WatchAction) {
        clearAllMenuItems()
        let actionDictionary = ["action": action.rawValue]
        WatchCommunication
            .shared
            .sendMessage(
                actionDictionary,
                replyHandler: { (replyDictionary) in
                    DispatchQueue.main.async {
                        self.saveDataFromDictionary(replyDictionary)
                        self.setupTickerUI()
                    }
                }) { [weak self] error in
                    print("Watch message failed: \(error)")
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.setupTickerUI()
                        let title = NSLocalizedString("watch_connection_unconfirmed", value: "Connection not confirmed", comment: "Watch communication failure title")
                        let message = NSLocalizedString("watch_connection_unconfirmed_message", value: "The iPhone did not confirm the request. Check the connection and reopen the watch app to refresh the status before trying again.", comment: "Watch communication failure explanation")
                        let ok = WKAlertAction(title: NSLocalizedString("OK", comment: "Dismiss"), style: .default) {}
                        self.presentAlert(withTitle: title, message: message, preferredStyle: .alert, actions: [ok])
                    }
                }
    }

    @objc func updateClock() {
        if checkInTime != nil && startTime == nil {
            // working
            let time = totalTimeUntilNowWithSeconds(checkInTime!, secondsToSubstract: secondsPaused!)
            tickerLabel.setText(time)
        } else if let defineteStartTime = startTime {
            // pausing
            let time = totalTimeUntilNowWithSeconds(defineteStartTime)
            tickerLabel.setText(time)
        }

        let bottomLabelText: String
        if startTime != nil {
            bottomLabelText = "\(checkoutSalaryString!) \(currency!)"
        } else {
            bottomLabelText = "\(NumberFormatter.defaultFormatter(isStatic: true).string(from: salaryUntilNowAsDouble())!) \(currency!)"
        }
        firstBottomLabel.setText(bottomLabelText)
    }

    @objc func salaryUntilNowAsDouble() -> NSNumber {
        guard let hourlyWage = hourlyWage, hourlyWage.isGreaterZero else {
            return NSNumber(value: 0)
        }
        var returnValue: Double = 0

        let hoursWorked: Double = minutesWorkedUntilNowAsDouble() / 60.0
        returnValue = hoursWorked * hourlyWage.doubleValue

        return NSNumber(value: returnValue as Double)
    }

    @objc func minutesWorkedUntilNowAsDouble() -> Double {
        guard let checkInTime = checkInTime, let secondsPaused = secondsPaused else {
            return 0.0
        }
        let resultSecondsPausedUntilNow = secondsPausedUntilNow(checkInTime, secondsToSubstract: secondsPaused)
        let returnValue: Double = resultSecondsPausedUntilNow.doubleValue / 60.0

        return returnValue
    }

    @objc func totalTimeUntilNowWithSeconds(_ date: Date) -> String {
        return secondsPausedUntilNow(date).clockDisplayValue
    }

    @objc func totalTimeUntilNowWithSeconds(_ date: Date, secondsToSubstract: NSNumber) -> String {
        return secondsPausedUntilNow(date, secondsToSubstract: secondsToSubstract).clockDisplayValue
    }

    @objc func totalTimeBetweenDatesWithSeconds(_ earlierDate: Date, laterDate: Date) -> String {
        return secondsPausedBetweenDates(earlierDate, laterDate: laterDate).clockDisplayValue
    }

    @objc func totalTimeBetweenDatesWithSeconds(_ earlierDate: Date, laterDate: Date, secondsToSubstract: NSNumber) -> String {
        return secondsPausedBetweenDates(earlierDate, laterDate: laterDate, secondsToSubstract: secondsToSubstract).clockDisplayValue
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
}
