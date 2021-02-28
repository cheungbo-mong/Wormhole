//
//  MainInteractor.swift
//  Example
//
//  Created by Vance Will on 2/28/21.
//

import Combine
import WidgetKit
import Wormhole

protocol MainInteractor {
    func startListening()
    func stopListening()
    var buttonFromCompanion: AnyPublisher<String, Never> { get }
    var messageFromWidget: AnyPublisher<String, Never> { get }
    func segmentChange(_ title: String)
}

struct ActualMainInteractor: MainInteractor {
    private let watchButtonValueSubject = PassthroughSubject<String, Never>()
    private let widgetMessageSubject = PassthroughSubject<String, Never>()
    private let traditionalWormhole = Wormhole(
        appGroup: .wormholeAppGroup,
        container: .wormholeContainer
    )
    private let watchConnectivityWormhole = Wormhole(
        appGroup: .wormholeAppGroup,
        container: .wormholeContainer,
        transitingType: .sessionContext
    )

    var buttonFromCompanion: AnyPublisher<String, Never> {
        watchButtonValueSubject
            .map { buttonValue in
                buttonValueChanged(buttonValue)
                return buttonValue
            }
            .eraseToAnyPublisher()
    }

    var messageFromWidget: AnyPublisher<String, Never> {
        widgetMessageSubject.eraseToAnyPublisher()
    }

    func startListening() {
        watchConnectivityWormhole.listenForMessage(with: .watchPhoneMsgID) { message in
            guard
                let object = message?.open(as: [String: String].self),
                let buttonValue = object["buttonNumber"]
            else {
                return
            }

            self.watchButtonValueSubject.send(buttonValue)
        }

        if
            let box = traditionalWormhole.message(with: .widgetPhoneMsgID),
            let message = box.open(as: [String: String].self),
            let area = message["message"]
        {
            widgetMessageSubject.send(area)
        }

        if
            let box = watchConnectivityWormhole.message(with: .watchPhoneMsgID),
            let message = box.open(as: [String: String].self),
            let buttonValue = message["buttonNumber"]
        {
            watchButtonValueSubject.send(buttonValue)
        }
    }

    func stopListening() {
        traditionalWormhole.stopListeningForMessage(with: .widgetPhoneMsgID)
        watchConnectivityWormhole.stopListeningForMessage(with: .watchPhoneMsgID)
    }

    func segmentChange(_ title: String) {
        traditionalWormhole.passMessage(["selectionString": title], with: .phoneWidgetMsgID)
        watchConnectivityWormhole.passMessage(["selectionString": title], with: .phoneWatchMsgID)
        WidgetCenter.shared.reloadTimelines(ofKind: "Example_iOS_Widget")
    }

    private func buttonValueChanged(_ newValue: String) {
        traditionalWormhole.passMessage(["buttonNumber": newValue], with: .watchPhoneWidgetMsgID)
        WidgetCenter.shared.reloadTimelines(ofKind: "Example_iOS_Widget")
    }
}

struct StubInteractor: MainInteractor {
    let buttonFromCompanion: AnyPublisher<String, Never> = Just<String>("").eraseToAnyPublisher()
    var messageFromWidget: AnyPublisher<String, Never> = Just<String>("").eraseToAnyPublisher()
    func segmentChange(_: String) {}
    func startListening() {}
    func stopListening() {}
}
