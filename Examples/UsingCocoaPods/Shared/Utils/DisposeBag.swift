//
//  DisposeBag.swift
//  Example
//
//  Created by Vance Will on 2/28/21.
//

import Combine

final class DisposeBag {
    var cancellables = Set<AnyCancellable>()

    func cancel() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}

extension AnyCancellable {
    func store(in disposeBag: DisposeBag) {
        disposeBag.cancellables.insert(self)
    }
}
