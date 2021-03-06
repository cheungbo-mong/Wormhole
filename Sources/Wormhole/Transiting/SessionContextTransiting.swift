//
// SessionContextTransiting.swift
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Created by Vance Will (vancewilll@icloud.com).
//

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
@available(iOS 10.0, watchOS 3.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
class SessionContextTransiting: Transiting {
    private let wcSession = WCSession.default
    private var lastContext: [String: Any]?

    var delegate: WCSessionDelegate? {
        get {
            wcSession.delegate
        }

        set {
            wcSession.delegate = newValue
        }
    }

    func writeMessage<T: Codable>(_ message: T?, for identifier: String, errorHandler: ((Error) -> Void)?) -> Bool {
        guard
            WCSession.isSupported()
        else {
            errorHandler?(WormholeError.sessionUnsupported)
            return false
        }

        do {
            let data = try JSONEncoder().encode(CodableBox(message))

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

            if wcSession.activationState != .activated {
                wcSession.activate()
            }

            try wcSession.updateApplicationContext(currentContext)
        } catch {
            errorHandler?(error)
            return false
        }

        // always false, no need for notification
        return false
    }

    func message(for identifier: String, errorHandler: ((Error) -> Void)?) -> CodableBox? {
        let data: Data = {
            if
                let recievedData = wcSession.receivedApplicationContext[identifier] as? Data
            {
                return recievedData
            } else {
                let recent = wcSession.applicationContext[identifier] as? Data
                return recent ?? Data()
            }
        }()
        do {
            return try JSONDecoder().decode(CodableBox.self, from: data)
        } catch {
            errorHandler?(error)
            return nil
        }
    }

    func deleteContent(for identifier: String, errorHandler: ((Error) -> Void)?) {
        lastContext?.removeValue(forKey: identifier)
        var currentContext = wcSession.applicationContext
        currentContext.removeValue(forKey: identifier)
        do {
            try wcSession.updateApplicationContext(currentContext)
        } catch {
            errorHandler?(error)
        }
    }

    func deleteContentForAllMessages(errorHandler: ((Error) -> Void)?) {
        lastContext?.removeAll()
        do {
            try wcSession.updateApplicationContext([:])
        } catch {
            errorHandler?(error)
        }
    }
}
