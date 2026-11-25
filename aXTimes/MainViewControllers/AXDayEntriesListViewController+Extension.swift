//
//  AXDayEntriesListViewController+Extension.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 26.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import UIKit

extension AXDayEntriesListViewController {
    @objc func showDayTypeChooserAlert() {
        DayTypeChooser.present(from: self) { [weak self] type in
            guard let self = self else { return }
            AXUtility.dayTypeChanged(with: type.rawValue, with: self.date)
        }
    }
}
