//
//  DisplayClientTableViewController.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 02/09/16.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import UIKit

private enum FirstSectionRowIndex: Int {
    case name = 0
    case code
    case description
    case email
    case phone
    case count
}

class DisplayClientTableViewController: UITableViewController {

    @objc var customer: Customer?

    private let cellIdentifier = "Cell"
    private let standardIdentifier = "AXStandardTableViewCell"
    private let colorRightSideIdentifier = String(describing: ColorRightSideTableViewCell.self)
    private let projectCellIdentifier = String(describing: ColorProjectListTableViewCell.self)

    override init(style: UITableView.Style) {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Client Details", comment: "")

        let editButton = UIBarButtonItem(barButtonSystemItem: .edit,
                                         target: self,
                                         action: #selector(edit))
        navigationItem.rightBarButtonItem = editButton
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.register(UINib(nibName: standardIdentifier, bundle: nil),
                           forCellReuseIdentifier: standardIdentifier)
        tableView.register(UINib(nibName: colorRightSideIdentifier, bundle: nil),
                           forCellReuseIdentifier: colorRightSideIdentifier)
        tableView.register(UINib(nibName: projectCellIdentifier, bundle: nil),
                           forCellReuseIdentifier: projectCellIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return FirstSectionRowIndex.count.rawValue
        } else {
            return customer?.projects?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.detailTextLabel?.textColor = UIColor.black
        }

        cell?.selectionStyle = .none

        if indexPath.section == 0 {
            if indexPath.row == FirstSectionRowIndex.name.rawValue {
                // swiftlint:disable force_cast
                let colorCell = tableView.dequeueReusableCell(withIdentifier: colorRightSideIdentifier,
                                                              for: indexPath) as! ColorRightSideTableViewCell
                colorCell.selectionStyle = .none
                colorCell.customTextLabel.text = LocalizationConstants.name
                colorCell.customDetailTextLabel.text = customer?.displayName
                colorCell.colorView.backgroundColor = customer?.color
                return colorCell
            } else if indexPath.row == FirstSectionRowIndex.code.rawValue {
                // swiftlint:disable force_cast
                let standardCell: AXStandardTableViewCell = tableView.dequeueReusableCell(withIdentifier: standardIdentifier, for: indexPath) as! AXStandardTableViewCell
                standardCell.customTextLabel.text = LocalizationConstants.code
                standardCell.customDetailTextLabel.text = customer?.code
                return standardCell
            } else if indexPath.row == FirstSectionRowIndex.description.rawValue {
                // swiftlint:disable force_cast
                let standardCell: AXStandardTableViewCell = tableView.dequeueReusableCell(withIdentifier: standardIdentifier, for: indexPath) as! AXStandardTableViewCell
                standardCell.customTextLabel.text = LocalizationConstants.description
                standardCell.customDetailTextLabel.text = customer?.notes
                return standardCell
            } else if indexPath.row == FirstSectionRowIndex.email.rawValue {
                // swiftlint:disable force_cast
                let standardCell: AXStandardTableViewCell = tableView.dequeueReusableCell(withIdentifier: standardIdentifier, for: indexPath) as! AXStandardTableViewCell
                standardCell.customTextLabel.text = LocalizationConstants.email
                standardCell.customDetailTextLabel.text = customer?.email
                return standardCell
            } else if indexPath.row == FirstSectionRowIndex.phone.rawValue {
                // swiftlint:disable force_cast
                let standardCell: AXStandardTableViewCell = tableView.dequeueReusableCell(withIdentifier: standardIdentifier, for: indexPath) as! AXStandardTableViewCell
                standardCell.customTextLabel.text = LocalizationConstants.phone
                standardCell.customDetailTextLabel.text = customer?.phone
                return standardCell
            }
        } else {
            // swiftlint:disable force_cast
            let projectCell = tableView.dequeueReusableCell(withIdentifier: projectCellIdentifier,
                                                            for: indexPath) as! ColorProjectListTableViewCell
            projectCell.selectionStyle = .none
            if let project = customer?.sortedProjects[indexPath.row] {
                projectCell.setProject(project)
            }
            return projectCell
        }

        return cell!
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return LocalizationConstants.projects
        default:
            return nil
        }
    }

    // MARK: - private methods

    @objc private func edit() {
        let editCustomerTableViewController = AXEditCustomerTableViewController()
        editCustomerTableViewController.customer = customer
        editCustomerTableViewController.newCustomer = false

        let navigationController = UINavigationController(rootViewController: editCustomerTableViewController)

        self.present(navigationController,
                     animated: true,
                     completion: nil)
    }
}
