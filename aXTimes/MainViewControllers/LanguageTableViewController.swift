//
//  LanguageTableViewController.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 18/08/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import UIKit

class LanguageTableViewController: UITableViewController {

    private let cellIdentifier = "Cell"

    @objc let settingsManager = SettingsManager()
    @objc var data: [String]!

    override init(style: UITableView.Style) {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.language
        data = settingsManager.languageLocales
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell?.detailTextLabel?.textColor = UIColor.black
        }

        let locale = data[indexPath.row]

        cell?.textLabel?.text = AXUtility.locale(toExportLanguageString: locale).capitalized

        if settingsManager.exportLanguageLocale == locale {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }

        return cell!
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.toggleCheckmark(indexPath)
        settingsManager.exportLanguageLocale = data[indexPath.row]
    }
}
