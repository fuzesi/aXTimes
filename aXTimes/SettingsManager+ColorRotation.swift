//
//  SettingsManager+ProjectColorRotation.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 10/02/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

private enum Constants {

    private static let totalColors: UInt = 10
    private static let colors = [
        "#6666ff",
        "#cc9966",
        "#66ffff",
        "#66ff66",
        "#ff66ff",
        "#ffb366",
        "#e600e6",
        "#ff6666",
        "#ffff66",
        "#888888"
    ]
    static let colorPalette = colors.map { $0.color }
}

extension SettingsManager {

    @objc var colorPool: [UIColor] {
        return Constants.colorPalette
    }

    private var totalColors: UInt {
        return UInt(colorPool.count)
    }

    @objc func colorForClient() -> UIColor {
        let index = clientColorRotationIndex()
        return colorPool[index]
    }

    @objc func colorForProject() -> UIColor {
        let index = projectColorRotationIndex()
        return colorPool[index]
    }

    @objc func advanceProjectColorRotation() {
        let nextIndex = UInt((UInt(projectColorRotationIndex()) + 1) % totalColors)
        setProjectColorRotationIndex(nextIndex)
    }

    @objc func advanceClientColorRotation() {
        let nextIndex = UInt((UInt(clientColorRotationIndex()) + 1) % totalColors)
        setClientColorRotationIndex(nextIndex)
    }

    @objc func setProjectColorRotationIndex(_ index: UInt) {
        UserDefaults.standard.set(index, forKey: SettingConstants.projectColorRotation)
        UserDefaults.standard.synchronize()
    }

    private func projectColorRotationIndex() -> Int {
        return UserDefaults.standard.integer(forKey: SettingConstants.projectColorRotation)
    }

    @objc func setClientColorRotationIndex(_ index: UInt) {
        UserDefaults.standard.set(index, forKey: SettingConstants.clientColorRotation)
        UserDefaults.standard.synchronize()
    }

    private func clientColorRotationIndex() -> Int {
        return UserDefaults.standard.integer(forKey: SettingConstants.clientColorRotation)
    }
}


