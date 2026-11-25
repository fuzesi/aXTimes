//
//  DayType+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 13/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

@objc enum DayTypus2: Int {
    case notSpecified = -2
    case noSelectionIsWork = -1
    case off = 0
    case holiday = 1
    case vacation = 2
    case sickness = 3
}

extension DayType {
    @objc func configure(withDate date: Date,
                   andTimeZone timeZone: String = NSTimeZone.system.identifier) {
        calendarDate = date as NSDate
        calendarDateTimeZone = timeZone

        let formatter = DateFormatter()
        formatter.locale = NSLocale.current
        formatter.dateFormat = "yyyy_MM_dd"
        calendarDay = formatter.string(from: date)

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        formatter.dateFormat = "yyyy"
        year = numberFormatter.number(from: formatter.string(from: date))

        formatter.dateFormat = "MM"
        month = numberFormatter.number(from: formatter.string(from: date))

        formatter.dateFormat = "dd"
        day = numberFormatter.number(from: formatter.string(from: date))
    }

    @objc var dayKey: String {
        return calendarDay?.replacingOccurrences(of: "_", with: "") ?? ""
    }

    @objc func setWork() {
        work = NSNumber(value: true)
        vacation = NSNumber(value: false)
        sickness = NSNumber(value: false)
        holiday = NSNumber(value: false)
    }

    @objc func setVacation() {
        work = NSNumber(value: true)
        vacation = NSNumber(value: true)
        sickness = NSNumber(value: false)
        holiday = NSNumber(value: false)
    }

    @objc func setHoliday() {
        work = NSNumber(value: false)
        vacation = NSNumber(value: false)
        sickness = NSNumber(value: false)
        holiday = NSNumber(value: true)
    }

    @objc func setSickness() {
        work = NSNumber(value: true)
        vacation = NSNumber(value: false)
        sickness = NSNumber(value: true)
        holiday = NSNumber(value: false)
    }

    @objc func setOff() {
        work = NSNumber(value: false)
        vacation = NSNumber(value: false)
        sickness = NSNumber(value: false)
        holiday = NSNumber(value: false)
    }

    @objc var isWork: Bool {
        return work?.boolValue ?? false
    }

    @objc var isHoliday: Bool {
        return holiday?.boolValue ?? false
    }

    @objc var isVacation: Bool {
        return vacation?.boolValue ?? false
    }

    @objc var isSickness: Bool {
        return sickness?.boolValue ?? false
    }

    @objc var isOff: Bool {
        if !isWork &&
            !isHoliday &&
            !isVacation &&
            !isSickness {
            return true
        } else {
            return false
        }
    }

    @objc var isNotWorking: Bool {
        if isHoliday {
            return true
        }
        if !isWork &&
            !isHoliday &&
            !isVacation &&
            !isSickness {
            return true
        }
        return false
    }

    @objc var primaryColor: UIColor {
        if isVacation {
            return ColorPalette.vacation
        } else if isSickness {
            return ColorPalette.sickness
        } else if isHoliday {
            return ColorPalette.holiday
        } else if isOff {
            return ColorPalette.dayOff
        } else {
            return UIColor.white
        }
    }

    @objc var image: UIImage {
        if isVacation {
            return DayType.vacationImage
        } else if isSickness {
            return DayType.sicknessImage
        } else if isHoliday {
            return DayType.holidayImage
        } else if isOff {
            return DayType.offImage
        } else {
            return DayType.workImage
        }
    }

    @objc var title: String {
        if isVacation {
            return LocalizationConstants.vacation
        } else if isSickness {
            return LocalizationConstants.sickness
        } else if isHoliday {
            return LocalizationConstants.holiday
        } else if isOff {
            return LocalizationConstants.dayOffSingular
        } else {
            return LocalizationConstants.workDay
        }
    }

    // http://stackoverflow.com/a/29814707/1113632
    @objc static var vacationImage: UIImage {
        struct Local {
            static let cache: UIImage = UIImage(named: "sun")!.withBurnTint(ColorPalette.vacation)
        }
        return Local.cache
    }

    @objc static var sicknessImage: UIImage {
        struct Local {
            static let cache: UIImage = UIImage(named: "sickness")!.withBurnTint(ColorPalette.sickness)
        }
        return Local.cache
    }

    @objc static var holidayImage: UIImage {
        struct Local {
            static let cache: UIImage = UIImage(named: "candle")!.withBurnTint(ColorPalette.holiday)
        }
        return Local.cache
    }

    @objc static var workImage: UIImage {
        struct Local {
            static let cache: UIImage = UIImage(named: "work")!.withBurnTint(ColorPalette.signature)
        }
        return Local.cache
    }

    @objc static var offImage: UIImage {
        struct Local {
            static let cache: UIImage = UIImage(named: "dayOff")!.withBurnTint(ColorPalette.dayOff)
        }
        return Local.cache
    }
}
