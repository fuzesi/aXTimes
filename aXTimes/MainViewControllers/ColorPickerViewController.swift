//
//  ColorPickerViewController.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 23.01.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @objc var viewModel: ColorPickerViewModelProtocol!

    private let cellIdentifier = String(describing: ColorTableViewCell.self)
    private var tableView: UITableView!

    // MARK: - lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.color
        setupTableView()
    }

    // MARK: - private methods

    @objc func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ColorTableViewCell
        guard let colorCell = cell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }

        colorCell.colorView.backgroundColor = viewModel.color(indexPath: indexPath)
        colorCell.accessoryType = viewModel.isSelected(indexPath: indexPath) ? .checkmark : .none

        return colorCell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.toggleCheckmark(indexPath)
        viewModel.selectedIndexPath(indexPath: indexPath)
    }

}

