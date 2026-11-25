//
//  Dictionary+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 22/03/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func update(_ dict: Dictionary) {
        for (key, value) in dict {
            updateValue(value, forKey:key)
        }
    }
//    static func += <K, V> (left: inout [K:V], right: [K:V]) {
//        for (k, v) in right {
//            left[k] = v
//        }
//    }
}
