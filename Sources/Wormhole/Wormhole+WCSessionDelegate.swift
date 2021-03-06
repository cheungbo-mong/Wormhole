//
// Wormhole+WCSessionDelegate.swift
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Created by Vance Will (vancewilll@icloud.com).
//

import Foundation
import WatchConnectivity

@available(iOS 10.0, watchOS 3.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension Wormhole: WCSessionDelegate {
    public func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {}

    public func sessionReachabilityDidChange(_: WCSession) {}

    public func session(_: WCSession, didReceiveMessage message: [String: Any]) {
        message.forEach { identifier, value in
            guard let data = value as? Data else {
                notifyListener(with: nil, for: identifier)
                return
            }
            let msgContainer = try? JSONDecoder().decode(CodableBox.self, from: data)
            notifyListener(with: msgContainer, for: identifier)
        }
    }

    public func session(_: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        applicationContext.forEach { identifier, value in
            guard let data = value as? Data else {
                notifyListener(with: nil, for: identifier)
                return
            }
            let msgContainer = try? JSONDecoder().decode(CodableBox.self, from: data)
            notifyListener(with: msgContainer, for: identifier)
        }
    }

    public func session(_: WCSession, didReceive file: WCSessionFile) {
        guard
            let identifier = file.metadata?["identifier"] as? String
        else {
            return
        }

        do {
            let data = try Data(contentsOf: file.fileURL)
            let msgContainer = try JSONDecoder().decode(CodableBox.self, from: data)
            notifyListener(with: msgContainer, for: identifier)

            // update file wi
            guard
                let fileMessenger = messenger as? FileTransiting
            else {
                return
            }

            let directory = try fileMessenger.fileDirectory(for: identifier)
            try data.write(to: directory)
        } catch {
            errorHandlers[identifier]?(error)
        }
    }
}

@available(iOS 10.0, *)
@available(watchOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
public extension Wormhole {
    func sessionDidBecomeInactive(_: WCSession) {}
    func sessionDidDeactivate(_: WCSession) {}
}
