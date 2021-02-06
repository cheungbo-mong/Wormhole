// SessionContextTransiting.swift
//  Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//  Created by Vance Will (vancewilll@icloud.com).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if !os(macOS)
    import AnyCodable
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

        override func writeMessage<T: Codable>(_ message: T?, for identifier: String) -> Bool {
            guard
                WCSession.isSupported(),
                let data = try? JSONEncoder().encode(AnyCodable(message))
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

        override func message(for identifier: String) -> Any? {
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
            let msgContainer = try? JSONDecoder().decode(AnyCodable.self, from: data)
            return msgContainer?.value
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
