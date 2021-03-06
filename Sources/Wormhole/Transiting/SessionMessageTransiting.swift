//
// SessionMessageTransiting.swift
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Created by Vance Will (vancewilll@icloud.com).
//

import Foundation
import WatchConnectivity

/// This class provides support for the WatchConnectivity framework's real time message passing ability.
///
/// - Important: This is the only version of the WormholeSessionTransiting system that will be able to wake up
/// your iPhone app in the background. As such, this class has a very specific purpose. It also means
/// that it will most likely be used only by your Apple Watch app, or in very very specific instances
/// by your iPhone app. Typically, your iPhone app will want to use the
/// MMWormholeSessionContextTransiting option instead.
///
/// - Warning: Waking up the iPhone app from a Watch app is an expensive operation. You should only use
/// this transiting implementation when this action is required for your application. Otherwise you are
/// better served by using the `Wormhole.SessionContextTransiting` implementation.
/// This transiting implementation does not support reading message contents because real time
/// messages are delivered once and not persisted.
///
/// This class should be used in cases where your Apple Watch app needs to ensure your
/// iPhone app is running to receive a message and take some action on it. One example of this would be
/// to start background location tracking or audio.
@available(iOS 10.0, watchOS 3.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
class SessionMessageTransiting: Transiting {
    private let wcSession = WCSession.default

    var delegate: WCSessionDelegate? {
        get {
            wcSession.delegate
        }

        set {
            wcSession.delegate = newValue
        }
    }

    func writeMessage<T: Codable>(_ message: T?, for identifier: String, errorHandler: ((Error) -> Void)?) -> Bool {
        if wcSession.activationState != .activated {
            wcSession.activate()
        }

        guard wcSession.isReachable else {
            errorHandler?(WormholeError.counterpartUnreachable)
            return false
        }

        do {
            let data = try JSONEncoder().encode(CodableBox(message))
            wcSession.sendMessage([identifier: data], replyHandler: nil)
        } catch {
            errorHandler?(error)
        }
        return false
    }

    func message(for _: String, errorHandler _: ((Error) -> Void)?) -> CodableBox? { nil }

    func deleteContent(for _: String, errorHandler _: ((Error) -> Void)?) {}

    func deleteContentForAllMessages(errorHandler _: ((Error) -> Void)?) {}
}
