//
//  Project+CurrentColorProviderProtocol.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 25.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation

extension Project: CurrentColorProviderProtocol {
    var currentColor: UIColor {
        return self.color
    }

    func selectionChanged(color: UIColor) {
        colourAsHex = color.hex
    }
}
