//
//  Export.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 28.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation

enum ExportError: Error {
    case dataConstructionFailed
}

@objc protocol Export {
    @objc func data() throws -> Data
}
