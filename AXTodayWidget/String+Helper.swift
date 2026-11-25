//
//  String.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 26/01/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

struct Characters {
    static let paragraphSeparatorCharacter: Character = "\u{2029}"
    static let lineSeparatorCharacter: Character = "\u{2028}"
    static let newlineCharacter: Character = "\u{000a}"
    static let specialChars = [String(paragraphSeparatorCharacter),
                               String(lineSeparatorCharacter),
                               String(newlineCharacter)]
}

extension String {
    var stripped: String {
        var returnValue = self
        for char in Characters.specialChars {
            returnValue = returnValue.replacingOccurrences(of: char,
                                                           with: " ")
        }
        return returnValue
    }
    
    static func uuid() -> String {
        return UUID().uuidString
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    
    func localized(exportLanguage: String?) -> String {
        guard let exportLanguage = exportLanguage,
            let path = Bundle.main.path(forResource: exportLanguage, ofType: "lproj"),
            let languageBundle = Bundle(path: path) else {
                return self.localized
        }
        
        return languageBundle.localizedString(
            forKey: self,
            value: "",
            table: nil
        )
    }
}

extension Sequence where Iterator.Element == String {
    func escaped() -> [String] {
        return map { "\"\($0)\"" }
    }
}
