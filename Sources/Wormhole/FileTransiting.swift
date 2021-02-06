//
//  FileTransiting.swift
//
//
//  Created by Ethan Mengoreo on 2021/2/3.
//

import Foundation
import AnyCodable

/// This class is a default implementation of the `Wormhole.Transiting` protocol that implements
/// message transiting by archiving and unarchiving messages that are written and read to files on
/// disk in an optional directory in the given app group. This default implementation has a relatively
/// naive implementation of file writing, and simply uses the built in Data file operations.
///
/// This class is able to be subclassed to provide slightly different file reading and writing behavior
/// while still maintaining the logic for naming a file within the given directory and app group.
public class FileTransiting: Transiting {
    /// The File Manager associated with this transiting implementation. You can use this property for
    /// implementing your own variant of file transiting that needs to customize where and how files are
    /// stored.
    public let fileManager: FileManager

    private let appGroup: String
    private let container: String?

    /// This method must be called with an application group identifier that will
    /// be used to contain passed messages. It is also recommended that you include a directory name for
    /// messages to be read and written, but this parameter is optional.
    /// - Parameters:
    ///   - appGroup: An application group identifier
    ///   - container: An optional container to read/write messages
    public init(appGroup: String?, container: String? = nil) {
        let fileManager = FileManager.default
        // check app group capabilities
        guard
            fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroup ?? "") != nil
        else {
            fatalError("""
            App Group Capabilities may not be correctly configured for your project, or your appGroupIdentifier may not match your project settings. Check Project->Capabilities->App Groups. Three checkmarks should be displayed in the steps section, and the value passed in for your appGroupIdentifier should match the setting in your project file.
            """)
        }

        self.appGroup = appGroup ?? ""
        self.container = container
        self.fileManager = fileManager
    }

    /// This property is the full file path for the message passing directory, including the optional
    /// container passed in the designated initializer. Subclasses can override this property to provide custom implementations.
    public var messagePassingDirectory: URL? {
        guard
            let groupContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
        else {
            return nil
        }

        let directory: URL = {
            guard let container = container else {
                return groupContainer
            }
            return groupContainer.appendingPathComponent(container, isDirectory: true)
        }()

        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            return directory
        } catch {
            return nil
        }
    }

    public func writeMessage<T: Codable>(_ message: T?, for identifier: String) -> Bool {
        guard let message = message else {
            // just notification
            return true
        }

        guard
            let fileDir = fileDirectory(for: identifier),
            let data = try? JSONEncoder().encode(AnyCodable(message))

        else {
            return false
        }

        do {
            try data.write(to: fileDir)
            return true
        } catch {
            return false
        }
    }

    public func message(for identifier: String) -> Any? {
        guard
            let fileDir = fileDirectory(for: identifier),
            let data = try? Data(contentsOf: fileDir)
        else {
            return nil
        }

        let msgContainer = try? JSONDecoder().decode(AnyCodable.self, from: data)
        return msgContainer?.value
    }

    public func deleteContent(for identifier: String) {
        guard
            let fileDir = fileDirectory(for: identifier)
        else {
            return
        }

        try? fileManager.removeItem(at: fileDir)
    }

    public func deleteContentForAllMessages() {
        guard let directory = messagePassingDirectory else {
            return
        }
        try? fileManager.contentsOfDirectory(atPath: directory.path)
            .forEach(fileManager.removeItem)
    }
    
    
    /// This method returns the full file directory for the file associated with the given message identifier.
    /// It includes the optional container passed in the designated initializer if there is one.
    /// Subclasses can use this method to provide custom implementations.
    /// - Parameter identifier: The identifier for the message
    public func fileDirectory(for identifier: String) -> URL? {
        guard
            let directory = messagePassingDirectory,
            !identifier.isEmpty
        else {
            return nil
        }
        return directory.appendingPathComponent("\(identifier).archive", isDirectory: false)
    }
}
