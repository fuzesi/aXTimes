//
//  DataSharingProcess.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 08.10.17.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

protocol DataSharingProcessProtocol {
    func createBackup()
    func restoreBackup(withURL url: URL)
    func importOldData(withURL url: URL)
}

class DataSharingProcess: NSObject, DataSharingProcessProtocol {

    fileprivate let viewController: UIViewController

    @objc init(viewController: UIViewController?) {
        if let controller = viewController {
            self.viewController = controller
        } else {
            // TODO check
            self.viewController = UIApplication.topViewController()!
        }
    }

    @objc func createBackup() {
        do {
            let dataSharingController = DataSharingController(settingsManager: SettingsManager())
            let backupFileURL = try dataSharingController.backupFileURL()

            let controller = UIAlertController(
                title: LocalizationConstants.success,
                message: LocalizationConstants.createBackupSuccess,
                preferredStyle: .alert)
            let continueAction = UIAlertAction(
                title: LocalizationConstants.continue,
                style: .default,
                handler: { (_) in
                    let controller = UIActivityViewController(
                        activityItems: [backupFileURL],
                        applicationActivities: nil)
                    self.viewController.present(
                        controller,
                        animated: true,
                        completion: nil)
            })
            controller.addAction(continueAction)

            let cancelAction = UIAlertAction(
                title: LocalizationConstants.cancel,
                style: .cancel,
                handler: nil)
            controller.addAction(cancelAction)

            viewController.present(
                controller,
                animated: true,
                completion: nil)
        } catch let error as BackupCreationError {
            showAlert(
                withPresentingController: viewController,
                title: "\(LocalizationConstants.error) (\(error.rawValue))",
                message: LocalizationConstants.createBackupGenericError)
        } catch let error as NSError {
            showAlert(
                withPresentingController: viewController,
                title: "\(LocalizationConstants.error)",
                message: "\(LocalizationConstants.createBackupGenericError) (\(error.localizedDescription))")
        }
    }

    @objc func restoreBackup(withURL url: URL) {
        let controller = UIAlertController(
            title: LocalizationConstants.restoreBackupTitle,
            message: LocalizationConstants.restoreBackupStartMessage,
            preferredStyle: .alert)
        let continueAction = UIAlertAction(
            title: LocalizationConstants.continue,
            style: .destructive,
            handler: { (_) in
                do {
                    let dataSharingController = DataSharingController(settingsManager: SettingsManager())
                    try dataSharingController
                        .restoreFromBackup(withBackupFileURL: url)
                    self.showAlert(
                        withPresentingController: self.viewController,
                        title: LocalizationConstants.success,
                        message: LocalizationConstants.restoreBackupSuccess)
                    NotificationCenter.default.post(name: .importDataFinished, object: nil)
                } catch let error as BackupRestoreError {
                    self.showAlert(
                        withPresentingController: self.viewController,
                        title: "\(LocalizationConstants.error) (\(error.rawValue))",
                        message: LocalizationConstants.restoreBackupGenericError)
                } catch let error as NSError {
                    self.showAlert(
                        withPresentingController: self.viewController,
                        title: "\(LocalizationConstants.error)",
                        message: "\(LocalizationConstants.restoreBackupGenericError) (\(error.localizedDescription))")
                }
        })
        controller.addAction(continueAction)

        let cancelAction = UIAlertAction(
            title: LocalizationConstants.cancel,
            style: .cancel,
            handler: nil)
        controller.addAction(cancelAction)

        viewController.present(
            controller,
            animated: true,
            completion: nil)
    }

