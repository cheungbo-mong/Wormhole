//
// Wormhole.swift
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Created by Vance Will (vancewilll@icloud.com).
//

import CoreServices
import Foundation

/// This class creates a wormhole between a containing iOS application and an extension. The wormhole
/// is meant to be used to pass data or commands back and forth between the two locations. The effect
/// closely resembles interprocess communication between the app and the extension, though this is not
/// really the case. The wormhole does have some disadvantages, including the fact that a contract must
/// be determined in advance between the app and the extension that defines the interchange format.
///
/// A good way to think of the wormhole is a collection of shared mailboxes. An identifier is
/// essentially a unique mailbox you can send messages to. You know where a message will be delivered
/// to because of the identifier you associate with it, but not necessarily when the message will be
/// picked up by the recipient. If the app or extension are in the background, they may not receive the
/// message immediately. By convention, sending messages should be done from one side to another, not
/// necessarily from yourself to yourself. It's also a good practice to check the contents of your
/// mailbox when your app or extension wakes up, in case any messages have been left there while you
/// were away.
///
/// Passing a message to the wormhole can be inferred as a data transfer package or as a command. In
/// both cases, the passed message is archived using NSKeyedArchiver to a .archive file named with the
/// included identifier. Once passed, the contents of the written .archive file can be queried using
/// the messageWithIdentifier: method. As a command, the simple existence of the message in the shared
/// app group should be taken as proof of the command's invocation. The contents of the message then
/// become parameters to be evaluated along with the command. Of course, to avoid confusion later, it
/// may be best to clear the contents of the message after recognizing the command. The
/// -clearMessageContentsForIdentifier: method is provided for this purpose.
///
/// A good wormhole includes wormhole aliens who listen for message changes. This class supports
/// CFNotificationCenter Darwin Notifications, which act as a bridge between the containing app and the
/// extension. When a message is passed with an identifier, a notification is fired to the Darwin
/// Notification Center with the given identifier. If you have indicated your interest in the message
/// by using the -listenForMessageWithIdentifier:completion: method then your completion block will be
/// called when this notification is received, and the contents of the message will be unarchived and
/// passed as an object to the completion block.
///
/// It's worth noting that as a best practice to avoid confusing issues or deadlock that messages
/// should be passed one way only for a given identifier. The containing app should pass messages to
/// one set of identifiers, which are only ever read or listened for by the extension, and vice versa.
/// The extension should not then write messages back to the same identifier. Instead, the extension
/// should use it's own set of identifiers to associate with it's messages back to the application.
/// Passing messages to the same identifier from two locations should be done only at your own risk.
@available(iOS 10.0, watchOS 3.0, macOS 10.10, *)
@available(tvOS, unavailable)
public class Wormhole: NSObject, TransitingDelegate {
    var listenerBlocks = [String: (CodableBox?) -> Void]()
    var errorHandlers = [String: (Error) -> Void]()
    /// The wormhole messenger is an object that conforms to the `Wormhole.Transiting` protocol. By default
    /// this object will be set to a default implementation of this protocol which handles archiving and
    /// unarchiving the message to the shared app group in a file named after the identifier of the
    /// message.
    ///
    /// Users of this class may create their own implementation of the `Wormhole.Transiting` protocol to use
    /// for the purpose of defining the means by which messages transit the wormhole. You could use this to
    /// change the way that Wormhole stores messages as files, to read and write messages to a database,
    /// or otherwise be notified in other ways when messages are changed.
    ///
    ///  - Warning: While changing this property is optional, the value of the wormhole messenger **should not be nil** and is required for the class to work.
    ///
    public var messenger: Transiting?

    /// This method must be called with an application group identifier that will be used to contain passed messages. It is also recommended that you include a container name for messages to be read and written, but this parameter is optional. By default Wormhole will use the `Wormhole.TransitingType.file` option when creating a Wormhole, however, this method can be used to easily choose a different transiting class at initialization time. You can always initialize a different class that implements the `Wormhole.Transiting` protocol later and replace the Wormhole's `messenger` property to change the transiting type at a later time.
    /// - Parameters:
    ///   - appGroup: An application group identifier
    ///   - container: An optional directory to read/write messages
    ///   - transitingType: A type of wormhole message transiting that will be used for message passing.
    public init(appGroup: String, container: String? = nil, transitingType: TransitingType = .file) {
        super.init()
        switch transitingType {
        case .file:
            messenger = FileTransiting(appGroup: appGroup, container: container)
        case .coordinatedFile:
            messenger = CoordinatedFileTransiting(appGroup: appGroup, container: container)
        #if !os(macOS)
            case .sessionContext:
                let transiting = SessionContextTransiting()
                transiting.delegate = self
                messenger = transiting
            case .sessionMessage:
                let transiting = SessionMessageTransiting()
                transiting.delegate = self
                messenger = transiting
            case .sessionFile:
                let transiting = SessionFileTransiting(appGroup: appGroup, container: container)
                transiting.delegate = self
                messenger = transiting
        #endif
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveNotification(_:)), name: .wormhole, object: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterRemoveEveryObserver(center, bridge(obj: self))
    }

