//
// Error.swift
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Created by Vance Will (vancewilll@icloud.com).
//

import Foundation

enum WormholeError: Error {
    case invalidAppGroup
    case emptyIdentifier
    case counterpartUnreachable
    case sessionUnsupported
}
