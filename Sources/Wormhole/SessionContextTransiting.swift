//
//  SessionContextTransiting.swift
//
//
//  Created by Ethan Mengoreo on 2021/2/3.
//

#if !os(macOS)
    import Foundation
    import WatchConnectivity

    /// This class provides support for the WatchConnectivity framework's Application Context message
    /// reading and writing ability. This class will pass it's messages directly via the
    /// -updateApplicationContext method, and read message values from application context.
    ///
    /// This class also uses a local mutable dictionary for maintaining a more consistent version of your
    /// wormhole-based application context. The contents of the local dictionary are merged with the
    /// application context for passing messages. Clearing message contents on a wormhole using this
    /// transiting implementation will clear both the applicationContext as well as the local mutable
    /// dictionary.
    ///
    /// This class should be treated as the default `Wormhole.Transiting` implementation for
    /// applications wanting to leverage the WatchConnectivity framework within Wormhole. The application
    /// context provides the best of both real time message passing and baked in state persistence for
    /// setting up your UI.
    class SessionContextTransiting: FileTransiting {
        private let wcSession = WCSession.default
        private var lastContext: [String: Any]?

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

            if lastContext == nil {
                lastContext = wcSession.applicationContext
            }

            guard let last = lastContext else {
                return false
            }
            var currentContext = wcSession.applicationContext
            currentContext.merge(last) { _, new in new }
            currentContext[identifier] = data

            lastContext = currentContext

            try? wcSession.updateApplicationContext(currentContext)
            // always false, no need for notification
            return false
        }

        override func message(for identifier: String) -> Message? {
            guard let data: Data = {
                if
                    let recievedData = wcSession.receivedApplicationContext[identifier] as? Data
                {
                    return recievedData
                } else {
                    return wcSession.applicationContext[identifier] as? Data
                }
            }() else {
                return nil
            }

            return try? JSONDecoder().decode(Message.self, from: data)
        }

        override func deleteContent(for identifier: String) {
            lastContext?.removeValue(forKey: identifier)
            var currentContext = wcSession.applicationContext
            currentContext.removeValue(forKey: identifier)
            try? wcSession.updateApplicationContext(currentContext)
        }

        override func deleteContentForAllMessages() {
            lastContext?.removeAll()
            try? wcSession.updateApplicationContext([:])
        }
    }
#endif
