//
//  ColorPickerViewModel.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 24.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation

@objc protocol CurrentColorProviderProtocol {
    var currentColor: UIColor { get }
    func selectionChanged(color: UIColor)
}

@objc protocol ColorPickerViewModelProtocol {
    var numberOfSections: Int { get }
    var numberOfRowsInSection: Int { get }
    func isSelected(indexPath: IndexPath) -> Bool
    func color(indexPath: IndexPath) -> UIColor?
    func selectedIndexPath(indexPath: IndexPath)
}

class ColorPickerViewModel: NSObject, ColorPickerViewModelProtocol {
    
    let numberOfSections: Int
    let numberOfRowsInSection: Int
    
    private let colors: [UIColor]
    private let currentColorProvider: CurrentColorProviderProtocol

    @objc init(colors: [UIColor],
         currentColorProvider: CurrentColorProviderProtocol) {
        self.colors = colors
        self.currentColorProvider = currentColorProvider
        numberOfSections = 1
        numberOfRowsInSection = colors.count
        super.init()
    }

    @available(*, unavailable)
    override init() {
        fatalError()
    }
    
    func isSelected(indexPath: IndexPath) -> Bool {
        guard let color = color(indexPath: indexPath) else {
            return false
        }
        return color.hex == currentColorProvider.currentColor.hex
    }
    
    func color(indexPath: IndexPath) -> UIColor? {
        guard colors.count >= indexPath.row else {
            return nil
        }
        return colors[indexPath.row]
    }
    
    func selectedIndexPath(indexPath: IndexPath) {
        guard let color = color(indexPath: indexPath) else {
            return
        }
        currentColorProvider.selectionChanged(color: color)
    }
}
