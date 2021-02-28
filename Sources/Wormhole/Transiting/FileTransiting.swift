//
// FileTransiting.swift
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Created by Vance Will (vancewilll@icloud.com).
//

import Foundation

/// This class is a default implementation of the `Transiting` protocol that implements
/// message transiting by archiving and unarchiving messages that are written and read to files on
/// disk in an optional directory in the given app group. This default implementation has a relatively
/// naive implementation of file writing, and simply uses the built in Data file operations.
///
/// This class is able to be subclassed to provide slightly different file reading and writing behavior
/// while still maintaining the logic for naming a file within the given directory and app group.
class FileTransiting: Transiting {
    /// The File Manager associated with this transiting implementation. You can use this property for
    /// implementing your own variant of file transiting that needs to customize where and how files are
    /// stored.
    let fileManager = FileManager.default

    private let appGroup: String
    private let container: String?

    /// This method must be called with an application group identifier that will
    /// be used to contain passed messages. It is also recommended that you include a directory name for
    /// messages to be read and written, but this parameter is optional.
    /// - Parameters:
    ///   - appGroup: An application group identifier
    ///   - container: An optional container to read/write messages
    init(appGroup: String, container: String? = nil) {
        self.appGroup = appGroup
        self.container = container
    }

    /// This method returns the full file path for the message passing directory, including the optional
    /// container passed in the designated initializer. Subclasses can override this property to provide custom implementations.
    func messagePassingDirectory() throws -> URL {
        guard
            let groupContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
        else {
            throw WormholeError.invalidAppGroup
        }

        let directory: URL = {
            guard let container = container else {
                return groupContainer
            }
            return groupContainer.appendingPathComponent(container, isDirectory: true)
        }()

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        return directory
    }

    func writeMessage<T: Codable>(_ message: T?, for identifier: String, errorHandler: ((Error) -> Void)?) -> Bool {
        guard let message = message else {
            // just notification
            return true
        }

        do {
            let fileDir = try fileDirectory(for: identifier)
            let data = try JSONEncoder().encode(CodableBox(message))
            try data.write(to: fileDir)
            return true
        } catch {
            errorHandler?(error)
            return false
        }
    }

    func message(for identifier: String, errorHandler: ((Error) -> Void)?) -> CodableBox? {
        do {
            let fileDir = try fileDirectory(for: identifier)
            let data = try Data(contentsOf: fileDir)
            let msgContainer = try JSONDecoder().decode(CodableBox.self, from: data)
            return msgContainer
        } catch {
            errorHandler?(error)
            return nil
        }
    }

    func deleteContent(for identifier: String, errorHandler: ((Error) -> Void)?) {
        do {
            let fileDir = try fileDirectory(for: identifier)
            try fileManager.removeItem(at: fileDir)
        } catch {
            errorHandler?(error)
        }
    }

    func deleteContentForAllMessages(errorHandler: ((Error) -> Void)?) {
        do {
            let directory = try messagePassingDirectory()
            try fileManager.contentsOfDirectory(atPath: directory.path)
                .forEach(fileManager.removeItem)
        } catch {
            errorHandler?(error)
        }
    }

    /// This method returns the full file directory for the file associated with the given message identifier.
    /// It includes the optional container passed in the designated initializer if there is one.
    /// Subclasses can use this method to provide custom implementations.
    /// - Parameter identifier: The identifier for the message
    func fileDirectory(for identifier: String) throws -> URL {
        let directory = try messagePassingDirectory()
        guard
            !identifier.isEmpty
        else {
            throw WormholeError.emptyIdentifier
        }
        return directory.appendingPathComponent("\(identifier).archive", isDirectory: false)
    }
}
