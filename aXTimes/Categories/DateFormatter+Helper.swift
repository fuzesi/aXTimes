//
//  DateFormatter+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 25/01/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension DateFormatter {
    private static let staticDayMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    @objc static func dayMonthYear(isStatic: Bool) -> DateFormatter {
        if isStatic {
            return staticDayMonthYear
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            return formatter
        }
    }

    private static let staticHHmmdMMMyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm d. MMM yy"
        return formatter
    }()

    @objc static func HHmmdMMMyy(isStatic: Bool) -> DateFormatter {
        if isStatic {
            return staticHHmmdMMMyy
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm d. MMM yy"
            return formatter
        }
    }

    private static let staticHHmmdMMM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm d. MMM"
        return formatter
    }()

    @objc static func HHmmdMMM(isStatic: Bool) -> DateFormatter {
        if isStatic {
            return staticHHmmdMMM
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm d. MMM"
            return formatter
        }
    }

    private static let staticHHmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    @objc static func HHmm(isStatic: Bool) -> DateFormatter {
        if isStatic {
            return staticHHmm
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }
    }

    private static let staticFulltimeStamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"
        return formatter
    }()

    @objc static func fulltimeStamp(isStatic: Bool) -> DateFormatter {
        if isStatic {
            return staticFulltimeStamp
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"
            return formatter
        }
    }
}
