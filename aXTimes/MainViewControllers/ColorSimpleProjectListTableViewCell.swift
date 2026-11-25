//
//  ColorSimpleProjectListTableViewCell.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 23/09/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import UIKit

class ColorSimpleProjectListTableViewCell: UITableViewCell, SKSTableViewCellProtocol {

    @IBOutlet weak var customTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!

    fileprivate var primaryColor: UIColor?
    fileprivate var secondaryColor: UIColor?
    fileprivate var expandable = false
    fileprivate var expanded = false

    fileprivate let kIndicatorViewTag = -1

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .default
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func preferredContentSizeChanged(notification: NSNotification) {
        self.setupTextUI()
    }

    @objc func setupTextUI() {
        self.customTextLabel.font = UIFont.preferredFont(forTextStyle: .body)
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

    override func layoutSubviews() {
        super.layoutSubviews()

        let indentPoints = self.indentationLevel * Int(self.indentationWidth)

        self.contentView.frame = CGRect(
            x: CGFloat(indentPoints),
            y: self.contentView.frame.origin.y,
            width: self.contentView.frame.size.width - CGFloat(indentPoints),
            height: self.contentView.frame.size.height
        )

        if self.isExpanded() {
            if !self.containsIndicatorView() {
                self.addIndicatorView()
            } else {
                self.removeIndicatorView()
                self.addIndicatorView()
            }
        }
    }

    // MARK: - private methods

    private var expandableView: UIView = {
        let expandableImage = UIImage(named: "expandableImage.png")!
        let button = UIButton(type: .custom)
        let frame = CGRect(x: 0.0,
                           y: 0.0,
                           width: expandableImage.size.width,
                           height: expandableImage.size.height)
        button.frame = frame
        button.setBackgroundImage(expandableImage,
                                  for: UIControl.State())
        return button
    }()

    @objc func setExpandable(_ expandable: Bool) {
        if expandable {
            // do not set again because it causes a weird 
            // and unwanted animation
            if accessoryView != expandableView {
                accessoryView = expandableView
            }
        } else {
            accessoryView = nil
        }
        self.expandable = expandable
    }

    // MARK: - SKSTableViewCellProtocol

    func isExpandable() -> Bool {
        return self.expandable
    }

    func isExpanded() -> Bool {
        return self.expanded
    }

    func setExpanded(_ expanded: Bool) {
        self.expanded = expanded
    }

    func getExpandButton() -> UIButton! {
        return self.accessoryView as! UIButton
    }

    func setPrimaryColor(_ color: UIColor!) {
        self.primaryColor = color
    }

    func setSecondaryColor(_ color: UIColor!) {
        self.secondaryColor = color
    }

    func addIndicatorView() {
        if self.containsIndicatorView() {
            return
        }

        let point = self.accessoryView!.center
        let bounds = self.accessoryView!.bounds

        let frame = CGRect(x: (point.x - bounds.width * 1.5),
                           y: point.y * 1.4,
                           width: bounds.width * 3.0,
                           height: self.bounds.height - point.y * 1.4)

        let indicatorView = SKSTableViewCellIndicator(frame: frame)
        indicatorView.indicatorColor = self.secondaryColor
        indicatorView.tag = kIndicatorViewTag
        self.contentView.addSubview(indicatorView)
    }

    func removeIndicatorView() {
        if let indicatorView = self.contentView.viewWithTag(kIndicatorViewTag) {
            indicatorView.removeFromSuperview()
        }
    }

    func containsIndicatorView() -> Bool {
        return self.contentView.viewWithTag(kIndicatorViewTag) != nil ? true : false
    }

    func expandButtonAnimation() {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                if self.isExpanded() {
                    self.accessoryView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                } else {
                    self.accessoryView?.transform = CGAffineTransform(rotationAngle: 0)
                }
            }, completion: { (_) in
                if !self.isExpanded() {
                    self.removeIndicatorView()
                }
        })
    }
}
