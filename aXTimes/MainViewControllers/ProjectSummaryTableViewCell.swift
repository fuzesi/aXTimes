//
//  ProjectSummaryTableViewCell.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 04/09/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import UIKit

class ProjectSummaryTableViewCell: UITableViewCell, SKSTableViewCellProtocol {

    @IBOutlet weak var projectColor: UIView!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak fileprivate var workingTimeImage: UIImageView!
    @IBOutlet weak fileprivate var workingTimeDescriptionLabel: UILabel!
    @IBOutlet weak var workingTimeValueLabel: UILabel!
    @IBOutlet weak var workingTimeValueTwoLabel: UILabel!
    @IBOutlet weak var remainingBudgetImage: UIImageView!
    @IBOutlet weak var remainingBudgetDescriptionLabel: UILabel!
    @IBOutlet weak var remainingBudgetValueLabel: UILabel!
    @IBOutlet weak var remainingBudgetValueTwoLabel: UILabel!
    @IBOutlet weak fileprivate var incomeImage: UIImageView!
    @IBOutlet weak fileprivate var incomeDescriptionLabel: UILabel!
    @IBOutlet weak var incomeValueLabel: UILabel!

    private var primaryColor: UIColor?
    private var secondaryColor: UIColor?
    private var expandable = false
    private var expanded = false
    
    @objc let kIndicatorViewTag = -1
    @objc let expandableImage = UIImage(named: "expandableImage.png")

    override func awakeFromNib() {
        super.awakeFromNib()

        workingTimeImage.image = UIImage(named: "working_time")!.withBurnTint(UIColor.black)
        remainingBudgetImage.image = UIImage(named: "remaining")!.withBurnTint(UIColor.black)
        incomeImage.image = UIImage(named: "income")!.withBurnTint(UIColor.black)

        workingTimeDescriptionLabel.text = LocalizationConstants.workingTime
        remainingBudgetDescriptionLabel.text = LocalizationConstants.remainingBudget
        incomeDescriptionLabel.text = LocalizationConstants.income

        remainingBudgetValueLabel.text = "-"
        remainingBudgetValueTwoLabel.text = "-"

        contentView.preservesSuperviewLayoutMargins = true
        preservesSuperviewLayoutMargins = true

        setupTextUI()

        if #available(iOS 10.0, *) {
            projectName.adjustsFontForContentSizeCategory = true
            workingTimeDescriptionLabel.adjustsFontForContentSizeCategory = true
            workingTimeValueLabel.adjustsFontForContentSizeCategory = true
            workingTimeValueTwoLabel.adjustsFontForContentSizeCategory = true
            remainingBudgetDescriptionLabel.adjustsFontForContentSizeCategory = true
            remainingBudgetValueLabel.adjustsFontForContentSizeCategory = true
            remainingBudgetValueTwoLabel.adjustsFontForContentSizeCategory = true
            incomeDescriptionLabel.adjustsFontForContentSizeCategory = true
            incomeValueLabel.adjustsFontForContentSizeCategory = true
        }
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(preferredContentSizeChanged(notification:)),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func hideRemaining(){
        remainingBudgetValueLabel.isHidden = true
        remainingBudgetValueTwoLabel.isHidden = true
        remainingBudgetImage.isHidden = true
        remainingBudgetDescriptionLabel.isHidden = true
    }
    
    @objc func preferredContentSizeChanged(notification: NSNotification) {
        setupTextUI()
    }

    @objc func setupTextUI() {
        projectName.font = UIFont.preferredFont(forTextStyle: .body)
        workingTimeDescriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        workingTimeValueLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        workingTimeValueTwoLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        remainingBudgetDescriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        remainingBudgetValueLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        remainingBudgetValueTwoLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        incomeDescriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        incomeValueLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    }

    override var backgroundColor: UIColor? {
        didSet {
            workingTimeValueLabel.backgroundColor = backgroundColor
            workingTimeValueTwoLabel.backgroundColor = backgroundColor
            remainingBudgetValueLabel.backgroundColor = backgroundColor
            remainingBudgetValueTwoLabel.backgroundColor = backgroundColor
            incomeValueLabel.backgroundColor = backgroundColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let indentPoints = indentationLevel * Int(indentationWidth)

        self.contentView.frame = CGRect(
            x: CGFloat(indentPoints),
            y: contentView.frame.origin.y,
            width: contentView.frame.size.width - CGFloat(indentPoints),
            height: contentView.frame.size.height
        )

        if self.isExpanded() {
            if !containsIndicatorView() {
                addIndicatorView()
            } else {
                removeIndicatorView()
                addIndicatorView()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = projectColor.backgroundColor
        super.setSelected(selected, animated: animated)

        if selected {
            projectColor.backgroundColor = color
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = projectColor.backgroundColor
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            projectColor.backgroundColor = color
        }
    }

    // MARK: - private methods

    @objc func expandableView() -> UIView {

        let button = UIButton(type: .custom)
        let frame = CGRect(x: 0.0,
                           y: 0.0,
                           width: self.expandableImage!.size.width,
                           height: self.expandableImage!.size.height)
        button.frame = frame
        button.setBackgroundImage(self.expandableImage, for: UIControl.State())

        return button
    }

    @objc func setExpandable(_ expandable: Bool) {
        if expandable {
            self.accessoryView = self.expandableView()
        } else {
            let view = UIView(frame:
                CGRect(
                    x: 0.0,
                    y: 0.0,
                    width: self.expandableImage!.size.width,
                    height: self.expandableImage!.size.height))
            self.accessoryView = view
        }

        self.expandable = expandable
    }

    // MARK: - SKSTableViewCellProtocol

    func isExpandable() -> Bool {
        return self.expandable
    }

    func isExpanded() -> Bool {
        return expanded
    }

    func setExpanded(_ expanded: Bool) {
        self.expanded = expanded
    }

    func getExpandButton() -> UIButton! {
        return accessoryView as? UIButton
    }

    func setPrimaryColor(_ color: UIColor!) {
        primaryColor = color
    }

    func setSecondaryColor(_ color: UIColor!) {
        secondaryColor = color
    }

    func addIndicatorView() {
        if containsIndicatorView() {
            return
        }

        let point = accessoryView!.center
        let bounds = accessoryView!.bounds
        let height: CGFloat = 15

        let frame = CGRect(x: (point.x - bounds.width * 1.5),
                           y: self.bounds.height - height,
                           width: bounds.width * 3.0,
                           height: height)

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
