//
//  ColorLeftSideTableViewCell.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 23/09/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import UIKit

class ColorLeftSideTableViewCell: UITableViewCell {

    @IBOutlet weak var customTextLabel: UILabel!
    @IBOutlet weak var customDetailTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .default
        self.customDetailTextLabel.text = ""
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

    @objc func preferredContentSizeChanged(notification: NSNotification) {
        self.setupTextUI()
    }

    @objc func setupTextUI() {
        self.customTextLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.customDetailTextLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = colorView.backgroundColor
        super.setSelected(selected, animated: animated)

        if selected {
            colorView.backgroundColor = color
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = colorView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            colorView.backgroundColor = color
        }
    }
}
