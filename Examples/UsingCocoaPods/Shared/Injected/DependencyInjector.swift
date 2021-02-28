//
//  DependencyInjector.swift
//  Example
//
//  Created by Vance Will on 2/28/21.
//

import Combine
import SwiftUI

struct DIContainer: EnvironmentKey {
    let interactors: Interactors

    init(interactors: Interactors) {
        self.interactors = interactors
    }

    static var defaultValue: Self { Self.default }

    private static let `default` = Self(interactors: .stubs)
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

extension View {
    func inject(_ interactors: DIContainer.Interactors) -> some View {
        let container = DIContainer(interactors: interactors)
        return inject(container)
    }

    func inject(_ container: DIContainer) -> some View {
        return environment(\.injected, container)
    }
}

