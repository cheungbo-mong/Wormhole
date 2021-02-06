//
//  SessionMessageTransiting.swift
//
//
//  Created by Ethan Mengoreo on 2021/2/3.
//

#if !os(macOS)
import Foundation
import WatchConnectivity
import AnyCodable

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
class SessionMessageTransiting: FileTransiting {
    private let wcSession = WCSession.default

    override init(appGroup: String?, container: String? = nil) {
        super.init(appGroup: appGroup, container: container)
        guard wcSession.delegate != nil else {
            fatalError("WCSession's delegate is required to be set before you can send messages. Please initialize the MMWormholeSession sharedListeningSession object prior to creating a separate wormhole using the MMWormholeSessionTransiting classes.")
        }
    }

    override func writeMessage<T: Codable>(_ message: T?, for identifier: String) -> Bool {
        guard
            wcSession.isReachable,
            let data = try? JSONEncoder().encode(AnyCodable(message))
        else {
            return false
        }

        wcSession.sendMessage([identifier: data], replyHandler: nil)
        return false
    }

    override func message(for identifier: String) -> Any? {
        nil
    }

    override func deleteContent(for identifier: String) {}

    override func deleteContentForAllMessages() {}
}
#endif
