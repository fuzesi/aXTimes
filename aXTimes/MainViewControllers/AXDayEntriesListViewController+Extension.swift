//
//  AXDayEntriesListViewController+Extension.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 26.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation
import AlertsPickers

extension AXDayEntriesListViewController {
    @objc func showDayTypeChooserAlert() {
        let alert = UIAlertController(
            style: .actionSheet,
            title: LocalizationConstants.dayType,
            message: LocalizationConstants.dayTypeInstructions
        )
        alert.addAction(
            image: DayType.workImage,
            title: LocalizationConstants.workDay,
            color: ColorPalette.signature,
            style: .default
        ) { action in
            AXUtility.dayTypeChanged(with: DayTypus.noSelectionIsWork.rawValue, with: self.date)
        }
        alert.addAction(
            image: DayType.vacationImage,
            title: LocalizationConstants.vacation,
            color: ColorPalette.vacation,
            style: .default
        ) { action in
            AXUtility.dayTypeChanged(with: DayTypus.vacationDay.rawValue, with: self.date)
        }
        alert.addAction(
            image: DayType.sicknessImage,
            title: LocalizationConstants.sickness,
            color: ColorPalette.sickness,
            style: .default
        ) { action in
            AXUtility.dayTypeChanged(with: DayTypus.sickDay.rawValue, with: self.date)
        }
        alert.addAction(
            image: DayType.holidayImage,
            title: LocalizationConstants.holiday,
            color: ColorPalette.holiday,
            style: .default
        ) { action in
            AXUtility.dayTypeChanged(with: DayTypus.holiday.rawValue, with: self.date)
        }
        alert.addAction(
            image: DayType.offImage,
            title: LocalizationConstants.dayOffSingular,
            color: ColorPalette.dayOff,
            style: .default
        ) { action in
            AXUtility.dayTypeChanged(with: DayTypus.notAWorkingDay.rawValue, with: self.date)
        }
        alert.addAction(
            title: LocalizationConstants.cancel,
            style: .cancel
        )
        alert.show()

    }
}
