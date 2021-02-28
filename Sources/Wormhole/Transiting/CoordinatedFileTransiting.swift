//
// CoordinatedFileTransiting.swift
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Created by Vance Will (vancewilll@icloud.com).
//

import Foundation

/// This class inherits from the default implementation of the `Transiting` protocol and implements message transiting in a similar way but using NSFileCoordinator for its file reading and writing.
class CoordinatedFileTransiting: FileTransiting {
    /// The default file writing option is `Data.WritingOptions.atomic`. It may be important for your app to use
    /// additional file writing options to control the specific data protection class for message files
    /// being written by your application. When you create your file transiting object, set this property
    /// to the additional writing options you want to use.
    var additionalDataWritingOptions = Data.WritingOptions.atomic

    override public func writeMessage<T: Codable>(_ message: T?, for identifier: String, errorHandler: ((Error) -> Void)?) -> Bool {
        guard let message = message else {
            // just notification
            return true
        }

        do {
            let fileDir = try fileDirectory(for: identifier)
            let data = try JSONEncoder().encode(CodableBox(message))
            let coordinator = NSFileCoordinator()
            var error: NSError?
            var succeeded = false
            coordinator.coordinate(writingItemAt: fileDir, options: .init(rawValue: 0), error: &error) { newURL in
                do {
                    try data.write(
                        to: newURL,
                        options: [.atomic, additionalDataWritingOptions]
                    )
                    succeeded = true
                } catch {
                    succeeded = false
                }
            }

            if let e = error {
                errorHandler?(e)
            }
            return (error == nil) && succeeded
        } catch {
            errorHandler?(error)
            return false
        }
    }

    override func message(for identifier: String, errorHandler: ((Error) -> Void)?) -> CodableBox? {
        do {
            let fileURL = try fileDirectory(for: identifier)
            let coordinator = NSFileCoordinator()
            var outError1: NSError?
            var outError2: NSError?
            var data = Data()
            coordinator.coordinate(readingItemAt: fileURL, options: .init(rawValue: 0), error: &outError1) { newURL in
                do {
                    data = try Data(contentsOf: newURL)
                } catch {
                    outError2 = error as NSError
                }
            }

            if let error = outError1 ?? outError2 {
                errorHandler?(error)
                return nil
            }

            let msgContainer = try JSONDecoder().decode(CodableBox.self, from: data)
            return msgContainer
        } catch {
            errorHandler?(error)
            return nil
        }
    }
}
