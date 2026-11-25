//
//  SegmentedControlCell.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 08/11/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import UIKit

class SegmentedControlCell: UITableViewCell {

    @IBOutlet weak var customTextLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        // UIKit loads table-view cells on the main thread.
        MainActor.assumeIsolated {
            self.selectionStyle = .none

            self.contentView.preservesSuperviewLayoutMargins = true
            self.preservesSuperviewLayoutMargins = true
            self.setupTextUI()
            if #available(iOS 10.0, *) {
                self.customTextLabel.adjustsFontForContentSizeCategory = true
            }
            NotificationCenter.default.addObserver(self,
                                                   selector:#selector(preferredContentSizeChanged(notification:)),
                                                   name: UIContentSizeCategory.didChangeNotification,
                                                   object: nil)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func preferredContentSizeChanged(notification: NSNotification) {
        self.setupTextUI()
    }

    private func setupTextUI() {
        self.customTextLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }

}
