//
// SessionFileTransiting.swift
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Created by Vance Will (vancewilll@icloud.com).
//

import Foundation
import WatchConnectivity

/// This class provides support for the WatchConnectivity framework's file transfer ability. This class
/// will behave very similar to the `Wormhole.FileTransiting` implementation, meaning it will archive
/// messages to disk as files and send them via the WatchConnectivity framework's transferFile API.
///
/// This class should only be used in very specific circumstances. Typically speaking, if
/// you find yourself needing to use the WatchConnectivity framework's file transfer APIs you will best
/// be served by using the WatchConnectivity framework directly and bypassing Wormhole. This class
/// is provided as a basic implementation for simple use cases and isn't intended to be the core of
/// your file based message transfer system.
///
/// - Warning: In order for your Wormhole to support reading the contents of transferred file messages,
/// you will need to set this object as the `messenger` property on the
/// `Wormhole.Session.shared`. The reason for this is that the sharedListeningSession
/// requires a configured application group and optional file directory in order to know where to save
/// received files. If you don't set this object as the `messenger` you will still be notified
/// when your receive files, but you will be responsible for storing the contents yourself and they
/// won't be persisted for you.
///
@available(iOS 10.0, watchOS 3.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
class SessionFileTransiting: FileTransiting {
    private let wcSession = WCSession.default

    var delegate: WCSessionDelegate? {
        get {
            wcSession.delegate
        }

        set {
            wcSession.delegate = newValue
        }
    }

    override func writeMessage<T: Codable>(_ message: T?, for identifier: String, errorHandler: ((Error) -> Void)?) -> Bool {
        guard WCSession.isSupported() else {
            errorHandler?(WormholeError.sessionUnsupported)
            return false
        }

        guard !identifier.isEmpty else {
            errorHandler?(WormholeError.emptyIdentifier)
            return false
        }

        do {
            let data = try JSONEncoder().encode(CodableBox(message))
            let tempDir = (try? messagePassingDirectory()) ?? URL(fileURLWithPath: NSTemporaryDirectory())
            let fileURL = tempDir.appendingPathComponent("\(identifier).archive", isDirectory: false)
            if wcSession.activationState != .activated {
                wcSession.activate()
            }
            try data.write(to: fileURL, options: .atomic)
            wcSession.transferFile(fileURL, metadata: ["identifier": identifier])
        } catch {
            errorHandler?(error)
        }
        return false
    }
}
