//
//  SessionFileTransiting.swift
//
//
//  Created by Ethan Mengoreo on 2021/2/3.
//

#if !os(macOS)
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
    class SessionFileTransiting: FileTransiting {
        private let wcSession = WCSession.default

        override init(appGroup: String?, container: String? = nil) {
            super.init(appGroup: appGroup, container: container)
            guard wcSession.delegate != nil else {
                fatalError(
                    "WCSession's delegate is required to be set before you can send messages. Please initialize the MMWormholeSession sharedListeningSession object prior to creating a separate wormhole using the MMWormholeSessionTransiting classes."
                )
            }
        }

        override func writeMessage(_ message: Message?, for identifier: String) -> Bool {
            guard
                WCSession.isSupported(),
                let data = try? JSONEncoder().encode(message)
            else {
                return false
            }
            let tempDir = messagePassingDirectory ?? URL(fileURLWithPath: NSTemporaryDirectory())
            let fileURL = tempDir.appendingPathComponent(identifier, isDirectory: false)

            do {
                try data.write(to: fileURL, options: .atomic)
                wcSession.transferFile(fileURL, metadata: ["identifier": identifier])
                return false
            } catch {
                return false
            }
        }
    }

#endif