    @objc func importOldData(withURL url: URL) {
        let projectsViewController = AXProjectCheckinSettingsViewController()
        projectsViewController.isOldDataImport = true
        projectsViewController.isShowCancelAndDone = true
        projectsViewController.controllerTitle = LocalizationConstants.oldDataImportProjectSelectionTitle
        projectsViewController.doneButtonTitle = LocalizationConstants.continue
        projectsViewController.selectedProjectBlock = { project in
            do {
                let dataSharingController = DataSharingController(settingsManager: SettingsManager())
                dataSharingController.delegate = self
                try dataSharingController
                    .restoreFromMigrationData(
                        withPasteboardDataURL: url,
                        targetProject: project,
                        completion: { (error) in
                            if let error = error as NSError? {
                                self.showAlert(
                                    withPresentingController: self.viewController,
                                    title: "\(LocalizationConstants.error)",
                                    message: "\(LocalizationConstants.oldDataImportGenericError) (\(error.localizedDescription))")
                            } else {
                                self.showAlert(
                                    withPresentingController: self.viewController,
                                    title: LocalizationConstants.success,
                                    message: LocalizationConstants.oldDataImportSuccess)
                                NotificationCenter.default.post(name: .importDataFinished, object: nil)
                            }
                    })
            } catch MigrationRestoreError.projectDurationMismatch {
                self.showAlert(
                    withPresentingController: self.viewController,
                    title: LocalizationConstants.error,
                    message: LocalizationConstants.oldDataImportProjectDurationMismatch)
            } catch MigrationRestoreError.projectHourlyRateMismatch {
                self.showAlert(
                    withPresentingController: self.viewController,
                    title: LocalizationConstants.error,
                    message: LocalizationConstants.oldDataImportProjectHoulyWageMismatch)
            } catch let error as MigrationRestoreError {
                self.showAlert(
                    withPresentingController: self.viewController,
                    title: "\(LocalizationConstants.error) (\(error.rawValue))",
                    message: LocalizationConstants.oldDataImportGenericError)
            } catch let error as NSError {
                self.showAlert(
                    withPresentingController: self.viewController,
                    title: "\(LocalizationConstants.error)",
                    message: "\(LocalizationConstants.oldDataImportGenericError) (\(error.localizedDescription))")
            }
        }

        let controller = UIAlertController(
            title: LocalizationConstants.oldDataImportProjectSelectionTitle,
            message: LocalizationConstants.oldDataImportProjectQuestion,
            preferredStyle: .alert)
        let continueAction = UIAlertAction(
            title: LocalizationConstants.continue,
            style: .default,
            handler: { (_) in
                let navigationController = UINavigationController(
                    rootViewController: projectsViewController)
                navigationController.modalPresentationStyle = .overCurrentContext
                self.viewController.present(
                    navigationController,
                    animated: true,
                    completion: nil)
        })
        controller.addAction(continueAction)

        let cancelAction = UIAlertAction(
            title: LocalizationConstants.cancel,
            style: .cancel,
            handler: nil)
        controller.addAction(cancelAction)

        viewController.present(
            controller,
            animated: true,
            completion: nil)
    }

    // MARK: - private methods

    private func showAlert(withPresentingController controller: UIViewController,
                           title: String,
                           message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let ok = UIAlertAction(
            title: LocalizationConstants.ok,
            style: .default,
            handler: nil)
        alert.addAction(ok)
        controller.present(
            alert,
            animated: true,
            completion: nil)
    }
}

extension DataSharingProcess: DataSharingControllerDelegate {
    @objc func shouldOverwrite(existingEntriesFromDate date: Date, handler: @escaping ((Bool) -> Void)) {

        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .autoupdatingCurrent
        formatter.formatOptions = [.withFullDate]
        let controller = UIAlertController(
            title: LocalizationConstants.warning,
            message: String(format: LocalizationConstants.oldDataImportOverwriteQuestion, formatter.string(from: date)),
            preferredStyle: .alert)
        let continueAction = UIAlertAction(
            title: LocalizationConstants.continue,
            style: .destructive,
            handler: { (_) in
                handler(true)
        })
        controller.addAction(continueAction)

        let cancelAction = UIAlertAction(
            title: LocalizationConstants.cancel,
            style: .cancel,
            handler: { (_) in
                handler(false)
        })
        controller.addAction(cancelAction)

        viewController.present(
            controller,
            animated: true,
            completion: nil)
    }
}
