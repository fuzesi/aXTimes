//
//  DeletionCell.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 05/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import UIKit

class DeletionCell: UITableViewCell {

    @IBOutlet weak var customTextLabel: UILabel!
    @IBOutlet weak var customDetailTextLabel: UILabel!
    @IBOutlet weak var deletionButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .default
        self.customDetailTextLabel.text = ""
        self.deletionButton.tintColor = ColorPalette.systemRed

        self.contentView.preservesSuperviewLayoutMargins = true
        self.preservesSuperviewLayoutMargins = true
        self.setupTextUI()
        if #available(iOS 10.0, *) {
            self.customTextLabel.adjustsFontForContentSizeCategory = true
            self.customDetailTextLabel.adjustsFontForContentSizeCategory = true
        }
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(preferredContentSizeChanged(notification:)),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func preferredContentSizeChanged(notification: NSNotification) {
        self.setupTextUI()
    }

    private func setupTextUI() {
        self.customTextLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.customDetailTextLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }

}
