//
// CodableBox.swift
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Created by Vance Will (vancewilll@icloud.com).
//

import Foundation

/// A type-erased codable box.
///
/// The `CodableBox` type forwards encoding and decoding operations
/// to an underlying codable value, hiding the type of the wrapped value.
///
/// Calling `open(as:)` will try to cast underlying codable value to the target type.
/// To get the underlying codable value, call `open(as:)`.
///
///     let someCodable = CodableBox(10)
///     print(someCodable.open(as: Int.self)!)      // prints "10"
///     print(someCodable.open(as: Double.self))    // prints "nil"
///
///     let encoded = try! JSONEncoder().encode(someCodable)
///     let decoded = try! JSONDecoder().decode(CodableBox.self, from: encoded)
///     print(someCodable.open(as: Int.self)!)      // prints "10"
///     print(someCodable.open(as: Double.self))    // prints "nil"
public struct CodableBox: Codable {
    struct CodingBox<T: Codable>: Codable {
        let value: T
        init(_ value: T) {
            self.value = value
        }
    }

    private let value: Any?
    private let data: Data?
    private var toData: () throws -> Data

    public init<T: Codable>(_ value: T) {
        let box = CodingBox(value)
        toData = {
            try JSONEncoder().encode(box)
        }
        self.value = value
        data = nil
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decodedData = try container.decode(Data.self)
        toData = { decodedData }
        data = decodedData
        value = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data2Encode = try (data ?? toData())
        try container.encode(data2Encode)
    }

    public func open<T: Codable>(as _: T.Type) -> T? {
        if let casted = value as? T {
            return casted
        }

        guard let encoded = data else {
            return nil
        }

        do {
            let box = try JSONDecoder().decode(CodingBox<T>.self, from: encoded)
            return box.value
        } catch {
            return nil
        }
    }
}
