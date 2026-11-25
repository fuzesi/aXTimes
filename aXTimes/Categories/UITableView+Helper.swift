//
//  UITableView+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 28/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension UITableView {
    @objc func setupHintView(withText text: String) {
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: bounds.size.width,
                                          height: bounds.size.height))
        label.text = text
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        backgroundView = label
        separatorStyle = .none
    }

    @objc func resetHintView() {
        backgroundView = nil
        separatorStyle = .singleLine
    }
}
