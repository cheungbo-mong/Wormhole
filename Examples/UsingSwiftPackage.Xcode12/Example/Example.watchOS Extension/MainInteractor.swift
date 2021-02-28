//
//  MainInteractor.swift
//  Example.watchOS Extension
//
//  Created by Vance Will on 2/28/21.
//

import Combine
import WatchConnectivity
import Wormhole

protocol MainInteractor {
    func startListening()
    func stopListening()
    var segmentFromCompanion: AnyPublisher<String, Never> { get }
    func tapButton(tag: Int)
}

struct ActualMainInteractor: MainInteractor {
    private let titleSubject = PassthroughSubject<String, Never>()
    private let wormhole = Wormhole(
        appGroup: .wormholeAppGroup,
        container: .wormholeContainer,
        transitingType: .sessionContext
    )

    var segmentFromCompanion: AnyPublisher<String, Never> {
        titleSubject.eraseToAnyPublisher()
    }

    func startListening() {
        wormhole.listenForMessage(with: .phoneWatchMsgID) { message in
            guard
                let object = message?.open(as: [String: String].self),
                let selection = object["selectionString"]
            else {
                return
            }
            self.titleSubject.send(selection)
        }
    }

    func stopListening() {
        wormhole.stopListeningForMessage(with: .phoneWatchMsgID)
    }

    func tapButton(tag: Int) {
        wormhole.passMessage(["buttonNumber": "\(tag)"], with: .watchPhoneMsgID)
    }
}

struct StubInteractor: MainInteractor {
    let segmentFromCompanion: AnyPublisher<String, Never> = Just<String>("").eraseToAnyPublisher()
    func tapButton(tag _: Int) {}
    func startListening() {}
    func stopListening() {}
}
