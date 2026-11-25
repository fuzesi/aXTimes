//
//  Array+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 13/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
