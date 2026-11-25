//
//  JSONRepresentable.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 21/02/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

protocol JSONRepresentable {
    var jsonRepresentation: [String: Any] { get }
}

struct JSONHelper {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        return formatter
    }()

    static func jsonObject(object: Any?) -> Any {
        guard let actualObject = object else {
            return NSNull()
        }
        if let date = object as? Date {
            let timeStamp = JSONHelper.formatter.string(from: date)
            return timeStamp
        }
        return actualObject
    }

    static func date(object: Any?) -> NSDate? {
        guard let dateString = object as? String else {
            return nil
        }
        guard let date = JSONHelper.formatter.date(from: dateString) else {
            return nil
        }
        return NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
    }
}
