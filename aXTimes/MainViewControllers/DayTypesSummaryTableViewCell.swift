//
//  DayTypesSummaryTableViewCell.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 02/09/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import UIKit

class DayTypesSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var workDayImageView: UIImageView!
    @IBOutlet weak var dayOffImageView: UIImageView!
    @IBOutlet weak var publicHolidayImageView: UIImageView!
    @IBOutlet weak var vacationImageView: UIImageView!
    @IBOutlet weak var sicknessImageView: UIImageView!

    @IBOutlet weak var workDayLabel: UILabel!
    @IBOutlet weak var dayOffLabel: UILabel!
    @IBOutlet weak var publicHolidayLabel: UILabel!
    @IBOutlet weak var vacationLabel: UILabel!
    @IBOutlet weak var sicknessLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.contentView.preservesSuperviewLayoutMargins = true
        self.preservesSuperviewLayoutMargins = true

        workDayImageView.image = DayType.workImage
        dayOffImageView.image = DayType.offImage
        publicHolidayImageView.image = DayType.holidayImage
        vacationImageView.image = DayType.vacationImage
        sicknessImageView.image = DayType.sicknessImage

        self.setupTextUI()
        if #available(iOS 10.0, *) {
            self.workDayLabel.adjustsFontForContentSizeCategory = true
            self.dayOffLabel.adjustsFontForContentSizeCategory = true
            self.publicHolidayLabel.adjustsFontForContentSizeCategory = true
            self.vacationLabel.adjustsFontForContentSizeCategory = true
            self.sicknessLabel.adjustsFontForContentSizeCategory = true
        }
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(preferredContentSizeChanged(notification:)),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func preferredContentSizeChanged(notification: NSNotification) {
        self.setupTextUI()
    }

    @objc func setupTextUI() {
        self.workDayLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.dayOffLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.publicHolidayLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.vacationLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.sicknessLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }
}
