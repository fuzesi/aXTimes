//
//  DayEntryTableViewCell.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 10/09/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import UIKit

class DayEntryTableViewCell: UITableViewCell {

    @IBOutlet weak var customTextLabel: UILabel!
    @IBOutlet weak var customDetailTextLabel: UILabel!
    @IBOutlet weak var projectTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet fileprivate weak var commentTextLabel: UILabel!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .default
        self.commentTextLabel.numberOfLines = 2
        self.customDetailTextLabel.text = ""
        self.commentTextLabel.text = ""
        self.contentView.preservesSuperviewLayoutMargins = true
        self.preservesSuperviewLayoutMargins = true

        self.setupTextUI()
        if #available(iOS 10.0, *) {
            self.customTextLabel.adjustsFontForContentSizeCategory = true
            self.customDetailTextLabel.adjustsFontForContentSizeCategory = true
            self.projectTextLabel.adjustsFontForContentSizeCategory = true
            self.commentTextLabel.adjustsFontForContentSizeCategory = true
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
        self.projectTextLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        self.commentTextLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    }

    @objc func setCommentText(_ comment: String?) {
        if let finalcomment = comment {
            if finalcomment.count > 0 {
                self.increaseBottomConstraint()
            } else {
                self.decreaseBottomConstraint()
            }
        } else {
            self.decreaseBottomConstraint()
        }
        self.commentTextLabel.text = comment
    }

    @objc func decreaseBottomConstraint() {
        self.bottomContraint.constant = 0
        self.needsUpdateConstraints()
        self.updateConstraints()
    }

    @objc func increaseBottomConstraint() {
        self.bottomContraint.constant = 5
        self.needsUpdateConstraints()
        self.updateConstraints()
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
