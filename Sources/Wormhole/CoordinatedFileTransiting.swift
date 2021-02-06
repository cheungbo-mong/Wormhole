// CoordinatedFileTransiting.swift
//  Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//  Created by Vance Will (vancewilll@icloud.com).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import AnyCodable
import Foundation

/// This class inherits from the default implementation of the MMWormholeTransiting protocol and implements message transiting in a similar way but using NSFileCoordinator for its file reading and writing.
public class CoordinatedFileTransiting: FileTransiting {
    /// The default file writing option is `Data.WritingOptions.atomic`. It may be important for your app to use
    /// additional file writing options to control the specific data protection class for message files
    /// being written by your application. When you create your file transiting object, set this property
    /// to the additional writing options you want to use.
    public var additionalDataWritingOptions = Data.WritingOptions.atomic

    override public func writeMessage<T: Codable>(_ message: T?, for identifier: String) -> Bool {
        guard let message = message else {
            // just notification
            return true
        }

        guard
            let data = try? JSONEncoder().encode(AnyCodable(message)),
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

    override public func message(for identifier: String) -> Any? {
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

        let msgContainer = try? JSONDecoder().decode(AnyCodable.self, from: messageData)
        return msgContainer?.value
    }
}
