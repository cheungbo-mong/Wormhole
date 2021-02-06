//
//  Session.swift
//
//
//  Created by Ethan Mengoreo on 2021/2/3.
//

#if !os(macOS)
    import Foundation
    import WatchConnectivity
import AnyCodable

    public class Session: Wormhole {
        /// This is a specific instance of `Wormhole.Session` that should be used for listening. You
        /// may create your own instances of `Wormhole.Session` for sending messages, but this is the only object that will be able to receive messages.
        ///
        /// The reason for this is that `Wormhole.Session` is based on the `WCSession` class that is part of the `WatchConnectivity` framework provided by Apple, and `WCSession` is itself a singleton with a single delegate.
        /// Therefore, to receive callbacks, only one `Wormhole.Session` object may register itself as a listener.
        public static var shared: Session = {
            let session = Session(appGroup: nil)
            session.wcSession.delegate = session
            return session
        }()

        private let wcSession = WCSession.default

        /// This method should be called after all of your initial listeners have been set and you are ready to begin listening for messages.
        /// There are likely some listeners that your application requires to be active so that it won't miss critical messages.
        /// You should set up these listeners before calling this method so that any already queued messages will be delivered immediately when you activate the session.
        /// Any listeners you set up after calling this method may miss messages that were already queued and waiting to be delivered.
        public func startListening() {
            wcSession.activate()
        }

        // MARK: Public subclass methods

        override public func passMessage<T: Codable>(_: T?, with _: String) {
            fatalError(
                "Message passing is not supported in Wormhole.Session. Please use Wormhole with an Wormhole.SessionTransiting type to pass messages using WatchConnectivity."
            )
        }

        override public func message(with _: String) -> Any? {
            fatalError(
                "Message passing is not supported in Wormhole.Session. Please use Wormhole with an Wormhole.SessionTransiting type to pass messages using WatchConnectivity."
            )
        }

        override public func clearMessage(for _: String) {
            fatalError(
                "Message passing is not supported in Wormhole.Session. Please use Wormhole with an Wormhole.SessionTransiting type to pass messages using WatchConnectivity."
            )
        }

        override public func clearAllMessageContents() {
            fatalError(
                "Message passing is not supported in Wormhole.Session. Please use Wormhole with an Wormhole.SessionTransiting type to pass messages using WatchConnectivity."
            )
        }

        // MARK: Private subclass methods
        override func registerNotification(with _: String) {
            // Wormhole.Session uses WatchConnectivity delegate callbacks and does not support Darwin Notification Center notifications.
        }

        override func unregisterNotification(with _: String) {
            // Wormhole.Session uses WatchConnectivity delegate callbacks and does not support Darwin Notification Center notifications.
        }
    }

    extension Session: WCSessionDelegate {
        public func sessionDidBecomeInactive(_: WCSession) {}

        public func sessionDidDeactivate(_: WCSession) {}

        public func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {}

        public func session(_: WCSession, didReceiveMessage message: [String: Any]) {
            message.forEach { identifier, value in
                guard let data = value as? Data else {
                    notifyListener(with: nil, for: identifier)
                    return
                }
                let msgContainer = try? JSONDecoder().decode(AnyCodable.self, from: data)
                notifyListener(with: msgContainer?.value, for: identifier)
            }
        }

        public func session(_: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
            applicationContext.forEach { identifier, value in
                guard let data = value as? Data else {
                    notifyListener(with: nil, for: identifier)
                    return
                }
                let msgContainer = try? JSONDecoder().decode(AnyCodable.self, from: data)
                notifyListener(with: msgContainer?.value, for: identifier)
            }
        }

        public func session(_: WCSession, didReceive file: WCSessionFile) {
            guard
                let identifier = file.metadata?["identifier"] as? String
            else {
                return
            }
            
            guard let data = try? Data(contentsOf: file.fileURL) else {
                notifyListener(with: nil, for: identifier)
                return
            }
            let msgContainer = try? JSONDecoder().decode(AnyCodable.self, from: data)
            notifyListener(with: msgContainer?.value, for: identifier)
            
            // update file
            guard
                let fileMessenger = messenger as? FileTransiting,
                let directory = fileMessenger.fileDirectory(for: identifier)
            else {
                return
            }
            
            try? data.write(to: directory)
        }
    }
#endif
