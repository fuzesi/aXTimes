//
//  ProjectSummaryTableViewCell+Project.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 02/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import Foundation

extension ProjectSummaryTableViewCell {
    
    // MARK: - public methods
    @objc func setProject(_ project: Project, isProjectSubproject: Bool) {
        projectName.text = project.displayNameForTreeView()
        projectColor.backgroundColor = project.color
        workingTimeValueLabel.text = project.netTimeHoursDisplayValue
        workingTimeValueTwoLabel.text = project.netTimeDaysDisplayValue()
        if(isProjectSubproject){
            remainingBudgetValueLabel.text = ""
            remainingBudgetValueTwoLabel.text = ""
            remainingBudgetValueTwoLabel.isHidden = true
            remainingBudgetValueLabel.isHidden = true
            remainingBudgetImage.isHidden = true
            remainingBudgetDescriptionLabel.isHidden = true
            self.hideRemaining()
        }else{
            remainingBudgetValueLabel.text = project.remainingBudgetHoursTotalDisplayValue()
            remainingBudgetValueTwoLabel.text = project.remainingBudgetDaysTotalDisplayValue()
        }
        
        incomeValueLabel.text = project.incomeDisplayValue()
    }
}
