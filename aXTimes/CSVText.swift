//
//  CSVText.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 28.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation

private enum Constants {
    static let bom = "\u{feff}"
}

struct CSVText {
    
    private let separator: String
    private let lineBreak: String
    private let table: [[String]]
    private let isUseBom: Bool

    init(
        separator: String,
        lineBreak: String,
        table: [[String]],
        isUseBom: Bool
        ) {
        self.separator = separator
        self.lineBreak = lineBreak
        self.table = table
        self.isUseBom = isUseBom
    }
    
    func value() -> String {
        var output = ""
        if isUseBom {
            output.append(Constants.bom)
        }
        table.forEach { row in
            let rowValue = row.joined(separator: self.separator)
            output.append(rowValue)
            output.append(lineBreak)
        }
        return output
    }
}
