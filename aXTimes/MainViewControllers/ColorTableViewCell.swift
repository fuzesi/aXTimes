//
//  ColorLeftSideSimpleTableViewCell.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 24.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import UIKit

class ColorTableViewCell: UITableViewCell {

    @IBOutlet weak var colorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .default
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
