//
//  ReportSettingsTableViewController.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 16/08/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import UIKit

class ReportSettingsTableViewController: UITableViewController {

    private let cellIdentifier = "Cell"

    @objc let settingsManager = SettingsManager()

    override init(style: UITableView.Style) {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizationConstants.reportSettings
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.detailTextLabel?.textColor = UIColor.black
        }

        if indexPath.row == 0 {
            cell?.textLabel?.text = LocalizationConstants.timeUnit
            cell?.detailTextLabel?.text = settingsManager.workTimeUnitDisplayValue
        } else {
            cell?.textLabel?.text = LocalizationConstants.rounding
            cell?.detailTextLabel?.text = settingsManager.netRoundingDisplayValue
        }

        cell?.accessoryType = .disclosureIndicator

        return cell!
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let controller = AXTimeUnitSettingsTableViewController()
            controller.delegate = self
            controller.initialValue = settingsManager.workTimeUnit
            navigationController?.pushViewController(
                controller,
                animated: true)
        } else if indexPath.row == 1 {
            let controller = AXRoundingSettingsTableViewController()
            controller.delegate = self
            controller.initialValue = settingsManager.netRounding
            navigationController?.pushViewController(
                controller,
                animated: true)
        }
    }
}

extension ReportSettingsTableViewController: AXTimeUnitSettingsTableViewControllerDelegate {
    func setSelectedTimeUnit(_ timeUnitInMinutes: UInt) {
        settingsManager.workTimeUnit = timeUnitInMinutes
    }
}

extension ReportSettingsTableViewController: AXRoundingSettingsTableViewControllerDelegate {
    func setSelectedRoundingBehaviour(_ roundingBehaviour: RoundingBehaviour) {
        settingsManager.netRounding = roundingBehaviour
    }
}
