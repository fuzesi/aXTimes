//
//  AXOverviewViewController+Extension.swift
//  aXTimes
//
//  Created by Simon Schmidt on 02.04.19.
//  Copyright © 2019 aXimilate. All rights reserved.
//

import Foundation
import AlertsPickers

@objc extension AXOverviewViewController {
    @objc func showDayArrayTypeChooserAlert() {
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
            AXUtility.dayTypeArrayChanged(DayTypus.noSelectionIsWork.rawValue, withDateArray: self.curDaySelectionArray)
        }
        alert.addAction(
            image: DayType.vacationImage,
            title: LocalizationConstants.vacation,
            color: ColorPalette.vacation,
            style: .default
        ) { action in
            AXUtility.dayTypeArrayChanged(DayTypus.vacationDay.rawValue, withDateArray: self.curDaySelectionArray)
        }
        alert.addAction(
            image: DayType.sicknessImage,
            title: LocalizationConstants.sickness,
            color: ColorPalette.sickness,
            style: .default
        ) { action in
            AXUtility.dayTypeArrayChanged(DayTypus.sickDay.rawValue, withDateArray: self.curDaySelectionArray)
        }
        alert.addAction(
            image: DayType.holidayImage,
            title: LocalizationConstants.holiday,
            color: ColorPalette.holiday,
            style: .default
        ) { action in
            AXUtility.dayTypeArrayChanged(DayTypus.holiday.rawValue, withDateArray: self.curDaySelectionArray)
        }
        alert.addAction(
            image: DayType.offImage,
            title: LocalizationConstants.dayOffSingular,
            color: ColorPalette.dayOff,
            style: .default
        ) { action in
            AXUtility.dayTypeArrayChanged(DayTypus.notAWorkingDay.rawValue, withDateArray: self.curDaySelectionArray)
        }
        alert.addAction(
            title: LocalizationConstants.cancel,
            style: .cancel
        )
        alert.show()
        
    }
}
