//
// Helpers.swift
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Created by Vance Will (vancewilll@icloud.com).
//

import CoreServices
import Foundation

extension Notification.Name {
    static let wormhole = Notification.Name("wormhole.Z3SdZWgvUO5T8rYmnW8d")
}

func bridge<T: AnyObject>(obj: T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

let darwinNotiCallback: @convention(c) (
    _ center: CFNotificationCenter?,
    _ observer: UnsafeMutableRawPointer?,
    _ name: CFNotificationName?,
    _ object: UnsafeRawPointer?,
    _ userInfo: CFDictionary?
) -> Void = { _, _, name, _, _ in
    guard let identifier = name?.rawValue as String? else {
        return
    }
    NotificationCenter.default.post(name: .wormhole, object: nil, userInfo: ["identifier": identifier])
}
