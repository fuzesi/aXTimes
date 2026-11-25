//
//  UIColor+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 25.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import UIKit

extension UIColor {
    @objc var hex: String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let value = UInt32((red * 255).rounded()) << 16 |
                    UInt32((green * 255).rounded()) << 8 |
                    UInt32((blue * 255).rounded())
        return String(format: "#%06x", value)
    }
}

extension String {
    var color: UIColor {
        let text = trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: text)
        if text.hasPrefix("#") { scanner.scanLocation = 1 }
        var value: UInt32 = 0
        guard scanner.scanHexInt32(&value) else { return .black }
        let hasAlpha = text.count > 7
        let red = (value >> (hasAlpha ? 24 : 16)) & 0xff
        let green = (value >> (hasAlpha ? 16 : 8)) & 0xff
        let blue = (value >> (hasAlpha ? 8 : 0)) & 0xff
        let alpha = hasAlpha ? value & 0xff : 255
        return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255,
                       blue: CGFloat(blue) / 255, alpha: CGFloat(alpha) / 255)
    }
}
