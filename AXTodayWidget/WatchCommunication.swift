//
//  WatchCommunication.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 18.03.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol WatchCommunicationWatchDelegate: class {
    func latestContext(_ context: [String: Any])
}

@objc protocol WatchCommunicationAppDelegate: class, NSObjectProtocol {
    @objc func didReceiveMessage(_ message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void)
}

@objc protocol WatchCommunicationDelegate: class, NSObjectProtocol {
    func sessionActivated()
}

protocol WatchCommunicationProtocol {
    func updateApplicationContext(_ applicationContext: [String: Any]) throws
    func sendMessage(
        _ message: [String: Any],
        replyHandler: (([String: Any]) -> Void)?,
        errorHandler: ((Error) -> Void)?
    )
    var isActive: Bool { get }
}

@objc final class WatchCommunication: NSObject, WatchCommunicationProtocol, WCSessionDelegate {

    @objc static let shared = WatchCommunication()

    weak var delegate: WatchCommunicationDelegate?
    weak var watchDelegate: WatchCommunicationWatchDelegate?
    @objc weak var appDelegate: WatchCommunicationAppDelegate?

    private let watchSession: WCSession

    var isActive: Bool {
        return watchSession.activationState == .activated
    }

    override init() {
        //makes sure it's not an iPad or iPod
//        guard WCSession.isSupported() else { return nil }
        watchSession = WCSession.default
        super.init()
        watchSession.delegate = self
        watchSession.activate()
    }

    func sendMessage(
        _ message: [String: Any],
        replyHandler: (([String: Any]) -> Void)?,
        errorHandler: ((Error) -> Void)? = nil
    ) {
        watchSession.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }

    @objc func updateApplicationContext(_ applicationContext: [String: Any]) throws {
        #if os(iOS)
            guard watchSession.activationState == .activated,
                watchSession.isPaired,
                watchSession.isWatchAppInstalled
                else {
                    return
            }
        #else
            guard watchSession.activationState == .activated
                else {
                    return
            }
        #endif
        try watchSession.updateApplicationContext(applicationContext)
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("session didReceiveMessage")
        appDelegate?.didReceiveMessage(message, replyHandler: replyHandler)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        print("session didReceiveApplicationContext")
        watchDelegate?.latestContext(applicationContext)
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session activationDidCompleteWith activationState \(activationState)")
        guard activationState == .activated else { return }
        delegate?.sessionActivated()
    }

    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) {
            print("sessionDidBecomeInactive")
        }

        func sessionDidDeactivate(_ session: WCSession) {
            print("sessionDidDeactivate")
            // A different watch may now be paired; activate the session for it.
            session.activate()
        }
    #endif
}
