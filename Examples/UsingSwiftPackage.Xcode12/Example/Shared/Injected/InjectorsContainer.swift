//
//  InjectorsContainer.swift
//  Example
//
//  Created by Vance Will on 2/28/21.
//

extension DIContainer {
    struct Interactors {
        let mainInteractor: MainInteractor

        init(_ interactor: MainInteractor) {
            mainInteractor = interactor
        }

        static var stubs: Self {
            .init(StubInteractor())
        }
    }
}
