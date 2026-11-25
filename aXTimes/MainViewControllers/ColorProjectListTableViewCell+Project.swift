//
//  ColorProjectListTableViewCell+Project.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 28/10/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension ColorProjectListTableViewCell {

    // MARK: - public methods
    @objc func setProject(_ project: Project) {
        customTextLabel.text = project.name
        customDetailTextLabel.text = project.budgetDaysDisplayValue()
        customDetailTwoTextLabel.text = project.remainingBudgetDaysLeftTotalDisplayValue()
        customSubtitleTextLabel.text = project.timeRangeDisplayValue
        colorView.backgroundColor = project.color
    }
}
