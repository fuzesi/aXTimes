//
//  DataManagementTableViewController.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 27/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

private enum SectionIndex: Int {
    case createBackup = 0
    case restoreBackup
    case importOldData
}

class DataManagementTableViewController: UITableViewController {

    private let dataSharingService = DataSharingController(settingsManager: SettingsManager())
    private var dataSharingProcess: DataSharingProcessProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.dataManagement
        dataSharingProcess = DataSharingProcess(viewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 2
        if UIApplication.shared.canOpenURL(URL(string: "com.aximilate.axtimes://")!) {
            sections += 1
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "reuseIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(
                style: .default,
                reuseIdentifier: identifier)
        }

        if indexPath.section == SectionIndex.createBackup.rawValue {
            cell?.textLabel?.text = LocalizationConstants.createBackupTitle
        } else if indexPath.section == SectionIndex.restoreBackup.rawValue {
            cell?.textLabel?.text = LocalizationConstants.restoreBackupTitle
        } else if indexPath.section == SectionIndex.importOldData.rawValue {
            cell?.textLabel?.text = LocalizationConstants.oldDataImportTitle
        }

        return cell!
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == SectionIndex.createBackup.rawValue {
            startCreateBackup()
        } else if indexPath.section == SectionIndex.restoreBackup.rawValue {
            startRestoreBackup()
        } else if indexPath.section == SectionIndex.importOldData.rawValue {
            let alert = UIAlertController(
                title: LocalizationConstants.oldDataImportTitle,
                message: LocalizationConstants.oldDataImportStartMessage,
                preferredStyle: .alert)

            let continueAction = UIAlertAction(
                title: LocalizationConstants.continue,
                style: .default,
                handler: { [weak self] (_) in
                    self?.startImportOldData()
            })
            alert.addAction(continueAction)

            let cancelAction = UIAlertAction(
                title: LocalizationConstants.cancel,
                style: .cancel,
                handler: nil)
            alert.addAction(cancelAction)
            present(alert,
                    animated: true,
                    completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == SectionIndex.createBackup.rawValue {
            return LocalizationConstants.createBackupActionDescription
        } else if section == SectionIndex.restoreBackup.rawValue {
            return LocalizationConstants.restoreBackupActionDescription
        } else if section == SectionIndex.importOldData.rawValue {
            return LocalizationConstants.oldDataImportActionDescription
        }
        return ""
    }

    // MARK: - private methods

    private func startImportOldData() {
        let oldAppURLString = "com.aximilate.axtimes://"
        let application = UIApplication.shared
        if application.canOpenURL(URL(string: oldAppURLString)!) {
            application.open(
                URL(string: "\(oldAppURLString)?triggerexport")!,
                options: [:],
                completionHandler: nil
            )
        }
    }

    private func startCreateBackup() {
        dataSharingProcess.createBackup()
    }

    private func startRestoreBackup() {
        // Import an external document. The user selects an external document. The document picker copies the document, leaving the original unchanged.
        let controller = UIDocumentPickerViewController(
            forOpeningContentTypes: [.text],
            asCopy: true)
        controller.delegate = self
        controller.allowsMultipleSelection = false
        let navigationController = UINavigationController(rootViewController: controller)

        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissDocumentPicker))
        controller.navigationItem.leftBarButtonItem = cancelButton

        controller.title = LocalizationConstants.restoreBackupPickertitle
        navigationController.navigationBar.barTintColor = nil
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UIApplication.shared.statusBarStyle = .default
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:ColorPalette.signature], for: .normal)

        present(
            navigationController,
            animated: true,
            completion: nil
        )
    }

    @objc private func dismissDocumentPicker() {
        dismiss(
            animated: true,
            completion: nil)
    }

    fileprivate func restoreBackup(withURL url: URL) {
        dataSharingProcess.restoreBackup(withURL: url)
    }
}

extension DataManagementTableViewController: UIDocumentPickerDelegate {
    @available(iOS 11.0, *)
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        restoreBackup(withURL: url)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        restoreBackup(withURL: url)
    }
}
