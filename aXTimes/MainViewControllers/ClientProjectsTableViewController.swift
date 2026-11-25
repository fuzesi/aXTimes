//
//  ClientProjectsTableViewController.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 28/10/2016.
//  Copyright © 2016 aXimilate. All rights reserved.
//

import UIKit

class ClientProjectsTableViewController: UITableViewController {

    @objc var client: Customer?
    private let colorCellIdentifier = String(describing: ColorProjectListTableViewCell.self)

    override init(style: UITableView.Style) {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.projects

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.register(UINib(nibName: colorCellIdentifier, bundle: nil),
                           forCellReuseIdentifier: colorCellIdentifier)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return client?.sortedProjects.count ?? 0
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let colorCell = tableView.dequeueReusableCell(withIdentifier: colorCellIdentifier,
                                                      for: indexPath) as! ColorProjectListTableViewCell
        configureCell(cell: colorCell,
                      atIndexPath: indexPath)

        return colorCell
    }

    // MARK: - Private methods

    @objc func configureCell(cell: ColorProjectListTableViewCell,
                       atIndexPath indexPath: IndexPath) {
        cell.selectionStyle = .none
        if let tempProject = client?.sortedProjects[indexPath.row] {
            cell.setProject(tempProject)
        }
    }
}
