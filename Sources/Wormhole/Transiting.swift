//
//  Transiting.swift
//
//
//  Created by Ethan Mengoreo on 2021/2/3.
//

import Foundation

/// This protocol defines the public interface for classes wishing to support the transiting of data
/// between two sides of the wormhole. Transiting is defined as passage between two points, and in this
/// case it involves both the reading and writing of messages as well as the deletion of message
/// contents.
public protocol Transiting: class {
    /// This method is responsible for writing a given message object in a persisted format for a given identifier. The method should return true if the message was successfully saved. The message object may be nil, in which case true should also be returned. Returning true from this method results in a notification being fired which will trigger the corresponding listener block for the given identifier.
    /// - Parameters:
    ///   - message: The message object to be passed. This object may be nil. In this the method should return true.
    ///   - identifier: The identifier for the message
    /// - Returns: true indicating that a notification should be sent and false otherwise
    func writeMessage(_ message: Message?, for identifier: String) -> Bool

    /// This method is responsible for reading and returning the contents of a given message. It should understand the structure of messages saved by the implementation of the above `writeMessage(_:for)` method and be able to read those messages and return their contents.
    /// - Parameter identifier: The identifier for the message
    func message(for identifier: String) -> Message?

    /// This method should clear the persisted contents of a specific message with a given identifier.
    /// - Parameter identifier: The identifier for the message
    func deleteContent(for identifier: String)

    /// This method should clear the contents of all messages passed to the wormhole.
    func deleteContentForAllMessages()
}

protocol TransitingDelegate: class {
    func notifyListenerForMessage(_ message: Message, with identifier: String)
}
