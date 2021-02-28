//
//  File.swift
//  
//
//  Created by Ethan Mengoreo on 2/28/21.
//

import Foundation

enum WormholeError: Error {
    case invalidAppGroup
    case emptyIdentifier
    case counterpartUnreachable
    case sessionUnsupported
}