    // MARK: - Public Interface Methods

    /// This method passes a message object associated with a given identifier. This is the primary means of passing information through the wormhole.
    ///
    /// - Warning: You should avoid situations where you need to pass messages to the same identifier in rapid succession. If a message's contents will be changing rapidly then consider modifying your workflow to write bulk changes without listening on the other side of the wormhole, and then add a listener for a "finished changing" message to let the other side know it's safe to read the contents of your message.
    ///
    /// - Parameters:
    ///   - message: The message object to be passed. This object may be nil. In this case only a notification is posted.
    ///   - identifier: The identifier for the message
    public func passMessage<T: Codable>(_ message: T?, with identifier: String, errorHandler: ((Error) -> Void)? = nil) {
        if messenger?.writeMessage(message, for: identifier, errorHandler: errorHandler) == true {
            sendNotificationForMessage(with: identifier)
        }
    }

    /// This method returns the value of a message with a specific identifier as an object.
    /// - Parameter identifier: The identifier for the message
    public func message(with identifier: String, errorHandler: ((Error) -> Void)? = nil) -> CodableBox? {
        return messenger?.message(for: identifier, errorHandler: errorHandler)
    }

    /// This method clears the contents of a specific message with a given identifier.
    /// - Parameter identifier: The identifier for the message
    public func clearMessage(for identifier: String, errorHandler: ((Error) -> Void)? = nil) {
        messenger?.deleteContent(for: identifier, errorHandler: errorHandler)
    }

    /// This method clears the contents of your optional message directory to give you a clean state.
    ///
    /// - Warning: This method will delete all messages passed to your message directory. Use with care.
    public func clearAllMessageContents(errorHandler: ((Error) -> Void)? = nil) {
        messenger?.deleteContentForAllMessages(errorHandler: errorHandler)
    }

    /// This method begins listening for notifications of changes to a message with a specific identifier.  If notifications are observed then the given listener block will be called along with the actual message object.
    ///
    /// This class only supports one listener per message identifier, so calling this method repeatedly for the same identifier will update the listener block that will be called when a message is heard.
    ///
    /// - Parameters:
    ///   - identifier: The identifier for the message
    ///   - listener: A listener block called with the message parameter when a notification is observed.
    public func listenForMessage(with identifier: String, listener: @escaping (CodableBox?) -> Void, errorHandler: ((Error) -> Void)? = nil) {
        listenerBlocks[identifier] = listener
        if let handler = errorHandler {
            errorHandlers[identifier] = handler
        }
        registerNotification(with: identifier)
    }

    /// This method stops listening for change notifications for a given message identifier.
    ///
    /// This method is **NOT** required to be called. If the wormhole is deallocated then all listeners will go away as well.
    ///
    /// - Parameter identifier: The identifier for the message
    public func stopListeningForMessage(with identifier: String) {
        listenerBlocks.removeValue(forKey: identifier)
        unregisterNotification(with: identifier)
    }

    // MARK: - Private Notification Methods

    internal func sendNotificationForMessage(with identifier: String) {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            .init(identifier as CFString),
            nil, nil, true
        )
    }

    internal func registerNotification(with identifier: String) {
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            bridge(obj: self),
            darwinNotiCallback,
            identifier as CFString,
            nil,
            .deliverImmediately
        )
    }

    internal func unregisterNotification(with identifier: String) {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            bridge(obj: self),
            .init(identifier as CFString),
            nil
        )
    }

    @objc
    internal func didRecieveNotification(_ notification: Notification) {
        guard
            let identifier = notification.userInfo?["identifier"] as? String
        else {
            return
        }
        let handler = errorHandlers[identifier]
        notifyListener(
            with: messenger?.message(for: identifier, errorHandler: handler),
            for: identifier
        )
    }

    internal func notifyListener(with message: CodableBox?, for identifier: String) {
        guard let listenerBlock = listenerBlocks[identifier] else {
            return
        }

        DispatchQueue.main.async {
            listenerBlock(message)
        }
    }
}
