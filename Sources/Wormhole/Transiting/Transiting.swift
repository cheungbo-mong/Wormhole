//
// Transiting.swift
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Created by Vance Will (vancewilll@icloud.com).
//

import Foundation

/// This protocol defines the public interface for classes wishing to support the transiting of data
/// between two sides of the wormhole. Transiting is defined as passage between two points, and in this
/// case it involves both the reading and writing of messages as well as the deletion of message
/// contents.
public protocol Transiting: AnyObject {
    /// This method is responsible for writing a given message object in a persisted format for a given identifier. The method should return true if the message was successfully saved. The message object may be nil, in which case true should also be returned. Returning true from this method results in a notification being fired which will trigger the corresponding listener block for the given identifier.
    /// - Parameters:
    ///   - message: The message object to be passed. This object may be nil. In this the method should return true.
    ///   - identifier: The identifier for the message
    /// - Returns: true indicating that a notification should be sent and false otherwise
    func writeMessage<T: Codable>(_ message: T?, for identifier: String, errorHandler: ((Error) -> Void)?) -> Bool

    /// This method is responsible for reading and returning the contents of a given message. It should understand the structure of messages saved by the implementation of the above `writeMessage(_:for)` method and be able to read those messages and return their contents.
    /// - Parameter identifier: The identifier for the message
    func message(for identifier: String, errorHandler: ((Error) -> Void)?) -> CodableBox?

    /// This method should clear the persisted contents of a specific message with a given identifier.
    /// - Parameter identifier: The identifier for the message
    func deleteContent(for identifier: String, errorHandler: ((Error) -> Void)?)

    /// This method should clear the contents of all messages passed to the wormhole.
    func deleteContentForAllMessages(errorHandler: ((Error) -> Void)?)
}

protocol TransitingDelegate: AnyObject {
    func notifyListener(with message: CodableBox?, for identifier: String)
}

/// Wormhols transiting type
///
/// - Important: Test failed on `sessionFile`, please be noted
public enum TransitingType {
    case file
    case coordinatedFile

    /// Communicating between iOS and watchOS by updating application context
    @available(iOS 10.0, watchOS 3.0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    case sessionContext

    /// Communicating between iOS and watchOS by sending messages
    @available(iOS 10.0, watchOS 3.0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    case sessionMessage

    /// Communicating between iOS and watchOS by transferring files
    @available(iOS, unavailable, message: "Test failed for now, please use sessionContext or sessionMessage")
    @available(watchOS, unavailable, message: "Test failed for now, please use sessionContext or sessionMessage")
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    case sessionFile
}
