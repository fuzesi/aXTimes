//
//  AXOverviewViewController+Extension.swift
//  aXTimes
//
//  Created by Simon Schmidt on 02.04.19.
//  Copyright © 2019 aXimilate. All rights reserved.
//

import UIKit

// The same options are used for single-day and multi-day changes.
enum DayTypeChooser {
    struct Option {
        let title: String
        let type: DayTypus
        let color: UIColor
        let image: UIImage
    }

    static var options: [Option] {
        [
            Option(title: LocalizationConstants.workDay, type: .noSelectionIsWork, color: ColorPalette.signature, image: DayType.workImage),
            Option(title: LocalizationConstants.vacation, type: .vacationDay, color: ColorPalette.vacation, image: DayType.vacationImage),
            Option(title: LocalizationConstants.sickness, type: .sickDay, color: ColorPalette.sickness, image: DayType.sicknessImage),
            Option(title: LocalizationConstants.holiday, type: .holiday, color: ColorPalette.holiday, image: DayType.holidayImage),
            Option(title: LocalizationConstants.dayOffSingular, type: .notAWorkingDay, color: ColorPalette.dayOff, image: DayType.offImage)
        ]
    }

    static func present(from controller: UIViewController, onSelection: @escaping (DayTypus) -> Void) {
        let chooser = DayTypeChooserViewController(onSelection: onSelection)
        chooser.modalPresentationStyle = .pageSheet
        controller.present(chooser, animated: true)
    }
}

final class DayTypeChooserViewController: UIViewController {
    private let onSelection: (DayTypus) -> Void
    private(set) var optionButtons: [UIButton] = []
    private(set) var cancelButton = UIButton(type: .system)

    init(onSelection: @escaping (DayTypus) -> Void) {
        self.onSelection = onSelection
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -48)
        ])
        let titleLabel = UILabel()
        titleLabel.text = LocalizationConstants.dayType
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityTraits = .header
        stack.addArrangedSubview(titleLabel)
        let description = UILabel()
        description.text = LocalizationConstants.dayTypeInstructions
        description.textColor = .secondaryLabel
        description.font = .preferredFont(forTextStyle: .subheadline)
        description.adjustsFontForContentSizeCategory = true
        description.numberOfLines = 0
        stack.addArrangedSubview(description)
        for option in DayTypeChooser.options {
            var config = UIButton.Configuration.filled()
            config.title = option.title
            config.image = option.image.withRenderingMode(.alwaysOriginal)
            config.imagePadding = 16
            config.baseForegroundColor = option.color
            config.baseBackgroundColor = .secondarySystemBackground
            config.cornerStyle = .large
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true)
                self.onSelection(option.type)
            })
            button.contentHorizontalAlignment = .leading
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 54).isActive = true
            optionButtons.append(button)
            stack.addArrangedSubview(button)
        }
        var cancelConfig = UIButton.Configuration.tinted()
        cancelConfig.title = LocalizationConstants.cancel
        cancelConfig.baseForegroundColor = .label
        cancelButton.configuration = cancelConfig
        cancelButton.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        cancelButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        stack.addArrangedSubview(cancelButton)
    }
}

@objc extension AXOverviewViewController {
    @objc func showDayArrayTypeChooserAlert() {
        DayTypeChooser.present(from: self) { [weak self] type in
            guard let self = self else { return }
            AXUtility.dayTypeArrayChanged(type.rawValue, withDateArray: self.curDaySelectionArray)
        }
    }
}
