//
//  AXAppDelegate+Extension.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 05/08/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension AXAppDelegate {
    @objc func handleRestoreBackup(_ url: URL) {
        DataSharingProcess(viewController: nil).restoreBackup(withURL: url)
    }

    @objc func handleImportOldData(_ url: URL) {
        DataSharingProcess(viewController: nil).importOldData(withURL: url)
    }
}

extension AXAppDelegate: AXInitiateCheckInOnSpecificProjectProtocol {
    public func triggerCheckIn(on project: Project) {
        self.project = project
    }
}
