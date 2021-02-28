//
//  WatchSessionHandler.swift
//  Example.watchOS Extension
//
//  Created by Vance Will on 2/28/21.
//

import SwiftUI
import WatchConnectivity

protocol WatchSessionHandler {
    func onScenePhaseChange(_ scenePhase: ScenePhase)
    func onLaunch()
}

class ActualWatchSessionHandler: NSObject, WatchSessionHandler {
    let container: DIContainer
    private let disposeBag = DisposeBag()

    init(container: DIContainer) {
        self.container = container
        super.init()
    }

    func onScenePhaseChange(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            container.interactors.mainInteractor.startListening()
        case .background, .inactive:
            container.interactors.mainInteractor.stopListening()
        @unknown default:
            fatalError("Unhandled case")
        }
    }

    func onLaunch() {
        container.interactors.mainInteractor.startListening()
    }
}
