//
//  Customer+CurrentColorProviderProtocol.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 25.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation

extension Customer: CurrentColorProviderProtocol {
    var currentColor: UIColor {
        return self.color
    }

    func selectionChanged(color: UIColor) {
        colourAsHex = color.hex
    }
}
