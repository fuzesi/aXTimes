//
//  CurrencyTableViewController.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 16/08/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import UIKit

class CurrencyTableViewController: UITableViewController {

    private let cellIdentifier = "Cell"

    @objc let settingsManager = SettingsManager()
    @objc var data = Locale.isoCurrencyCodes

    override init(style: UITableView.Style) {
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.currency
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var rowToSelect = 0
        let selectString = settingsManager.currencyIso

        for (index, element) in data.enumerated() {
            if element == selectString {
                rowToSelect = index
            }
        }
        tableView.scrollToRow(
            at: IndexPath(row: rowToSelect, section: 0),
            at: .middle,
            animated: false)
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
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.detailTextLabel?.textColor = UIColor.black
        }

        let isoIdentifier = data[indexPath.row]
        cell?.textLabel?.text = isoIdentifier

        if settingsManager.currencyIso == isoIdentifier {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }

        return cell!
    }

    // http://stackoverflow.com/a/15846321
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        let newRow = indexForFirstChar(title, array: data)
        let newIndexPath = IndexPath(row: newRow, section: 0)

        tableView.scrollToRow(
            at: newIndexPath,
            at: .top,
            animated: false)

        return index
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.toggleCheckmark(indexPath)
        settingsManager.currencyIso = data[indexPath.row]
    }

    // MARK: - private methods

    /// Return the index for the location of the first item in an array that begins with a certain character
    private func indexForFirstChar(_ character: String, array: [String]) -> Int {
        var count = 0
        for string in array {
            if string.hasPrefix(character) {
                return count
            }
            count += 1
        }
        return 0
    }
}
