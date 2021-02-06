//
//  CoordinatedFileTransiting.swift
//
//
//  Created by Ethan Mengoreo on 2021/2/3.
//

import Foundation

/// This class inherits from the default implementation of the MMWormholeTransiting protocol and implements message transiting in a similar way but using NSFileCoordinator for its file reading and writing.
public class CoordinatedFileTransiting: FileTransiting {
    
    /// The default file writing option is `Data.WritingOptions.atomic`. It may be important for your app to use
    /// additional file writing options to control the specific data protection class for message files
    /// being written by your application. When you create your file transiting object, set this property
    /// to the additional writing options you want to use.
    public var additionalDataWritingOptions = Data.WritingOptions.atomic

    public override func writeMessage(_ message: Message?, for identifier: String) -> Bool {
        guard let message = message else {
            // just notification
            return true
        }

        guard
            let data = try? JSONEncoder().encode(message),
            let fileDir = fileDirectory(for: identifier)
        else {
            return false
        }

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

        return (error == nil) && succeeded
    }

    public override func message(for identifier: String) -> Message? {
        guard let fileURL = fileDirectory(for: identifier) else {
            return nil
        }

        let coordinator = NSFileCoordinator()
        var error: NSError?
        var data: Data?
        coordinator.coordinate(readingItemAt: fileURL, options: .init(rawValue: 0), error: &error) { newURL in
            data = try? Data(contentsOf: newURL)
        }

        guard let messageData = data else {
            return nil
        }

        return try? JSONDecoder().decode(Message.self, from: messageData)
    }
}
