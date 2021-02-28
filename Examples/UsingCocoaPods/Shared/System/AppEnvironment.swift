//
//  AppEnvironment.swift
//  Example
//
//  Created by Vance Will on 2/28/21.
//

import SwiftUI

struct AppEnvironment {
    let container: DIContainer
    #if os(watchOS)
        let handler: WatchSessionHandler
        init(container: DIContainer, handler: WatchSessionHandler) {
            self.container = container
            self.handler = handler
        }

        static func bootstrap() -> AppEnvironment {
            let container = DIContainer(interactors: .init(ActualMainInteractor()))
            let watchHandle = ActualWatchSessionHandler(container: container)
            return .init(container: container, handler: watchHandle)
        }

    #elseif os(iOS)
        let handler: PhoneSessionHandler
        init(container: DIContainer, handler: PhoneSessionHandler) {
            self.container = container
            self.handler = handler
        }

        static func bootstrap() -> AppEnvironment {
            let container = DIContainer(interactors: .init(ActualMainInteractor()))
            let watchHandle = ActualPhoneSessionHandler(container: container)
            return .init(container: container, handler: watchHandle)
        }
    #endif
}
